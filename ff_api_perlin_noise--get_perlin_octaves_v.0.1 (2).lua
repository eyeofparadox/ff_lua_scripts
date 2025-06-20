-- perlin noise - get_perlin_octaves(x, y, z,channel) v.0.1
function prepare()
--	constants
	amp_c = 1.731628995
	rough_c = 0.00001
	min_c = 0.00001

--	input values
	details = get_slider_input(DETAILS) * 25
	noise_size = get_slider_input(SCALE)
	roughness = rough_c + 
		(get_slider_input(ROUGHNESS) + 0.25) * (1.0 - rough_c)
	set_perlin_noise_seed(get_intslider_input(SEED))
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local noise_r, noise_g, noise_b, noise_a = get_sample_map(x, y, NOISE)
	 local z = 0

	local alpha = get_perlin_octaves(x, y, z, 1)
	
	r, g, b, a = blend_normal(r, g, b, a, noise_r, noise_g, noise_b, noise_a, alpha)
	return  r, g, b, a 
end;

function get_perlin_octaves(x, y, z,channel)
	octaves_n = math.floor(details)
	local remainder = details - octaves_n
	if (remainder > min_c) then
		octaves_n = octaves_n + 1
	end
	octaves = {}
	local cell_size = (0.01 + noise_size * 0.99) * 1000
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

	local alpha = 0
	local octave_index 
	for octave_index = 1, octaves_n do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		z = octave_index
		alpha = alpha + opacity * (2 * get_perlin_noise(x, y, z, size) - 1)
	end
	alpha = (alpha * norm + amp_c) * 
		(0.5 / amp_c)
	return alpha
end;

