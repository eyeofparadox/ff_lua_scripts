function prepare()
	oct_max = get_intslider_input(NOISE_OCTAVES)
--	detail = 4 - get_slider_input(NOISE_DETAIL) * 2 + 0.01 -- mapped alternate
--	scale = get_slider_input(NOISE_SCALE) * 10 + 1 -- mapped alternate
	distort = get_slider_input(NOISE_DISTORT) * 2
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seed(get_intslider_input(NOISE_SEED))
end;

function get_sample(x, y)
	local v = 0
	local scale = get_sample_grayscale(x, y, SCALE) -- * 10 + 1 -- unsuitable range
	local vosx = get_sample_grayscale(x, y, OFFSET_X)
	local vosy = get_sample_grayscale(x, y, OFFSET_Y)
	local vosz = get_sample_grayscale(x, y, OFFSET_Z)
   local detail = 3.75 - get_sample_grayscale(x, y, DETAIL) * 2 + 0.01
	local s = 500
	local amp = 1
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) * scale + vosx
	local ny = math.sin(x) * math.sin(y) * scale + vosy
	local nz = math.cos(y) * scale + vosz
	for oct = 1, oct_max do
		local d1 = get_perlin_noise(nx+1,ny,nz,s) * distort
		local d2 = get_perlin_noise(nx+2,ny,nz,s) * distort
		local d3 = get_perlin_noise(nx+3,ny,nz,s) * distort
		if oct == 1 then v = get_perlin_noise(nx+d1,ny+d2,nz+d3,s) else
			v = (v + get_perlin_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,s) * amp ) / (1 + amp)
		end
		nz = nz * 2
		s = s / 2
		amp = amp / detail
	end
	v = get_sample_curve(x,y,v,NOISE_PROFILE)
	return v,v,v,1
end;