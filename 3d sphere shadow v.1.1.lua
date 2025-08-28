-- 3d sphere shadow v.1.1.230602
	-- produces a surface mapped 3d sphere 
	-- produces light and shadow mapped to a 3d sphere 
	local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi;
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2;

function prepare()
	radius = 1  / get_slider_input(RADIUS)
	per = get_slider_input(PERSP) * .25 * pi
	sp, cp = sin(per), cos(per)
	sp_div = 1 / sp

	-- tilt & rotation precalc
	rotation_1 = rad(get_angle_input(ROTATION_1)) -- y axis
	tilt_1 = rad(get_angle_input(TILT_1)) -- x axis
	roll_1 = rad(get_angle_input(ROLL_1))-- z axis
	cy_1, sy_1, cx_1, sx_1, cz_1, sz_1 = get_cos_sin(rotation_1, tilt_1, roll_1)
	rotation_2 = rad(get_angle_input(ROTATION_2)) -- y axis
	tilt_2 = rad(get_angle_input(TILT_2)) -- x axis
	roll_2 = rad(get_angle_input(ROLL_2))-- z axis
	cy_2, sy_2, cx_2, sx_2, cz_2, sz_2 = get_cos_sin(rotation_2, tilt_2, roll_2)
end;


function get_sample(x, y)
	-- sphere generation
	spx_1, spy_1, spz_1, rho_1 = get_sphere(x, y)
	spx_2, spy_2, spz_2, rho_2 = get_sphere(x, y)

	-- sphere manipulation
	local spx_1, spy_1, spz_1 = rotate_sphere(spx_1, spy_1, spz_1, cy_1, sy_1, cx_1, sx_1, cz_1, sz_1)
	local spx_2, spy_2, spz_2 = rotate_sphere(spx_2, spy_2, spz_2, cy_2, sy_2, cx_2, sx_2, cz_2, sz_2)

	-- image generation
	local rho = min(rho_1, rho_2)
	if rho > 1.0 then return 0, 0, 0, 0 end
	rho = min(1, rho)
	p_1 = get_sample_curve(spx_1 * 0.5 + 0.5, spy_1 * 0.5 + 0.5, spz_1 * 0.5 + 0.5, PROFILE_1)
	p_2 = get_sample_curve(spx_2 * 0.5 + 0.5, spy_2 * 0.5 + 0.5, spz_2 * 0.5 + 0.5, PROFILE_2)
	local r, g, b, a = spx_1, spy_1, spz_1, 1

	-- return p_1, p_1, p_1, a
	-- return p_2, p_2, p_2, a
	return p_1, p_2, 0, a
	-- return spx_1 * 0.5 + 0.5, spx_1 * 0.5 + 0.5, spx_1 * 0.5 + 0.5, a
	-- return spx_1 * 0.5 + 0.5, spy_1 * 0.5 + 0.5, spz_1 * 0.5 + 0.5, a
	-- return r, g, b, a
end;


function get_cos_sin(rotation, tilt, roll)
	local rotation, tilt, roll = rotation, tilt, roll
	-- y-axis = yaw
	cy, sy = cos(rotation), sin(rotation)
	
	-- x-axis = pitch
	cx, sx = cos(tilt), sin(tilt)
	
	-- z-axis = roll
	cz, sz = cos(roll), sin(roll)
	
	return cy, sy, cx, sx, cz, sz
end;


function get_sphere(x, y)
	local spx, spy = x * 2 - 1, y * 2 - 1
	spx, spy = spx * radius, spy * radius
	local rho = sqrt((spx * spx)+(spy * spy))
	local th, ph = atan2(spy, spx), 0
	if per > 0 then
		ph = min(1, rho) * per
		local sph, cph = sin(ph), cos(ph)
		rho = sph * (cph* sp_div - sqrt((cph * cph - cp * cp)* sp_div* sp_div))
	end;
	px, py = rho * cos(th), rho * sin(th)
	local spz = -sqrt(1.0 - ((spx * spx)+(spy * spy)))
	return spx, spy, spz, rho
end;


function rotate_sphere(spx, spy, spz, cy, sy, cx, sx, cz, sz)
	-- roll : changes in x and y
	local tx = (cz * spx) - (sz * spy)
	local ty = (sz * spx) + (cz * spy)
	spx = tx
	spy = ty

	-- tilt : changes in y and z
	local tz = (cx * spz) - (sx * spy)
	local ty = (sx * spz) + (cx * spy)
	spz = tz
	spy = ty

	-- rotation : changes in x and z
	local tx = (cy * spx) - (sy * spz)
	local tz = (sy * spx) + (cy * spz)
	spx = tx
	spz = tz
	
	return spx, spy, spz
end;