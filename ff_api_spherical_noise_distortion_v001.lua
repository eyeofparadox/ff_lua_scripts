function prepare()
	oct_max = get_intslider_input(NOISE_OCTAVES)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seed(get_intslider_input(NOISE_SEED))
end;

function get_sample(x, y)
	local v = 0
	local scale = get_sample_grayscale(x, y, SCALE)
	local vosx = get_sample_grayscale(x, y, OFFSET_X)
	local vosy = get_sample_grayscale(x, y, OFFSET_Y)
	local vosz = get_sample_grayscale(x, y, OFFSET_Z)
	local detail = 3.75 - get_sample_grayscale(x, y, DETAIL) * 2 + 0.01
	local distortion = get_sample_grayscale(x, y, DISTORTION) * 2
	local s = 500
	local amp = 1
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) * scale + vosx
	local ny = math.sin(x) * math.sin(y) * scale + vosy
	local nz = math.cos(y) * scale + vosz
	for oct = 1, oct_max do
		local d1 = get_perlin_noise(nx+1,ny,nz,s) * distortion
		local d2 = get_perlin_noise(nx+2,ny,nz,s) * distortion
		local d3 = get_perlin_noise(nx+3,ny,nz,s) * distortion
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

-- [Some thoughts on this, the goal is to distort the source vertically and horizontally, in the plane of x,y, using spherically mapped noise. I believe I can exploit the z coordinate to add a divergence factor (+/-1) that can be adjusted via grayscale (for HDR range). That would change the application of distortion somehow, so I'm not sure if it can remain a multiplier of d1,d2,d3 the way it is now. I have to reexamine my distortion example to see the correct implementation. I do know that I want the divergence to be split positive and negative, so I need to subtract .5 (giving me a range of -.5/.5), possibly * 2 for a -1/1 range. Or handle it in the distortion map with HDR values. Of course, the point of this script is to emulate Noise Distortion, which has two perlin noises embedded. I'm making this to do the same with spherically mapped internal noise.]

--[On further consideration, an x,y distortion applied to spherically mapped noise would break seamlessness. What I'm thinking of can be done externally with a remapped Threshold, for the +/- value distortions. The divergence factor still seems interesting, though I'm not sure how that should apply to the current method.]