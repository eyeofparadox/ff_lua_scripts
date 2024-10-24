-- rotational shadow map v.0.1.20230602:02:00
	-- this version works (as of note creation)
	local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	-- inputs and precalculation.
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	ang_x = rad(get_angle_input(ANGLE_X)) 
	ang_y = rad(get_angle_input(ANGLE_Y))
	ang_z = rad(get_angle_input(ANGLE_Z)) -- 0

	cos_ax, sin_ax  = cos(ang_x), sin(ang_x)
	cos_ay, sin_ay = cos(ang_y), sin(ang_y)
	cos_az, sin_az = cos(ang_z), sin(ang_z)
	hdr = true
end;

function get_sample(x, y)
	local ir, ig, ib, ia = get_sample_map(x, y, SOURCE)
	local gs = 0.2126 * ir + 0.7152 * ig + 0.0722 * ib
	-- image generation
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
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		nx = nx * 2 - 1
	end
	sr, sg, sb, sa = get_shadowmap(nx, ny)
	r, g, b, a = blend_linear_dodge(gs, gs, gs, 1, 0.5, 0.5, 0.5, 1, 1, hdr)
	r, g, b, a = blend_multiply(r, g, b, a, sr, sg, sb, sa, 1, hdr)
	r, g, b, a = blend_hard_light(ir, ig, ib, ia, r, g, b, a, 1)
	return  r, g, b, a
end;

function get_shadowmap(x, y)
	local x = x * aspect * pi
	local y = y * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y)
	local nz = cos(y)
	nx, ny, nz = nx * 0.5 + 0.5, ny * 0.5 + 0.5, nz * 0.5 + 0.5
	r = get_sample_curve(nx, ny, nz, PROFILE)
	-- return nx, ny, nz, 1
	-- return nx, nx, nx, 1
	return r, r, r, 1
end;