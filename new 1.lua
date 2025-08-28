-- v.002.8.2

function prepare()
	--Constants
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

	-- Value  inputs
	details = get_intslider_input(DETAILS) * 0.5
	seed = get_intslider_input(SEED)

	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	-- Map inputs
	local fr, fg, fb, fa = get_sample_map(x, y, FOREGROUND)
	local br, bg, bb, ba = get_sample_map(x, y, BACKGROUND)
	roughness = math.max(3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 4.375, 0.01)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	
	sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	ox, oy, oz, oa = get_sample_map(x, y, OFFSET)
	dx, dy, dz, da = get_sample_map(x, y, DISTORTION) 

	sx, sy, sz, sa = sx * 1.25, sy * 1.25, sz * 1.25, sa * 1.25
	
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) * (sx * sa) + (ox * oa)
	local ny = math.sin(x) * math.sin(y) * (sy * sa) + (oy * oa)
	local nz = math.cos(y) * (sz * sa) + (oz * oa)

	-- Call perlin noise with x,y,z and seed offsets for channels
	local v = get_perlin_octaves(nx, ny, nz, 0)
	local r = get_perlin_octaves(nx, ny, nz, 100)
	local g = get_perlin_octaves(nx, ny, nz, 200)
	local b = get_perlin_octaves(nx, ny, nz, 300)

	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	v  = truncate(factor * (v - 0.5) + 0.5)
	r  = truncate(factor * (r - 0.5) + 0.5)
	g  = truncate(factor * (g - 0.5) + 0.5)
	b  = truncate(factor * (b - 0.5) + 0.5)

	v = get_sample_curve(x, y, v, PROFILE)
	r = get_sample_curve(x, y, r, PROFILE)
	g = get_sample_curve(x, y, g, PROFILE)
	b = get_sample_curve(x, y, b, PROFILE)

	return blend_normal(br, bg, bb, ba, fr, fg, fb, fa, v, hdr)
	-- return dx, dy, dz, da
	-- return r, g, b, a
end;

function get_perlin_octaves(x, y, z, offset)
	local offset_seed = seed + offset
	local s = 500
	local amp = 1

	for oct = 1, details do
		-- Adjust seeds for each distortion channel
		set_perlin_noise_seed(offset_seed + 100)
		local d1 = get_perlin_noise(x, y, z, s) * (dx * da)
		
		set_perlin_noise_seed(offset_seed + 200)
		local d2 = get_perlin_noise(x, y, z, s) * (dy * da)
		
		set_perlin_noise_seed(offset_seed + 300)
		local d3 = get_perlin_noise(x, y, z, s) * (dz * da)
		
		set_perlin_noise_seed(offset_seed)
		if oct == 1 then v = get_perlin_noise(x+d1, y+d2, z+d3, s) else
			v = (v + get_perlin_noise(x+d1/oct, y+d2/oct, z+d3/oct, s) * amp ) / (1 + amp)
		end
		
		z = z * 2
		s = s / 2
		amp = amp / roughness
	end
	
	return v
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;