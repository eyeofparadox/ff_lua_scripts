function prepare()
	-- v.000	
	MIN_SCALE = 0.01
	scale = math.max(MIN_SCALE, get_slider_input(SCALE) / 2)
	set_noise_seed(get_intslider_input(NOISE_SEED))
end;

function get_sample(x, y)
	local sx, sy = x / scale , y / scale
	local cell_x, cell_y = math.floor(sx), math.floor(sy)

	local offset_x, offset_y
	local min_dist = 100
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, 0)
			local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, 1)
			local dist = math.sqrt((sx - dx)^2 + (sy - dy)^2)
			min_dist = math.min(dist, min_dist)
		end
	end

	local a = 1
	min_dist = 1.0 - min_dist
	return min_dist, min_dist, min_dist, a
end;