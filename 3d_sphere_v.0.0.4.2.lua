-- 3d sphere v.0.0.4.2.230603:05:30
	-- produces a surface mapped 3d sphere with lighting and atmosphere 
	-- debug = true; if debug then return xxx, yyy, zzz, 1 end;
	local sqrt, min, max, rad, pi, pi_div = math.sqrt, math.min, math.max, math.rad, math.pi, 1 / math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	radius = 1 / get_slider_input(RADIUS)
	persp = get_slider_input(PERSP) * .25 * pi
	cp, sp = cos_sin(persp)
	sp_div = 1 / sp
	rotation_1 = 1 - rad(get_angle_input(ROTATION_1)) -- y axis
	tilt_1 = rad(get_angle_input(TILT_1)) -- x axis
	roll_1 = rad(get_angle_input(ROLL_1)) -- z axis
	cy_1, sy_1, cx_1, sx_1, cz_1, sz_1 = get_cos_sin(rotation_1, tilt_1, roll_1)
	rotation_2 = rad(get_angle_input(ROTATION_2)) -- y axis
	tilt_2 = rad(get_angle_input(TILT_2)) -- x axis
	roll_2 = rad(get_angle_input(ROLL_2)) -- z axis
	cy_2, sy_2, cx_2, sx_2, cz_2, sz_2 = get_cos_sin(rotation_2, tilt_2, roll_2)
	rotation_3 =0 -- y axis
	tilt_3 = 0 -- x axis
	roll_3 = 0-- z axis
	cy_3, sy_3, cx_3, sx_3, cz_3, sz_3 = get_cos_sin(rotation_3, tilt_3, roll_3)
end;


function get_sample(x, y)
	px_1, py_1, pz_1, pv = get_sphere(x, y)
	px_2, py_2, pz_2, pv = get_sphere_xyz(x, y, 2)
	px_3, py_3, pz_3, pv = get_sphere_xyz(x, y, 3)
	px_2, py_2, pz_2 = px_2 * 0.5 + 0.5, py_2 * 0.5 + 0.5, pz_2 * 0.5 + 0.5
	px_3, py_3, pz_3 = px_3 * 0.5 + 0.5, py_3 * 0.5 + 0.5, pz_3 * 0.5 + 0.5
	if pv == 0 then return 0, 0, 0, 0 end;
	pz_2 = get_sample_curve(pz_2, py_2, pz_2, PROFILE_S)
	pz_3 = get_sample_curve(pz_3, py_3, pz_3, PROFILE_A)
	-- fringe = pz_3 + pz_2 * 0.5
	sr, sg, sb, sa = get_sample_map(px_1, py_1, SOURCE)
	ar, ag, ab, aa = get_sample_map(px_3, py_3, ATMOS)
	r, g, b, a = blend_hard_light(0.65, 0.65, 0.65, 1, pz_2, pz_2, pz_2, 0.95, 1)
	r, g, b, a = blend_multiply(r, g, b, a, pz_2, pz_2, pz_2, 0.975, 0.975, true)
	r, g, b, a = blend_hard_light(sr, sg, sb, sa, r, g, b, a, 0.975)
	r, g, b, a = blend_linear_dodge(r, g, b, a, pz_2, pz_2, pz_2, 0.25, 0.25)
	r, g, b, a = blend_normal(r, g, b, a, ar, ag, ab, pz_3 * pz_2 * 2.75, pz_2, true)
	return r, g, b, a
end;
	--[[
	return pz_3, pz_3, pz_3, 1
	return 1 - pz_3, 1 - pz_3, 1 - pz_3, 1
	return px%1, py%1, 0, 1
	return py%1, py%1, py%1, 1
	return px%1, px%1, px%1, 1
	]]


function cos_sin(angle)
	local cos_angle, sin_angle = cos(angle), sin(angle)
	return cos_angle, sin_angle
end;


function get_cos_sin(rotation, tilt, roll)
	local rotation, tilt, roll = rotation, tilt, roll
	local cy, sy = cos_sin(rotation) -- y-axis = yaw
	local cx, sx = cos_sin(tilt) -- x-axis = pitch
	local cz, sz = cos_sin(roll) -- z-axis = roll
	return cy, sy, cx, sx, cz, sz
end;


function get_sphere(x, y)
	x, y = x * 2 - 1, y * 2 - 1
	x, y = x * radius, y * radius
	local alpha, rho = 1, sqrt(x * x + y * y)
	if rho > 1.0 then alpha = 0 end;
	local th = atan2(y, x)
	if persp > 0 then
		local ph = min(1, rho) * persp
		local sph, cph = sin(ph), cos(ph)
		rho = sph * (cph* sp_div - sqrt((cph * cph - cp * cp)* sp_div* sp_div))
	else
		rho = min(1, rho)
	end;
	x, y = rho * cos(th), rho * sin(th)
		local tx, ty = (cz_1 * x) - (sz_1 * y), (sz_1 * x) + (cz_1 * y)
		x, y = tx, ty
		x, y, z = rotate_xyz(x, y, rotation_1)
	return x, y, z, alpha
end;


function rotate_xyz(x, y, rotation) -- tha, phi
	local x, y, z = min(max(x, - 1), 1), - min(max(y, - 1), 1), 0
	local phi, tha = asin(y), 0
	local cph = cos(phi)
	x = min(max(x, - cph), cph)
	if cph~=0 then tha = asin(x / cph) end;
	phi = .5 * pi - phi
	x, y, z = cos(tha) * sin(phi), sin(tha) * sin(phi), cos(phi)
	x, z = x * cx_1 - z * sx_1, x * sx_1 + z * cx_1 -- tilt
	tha, phi = atan2(y, x) + rotation_1, acos(z) -- rotation
	tha, phi = (tha * pi_div + 1) * .5, phi * pi_div
	tha = xratio(tha) -- aspect auto-conversion
	x, y = tha, phi
	return x, y, z -- relative x, y
end;


function xratio(x)
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		x = x * 2 - 1 else x = x
	end;
	return x
end;


function get_sphere_xyz(x, y, i)
	local x, y, z, tx, ty, tz, alpha, rho, i = x, y, 0, 0, 0, 0, 1, 1, i
	x, y = (x * 2.0) - 1.0, (y * 2.0) - 1.0
	x, y = x * radius, y * radius
	rho = sqrt((x * x)+(y * y))
	if rho > 1.0 then alpha = 0 end
	z = -sqrt(1.0 - ((x * x)+(y * y)))
	if not i or i == 1 then
		cy, sy, cx, sx, cz, sz = cy_1, sy_1, cx_1, sx_1, cz_1, sz_1
	elseif i == 2 then
		cy, sy, cx, sx, cz, sz = cy_2, sy_2, cx_2, sx_2, cz_2, sz_2
	else
		cy, sy, cx, sx, cz, sz = cy_3, sy_3, cx_3, sx_3, cz_3, sz_3
	end	
	tx, ty = (cz * x) - (sz * y), (sz * x) + (cz * y)
 	x, y = tx, ty-- roll
	tz, ty = (cx * z) - (sx * y), (sx * z) + (cx * y)
 	z, y = tz, ty -- tilt
	tx, tz= (cy * x) - (sy * z), (sy * x) + (cy * z)
 	x, z = tx, tz -- rotation
 	return x, y, z, alpha, rho
end;
	-- px, py, pz, alpha, rho = get_sphere_xyz(x, y, rho)