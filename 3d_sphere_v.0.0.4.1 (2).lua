-- 3d sphere v.0.0.4.1
	-- produces a surface mapped 3d sphere 
	local sqrt, min, max, rad, pi, pi_div = math.sqrt, math.min, math.max, math.rad, math.pi, 1 / math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	radius = 1 / get_slider_input(RADIUS)
	persp = get_slider_input(PERSP) * .25 * pi
	roll = rad(get_angle_input(ROLL)) -- z axis
	tilt = rad(get_angle_input(TILT) + 180) -- x axis
	rotation = rad(get_angle_input(ROTATION)) -- y axis
	elevation = rad(get_angle_input(ELEVATION)) -- z axis » roll offset
	pitch = rad(get_angle_input(PITCH) + tilt) -- x axis
	phase = rad(get_angle_input(PHASE) + rotation) -- y axis » rotation offset
	
	sin_persp, cos_persp = sin(persp), cos(persp)
	sin_persp_div = 1/ sin_persp
	sin_roll, cos_roll = sin(roll), cos(roll)
	sin_tilt, cos_tilt = sin(tilt), cos(tilt)
	sin_phase, cos_phase = sin(phase), cos(phase)
	sin_pitch, cos_pitch = sin(pitch), cos(pitch)
	sin_elevation, cos_elevation = sin(elevation), cos(elevation)
end;

local function get_sphere_th_ph(th, ph)
	local x, y, z = cos(th) * sin(ph), sin(th) * sin(ph), cos(ph)
	-- tilt : changes in x and y
	x, z = x * cos_tilt - z * sin_tilt, x * sin_tilt + z * cos_tilt
	-- rotation : changes from x and y
	th, ph = atan2(y, x) + rotation, acos(z)
	return (th * pi_div + 1) * .5, ph * pi_div
end;

local function get_sphere(x, y)
	-- roll : changes in x and y
	-- local tx = (cos_roll * x) - (sin_roll * y)
	-- local ty = (sin_roll * x) + (cos_roll * y)
	-- x = tx
	-- y = ty
	x, y = min(max(x, - 1), 1), - min(max(y, - 1), 1)
	local ph = asin(y)
	local th = 0
	local cos_ph = cos(ph)
	x = min(max(x, - cos_ph), cos_ph)
	if cos_ph~=0 then
		th = asin(x / cos_ph)
	end;
	return get_sphere_th_ph(th, .5 * pi - ph)
end;

function get_sample(x, y)
	nx, ny = x * 2 - 1, y * 2 - 1
	nx = nx * radius
	ny = ny * radius
	local rho = sqrt(nx * nx + ny * ny)
	if rho > 1.0 then return 0, 0, 0, 0 end;
	local th = atan2(ny, nx)
	if persp > 0 then
		local ph = min(1, rho) * persp
		local sin_ph, cos_ph = sin(ph), cos(ph)
		rho = sin_ph * (cos_ph* sin_persp_div - sqrt((cos_ph * cos_ph - cos_persp * cos_persp)* sin_persp_div* sin_persp_div))
	else
		rho = min(1, rho)
	end;
	nx, ny = rho * cos(th), rho * sin(th)
	-- roll : changes in nx and ny
	local tx = (cos_roll * nx) - (sin_roll * ny)
	local ty = (sin_roll * nx) + (cos_roll * ny)
	nx = tx
	ny = ty
	nx, ny = get_sphere(nx, ny)
	-- aspect auto-conversion
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		nx = nx * 2 - 1
	end;
	-- input image
	r, g, b, a = get_sample_map(nx, ny, SOURCE)
	-- return nx%1, ny%1, 0, 1
	return ny%1, ny%1, ny%1, 1
	-- return nx%1, nx%1, nx%1, 1
	--	return r, g, b, a
end;