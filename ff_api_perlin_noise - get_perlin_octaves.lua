-- perlin noise - get_perlin_octaves(x,y,z,channel)
function prepare()
--	constants
	AMPLITUDE_CORRECTION_FACTOR = 1.731628995
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001

--	input values
	local details = get_slider_input(DETAILS) * 25
	OCTAVES_COUNT = math.floor(details)
	NOISE_SIZE = get_slider_input(SCALE)
	local remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	local roughness = ROUGHNESS_THRESHOLD + 
		(get_slider_input(ROUGHNESS) + 0.25) * (1.0 - ROUGHNESS_THRESHOLD)
	
	OCTAVES = {}
	local cell_size = (0.01 + NOISE_SIZE * 0.99) * 1000
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
	-- local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	-- local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	 local z = (x + y) / 2

	-- local r = get_perlin_octaves(x,y,z,1)
	-- local g = get_perlin_octaves(x,y,z,2) 
	-- local b = get_perlin_octaves(x,y,z,3)
	local alpha = get_perlin_octaves(x,y,z)
	
	-- r = truncate(factor * (r - 0.5) + 0.5)
	-- g = truncate(factor * (g - 0.5) + 0.5)
	-- b = truncate(factor * (b - 0.5) + 0.5)
	-- alpha = truncate(factor * (alpha - 0.5) + 0.5)
	-- return r, g, b, a
	-- return v
	r, g, b, a = blend_normal(r, g, b, a, noise_r, noise_g, noise_b, noise_a, alpha)
	return  r, g, b, a 
end;

function get_perlin_octaves(x,y,z,channel)
	local cx = 0
	local cy = 0
	local cz = 0
	if channel == 1 then
		cx = x
		cy = y
		cz = z
	elseif channel == 2 then
		cx = x+(OUTPUT_WIDTH*0.65)
		cy = y+(OUTPUT_HEIGHT*0.35)
		cz = z+(OUTPUT_WIDTH*0.25)
	elseif channel == 3 then
		cx = x+(OUTPUT_WIDTH*0.35)
		cy = y+(OUTPUT_HEIGHT*0.65)
		cz = z+(OUTPUT_WIDTH*0.5)
	else
		cx = x+(OUTPUT_WIDTH*0.5)
		cy = y+(OUTPUT_HEIGHT*0.5)
		cz = z+(OUTPUT_WIDTH*0.75)
	end;
	local alpha = 0
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		alpha = alpha + opacity * (2*get_perlin_noise(cx, cy, cz, size) - 1)
	end
	alpha = (alpha * NORM_FACTOR + AMPLITUDE_CORRECTION_FACTOR) * 
		(0.5 / AMPLITUDE_CORRECTION_FACTOR)
	return alpha
end;

-- function truncate(value)
	-- if value <= 0 then value = 0 end
	-- if value >= 1 then value = 1 end
	-- return value
-- end;