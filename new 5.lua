This is a lua script for a Filter Forge map script for generating flow maps from height maps. 

-- flow map base
function prepare()
	-- get inputs and set up
	height_scale = get_slider_input(SCALE)
	-- most textures are 1:1. if another aspect ratio is used, the shorter axis will be [0, 1] and the other will exceed 1.
	-- to preserve pixel aspect ratio, use the min axis.
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

-- compute derivative of a sample with respect to x or y
function get_derivative(x, y, height_scale, sample_type, axis)
	local delta = offset -- 1 / sample_type
	local x1, y1, x2, y2
	if axis == "x" then
		x1 = x - delta
		y1 = y
		x2 = x + delta
		y2 = y
	elseif axis == "y" then
		x1 = x
		y1 = y - delta
		x2 = x
		y2 = y + delta
	end
	local sample1, sample2
	if sample_type == HEIGHT then
		sample1 = get_sample_grayscale(x1, y1, sample_type) * height_scale
		sample2 = get_sample_grayscale(x2, y2, sample_type) * height_scale
	elseif sample_type == NORMAL then
		sample1 = get_sample_map(x1, y1, sample_type)
		sample2 = get_sample_map(x2, y2, sample_type)
	end

	return (sample2 - sample1) / (2 * delta)
end

-- compute sample data for a given pixel coordinate
function get_sample(x, y)
	-- get height and normal data
	local height = get_sample_grayscale(x, y, HEIGHT) * height_scale
	local normal_x, normal_y, normal_z = get_sample_map(x, y, NORMAL)

	-- compute surface gradient and normalize
	local dndx = get_derivative(x, y, height_scale, HEIGHT, "x")
	local dndy = get_derivative(x, y, height_scale, HEIGHT, "y")
	local gradient_x = dndx * normal_x -- * height_scale
	local gradient_y = dndy * normal_y -- * height_scale
	local gradient_z = height_scale ~= 0 and 2.0 / height_scale or 1.0

	-- compute dot product of normal and gradient to determine slope direction
	local dot_product = normal_x * gradient_x + normal_y * gradient_y + normal_z * gradient_z
	local alpha = math.atan(dot_product) / (math.pi / 2) -- dot_product > 0.0 and 1.0 or 0.0

	-- encode gradient as RGB and slope direction as alpha
	local r = (gradient_x + 1.0) / 2.0
	local g = (gradient_y + 1.0) / 2.0
	local b = (gradient_z + 1.0) / 2.0
	return r, g, b, alpha
end

-- flow map for offset
function prepare()
	-- get inputs and set up
	-- height_scale; adjust this value to adjust the scale of the surface gradient
	height_scale = get_slider_input(SCALE)
	-- most textures are 1:1. if another aspect ratio is used, the shorter axis will be [0, 1] and the other will exceed 1.
	-- to preserve pixel aspect ratio, use the min axis.
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

-- compute derivative of a sample with respect to x or y
function get_derivative(x, y, height_scale, sample_type, axis)
	local delta = offset -- 1 / sample_type
	local x1, y1, x2, y2
	if axis == "x" then
		x1 = x - delta
		y1 = y
		x2 = x + delta
		y2 = y
	elseif axis == "y" then
		x1 = x
		y1 = y - delta
		x2 = x
		y2 = y + delta
	end
	local sample1, sample2
	if sample_type == HEIGHT then
		sample1 = get_sample_grayscale(x1, y1, sample_type) * height_scale
		sample2 = get_sample_grayscale(x2, y2, sample_type) * height_scale
	elseif sample_type == NORMAL then
		sample1 = get_sample_map(x1, y1, sample_type)
		sample2 = get_sample_map(x2, y2, sample_type)
	end

	return (sample2 - sample1) / (2 * delta)
end

-- compute sample data for a given pixel coordinate
function get_sample(x, y)
	-- get height and normal data
	local height = get_sample_grayscale(x, y, HEIGHT) * height_scale
	local normal_x, normal_y, normal_z = get_sample_map(x, y, NORMAL)

	-- compute surface gradient and normalize
	local dndx = get_derivative(x, y, height_scale, HEIGHT, "x")
	local dndy = get_derivative(x, y, height_scale, HEIGHT, "y")
	local gradient_x = dndx * normal_x -- * height_scale
	local gradient_y = dndy * normal_y -- * height_scale
	local gradient_z = height_scale ~= 0 and 2.0 / height_scale or 1.0

	-- compute dot product of normal and gradient to determine slope direction
	local dot_product = normal_x * gradient_x + normal_y * gradient_y + normal_z * gradient_z
	local alpha = math.atan(dot_product) / (math.pi / 2) -- dot_product > 0.0 and 1.0 or 0.0

	-- encode gradient as RGB and slope direction as alpha
	local r = (gradient_x + 1.0) - 1
	local g = (gradient_y + 1.0) - 1
	local b = (gradient_z + 1.0) - 1
	return r, g, b, alpha
end

-- flow map for lookup
function prepare()
	-- get inputs and set up
	-- height_scale; adjust this value to adjust the scale of the surface gradient
	height_scale = get_slider_input(SCALE)
	-- most textures are 1:1. if another aspect ratio is used, the shorter axis will be [0, 1] and the other will exceed 1.
	-- to preserve pixel aspect ratio, use the min axis.
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

