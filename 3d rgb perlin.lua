-- 3d rgb perlin
function prepare()
	-- v.002.7.a
	details = get_intslider_input(DETAILS)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seed(get_intslider_input(SEED))
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	roughness = 3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local v = 0
	local osx, osy,  osz, osa = get_sample_map(x, y, OFFSET)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION) -- * 2
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	local s = 500
	amp = 1
	local x = x * aspect * math.pi
	local y = y * math.pi
	local z = (x + y) / 2 + math.pi
	local nx = math.cos(x) * math.sin(y) * (sx * sa) + (osx * osa)
	local ny = math.sin(x) * math.sin(y) * (sy * sa) + (osy * osa)
	local nz = math.cos(y) * (sz * sa) + (osz * osa)
	local r = get_perlin_octaves(x,y,z,dx,dy,dz,da,1,s)
	local g = get_perlin_octaves(x,y,z,dx,dy,dz,da,2,s) 
	local b = get_perlin_octaves(x,y,z,dx,dy,dz,da,3,s)
	local a = 1
	
	r  = truncate(factor * (r - 0.5) + 0.5)
	g  = truncate(factor * (g - 0.5) + 0.5)
	b  = truncate(factor * (b - 0.5) + 0.5)
	v  = truncate(factor * (v - 0.5) + 0.5)
	v = get_sample_curve(x,y,v,PROFILE)
	local opacity = v
--	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
--	return dx, dy, dz, da
	return r, g, b, a
end;

function get_perlin_octaves(x,y,z,dx,dy,dz,da,channel,s)
	nx = 0
	ny = 0
	nz = 0
	if channel == 1 then
		nx = x
		ny = y
		nz = z
	elseif channel == 2 then
		nx = x + 0.65 -- + (OUTPUT_WIDTH * 0.65)
		ny = y + 0.35 -- + (OUTPUT_HEIGHT * 0.35)
		nz = z + 1
	elseif channel == 3 then
		nx = x + 0.35 -- + (OUTPUT_WIDTH * 0.35)
		ny = y + 0.65 -- + (OUTPUT_HEIGHT * 0.65)
		nz = z + 2
	end;
	for oct = 1, details do
		local d1 = get_perlin_noise(x+1,y,nz,s) * (dx * da)
		local d2 = get_perlin_noise(x+2,y,nz,s) * (dy * da)
		local d3 = get_perlin_noise(x+3,y,nz,s) * (dz * da)
		if oct == 1 then v = get_perlin_noise(nx+d1,ny+d2,nz+d3,s) else
			v = (v + get_perlin_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,s) * amp ) / (1 + amp)
		end
		nz = nz * 2
		s = s / 2
		amp = amp / roughness
	end
	return channel
end;
	
	function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;