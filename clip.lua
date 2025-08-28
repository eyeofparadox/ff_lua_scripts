\\\ TRANSFER \\\
°

\\\ REVISING \\\


function get_sphere_xyz(x, y, i)
	local x, y, z, tx, ty, tz, alpha, rho, i = x, y, 0, 0, 0, 0, 1, 1, i
	x, y = (x * 2.0) - 1.0, (y * 2.0) - 1.0
	x, y = x * radius, y * radius
	rho = sqrt((x * x)+(y * y))
	if rho > 1.0 then alpha = 0 end
	z = -sqrt(1.0 - ((x * x)+(y * y)))
	-- cy, sy, cx, sx, cz, sz = cy_1, sy_1, cx_1, sx_1, cz_1, sz_1
	if not i or i == 1 then
		cy, sy, cx, sx, cz, sz = cy_1, sy_1, cx_1, sx_1, cz_1, sz_1
	elseif i == 2 then
		cy, sy, cx, sx, cz, sz = cy_2, sy_2, cx_2, sx_2, cz_2, sz_2
	else
		cy, sy, cx, sx, cz, sz = cy_3, sy_3, cx_3, sx_3, cz_3, sz_3
	end;
	tx, ty = (cz * x) - (sz * y), (sz * x) + (cz * y)
 	x, y = tx, ty-- roll
	tz, ty = (cx * z) - (sx * y), (sx * z) + (cx * y)
 	z, y = tz, ty -- tilt
	tx, tz= (cy * x) - (sy * z), (sy * x) + (cy * z)
 	x, z = tx, tz -- rotation
 	return x, y, z, alpha, rho
end;
	-- px, py, pz, alpha, rho = get_sphere_xyz(x, y, rho)

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
	-- px, py, pz, alpha, rho = sphere(x, y, rho)

\\\ HOLDING \\\

--[[
	local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2
-- prepare
	-- inputs and precalculation
	ang_x = rad(get_angle_input(ANGLE_X)) 
	ang_y = rad(get_angle_input(ANGLE_Y))
	ang_z = rad(get_angle_input(ANGLE_Z))

	cos_ax, sin_ax  = cos(ang_x), sin(ang_x)
	cos_ay, sin_ay = cos(ang_y), sin(ang_y)
	cos_az, sin_az = cos(ang_z), sin(ang_z)
]]
function get_map_rotations_xyz(x, y)
	local x = x - 0.5
	local y = y * pi
	x = x * aspect * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y)
	local nz = cos(y)
	local ax1, ax2 = (nx * cos_ax) + (ny * sin_ax), (nx * sin_ax) - (ny * cos_ax)
	local ay1, ay2 = (ax1 * cos_ay) - (cos(y) * sin_ay), (ax1 * sin_ay) + (cos(y) * cos_ay)
	local az1, az2 = (ax2 * cos_az) + (ay2 * sin_az), (ax2 * sin_az) - (ay2 * cos_az)
	nx = atan2(az1, ay1) * 0.159155 + 0.5
	ny = acos(az2) * 0.16 * 2
	nx = xratio(nx) -- aspect auto-conversion
	return nx, ny
end;


function xratio(x)
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then x = x * 2 - 1 end;
	return x
end;
	-- x = xratio(x) -- in get_sample or function


function cos_sin(angle)
	local cos_angle, sin_angle = cos(angle), sin(angle)
	return cos_angle, sin_angle
end;
	-- c_, s_ = cos_sin(angle) -- in prepare or function


function get_cos_sin(rotation, tilt, roll)
	local rotation, tilt, roll = rotation, tilt, roll
	cy, sy = cos_sin(rotation) -- y-axis aka yaw
	cx, sx = cos_sin(tilt) -- x-axis aka pitch
	cz, sz = cos_sin(roll) -- z-axis
	return cy, sy, cx, sx, cz, sz
end;
	-- cy_, sy_, cx_, sx_, cz_, sz_ = get_cos_sin(rotation_, tilt_, roll_) -- in prepare


function get_sphere(x, y)
	local x, y = x * 2 - 1, y * 2 - 1
	x, y = x * radius, y * radius
	local rho = sqrt((x * x)+(y * y))
	local tha, phi = atan2(y, x), 0
	if per > 0 then
		phi = min(1, rho) * per
		local h, cph = sin(phi), cos(phi)
		rho = h * (cph* _div - sqrt((cph * cph - cp * cp)* _div* _div))
	end;
	px, py = rho * cos(tha), rho * sin(tha)
	local z = -sqrt(1.0 - ((x * x)+(y * y)))
	return x, y, z, rho, phi, tha
end;
	-- x_, y_, z_, rho_, phi_, tha_ = get_sphere(x, y) -- in get_sample


function rotate_sphere(x, y, z, cy, sy, cx, sx, cz, sz)
	x, y = rotate_z(x, y, z) -- roll
	z, y = rotate_x(x, y, z) -- tilt
	x, z = rotate_y(x, y, z) -- rotation
	return x, y, z
end;


function rotate_z(x, y, z) -- z-axis -- roll
	local tx, ty = (cz * x) - (sz * y), (sz * x) + (cz * y)
	x, y = tx, ty
	return x, y
end;


function rotate_x(x, y, z) -- x-axis -- tilt
	local tz, ty = (cx * z) - (sx * y), (sx * z) + (cx * y)
	z, y = tz, ty
	return z, y
end;


function rotate_y(x, y, z) -- y-axis -- rotation
	local tx, tz= (cy * x) - (sy * z), (sy * x) + (cy * z)
	x, z = tx, tz
	return x, z
end;


function rotate_xy(x, y, rotation) -- tha, phi
	x, y = min(max(x, - 1), 1), - min(max(y, - 1), 1)
	local phi, tha = asin(y), 0
	local cph = cos(phi)
	x = min(max(x, - cph), cph)
	if cph~=0 then tha = asin(x / cph) end;
	phi = .5 * pi - phi
	local nx, ny, nz = cos(tha) * sin(phi), sin(tha) * sin(phi), cos(phi)
	nx, nz = nx * cx_1 - nz * sx_1, nx * sx_1 + nz * cx_1 -- tilt
	tha, phi = atan2(ny, nx) + rotation, acos(nz) -- rotation
	tha, phi = (tha * pi_div + 1) * .5, phi * pi_div
	tha = xratio(tha) -- aspect auto-conversion
	return tha, phi -- relative x, y
end;


