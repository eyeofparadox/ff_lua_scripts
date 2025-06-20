function prepare()
	--Constants
	amplitude_correction_factor = 1.731628995
	roughness_threshold = 0.000000001
	remainder_threshold = 0.000000001
   aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

	-- Input values
	roughness = get_slider_input(ROUGHNESS)
	roughness = map(roughness, 0, 100, 0, 105)
	details = get_intslider_input(DETAILS)
	noise_size = get_intslider_input(SCALE) * 3
	noise_size = mapToExpScale(noise_size, 1, 900, 6)
	seed = get_intslider_input(NOISE_VARIATION)

	-- Will need to add selector to switch output for alpha, r, g, b (blend masking), rgb (generation)
end

function get_sample(x, y) -- debugging base noise, certain parts commented out temporarily
	-- local br, bg, bb, ba = get_sample_map(x, y, BACKGROUND) 
	-- local fr, fg, fb, fa = get_sample_map(x, y, FOREGROUND)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))

   -- Trigonometric remapping for east-west and north-south seamlessness
    local longitude = x * aspect * math.pi
    local latitude = (y - 0.5) * math.pi
    local nx = math.cos(latitude) * math.cos(longitude) -- * (sx * sa) + (ox * oa)
    local ny = math.cos(latitude) * math.sin(longitude) -- * (sy * sa) + (oy * oa)
    local nz = math.sin(latitude) -- * (sz * sa) + (oz * oa)

	-- added multiple seeds for channels
	set_perlin_noise_seed(seed)
	local alpha = get_perlin_octaves(nx,ny,nz)

	set_perlin_noise_seed(seed+100)
	local r = get_perlin_octaves(nx,ny,nz)
	
	set_perlin_noise_seed(seed+200)
	local g = get_perlin_octaves(nx,ny,nz)
	
	set_perlin_noise_seed(seed+300)
	local b = get_perlin_octaves(nx,ny,nz)
	local a = 1 -- alpha
	
	r  = truncate(factor * (r - 0.5) + 0.5)
	g  = truncate(factor * (g - 0.5) + 0.5)
	b  = truncate(factor * (b - 0.5) + 0.5)

	-- debugging by channel
	-- return blend_normal(br, bg, bb, ba, fr, fg, fb, fa, a)
	-- return a, a, a, a
	-- return r, r, r, a
	-- return g, g, g, a
	-- return b, b, b, a
	return r, g, b, a
end

To illustrate, I have this function to add a z-dimension as a generic function. I would be able to pass the functions thet need to access that space to operate. I.e. `get_perlin_noise` and `get_perlin_octaves`.

function sample_z(x,y,function) -- use: `z = sample_z(x,y)` for `noise_value = get_perlin_noise(x,y,z)`
	-- when creating 3D noise a virtual z-dimension needs to be available
	z = 0
	z_max = math.min(OUTPUT_WIDTH,OUTPUT_HEIGHT)
	for x = 0, OUTPUT_WIDTH do
		for y = 0, OUTPUT_HEIGHT do
			for z = 0, z_max do
				-- arbitrary function here
					z = z + 1
				return z
			end
		end
	end
end

function get_perlin_octaves(x,y,z) -- updated function, only inputs remain in prepare()
	octaves_count = math.floor(details)
	local remainder = details - octaves_count
	if (remainder > remainder_threshold) then
		octaves_count = octaves_count + 1
	end

	 -- artifacts removed from roughness
	roughness = roughness_threshold + roughness * (1.0 - roughness_threshold)
	
	octaves = {}
	-- removeded unnecessary noise_size adjustments
	local cell_size = noise_size
	local scale = roughness
	local octave_index
	for octave_index = 1, octaves_count do
		if (scale < roughness_threshold) then
			octaves_count = octave_index - 1
			break
		end
		octaves[octave_index] = {cell_size, scale}
		cell_size = cell_size * 0.5
		scale = scale * roughness
	end
	
	if (remainder >= 0.001) then
		octaves[octaves_count][2] = octaves[octaves_count][2] * remainder
	end

	norm_factor = 0
	for octave_index = 1, octaves_count do
		norm_factor = norm_factor + octaves[octave_index][2] ^ 2
	end
	norm_factor = 1 / math.sqrt(norm_factor)

	local alpha = 0
	local octave_index 
	for octave_index = 1, octaves_count do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		if z == nil then
		    z = octave_index
		else
		    z = z -- + octave_index
		end
		alpha = alpha + opacity * (2 * get_perlin_noise(x, y, z, size) - 1)
	end
	alpha = (alpha * norm_factor + amplitude_correction_factor) * 
		(0.5 / amplitude_correction_factor)
	return alpha
end

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end

-- Map functions
function map(value, start1, stop1, start2, stop2)
    -- Avoid division by zero
    if stop1 - start1 == 0 then
        return start2
    else
        return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
    end
end

function mapToLogScale(value, min, max)
    -- Ensure the value is within the slider range
    if value < min then value = min end
    if value > max then value = max end

    -- Normalize the value to range [0, 1]
    local normalized = (value - min) / (max - min)

    -- Apply logarithmic scaling
    local logScale = math.log(normalized + 1) / math.log(12)  -- Base-2 logarithm

    -- Map back to desired scale (if needed)
    local mappedValue = min + logScale * (max - min)

    return mappedValue
end

function mapToExpScale(value, min, max, exponent)
    -- Ensure the value is within the slider range
    if value < min then value = min end
    if value > max then value = max end

    -- Normalize the value to range [0, 1]
    local normalized = (value - min) / (max - min)

    -- Apply exponential scaling with a custom exponent
    local expScale = (normalized ^ exponent)

    -- Map back to desired scale (if needed)
    local mappedValue = min + expScale * (max - min)

    return mappedValue
end