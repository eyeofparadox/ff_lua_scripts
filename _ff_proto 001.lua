-- perlin noise - get_perlin_octaves(x, y, z, channel) v.0.1.2
function prepare()
	-- v.001 planned revision
--	constants
	amp_c = 1.731628995
	rough_c = 0.00001
	min_c = 0.00001

--	input values
	details = math.max(get_slider_input(DETAILS), 0.000011)
	details = details + (details * 25)
	noise_size = get_slider_input(SCALE)
	roughness = math.max(get_slider_input(ROUGHNESS), 0.000011)
	roughness = roughness + (roughness * 0.5)
	contrast = get_slider_input(CONTRAST)
	contrast = contrast + (contrast * 2) - 1
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seed(get_intslider_input(SEED))
	set_perlin_noise_seed(get_intslider_input(SEED))
	if (get_checkbox_input(BOUNDLESS)) then
		boundless = true
		set_perlin_noise_seamless(false)
	else
		boundless = false
	end
	if (get_checkbox_input(TWO_ONE)) then
		two_one = true
		set_perlin_noise_seamless_region(aspect, aspect)
	else
		two_one = false
	end
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
	if (get_checkbox_input(SPHERICAL)) then
		spherical = true
	else
		spherical = false
	end
end;

function get_sample(x, y)
	local r1, g1, b1, a1 = get_sample_map(nx, ny, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(nx, ny, FOREGROUND)
	roughness = math.max(get_sample_grayscale(nx, ny, ROUGHNESS), 0.000011)
	roughness = roughness + (roughness * 0.5)
	local contrast = get_sample_grayscale(nx, ny, CONTRAST)
	contrast = contrast + (contrast * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))

	local vr, vg, vb, va = 
		get_perlin_octaves((nx + osx) + dx, (ny + osy) + dy, (nz + osz) + dz, 1), 
		get_perlin_octaves((nx + osx) + dx, (ny + osy) + dy, (nz + osz) + dz, 2), 
		get_perlin_octaves((nx + osx) + dx, (ny + osy) + dy, (nz + osz) + dz, 3)
		get_perlin_octaves((nx + osx) + dx, (ny + osy) + dy, (nz + osz) + dz, 0)
	
	vr = get_sample_curve(nx, ny, vr, PROFILE)
	vg = get_sample_curve(nx, ny, vg, PROFILE)
	vb = get_sample_curve(nx, ny, vb, PROFILE)
	va = get_sample_curve(nx, ny, va, PROFILE)
	
	if not hdr then
		vr  = truncate(factor * (vr - 0.5) + 0.5)
		vg  = truncate(factor * (vg - 0.5) + 0.5)
		vb  = truncate(factor * (vb - 0.5) + 0.5)
		va = truncate(factor * (va - 0.5) + 0.5)
	end

	va = 1 - (1 - opacity) + (va * opacity)

	r, g, b, a = blend_normal(r1, g1, b1, a1, r2, g2, b2, a2, va, hdr)
	-- return v, v, v, 1
	return vr, vg, vb, va
	-- return dx, dy, dz, da
	-- return nx, ny, nz, 1
	-- return r1, g1, b1, a1
	-- return r2, g2, b2, a2
	return r, g, b, a
end;

function get_perlin_octaves(x, y, z, channel)
	local v, x, y, z, channel = 0, x, y, z, channel

	local cx, cy = 0, 0
	if channel == 0 then
		cx = x
		cy = y
	elseif channel == 1 then
		cx = x + 0.25
		cy = y - 0.65
	elseif channel == 2 then
		cx = y + 0.5
		cy = 1 - (x - 0.5)
	elseif channel == 3 then
		cx = 1 - (x + 0.75)
		cy = 1 - (y - 0.35)
	end;

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
		alpha = alpha + opacity * (2 * get_perlin_noise(cx, cy, octave_index, size) - 1)
	end
	v = (v * norm + amp_c) * (0.5 / amp_c)
	return v
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;