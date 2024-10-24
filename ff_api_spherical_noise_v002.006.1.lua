function prepare()
	-- v.002.6.1
	detail = get_intslider_input(DETAIL)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seed(get_intslider_input(NOISE_SEED))
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local roughness = 3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local v = 0
	local vosx = get_sample_grayscale(x, y, OFFSET_X)
	local vosy = get_sample_grayscale(x, y, OFFSET_Y)
	local vosz = get_sample_grayscale(x, y, OFFSET_Z)
	local distortion = get_sample_grayscale(x, y, DISTORTION) * 2
	local scale = get_sample_grayscale(x, y, SCALE)
	local s = 500
	local amp = 1
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) * scale + vosx
	local ny = math.sin(x) * math.sin(y) * scale + vosy
	local nz = math.cos(y) * scale + vosz
	for oct = 1, detail do
		local d1 = get_perlin_noise(nx+1,ny,nz,s) * distortion
		local d2 = get_perlin_noise(nx+2,ny,nz,s) * distortion
		local d3 = get_perlin_noise(nx+3,ny,nz,s) * distortion
		if oct == 1 then v = get_perlin_noise(nx+d1,ny+d2,nz+d3,s) else
			v = (v + get_perlin_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,s) * amp ) / (1 + amp)
		end
		nz = nz * 2
		s = s / 2
		amp = amp / roughness
	end
	v  = truncate(factor * (v - 0.5) + 0.5)
	v = get_sample_curve(x,y,v,PROFILE)
	local opacity = v
	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
	return r, g, b, a
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;