-- compute derivative of a sample with respect to x or y
function get_derivative(x, y, height_scale, sample_type, axis)
	local delta = offset -- 1 / sample_type
	local x1, y1, x2, y2
	if axis == "x" then
		x1 = x - delta
		y1 = y
		x2 = x + delta
		y2 = y
	elseif axis == "y" then
		x1 = x
		y1 = y - delta
		x2 = x
		y2 = y + delta
	end
	local sample1, sample2
	if sample_type == HEIGHT then
		sample1 = get_sample_grayscale(x1, y1, sample_type) * height_scale
		sample2 = get_sample_grayscale(x2, y2, sample_type) * height_scale
	elseif sample_type == NORMAL then
		sample1 = get_sample_map(x1, y1, sample_type)
		sample2 = get_sample_map(x2, y2, sample_type)
	end

	return (sample2 - sample1) / (2 * delta)
end

-- compute sample data for a given pixel coordinate
function get_sample(x, y)
	-- get height and normal data
	local height = get_sample_grayscale(x, y, HEIGHT) * height_scale
	local normal_x, normal_y, normal_z = get_sample_map(x, y, NORMAL)

	-- compute surface gradient and normalize
	local dndx = get_derivative(x, y, height_scale, HEIGHT, "x")
	local dndy = get_derivative(x, y, height_scale, HEIGHT, "y")
	local gradient_x = dndx * normal_x -- * height_scale
	local gradient_y = dndy * normal_y -- * height_scale
	local gradient_z = height_scale ~= 0 and 2.0 / height_scale or 1.0

	local gradient_length = math.sqrt(gradient_x^2 + gradient_y^2 + gradient_z^2)
	gradient_x = gradient_x / gradient_length
	gradient_y = gradient_y / gradient_length
	gradient_z = gradient_z / gradient_length

	-- compute dot product of normal and gradient to determine slope direction
	local dot_product = normal_x * gradient_x + normal_y * gradient_y + normal_z * gradient_z
	local alpha = math.atan(dot_product) / (math.pi / 2) -- dot_product > 0.0 and 1.0 or 0.0

	-- encode gradient as RGB and slope direction as alpha
	local r = x - ((gradient_x + 1.0) - 1)
	local g = y - ((gradient_y + 1.0) - 1)
	local b = (gradient_z + 1.0) / 2
	return r, g, b, alpha
end

-- normal
function prepare()
	-- get inputs and set up
	height_scale = get_slider_input(SCALE)
	-- most textures are 1:1. if another aspect ratio is used, the shorter axis will be [0, 1] and the other will exceed 1.
	-- to preserve pixel aspect ratio, use the min axis.
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

function get_sample(x, y)
	-- get height and surface gradient
	local height = get_sample_grayscale(x, y, HEIGHT) * height_scale
	local gradient_x = (get_sample_grayscale(x + offset, y, HEIGHT) - get_sample_grayscale(x - offset, y, HEIGHT)) / (2 * offset)
	local gradient_y = (get_sample_grayscale(x, y + offset, HEIGHT) - get_sample_grayscale(x, y - offset, HEIGHT)) / (2 * offset)
	local gradient_z = 1 / math.sqrt(1 + gradient_x^2 + gradient_y^2)

	-- compute normal vector
	local nx = gradient_x * gradient_z
	local ny = gradient_y * gradient_z
	local nz = 1 - gradient_z

	-- encode normal vector as RGB
	local r = (nx + 1.0) / 2.0
	local g = (ny + 1.0) / 2.0
	local b = ((nz + 1.0) / 2.0) * 0.5 + 0.5
	local alpha = 1.0
	return r, g, b, alpha
end

-- sobel filtering for surface normals
function prepare()
    -- get inputs and set up
    height_scale = get_slider_input(SCALE)
    -- most textures are 1:1. if another aspect ratio is used, the shorter axis will be [0, 1] and the other will exceed 1.
    -- to preserve pixel aspect ratio, use the min axis.
    offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

function get_sample(x, y)
    -- get height and surface gradient
    local height = get_sample_grayscale(x, y, HEIGHT) * height_scale
    
    -- sobel kernel
    local kernel_x = {
        {-1, 0, 1},
        {-2, 0, 2},
        {-1, 0, 1}
    }
    
    local kernel_y = {
        {-1, -2, -1},
        {0, 0, 0},
        {1, 2, 1}
    }

    -- compute gradients
    local gx = 0
    local gy = 0

    for ky = -1, 1 do
        for kx = -1, 1 do
            local weight = 1
            if ky == 0 and kx == 0 then
                weight = 2
            end
            
            local height_sample = get_sample_grayscale(x + kx * offset, y + ky * offset, HEIGHT)
            local gradient_x = kernel_x[ky+2][kx+2] * height_sample
            local gradient_y = kernel_y[ky+2][kx+2] * height_sample
            
            gx = gx + gradient_x * weight
            gy = gy + gradient_y * weight
        end
    end

    local gradient_z = 1 / math.sqrt(1 + gx^2 + gy^2)

    -- compute normal vector
    local nx = gx * gradient_z
    local ny = gy * gradient_z
    local nz = 1 - gradient_z

    -- encode normal vector as RGB
    local r = (nx + 1.0) / 2.0
    local g = (ny + 1.0) / 2.0
    local b = ((nz + 1.0) / 2.0) * 0.5 + 0.5
    local alpha = 1.0
    
    return r, g, b, alpha
end

