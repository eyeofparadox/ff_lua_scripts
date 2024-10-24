function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
--	Constants
	AMPLITUDE_CORRECTION_FACTOR = 1.731628995
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001

--	Input values
	details = get_slider_input(DETAILS) * 10 + 1
	OCTAVES_COUNT = math.floor(details)
	NOISE_SIZE = get_slider_input(SCALE)
	remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	set_perlin_noise_seed(get_intslider_input(NOISE_VARIATION))
end;

function get_sample(x, y)
	local roughness = ROUGHNESS_THRESHOLD + 
		get_sample_grayscale(x, y, ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	
	OCTAVES = {}
	local cell_size = (0.01 + NOISE_SIZE * 0.99) * 150
	local scale = roughness
	local octave_index
	for octave_index = 1, OCTAVES_COUNT do
		if (scale < ROUGHNESS_THRESHOLD) then
			OCTAVES_COUNT = octave_index - 1
			break
		end
		OCTAVES[octave_index] = {cell_size, scale}
		cell_size = cell_size * 0.5
		scale = scale * roughness
	end
	
	if (remainder >= 0.001) then
		OCTAVES[OCTAVES_COUNT][2] = OCTAVES[OCTAVES_COUNT][2] * remainder
	end

	NORM_FACTOR = 0
	for octave_index = 1, OCTAVES_COUNT do
		NORM_FACTOR = NORM_FACTOR + OCTAVES[octave_index][2] ^ 2
	end
	NORM_FACTOR = 1 / math.sqrt(NORM_FACTOR)

	local x = x * aspect
	local br, bg, bb, ba = get_sample_map(x, y, BACKGROUND)
	local nr, ng, nb, na = get_sample_map(x, y, NOISE)

	local alpha = 0
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		local noise_z = octave_index
		alpha = alpha + opacity * (2*get_perlin_noise(x, y, noise_z, size) - 1)
	end
	
	alpha = (alpha * NORM_FACTOR + AMPLITUDE_CORRECTION_FACTOR) * 
		(0.5 / AMPLITUDE_CORRECTION_FACTOR)
	alpha  = truncate(factor * (alpha - 0.5) + 0.5)
	
	return blend_normal(br, bg, bb, ba, nr, ng, nb, na, alpha)
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;