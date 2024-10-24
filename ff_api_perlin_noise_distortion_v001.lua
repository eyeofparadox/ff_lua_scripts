-- perlin noise - get_perlin_octaves(x, y, z, channel) v.0.1.1
function prepare()
	-- v.001
--	constants
	amp_c = 1.731628995
	rough_c = 0.00001
	min_c = 0.00001

--	input values
	details = math.max(get_slider_input(DETAILS), 0.000011)
	details = details + (details * 25)
	noise_size = get_slider_input(SCALE)
	set_perlin_noise_seed(get_intslider_input(SEED))
end;

function get_sample(x, y)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION)
	local d_avg = (dx + dy + dz + da) * 0.25
	dx, dy = dx * 2 - 1, dy * 2 - 1
	roughness = math.max(get_sample_grayscale(x, y, ROUGHNESS), 0.000011)
	roughness = roughness + (roughness * 0.5)
	-- roughness = math.max(get_sample_grayscale(x, y, ROUGHNESS) + 0.25, 0.000011)
	local v = get_perlin_octaves(x, y, 1, 1)
	v = ((v * 2 - 1) * v) * d_avg
	dx, dy = (v + (dx * da)) * d_avg, (v + (dy * da)) * d_avg
	r, g, b, a = get_sample_map(x + dx, y + dy, SOURCE)
	return r, g, b, a
--	return v, v, v, 1
end;

function get_perlin_octaves(x, y, z, channel)
	local v, x, y, z, channel = 0, x, y, z, channel
	octaves_n = math.floor(details)
	local remainder = details - octaves_n
	if (remainder > min_c) then
		octaves_n = octaves_n + 1
	end
	octaves = {}
	local cell_size = (0.00001 + (noise_size * 0.99999))
	cell_size = cell_size + (cell_size * 1000)
	local scale = roughness
	local octave_index
	for octave_index = 1, octaves_n do
		if (scale < rough_c) then
			octaves_n = octave_index - 1
			break
		end
		octaves[octave_index] = {cell_size, scale}
		cell_size = cell_size * 0.5
		scale = scale * roughness
	end
	
	if (remainder >= 0.001) then
		octaves[octaves_n][2] = octaves[octaves_n][2] * remainder
	end

	norm = 0
	for octave_index = 1, octaves_n do
		norm = norm + octaves[octave_index][2] ^ 2
	end
	norm = 1 / math.sqrt(norm)

	local octave_index 
	for octave_index = 1, octaves_n do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		v = v + opacity * (2 * get_perlin_noise(x, y, octave_index, size) - 1)
	end
	v = (v * norm + amp_c) * (0.5 / amp_c)
	return v
end;