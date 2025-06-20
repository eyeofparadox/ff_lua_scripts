function prepare()
--	v.002
--	constants
	AMPLITUDE_CORRECTION_FACTOR = 1.731628995
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seamless(SEAMLESS)
	set_perlin_noise_seamless_region(SEAMLESS_REGION_WIDTH, SEAMLESS_REGION_HEIGHT)

--	input values
	details = get_slider_input(DETAILS) * 10 + 1
	OCTAVES_COUNT = math.floor(details)
	NOISE_SIZE = get_slider_input(SCALE)
	set_perlin_noise_seed(get_intslider_input(NOISE_VARIATION))
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local noise_r, noise_g, noise_b, noise_a = get_sample_map(x, y, NOISE)

	local remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
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

	-- insert spheremapping calculations
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) -- * scale + vosx
	local ny = math.sin(x) * math.sin(y) -- * scale + vosy
	-- local nz = math.cos(y) * math.pi -- * scale + vosz
	local alpha = 0
	
	for octave_index = 1, OCTAVES_COUNT do
		-- this minimizes stretching the most, still has artifacts
		local nz = octave_index * math.cos(y) * math.pi
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		-- local d1 = get_perlin_noise(nx+1,ny,nz,size) -- * distortion
		-- local d2 = get_perlin_noise(nx+2,ny,nz,size) -- * distortion
		-- local d3 = get_perlin_noise(nx+3,ny,nz,size) -- * distortion
		-- local noise_z = octave_index
		-- -- insert spheremapped x,y,z coordinates
		--  -- produces stretching along equator
		alpha = alpha + opacity * (2 * get_perlin_noise(nx,ny,nz,size) - 1)
		-- alpha = alpha + opacity * (2 * get_perlin_noise(nx+d1,ny+d2,nz+d3,size) - 1)
	end
	
	alpha = (alpha * NORM_FACTOR + AMPLITUDE_CORRECTION_FACTOR) * 
		(0.5 / AMPLITUDE_CORRECTION_FACTOR)
	local alpha = truncate(factor * (alpha - 0.5) + 0.5)
	
	return blend_normal(r, g, b, a, noise_r, noise_g, noise_b, noise_a, alpha)
	-- return size,size,size,1
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;