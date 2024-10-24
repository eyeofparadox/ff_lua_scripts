function prepare()
	-- title = ff_api_emme_circle_packing_ip.lua
	-- v.003.01
	-- dtype = get_intslider_input(DISTANCE_TYPE)
	-- p = get_intslider_input(P)

	-- input values
	points = get_intslider_input(POINTS)
	math.randomseed(get_intslider_input(SEED))
	mode = get_intslider_input(MODE)
	maxrad = get_slider_input(MAX_RADIUS) / 2 + 0.05
	minrad = get_slider_input(MIN_RADIUS) / 20 + 0.005
	scale = get_slider_input(SCALE) / 2 + 0.5
	circles = {}
	count = 0
	
	-- image aspect ratio
	if OUTPUT_WIDTH > OUTPUT_HEIGHT then
		sizex = OUTPUT_WIDTH / OUTPUT_HEIGHT
		sizey = 1
	else
		sizex = 1
		sizey = OUTPUT_HEIGHT / OUTPUT_WIDTH
	end
	
	-- distance mapping 
	--[[
	function dist_metric(x1,y1,z1,x2,y2,z2)
		local dist = 0
		if dtype == 1 then
			-- Euclidean 
			dist = math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)	
		elseif dtype == 2 then
			-- Chebyshev
			dist = math.max(math.abs(x1 - x2), math.abs(y1 - y2), math.abs(z1 - z2))	
		elseif dtype == 3 then
			-- Manhattan
			dist = (math.abs(x1 - x2) + math.abs(y1 - y2) + math.abs(z1 - z2)) / 1.5	
		elseif dtype == 4 then
			-- Minkowski 
			local pe = 1/p
			dist = (math.abs(x1 - x2)^p + math.abs(y1 - y2)^p + math.abs(z1 - z2)^p)^pe
		else
			-- Quadratic
			dist = ((x1 - px)^2 + (y1 - py)^2 + (z1 - pz)^2) / (1 + (x1 - px)^2 + (y1 - py)^2 + (z1 - pz)^2)
		end	
		return dist
	end;
	-- ]]
	-- default Euclidean  distance mapping 
	function distance (x1, y1, x2, y2)
		dist = math.sqrt((x1-x2)^2+(y1-y2)^2)
		return dist
	end

	-- array population
	for i=1, points do
		circle = { x = math.random()*sizex, y = math.random()*sizey, r = minrad, closest = maxrad, col = math.random(1,5)/5 }
		overlapping = false
		for j=1, count do
			other = circles[j]
			d = distance(circle.x, circle.y, other.x, other.y)
			if d < (circle.r + other.r) then
				overlapping = true
				break
			end
			if d - other.r < circle.closest then
				circle.closest = d - other.r 
			end
		end

		if overlapping == false then
			circle.r = circle.closest
			if circle.x - circle.r < 0 then
				circle.r = circle.r - 1-(circle.x - circle.r)
			elseif circle.x + circle.r > 1 then
				circle.r = circle.r - 1-(circle.x - circle.r)
			elseif circle.y - circle.r < 0 then
				circle.r = circle.r - 1-(circle.y - circle.r)
			elseif circle.y + circle.r > 1 then
				circle.r = circle.r - 1-(circle.y - circle.r)
			end
			table.insert(circles, circle)
			count = count + 1
		end
	end
end

function get_sample(x, y)
	v = 0
	vx = 0
	vy = 0
	aa_zone = 0

	for i=1, count do
		dist = distance(x, y, circles[i].x, circles[i].y)
		if dist < circles[i].r then
			if mode == 1 then
				v = circles[i].r / maxrad
			elseif mode == 2 then
				v = circles[i].col
			elseif mode == 3 then
				v = 1 - distance(x,y,circles[i].x, circles[i].y) / circles[i].r / scale
			elseif mode == 4 then
				vx = circles[i].x / sizex
				vy = circles[i].y / sizey
			elseif mode == 5 then
				vx = (x - circles[i].x) / circles[i].r / scale / 2 + 0.5
				vy = (y - circles[i].y) / circles[i].r / scale / 2 + 0.5
			end
			
			if dist > circles[i].r * scale then
				v = 0
				vx = 0
				vy = 0
			end
			-- fix aa zones to match scaling and each mode
			aa_zone = combine_aa_zones(aa_zone, 1)
			break
		end
	end
	if mode == 4 or mode == 5 then
		return vx, vy, 0, 1, aa_zone
	else
		return v, v, v, 1, aa_zone
	end
end