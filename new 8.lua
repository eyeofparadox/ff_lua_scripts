-- 3d sphere x y z
	-- produces a light shadow mapped to a 3d sphere
	local sqrt, min, max, rad, pi, divp = math.sqrt, math.min, math.max, math.rad, math.pi, 1 / math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	atmos = get_slider_input(ATMOS) * 0.25 * pi
	s_atmos, c_atmos = sin(atmos), cos(atmos)
	radius = get_slider_input(RADIUS)
	divr, divp = max(1 / radius, 0.0000001), max(1 / s_atmos)
	z_roll = rad(get_angle_input(ROLL))
	s_z, c_z = sin(z_roll), cos(z_roll)
	x_tilt = rad(get_angle_input(TILT))
	c_x, s_x = cos(x_tilt), sin(x_tilt)
	y_rotation = rad(get_angle_input(ROTATION))
	s_y, c_y = sin(y_rotation), cos(y_rotation)
end

function get_sample(x, y)
	local r, g, b, a, alpha, rho = 1, 1, 1, 1, 1, 1
	x, y, z, alpha = get_sphere_xyz(x, y)
	x, y, z = x * 0.5 + 0.5, y * 0.5 + 0.5, z * 0.5 + 0.5
	v = get_sample_curve(x, y, x, PROFILE)
	v = v * alpha
	z = (v * 0.5 + 0.5) * x * alpha
	r_atm, g_atm, b_atm, a_atm = get_sample_color(x, y, 0.055, 0.5775, 1.1, 1)
	r, g, b, a = blend_hard_light(x, x, x, alpha, r_atm, g_atm, b_atm, 1, z)
	return v, v, v, alpha
	-- return x, x, x, alpha
	-- return y, y, y, alpha
	-- return z, z, z, alpha
	-- return x, y, z, alpha
	-- return r, g, b, a
end

function get_sample_color(x, y, r, g, b, a)
	local r, g, b, a = x * y * r, x * y * g, x * y * b,  x * y * a
	return r, g, b, a
end
	-- r_, g_, b_, a_ = get_sample_color(x, y, 0.055, 0.5775, 1.1.1, 1)

function get_sphere_xyz(x, y)
	local x, y, z, tx, ty, tz, alpha, rho = x, y, z, 0, 0, 0, 1, 1
	x, y = (x * 2.0) - 1.0, (y * 2.0) - 1.0
	x, y = x * divr, y * divr
	rho = sqrt((x * x)+(y * y))
	if rho > 1.0 then alpha = 0 end;
	z = -sqrt(math.max(1.0 - ((x * x)+(y * y)), 0.0000001))
	tx, ty = (c_z * x) - (s_z * y), (s_z * x) + (c_z * y)
 	x, y = tx, ty-- roll
	tz, ty = (c_x * z) - (s_x * y), (s_x * z) + (c_x * y)
 	z, y = tz, ty -- tilt
	tx, tz= (c_y * x) - (s_y * z), (s_y * x) + (c_y * z)
 	x, z = tx, tz -- rotation
 	return x, y, z, alpha, rho
end;

function get_atmosphere(x,y)
	local ph, s_ph, c_ph
	local th = atan2(y, x)
	if atmos > 0 then
		local ph = min(1, rho) * atmos
		local s_ph, c_ph = sin(ph), cos(ph)
		rho = s_ph * (c_ph * divp - sqrt((c_ph * c_ph - c_atmos * c_atmos) * divp * divp))
	else
		rho = min(1, rho)
	end
	rho = s_ph * (c_ph * divp - sqrt((c_ph * c_ph - c_atmos * c_atmos) * divp * divp))
	x, y = rho * cos(th), rho * sin(th)
	x, y = get_sphere_rtp(x, y)
 	return x, y
end

local function get_theta_phi(th, ph)
	local x, y, z = cos(th) * sin(ph), sin(th) * sin(ph), cos(ph)
	x, z = x * c_tilt - z * s_tilt, x * s_tilt + z * c_tilt
	th, ph = atan2(y, x) + y_rotation, acos(z)
	return (th / pi + 1) * 0.5, ph / pi
end

local function get_sphere_rtp(x, y)
	x, y = min(max(x, - 1), 1), - min(max(y, - 1), 1)
	local ph = asin(y)
	local th = 0
	local c_ph = cos(ph)
	x = min(max(x, - c_ph), c_ph)
	if c_ph ~=0 then
		th = asin(x / c_ph)
	end
	return get_theta_phi(th, 0.5 * pi - ph)
end