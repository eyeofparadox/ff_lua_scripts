function prepare()
	mode = get_checkbox_input(MODE)
	-- p = get_slider_input(PERCENTAGE)
end;

function get_sample(x, y)
	rd, gd, bd, ad = get_sample_map(x, y, DISTORTER)
	p = get_sample_grayscale(x, y, PERCENTAGE)
	if mode then rd, gd, bd = rd * 2 + 1, gd * 2 + 1, bd * 2 + 1 end  
	dx = x + ((rd + bd/2) * ad * p)
	dy = y + ((gd + bd/2) * ad * p)

	r, g, b, a = get_sample_map(dx, dy, SOURCE)
	return r, g, b, a
end;


function prepare()
	-- prepare
	dis = get_slider_input(DISTANCE)
	dir = math.rad(get_angle_input(DIRECTION))
	nx = math.cos(dir)
	ny = math.cos(dir)
end;

function get_sample(x, y)
	-- then
	dx = x + nx * dis
	dy = y + ny * dis
	-- get source 
	local v = get_sample_grayscale(dx,dy,SOURCE)
	return v
end;


function prepare()
	-- prepare
	ox, oy = get_slider_input(ORIGIN_X), get_slider_input(ORIGIN_Y)
	dis = 5 -- get_slider_input(DISTANCE)
	dir = math.rad(get_angle_input(DIRECTION))
	nx = math.sin(dir)
	ny = math.cos(dir)
end;

function get_sample(x, y)
	-- variation on
	-- nx = c * (x-ox) - s * (y-oy) + ox
	-- ny = s * (x-ox) + c * (y-oy) + oy

	-- get source
	x = x + nx * dis
	y = y + ny * dis
	v = get_sample_grayscale(x,y,SOURCE)
	return v,v,v
end;



	local s = 500
	local osx, osy,  osz, osa = get_sample_map(x, y, OFFSET)
	local x = x * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) + (osx * osa)
	local ny = math.sin(x) * math.sin(y) + (osy * osa)
	local nz = math.cos(y) + (osz * osa)
	local d1 = get_perlin_noise(nx+1,ny,nz,s)
	local d2 = get_perlin_noise(nx+2,ny,nz,s)
	local d3 = get_perlin_noise(nx+3,ny,nz,s)
	v = get_perlin_noise(nx+d1,ny+d2,nz+d3,s)
	return v


-- Written by Nathan "jitspoe" Wulf
-- 2011-09-06

function prepare()
	pitch = math.rad(get_angle_input(PITCH))
	yaw = math.rad(get_angle_input(YAW))
	lightX2D = math.cos(yaw)
	lightY2D = math.sin(yaw)
	lightX = math.cos(pitch) * lightX2D
	lightY = math.cos(pitch) * lightY2D
	lightZ = math.sin(pitch)
	stepDist = get_slider_input(SHADOW_STEP_DIST)
	stepCount = 1000 * get_slider_input(SHADOW_STEP_COUNT)
	stepDistX = lightX * stepDist
	stepDistY = -lightY * stepDist
	stepDistZ = lightZ * stepDist
end;

function get_sample(x, y)
	local normX, normY, normZ = get_sample_map(x, y, HDR_NORMAL)
	local v = normX * lightX + normY * lightY + normZ * lightZ
	local h = get_sample_map(x, y, HEIGHT)
	local heightZ = h
	local heightX = x
	local heightY = y

	for i = 1, stepCount do
		heightX = heightX + stepDistX
		heightY = heightY + stepDistY
		heightZ = heightZ + stepDistZ
		h = get_sample_map(heightX, heightY, HEIGHT)
		if (h > heightZ) then
			v = 0
			break
		end
	end

	local r = v
	local g = v
	local b = v
	local a = 1
	return r, g, b, a
end;