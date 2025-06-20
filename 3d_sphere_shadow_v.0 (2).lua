-- 3d sphere shadow v.0.20230223:17:26
	-- produces a light shadow mapped to a 3d sphere 
	local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi;
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2;

function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	radius = get_slider_input(RADIUS)

	-- tilt & rotation precalc
	rotation = rad(get_angle_input(ROTATION)) 
	-- y-axis = yaw
	cos_y = cos(rotation)
	sin_y = sin(rotation)
	
	tilt = rad(get_angle_input(TILT)) 
	-- x-axis = pitch
	cos_x = cos(tilt)
	sin_x = sin(tilt)
	
	roll = rad(get_angle_input(ROLL)) 
	-- z-axis = roll
	sin_z = sin(roll)
	cos_z = cos(roll)
end;


function get_sample(x, y)
	local r, g, b, a = 1, 1, 1, 1
	
	-- image generation
	local px = (x * 2.0) - 1.0
	local py = (y * 2.0) - 1.0
	px = px / radius
	py = py / radius
	local len = sqrt((px * px)+(py * py))
	if len > 1.0 then return 0, 0, 0, 0 end

	local pz = -sqrt(1.0 - ((px * px)+(py * py)))

	-- roll : changes in x and y
	local tx = (cos_z * px) - (sin_z * py)
	local ty = (sin_z * px) + (cos_z * py)
	px = tx
	py = ty

	-- tilt : changes in y and z
	local tz = (cos_x * pz) - (sin_x * py)
	local ty = (sin_x * pz) + (cos_x * py)
	pz = tz
	py = ty

	-- rotation : changes in x and z
	local tx = (cos_y * px) - (sin_y * pz)
	local tz = (sin_y * px) + (cos_y * pz)
	px = tx
	pz = tz

	p = get_sample_curve(px / 2+.5, py / 2+.5, pz / 2+.5, PROFILE)
	local v = get_sample_grayscale(x, y, REFLECTION_MASK)

	return p, p, p, a 
	-- return px / 2+.5, px / 2+.5, px / 2+.5, a 
	-- return r, g, b, a
end;