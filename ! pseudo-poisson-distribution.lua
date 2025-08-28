Definately a memory use problem. One grid constraint used for poisson sampling used cells derived from the radius ('r = √ n') constrained to the 5 x 5 grid around the current point. Do we have that already (or something close to it)?
```
function prepare()
	points = get_intslider_input(POINTS)
	math.randomseed(get_intslider_input(SEED))
	mode = get_intslider_input(MODE)
	maxrad = get_slider_input(MAX_RADIUS) / 2 + 0.05
	minrad = get_slider_input(MIN_RADIUS) / 20 + 0.005
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
```