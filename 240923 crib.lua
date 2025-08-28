

-- perlin noise - get_perlin_octaves(x, y, z, channel) v.1 ~ 20240923
function prepare()
-- constants
	AMPLITUDE_CORRECTION_FACTOR = 1.731628995
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
		set_perlin_noise_seamless(true)
		set_perlin_noise_seamless_region(aspect, 1)
	else aspect = 1
	end

-- input values
	details = get_slider_input(DETAILS) * 10 + 1
	NOISE_SIZE = get_slider_input(SCALE)
	if (get_checkbox_input(MODE)) then
		mode = true
	else
		mode = false
	end
	set_perlin_noise_seed(get_intslider_input(NOISE_VARIATION))
end;

function get_sample(x, y)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local r1, g1, b1, a1 = get_sample_map(x, y, BACKGROUND)
	local x = x * aspect
	roughness = ROUGHNESS_THRESHOLD + get_sample_grayscale(x, y, ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))

	local alpha = get_perlin_octaves(x,y,0)
	local r = get_perlin_octaves(x,y,1)
	local g = get_perlin_octaves(x,y,2) 
	local b = get_perlin_octaves(x,y,3)
	local a = 1
	
	alpha  = truncate(factor * (alpha - 0.5) + 0.5)
	r  = truncate(factor * (r - 0.5) + 0.5)
	g  = truncate(factor * (g - 0.5) + 0.5)
	b  = truncate(factor * (b - 0.5) + 0.5)
	
	alpha = get_sample_curve(x, y, alpha, PROFILE)
	r = get_sample_curve(x, y, r, PROFILE)
	g = get_sample_curve(x, y, g, PROFILE)
	b = get_sample_curve(x, y, b, PROFILE)
	
	if mode then
		return r, g, b, a
	else
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1 , alpha, true)
		return r, g, b, a
	end
end;

function get_perlin_octaves(x,y,channel)
	cx = x
	cy = y
	local alpha = 0
	local octave_index 

	if channel == 0 then
		z_off = 0
	elseif channel == 1 then
		z_off = 1
	elseif channel == 2 then
		z_off = 2
	elseif channel == 3 then
		z_off = 3
	end;

-- perlin octaves
	OCTAVES_COUNT = math.floor(details)
	local remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
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

	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		local oi = octave_index + z_off -- + channel offset
		alpha = alpha + opacity * (2 * get_perlin_noise(cx, cy, oi, size) - 1)
	end
	alpha = (alpha * NORM_FACTOR + AMPLITUDE_CORRECTION_FACTOR) * 
		(0.5 / AMPLITUDE_CORRECTION_FACTOR)
	return alpha
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;


function prepare()
	pi, cos, sin = math.pi, math.cos, math.sin
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	if (get_checkbox_input(MODE)) then
		mode = true
	else
		mode = false
	end
	if (get_checkbox_input(USE_RGB)) then
		use_rgb = true
	else
		use_rgb = false
	end
end;

function get_sample(x, y)
	local r2, g2, b2, a2 = get_sample_map(x, y, SOURCE)
	local inv, r, g = y, 0, 0
	local x = x * aspect * pi
	local y = y * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y) 
	local nz = cos(y)
	if inv > 0.5 then
		r = 1 - (nx * 0.5 + 0.5)
		g = 1 - (ny * 0.5 + 0.5)
	else
		r = nx * 0.5 + 0.5
		g = ny * 0.5 + 0.5
	end
	local b = sin(y)
	if use_rgb then 
		if mode then 
			return r, g, b, a
		else
			r1, g1, b1, a1 = get_sample_map(r, g, SOURCE)
			r0, g0, b0, a0 = blend_normal(r1, r1, r1, a1, g1, g1, g1, a1, y, true)
			r, g, b, a = blend_normal(r0, g0, b0, a0, b2, b2, b2, a2, b, true)
			return r, g, b, a
		end
	else
		if mode then 
			return r, g, b, a
		else
			r1, g1, b1, a1 = get_sample_map(r, g, SOURCE)
			r2, g2, b2, a2 = blend_difference(r2, g2, b2, a2, 1, 1, 1, 1, 1, true)
			r, g, b, a = blend_normal(r1, g1, b1, a1, r2, g2, b2, a2, b, true)
			return r, g, b, a
		end
	end
end;


--[[ 
prepare()
--	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
--		aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
--	end
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seamless(true)
	set_perlin_noise_seamless_region(aspect, 1)
get_sample(x, y)
	local x = x * aspect
	roughness = ROUGHNESS_THRESHOLD + get_sample_grayscale(x, y, ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	-- 
	v = get_perlin_octaves((nx + osx) + dx, (ny+ osy) + dy, (nz+ osz) + dz, 1)
-- ]]


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

	for octave_index = 1, octaves_n do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		v = v + opacity * (2 * get_perlin_noise(x, y, octave_index, size) - 1)
	end
	v = (v * norm + amp_c) * (0.5 / amp_c)
	return v
end;

