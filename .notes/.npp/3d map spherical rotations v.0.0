-- 3d map spherical rotations v.0.0
local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi
local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	-- inputs and precalculation.
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	ang_x = rad(get_angle_input(ANGLE_X) + 180) 
	ang_y = rad(get_angle_input(ANGLE_Y))
	ang_z = rad(get_angle_input(ANGLE_Z) - 180)

	cos_ax, sin_ax  = cos(ang_x), sin(ang_x)
	cos_ay, sin_ay = cos(ang_y), sin(ang_y)
	cos_az, sin_az = cos(ang_z), sin(ang_z)
end;

function get_sample(x, y)
	local nx, ny = map_spherical_rotations(x, y)
	local r, g, b, a = get_sample_map(nx, ny, SOURCE)
   return r, g, b, a
end;

function map_spherical_rotations(x, y)
	-- coordinate rotations
	local x = x * aspect * pi
	local y = y * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y)
	local nz = cos(y)
	-- local r, g, b, a = nx, ny, 0, 1
	local ax1, ax2 = (nx * cos_ax) + (ny * sin_ax), (nx * sin_ax) - (ny * cos_ax)
	local ay1, ay2 = (ax1 * cos_ay) - (cos(y) * sin_ay), (ax1 * sin_ay) + (cos(y) * cos_ay)
	local az1, az2 = (ax2 * cos_az) + (ay2 * sin_az), (ax2 * sin_az) - (ay2 * cos_az)
	nx = atan2(az1, ay1) * 0.159155 + 0.5
	ny = acos(az2) * 0.159155 * 2
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		nx = nx * 2 - 1
	end
	return nx, ny
end;

