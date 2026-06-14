-- 3d map spherical rotations v.0.0.1
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
    -- Convert to spherical angles
    local lon = (x - 0.5) * aspect * pi
    local lat = y * pi

    -- Convert to Cartesian
    local X = cos(lon) * sin(lat)
    local Y = sin(lon) * sin(lat)
    local Z = cos(lat)

    -- Rotate around X axis
    local Y1 = Y * cos_ax - Z * sin_ax
    local Z1 = Y * sin_ax + Z * cos_ax

    -- Rotate around Y axis
    local X2 = X * cos_ay + Z1 * sin_ay
    local Z2 = -X * sin_ay + Z1 * cos_ay

    -- Rotate around Z axis
    local X3 = X2 * cos_az - Y1 * sin_az
    local Y3 = X2 * sin_az + Y1 * cos_az

    -- Convert back to spherical
    local lon2 = atan2(Y3, X3)
    local lat2 = acos(Z2)

    -- Normalize to 0..1
    local nx = lon2 * 0.159155 + 0.5
    local ny = lat2 * 0.159155 * 2

    if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
        nx = nx * 2 - 1
    end

    return nx, ny
end
