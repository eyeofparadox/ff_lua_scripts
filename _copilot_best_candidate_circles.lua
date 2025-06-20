-- Mitchell's approximate Poisson-disc sampling: https://observablehq.com/@mbostock/best-candidate-circles

-- Global variables
circles = {}
width = OUTPUT_WIDTH
height = OUTPUT_HEIGHT
sizex = 1
sizey = 1

function prepare()
    -- Parameters
    local maxRadius = 0.05   -- Maximum radius of circles (adjust as needed)
    local padding = 0.005    -- Padding between circles; acts as minimum radius
    local n = 250            -- Total number of circles to generate
    local k_start = 1        -- Initial number of candidates
    local k_max = 500        -- Maximum number of candidates
    local k_increment = 1.01 -- Increment factor for k
    local m_start = 10       -- Initial number of circles per frame
    local m_decrement = 0.998-- Decrement factor for m
    k = k_start
    m = m_start

    -- Initialize quadtree
    quadtree = quadtree_new(0, 0, sizex, sizey)

    -- Generate circles
    while n > 0 do
        local circlesThisFrame = math.floor(m)
        for j = 1, circlesThisFrame do
            if n <= 0 then break end
            local circle = best_circle(quadtree, math.floor(k), maxRadius, padding)
            if circle then
                table.insert(circles, circle)
                quadtree_insert(quadtree, circle)
            end
            n = n - 1
        end
        -- Update k and m
        if k < k_max then
            k = k * k_increment
            m = m * m_decrement
        end
    end
end

function best_circle(quadtree, k, maxRadius, padding)
    local bestX, bestY, bestDistance = 0, 0, 0

    for i = 1, k do
        local x = math.random() * sizex
        local y = math.random() * sizey
        local minDistance = maxRadius

        -- Search for the minimum distance to existing circles
        quadtree_search(quadtree, x, y, maxRadius * 2, function(p)
            local dx = x - p.x
            local dy = y - p.y
            local d = math.sqrt(dx * dx + dy * dy) - p.r
            minDistance = math.min(minDistance, d)
            return false -- Continue searching
        end)

        if minDistance > bestDistance then
            bestX = x
            bestY = y
            bestDistance = minDistance
        end
    end

    if bestDistance > padding then
        return { x = bestX, y = bestY, r = bestDistance - padding }
    else
        return nil
    end
end

-- Quadtree implementation adjusted for handling overlapping circles
function quadtree_new(x, y, w, h)
    return { x = x, y = y, w = w, h = h, points = {}, children = nil }
end

function quadtree_insert(node, circle)
    if not quadtree_intersects_circle(node, circle) then
        return false
    end

    if #node.points < 4 and not node.children then
        table.insert(node.points, circle)
        return true
    else
        if not node.children then
            quadtree_subdivide(node)
        end
        local inserted = false
        for i = 1, 4 do
            if quadtree_insert(node.children[i], circle) then
                inserted = true
            end
        end
        return inserted
    end
end

function quadtree_intersects_circle(node, circle)
    -- Circle's bounding box
    local x1 = circle.x - circle.r
    local y1 = circle.y - circle.r
    local x2 = circle.x + circle.r
    local y2 = circle.y + circle.r

    -- Node's bounding box
    local nx1 = node.x
    local ny1 = node.y
    local nx2 = node.x + node.w
    local ny2 = node.y + node.h

    -- Check for intersection
    return not (nx1 > x2 or nx2 < x1 or ny1 > y2 or ny2 < y1)
end

function quadtree_subdivide(node)
    local x, y, w, h = node.x, node.y, node.w / 2, node.h / 2
    node.children = {
        quadtree_new(x, y, w, h),           -- Top-left
        quadtree_new(x + w, y, w, h),       -- Top-right
        quadtree_new(x, y + h, w, h),       -- Bottom-left
        quadtree_new(x + w, y + h, w, h)    -- Bottom-right
    }
    -- Re-insert existing points into children
    for _, circle in ipairs(node.points) do
        quadtree_insert(node, circle)
    end
    node.points = {}
end

function quadtree_search(node, x, y, radius, callback)
    if not quadtree_intersects(node, x - radius, y - radius, radius * 2, radius * 2) then
        return
    end
    for _, p in ipairs(node.points) do
        callback(p)
        -- Continue searching; we need to consider all circles
    end
    if node.children then
        for i = 1, 4 do
            quadtree_search(node.children[i], x, y, radius, callback)
        end
    end
end

function quadtree_intersects(node, x, y, w, h)
    return not (node.x > x + w or node.x + node.w < x or node.y > y + h or node.y + node.h < y)
end

function get_sample(x, y)
    local x_pos = x * sizex
    local y_pos = y * sizey
    local v = 0
    local max_v = 0

    -- Search for circles containing this point
    quadtree_search_point(quadtree, x_pos, y_pos, function(circle)
        local dx = x_pos - circle.x
        local dy = y_pos - circle.y
        if dx * dx + dy * dy <= circle.r * circle.r then
            -- Compute the value based on circle properties
            local circle_value = circle.r / 0.05 -- Normalize radius for intensity
            if circle_value > max_v then
                max_v = circle_value
            end
        end
        return false -- Continue searching
    end)

    if max_v > 0 then
        return max_v, max_v, max_v, 1
    else
        return 0, 0, 0, 1
    end
end

function quadtree_search_point(node, x, y, callback)
    if not quadtree_contains_point(node, x, y) then
        return
    end
    for _, circle in ipairs(node.points) do
        if callback(circle) then
            -- Continue searching; other circles may also contain the point
        end
    end
    if node.children then
        for i = 1, 4 do
            quadtree_search_point(node.children[i], x, y, callback)
        end
    end
end

function quadtree_contains_point(node, x, y)
    return x >= node.x and x <= node.x + node.w and y >= node.y and y <= node.y + node.h
end
