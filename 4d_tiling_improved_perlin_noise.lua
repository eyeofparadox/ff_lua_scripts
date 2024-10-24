--4D Improved Perlin Noise
-- openai codex: write lua script to generate 4d tiling improved perlin noise (does not begin to work)

function prepare()
	--Generate 4D Perlin Noise
	math.randomseed(get_intslider_input(N_VARIATION))
	seed = math.random(0,255)
	function PerlinNoise4D(x, y, z, w, seed)
		local P = {
			151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
			8,99,37,240,21,10,23,190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
			35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,
			134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
			55,46,245,40,244,102,143,54, 65,25,63,161,1,216,80,73,209,76,132,187,208, 89,
			18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,
			250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,
			189,28,42,223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167,
			43,172,9,129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,
			97,228,251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,
			107,49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
			138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
		}
		
		--permutation table
		local perm = {}
		for i=0,255 do
			perm[i] = P[(i + seed) % 256]
		end
		
		--gradients
		local grad4 = {
			{0,1,1,1},  {0,1,1,-1},  {0,1,-1,1},  {0,1,-1,-1},
			{0,-1,1,1},  {0,-1,1,-1},  {0,-1,-1,1},  {0,-1,-1,-1},
			{1,0,1,1},  {1,0,1,-1},  {1,0,-1,1},  {1,0,-1,-1},
			{-1,0,1,1},  {-1,0,1,-1},  {-1,0,-1,1},  {-1,0,-1,-1},
			{1,1,0,1},  {1,1,0,-1},  {1,-1,0,1},  {1,-1,0,-1},
			{-1,1,0,1},  {-1,1,0,-1},  {-1,-1,0,1},  {-1,-1,0,-1},
			{1,1,1,0},  {1,1,-1,0},  {1,-1,1,0},  {1,-1,-1,0},
			{-1,1,1,0},  {-1,1,-1,0},  {-1,-1,1,0},  {-1,-1,-1,0}
		}
		
		--calculate noise
		local n0, n1, n2, n3, n0_0, n0_1, n1_0, n1_1, n2_0, n2_1, n3_0, n3_1, fade_x, fade_y, fade_z, fade_w
		local i0, i1, j0, j1, k0, k1, l0, l1
		local x0, x1, y0, y1, z0, z1, w0, w1
		local s, t, u, v
		local total

		x0 = math.floor(x)
		y0 = math.floor(y)
		z0 = math.floor(z)
		w0 = math.floor(w)
		x1 = x0 + 1
		y1 = y0 + 1
		z1 = z0 + 1
		w1 = w0 + 1

		i0 = perm[x0 % 256] + y0
		i1 = perm[x1 % 256] + y0
		j0 = perm[i0 % 256] + z0 
		j1 = perm[i1 % 256] + z0
		k0 = perm[j0 % 256] + w0
		k1 = perm[j1 % 256] + w0
		l0 = perm[k0 % 256]
		l1 = perm[k1 % 256]

		fade_x = x - x0
		fade_y = y - y0
		fade_z = z - z0
		fade_w = w - w0

		s = grad4[l0 % 16 + 1]
		t = grad4[l1 % 16 + 1]
		u = fade_x*s[1] + fade_y*s[2] + fade_z*s[3] + fade_w*s[4]
		v = fade_x*t[1] + fade_y*t[2] + fade_z*t[3] + fade_w*t[4]

		-- total = 0.5*(1.0 + u + v)

		return s, t, u, v
	end
end;

function get_sample(x, y)
	--Generate 4D Improved Perlin Noise
	local r, g, b, a = get_sample_map(x, y, SOURCE)
	local z, w = b, a
	local range = 100
	for x=0,range do
		for y=0,range do
			for z=0,range do
				for w=0,range do
					local s, t, u, v = PerlinNoise4D(x,y,z,w,seed)
					-- print(x,y,z,w,noise)
				end
			end
		end
	end
	return x, y, z, w
end;