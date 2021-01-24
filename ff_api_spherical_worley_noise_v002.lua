function prepare()
	-- v.002
	MIN_SCALE = 0.01
	scale = math.max(MIN_SCALE, get_slider_input(SCALE) / 2) * 5
	set_noise_seed(get_intslider_input(NOISE_SEED))
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
end;

function get_sample(x, y)
	local x = x * aspect * math.pi
	local y = y * math.pi
	local z = get_sample_grayscale(x, y, Z_COORDINATE)
	local nx = math.cos(x) * math.sin(y) 
	local ny = math.sin(x) * math.sin(y) 
	local nz = math.cos(y) * z
	local sx, sy, sz = nx / scale , ny / scale, nz / scale
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)

	local offset_x, offset_y, offset_z
	local min_dist = 100
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)
				min_dist = math.min(dist, min_dist)
			end
		end
	end

	local a = 1
	min_dist = 1.0 - min_dist
	return min_dist, min_dist, min_dist, a
end;