-- <?> 3.15.2023»01:57

-- STACK OVERFLOW.LmTinyToon: I'd recommend to use 0-indexing from java (to make fewer mistakes in original code). Here is the lua code for the 2d noise. You can easily adapt it for 3d/4d noises (no changes for arrays needed).
-- simplex noise proto.lua
-- solution to: v.0.0.1 revision and testing

function prepare()
	noiseScale = 50
	noiseOctaves = 4
	noiseLacunarity = 2.0
	noisePersistence = 0.5

	grad3 = {
			{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0},
			{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1},
			{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}
	}

	p = {151,160,137,91,90,15,
	131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
	190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
	88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
	77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
	102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
	135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
	5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
	223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
	129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
	251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
	49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180};

	perm = {};
	permMod12 = {};
	for i = 0, 512 do
		perm[i]=p[(i & 255) + 1];
		-- or with random values -> perm[i]=math.random(0,255)
		permMod12[i] = perm[i] % 12;
	end

	-- skewing and unskewing factors for 2, 3, and 4 dimensions
	F2 = 0.5*(math.sqrt(3.0)-1.0);
	G2 = (3.0-math.sqrt(3.0))/6.0;
	F3 = 1.0/3.0;
	G3 = 1.0/6.0;
	F4 = (math.sqrt(5.0)-1.0)/4.0;
	G4 = (5.0-math.sqrt(5.0))/20.0;
end;


function get_sample(x, y)
							if x < 0 or x > 1 or y < 0 or y > 1 then
									return 0.5, 0.5, 0.5, 1
							end
	local xin, yin = x/noiseScale, y/noiseScale
		local noise2D = noise(xin, yin)
	-- local noise3D = 0 -- get_3d_noise(xin, yin, 0, noiseOctaves, noiseLacunarity, noisePersistence)
	-- local noise4D = 0 -- get_4d_noise(xin, yin, 0, 0, noiseOctaves, noiseLacunarity, noisePersistence)

	local r = noise2D * 10
	-- local g = noise3D
	-- local b = noise4D
	local a = 1

	-- return r, g, b, a
	return r, 0, 0, a
	-- return 0, g, 0, a
	-- return 0, 0, b, a
end

-- this method is a *lot* faster than using (int)math.floor(x)
	function fastfloor(x) 
		local xi = math.floor(x)
		return (x < xi) and (xi-1) or xi
	end

	function dot(g, x, y) 
		return (g[1]*x) + (g[2]*y)
	end


	-- 2D simplex noise
	function noise(xin, yin)
		local n0, n1, n2; 												-- noise contributions from the three corners
																					-- skew the input space to determine which simplex cell we're in
		local s = (xin+yin)*F2; -- Hairy factor for 2D
		local i = fastfloor(xin+s);
		local j = fastfloor(yin+s);
		local t = (i+j)*G2;
		local X0 = i-t; 													-- unskew the cell origin back to (x,y) space
		local Y0 = j-t;
		local x0 = xin-X0; 											-- The x,y distances from the cell origin
		local y0 = yin-Y0;
																					-- for the 2d case, the simplex shape is an equilateral triangle.
																					-- determine which simplex we are in.
		local i1, j1; 														-- offsets for second (middle) corner of simplex in (i,j) coords
		if x0>y0 then
			i1=1; 
			j1=0; 																-- lower triangle, xy order: (0,0)->(1,0)->(1,1)
		else 
			i1=0; 
			j1=1;
		end																		-- upper triangle, YX order: (0,0)->(0,1)->(1,1)
																					-- a step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
																					-- a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
																					-- c = (3-sqrt(3))/6
		local x1 = x0 - i1 + G2; 									-- offsets for middle corner in (x,y) unskewed coords
		local y1 = y0 - j1 + G2;
		local x2 = x0 - 1.0 + 2.0 * G2; 						-- offsets for last corner in (x,y) unskewed coords
		local y2 = y0 - 1.0 + 2.0 * G2;
																					-- work out the hashed gradient indices of the three simplex corners
		local ii = i & 255;
		local jj = j & 255;
		local gi0 = permMod12[ii+perm[jj]];
		local gi1 = permMod12[ii+i1+perm[jj+j1]];
		local gi2 = permMod12[ii+1+perm[jj+1]];
																					-- calculate the contribution from the three corners
		local t0 = 0.5 - x0*x0-y0*y0;
		if t0<0 then
		n0 = 0.0;
		else 
			t0 = t0 * t0;
			n0 = t0 * t0 * dot(grad3[gi0], x0, y0);		-- (x,y) of grad3 used for 2d gradient
		end
		local t1 = 0.5 - x1*x1-y1*y1;
		if t1<0 then
		n1 = 0.0;
		else 
			t1 = t1 * t1;
			n1 = t1 * t1 * dot(grad3[gi1], x1, y1);
		end
		local t2 = 0.5 - x2*x2-y2*y2;
		if t2<0 then
			n2 = 0.0;
		else 
			t2 = t2 * t2;
			n2 = t2 * t2 * dot(grad3[gi2], x2, y2);
		end
																					-- add contributions from each corner to get the final noise value.
																					-- the result is scaled to return values in the interval [-1,1].
		return 70.0 * (n0 + n1 + n2);
	end