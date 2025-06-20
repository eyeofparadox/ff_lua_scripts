function prepare()
	-- v.002.7.c
	details = get_intslider_input(DETAILS)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seed(get_intslider_input(SEED))
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
	if (get_checkbox_input(RGBN)) then
		rgb = true
	else
		rgb = false
	end
	if (get_checkbox_input(ALPHA)) then
		an = true
	else
		an = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local roughness = 3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local v = 0
	local osx, osy,  osz, osa = get_sample_map(x, y, OFFSET)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION) -- * 2
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	local s = 500
	local amp = 1
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) * (sx * sa) + osx
	local ny = math.sin(x) * math.sin(y) * (sy * sa) + osy
	local nz = math.cos(y) * (sz * sa) + osz
	for oct = 1, details do
		local d1 = get_perlin_noise(nx+1,ny,nz,s) * (dx * da)
		local d2 = get_perlin_noise(nx+2,ny,nz,s) * (dy * da)
		local d3 = get_perlin_noise(nx+3,ny,nz,s) * (dz * da)
		if oct == 1 then 
			v = get_perlin_noise(nx+d1,ny+d2,nz+d3,s) 
			pr = get_perlin_noise(nx+d1+0.25,ny+d2,nz+d3,s) 
			pg = get_perlin_noise(nx+d1,ny+d2+0.5,nz+d3,s) 
			pb = get_perlin_noise(nx+d1,ny+d2,nz+d3+0.75,s) 
		else
			v = (v + get_perlin_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,s) * amp ) / (1 + amp)
			pr = (pr + get_perlin_noise(nx+d1+0.25/oct,ny+d2/oct,nz+d3/oct,s) * amp ) / (1 + amp)
			pg = (pg + get_perlin_noise(nx+d1/oct,ny+d2+0.5/oct,nz+d3/oct,s) * amp ) / (1 + amp)
			pb = (pb + get_perlin_noise(nx+d1/oct,ny+d2/oct,nz+d3+0.75/oct,s) * amp ) / (1 + amp)
		end
		nz = nz * 2
		s = s / 2
		amp = amp / roughness
	end
	v  = truncate(factor * (v - 0.5) + 0.5)
	pr  = truncate(factor * (pr - 0.5) + 0.5)
	pg  = truncate(factor * (pg - 0.5) + 0.5)
	pb  = truncate(factor * (pb - 0.5) + 0.5)
	v = get_sample_curve(x,y,v,PROFILE)
	pr = get_sample_curve(x,y,pr,PROFILE)
	pg = get_sample_curve(x,y,pg,PROFILE)
	pb = get_sample_curve(x,y,pb,PROFILE)
	local opacity = v
	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
--	return dx, dy, dz, da
	if rgb then
		if an then
			return pr, pg, pb, v
		end
		return pr, pg, pb, a
	else
		if an then
			return r, g, b, v
		end
		return r, g, b, a
	end
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;