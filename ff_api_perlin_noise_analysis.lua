function prepare()
--	Constants
	AMPLITUDE_CORRECTION_FACTOR = 1.731628995
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001

--	Input values
	local details = get_slider_input(DETAILS) * 10 + 1
	-- slider controlled, so no conflict with having it in prepare() 
	-- note that OCTAVES_COUNT depends on this 
	OCTAVES_COUNT = math.floor(details)
	-- assuming the slider gives a value from 0 to 1, wouldn't this zero out?
	-- logic suggests this value is from 0 to 1oo
	-- called from prepare() and get_sample() 
	NOISE_SIZE = get_slider_input(SCALE)
	-- not sure why this is in all caps; either means it's a constant or an API Variable
	local remainder = details - OCTAVES_COUNT
	-- sets up control for conditional logic of octave_index loop
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	local roughness = ROUGHNESS_THRESHOLD + 
		get_slider_input(ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
		-- replacing this with a grayscale input poses a problem, given the role this variable plays in precalculations
	
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

	set_perlin_noise_seed(get_intslider_input(NOISE_VARIATION))
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local noise_r, noise_g, noise_b, noise_a = get_sample_map(x, y, NOISE)

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
	
	return blend_normal(r, g, b, a, noise_r, noise_g, noise_b, noise_a, alpha)
end;