-- 3d sphere v.0.0.4.2
	-- produces a surface mapped 3d sphere 
	local sqrt, min, max, rad, pi, pi_div = math.sqrt, math.min, math.max, math.rad, math.pi, 1 / math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	radius = 1 / get_slider_input(RADIUS)
	per = get_slider_input(PERSP) * .25 * pi
	sp, cp = sin(per), cos(per)
	sp_div = 1 / sp
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
	px, py = x * 2 - 1, y * 2 - 1
	px, py = px * radius, py * radius
	local rho = sqrt(px * px + py * py)
	if rho > 1.0 then return 0, 0, 0, 0 end;
	local th = atan2(py, px)
	if per > 0 then
		local ph = min(1, rho) * per
		local sph, cph = sin(ph), cos(ph)
		rho = sph * (cph* sp_div - sqrt((cph * cph - cp * cp)* sp_div* sp_div))
	else
		rho = min(1, rho)
	end;
	px, py = rho * cos(th), rho * sin(th)
	-- roll
	local tx, ty = (cz_1 * px) - (sz_1 * py), (sz_1 * px) + (cz_1 * py)
	px,py  = tx, ty
	px, py = get_sphere(px, py, rotation_1)
	-- input image
	r, g, b, a = get_sample_map(px, py, SOURCE)
	-- return px%1, py%1, 0, 1
	-- return py%1, py%1, py%1, 1
	-- return px%1, px%1, px%1, 1
	return r, g, b, a
end;


function get_cos_sin(rotation, tilt, roll)
	local rotation, tilt, roll = rotation, tilt, roll
	cy, sy = cos(rotation), sin(rotation) -- y-axis = rotation
	cx, sx = cos(tilt), sin(tilt) -- x-axis = tilt
	cz, sz = cos(roll), sin(roll) -- z-axis = roll
	return cy, sy, cx, sx, cz, sz
end;


function get_sphere(x, y, rotation)
	x, y = min(max(x, - 1), 1), - min(max(y, - 1), 1)
	local ph = asin(y)
	local th = 0
	local cph = cos(ph)
	x = min(max(x, - cph), cph)
	if cph~=0 then th = asin(x / cph) end;
	ph = .5 * pi - ph
	local nx, ny, nz = cos(th) * sin(ph), sin(th) * sin(ph), cos(ph)
	nx, nz = nx * cx_1 - nz * sx_1, nx * sx_1 + nz * cx_1
	th, ph = atan2(ny, nx) + rotation, acos(nz)
	th, ph = (th * pi_div + 1) * .5, ph * pi_div
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then th = th * 2 - 1 end;
	return th, ph
end;
--[[
]]

