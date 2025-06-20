-- 3d sphere v.0.0.4.2.230611:01:30
 -- produces a surface mapped 3d sphere for relief shading
	local sqrt, min, max, rad, pi, pi_div = math.sqrt, math.min, math.max, math.rad, math.pi, 1 / math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	aspect = OUTPUT_WIDTH / OUTPUT_HEIGHT
	radius = 1 / get_slider_input(RADIUS)
	persp = get_slider_input(PERSP) * 0.25 * pi
	cp, sp = cos_sin(persp)
	divsp = 1 / sp
	tilt_1 = rad(get_angle_input(TILT_1) - 180) -- x axis
	rotation_1 = rad(get_angle_input(ROTATION_1)) -- y axis, facing 0 meridian
	roll_1 = - rad(get_angle_input(ROLL_1) - 181) -- z axis
	cx_1, sx_1, cy_1, sy_1, cz_1, sz_1 = get_cos_sin(tilt_1, rotation_1, roll_1)
end;

function get_sample(x, y)
	px_1, py_1, pz_1, pv = get_sphere(x, y)
	sr, sg, sb, sa = get_sample_map(px_1, py_1, SOURCE)
	return sr, sg, sb, pv
end;
	--[[
	-- -- -- -- -- 
	rotation_2 = rad(get_angle_input(ROTATION_2)) -- y axis
	tilt_2 = rad(get_angle_input(TILT_2) - 180) -- x axis
	roll_2 = rad(1 - get_angle_input(ROLL_2) - 181) -- z axis
	cx_2, sx_2, cy_2, sy_2, cz_2, sz_2 = get_cos_sin(rotation_2, tilt_2, roll_2)
	return px%1, py%1, 0, 1
	return py%1, py%1, py%1, 1
	return px%1, px%1, px%1, 1
	]]

function cos_sin(angle)
	local cos_angle, sin_angle = cos(angle), sin(angle)
	return cos_angle, sin_angle
end;

function get_cos_sin(tilt, rotation, roll)
	local rotation, tilt, roll = rotation, tilt, roll
	local cx, sx = cos_sin(tilt)
	local cy, sy = cos_sin(rotation)
	local cz, sz = cos_sin(roll)
	return cx, sx, cy, sy, cz, sz
end;

function get_perspective(x, y, r)
	local x, y = x, y
	local th = atan2(y, x)
	if persp > 0 then
		local ph = min(1, r) * persp
		local s_ph, c_ph = sin(ph), cos(ph)
		r = s_ph * (c_ph * divsp - sqrt((c_ph * c_ph - cp * cp) * divsp * divsp))
	else
		r = min(1, r)
	end
	return r * cos(th), r * sin(th)
end

function get_sphere(x, y)
	x, y = x * 2 - 1, y * 2 - 1
	x, y = x * radius, y * radius
	local alpha, rho = 1, sqrt(x * x + y * y)
	if rho > 1.0 then alpha = 0 end;
	x, y =  get_perspective(x, y, rho)
	local tx, ty, z = (cz_1 * x) - (sz_1 * y), (sz_1 * x) + (cz_1 * y), 0 -- roll
	x, y = tx, ty
	x, y, z = rotate_xyz(x, y, rotation_1)
	return x, y, z, alpha
end;

function rotate_xyz(x, y, rotation)
	local x, y, z = min(max(x, - 1), 1), - min(max(y, - 1), 1), 0
	local ph, th = asin(y), 0
	local cph = cos(ph)
	x = min(max(x, - cph), cph)
	if cph~=0 then th = asin(x / cph) end;
	ph = .5 * pi - ph
	x, y, z = cos(th) * sin(ph), sin(th) * sin(ph), cos(ph)
	x, z = x * cx_1 - z * sx_1, x * sx_1 + z * cx_1 -- tilt
	th, ph = atan2(y, x) + rotation_1, acos(z) -- rotation
	th, ph = (th * pi_div + 1) * .5, ph * pi_div
	th = xratio(th) -- aspect auto-conversion
	x, y = th, ph
	return x, y, z
end;

function xratio(x)
	if aspect == 2 then
		x = x * 2 - 1 else x = x
	end;
	return x
end;