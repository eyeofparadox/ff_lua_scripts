local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi
local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	radius = get_slider_input(RADIUS)
	persp = get_slider_input(PERSP) * .25 * pi
	s_persp, c_persp = sin(persp), cos(persp)
	divr, divp = 1 / radius, 1 / s_persp
	y_rotation = - rad(get_angle_input(ROTATION))
	x_tilt = rad(get_angle_input(TILT))
	s_tilt, c_tilt = sin(x_tilt), cos(x_tilt)
	z_roll = rad(get_angle_input(ROLL))
	s_roll, c_roll = sin(z_roll), cos(z_roll)
end

local function get_perspective(x, y, r)
	local x, y = x, y
	local th = atan2(y, x)
	if persp > 0 then
		local ph = min(1, r) * persp
		local s_ph, c_ph = sin(ph), cos(ph)
		r = s_ph * (c_ph * divp - sqrt((c_ph * c_ph - c_persp * c_persp) * divp * divp))
	else
		r = min(1, r)
	end
	return r * cos(th), r * sin(th)
end

local function get_theta_phi(th, ph)
	local x, y, z = cos(th) * sin(ph), sin(th) * sin(ph), cos(ph)
	x, z = x * c_tilt - z * s_tilt, x * s_tilt + z * c_tilt
	th, ph = atan2(y, x) + y_rotation, acos(z)
	return (th / pi + 1) * .5, ph / pi
end

local function get_sphere(x, y)
	x, y = min(max(x, - 1), 1), - min(max(y, - 1), 1)
	local ph, th = asin(y), 0
	local c_ph = cos(ph)
	x = min(max(x, - c_ph), c_ph)
	if c_ph ~=0 then
		th = asin(x / c_ph)
	end
	return get_theta_phi(th, .5 * pi - ph)
end

function get_sample(x, y)
	x, y = x * 2 - 1, y * 2 - 1
	x = x * divr
	y = y * divr
	local alpha, r = 1, sqrt(x * x + y * y)
	if r > 1.0 then alpha = 0 end
	x, y =  get_perspective(x, y, r)
	local tx, ty= (c_roll * x) - (s_roll * y), (s_roll * x) + (c_roll * y)
	x, y = tx, ty
	x, y = get_sphere(x, y)
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then x = x * 2 - 1 end
	r, g, b, a = get_sample_map(x, y, SOURCE)
	a = a * alpha
	return r, g, b, a
end
	-- return x%1, y%1, 0, 1