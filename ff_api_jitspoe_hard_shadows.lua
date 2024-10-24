function prepare()
	pitch = math.rad(get_angle_input(PITCH))
	yaw = math.rad(get_angle_input(YAW))
	lightX2D = math.cos(yaw)
	lightY2D = math.sin(yaw)
	lightX = math.cos(pitch) * lightX2D
	lightY = math.cos(pitch) * lightY2D
	lightZ = math.sin(pitch)
	stepDist = get_slider_input(SHADOW_STEP_DIST)
	stepCount = 1000 * get_slider_input(SHADOW_STEP_COUNT)
	stepDistX = lightX * stepDist
	stepDistY = -lightY * stepDist
	stepDistZ = lightZ * stepDist
end;

function get_sample(x, y)
	local normX, normY, normZ = get_sample_map(x, y, HDR_NORMAL)
	local v = normX * lightX + normY * lightY + normZ * lightZ
	local h = get_sample_map(x, y, HEIGHT)
	local heightZ = h
	local heightX = x
	local heightY = y

	for i = 1, stepCount do
		heightX = heightX + stepDistX
		heightY = heightY + stepDistY
		heightZ = heightZ + stepDistZ
		h = get_sample_map(heightX, heightY, HEIGHT)
		if (h > heightZ) then
			v = 0
			break
		end
	end

	local r = v
	local g = v
	local b = v
	local a = 1
	return r, g, b, a
end;