function prepare()
	points = get_intslider_input(POINTS)
	-- math.randomseed(get_intslider_input(SEED))
	set_noise_seed(get_intslider_input(SEED))
	mode = get_intslider_input(MODE)
	-- maxrad = get_slider_input(MAX_RADIUS) / 2 + 0.05
	-- minrad = get_slider_input(MIN_RADIUS) / 20 + 0.005
	scale = get_slider_input(SCALE) / 2 + 0.5
	circles = {}
	count = 0

	if OUTPUT_WIDTH > OUTPUT_HEIGHT then
		sizex = OUTPUT_WIDTH / OUTPUT_HEIGHT
		sizey = 1
	else
		sizex = 1
		sizey = OUTPUT_HEIGHT / OUTPUT_WIDTH
	end
	
	function distance (x1, y1, x2, y2)
		dist = math.sqrt((x1-x2)^2+(y1-y2)^2)
		return dist
	end
end

function get_sample(x, y)
	-- works as slider but not as map input
	maxrad = get_sample_grayscale(x, y, MAX_RADIUS) / 2 + 0.05
	minrad = get_sample_grayscale(x, y, MIN_RADIUS) / 20 + 0.005
	z = get_sample_grayscale(x, y, Z_INDEX)

	for i=1, points do
		-- circle = { x = math.random()*sizex, y = math.random()*sizey, r = minrad, closest = maxrad, col = math.random(1,5)/5 }
		circle = { x = get_noise(x + 0.25, y + 0.5, z + 0.75)*sizex, y = get_noise(x + 0.75, y + 0.25, z + 0.5)*sizey, r = minrad, closest = maxrad, col = get_noise(x + 1, y + 1, z + 1)}
		overlapping = false
		for j=1, count do
			other = circles[j]
			-- at these two lines, throws error: [[string "function prepare(); The script did not respond in a timely manner and has been auto-terminated.
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