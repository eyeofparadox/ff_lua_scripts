	
	
--[[
	generate 3D multi-octave Perlin noise with randomseed variable
	based on the code at http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
]]--

-- This code produces a seamless tileable texture, that is procedurally generated from 4D noise:	
local function GetData(module, mapData)
	mapData = {width = Width, height = Height}
 
	-- loop through each x,y point - get height value
	for x = 0, Width do 
		for y = 0, Height do
 
			-- Noise range
			local x1, x2 = 0, 2
			local y1, y2 = 0, 2				 
			local dx = x2 - x1
			local dy = y2 - y1
 
			-- Sample noise at smaller intervals
			local s = x / Width
			local t = y / Height
		 
			-- Calculate our 4D coordinates
			local nx = x1 + math.cos (s*2*math.pi) * dx/(2*math.pi)
			local ny = y1 + math.cos (t*2*math.pi) * dy/(2*math.pi)
			local nz = x1 + math.sin (s*2*math.pi) * dx/(2*math.pi)
			local nw = y1 + math.sin (t*2*math.pi) * dy/(2*math.pi)
		 
			local heightValue = HeightMap.Get (nx, ny, nz, nw)
			 
			-- keep track of the max and min values found
			if (heightValue > mapData.Max) then mapData.Max = heightValue end
			if (heightValue < mapData.Min) then mapData.Min = heightValue end
 
			mapData.Data[x,y] = heightValue
		end
	end
end
	
	-- openai codex playgroung - generate 2d multi-octave periodic perlin noise in lua version 5.1

--[[
	generate 2D multi-octave Perlin noise
	based on the code at http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
]]--

local F2 = 0.5 * (math.sqrt(3.0) - 1.0)
local G2 = (3.0 - math.sqrt(3.0)) / 6.0

local function dot(g, x, y)
	return g[1]*x + g[2]*y
end

local perm = {
	151,160,137,91,90,15,
	131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
	8,99,37,240,21,10,23,190, 6,148,247,120,234,75,0,26,197,
	62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,
	174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
	77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
	55,46,245,40,244,102,143,54, 65,25,63,161,1,216,80,73,209,
	76,132,187,208, 89,18,169,200,196,135,130,116,188,159,86,164,
	100,109,198,173,186, 3,64,52,217,226,250,124,123,5,202,38,
	147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,
	189,28,42,223,183,170,213,119,248,152, 2,44,154,163, 70,221,
	153,101,155,167, 43,172,9,129,22,39,253, 19,98,108,110,79,
	113,224,232,178,185, 112,104,218,246,97,228,
	251,34,242,193,238,210,144,12,191,179,162,241,
	81,51,145,235,249,14,239,107,49,192,214, 31,181,
	199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,
	215,61,156,180
}

local grad3 = {
	{1,1,0}, {-1,1,0}, {1,-1,0}, {-1,-1,0}, 
	{1,0,1}, {-1,0,1}, {1,0,-1}, {-1,0,-1}, 
	{0,1,1}, {0,-1,1}, {0,1,-1}, {0,-1,-1}
}

--[[ 
	This function generates a 2D Perlin noise. 
	It has a number of octaves which are summed together to create the noise.
	The higher the number of octaves, the more detailed the noise.
	
	Input:
		x, y		The coordinates
		octaves		The number of octaves to generate
		frequency		The base frequency of the noise
		amplitude		The base amplitude of the noise
		persistence		The persistence, or amount of damping applied to each octave
	
	Output:
		A single floating point value
]]

function perlin2D(x, y, octaves, frequency, amplitude, persistence, seed)
	math.randomseed(seed)
	
	local total = 0
	local maxValue = 0 -- Used for normalizing result to 0.0 - 1.0
	for i=0,octaves-1 do
	local freq = frequency * math.pow(2,i)
	local amp = amplitude * math.pow(persistence,i)
	total = total + perlin2D_octave(x * freq, y * freq, amp)
	maxValue = maxValue + amp
	end
	
	-- Normalize result
	return total/maxValue
end

--[[ 
	This is an internal function used by perlin2D to generate an octave of noise.
	
	Input:
		x, y		The coordinates
		amplitude		The amplitude of the octave
	
	Output:
		A single floating point value
]]

function perlin2D_octave(x, y, amplitude)
	local n0, n1, n2; -- Noise contributions from the three corners
	
	-- Skew the input space to determine which simplex cell we're in
	local s = (x+y)*F2; -- Hairy factor for 2D
	local i = math.floor(x+s);
	local j = math.floor(y+s);
	local t = (i+j)*G2;
	local X0 = i-t; -- Unskew the cell origin back to (x,y) space
	local Y0 = j-t;
	local x0 = x-X0; -- The x,y distances from the cell origin
	local y0 = y-Y0;
	
	-- For the 2D case, the simplex shape is an equilateral triangle.
	-- Determine which simplex we are in.
	local i1, j1; -- Offsets for second (middle) corner of simplex in (i,j) coords
	if x0>y0 then 
	i1=1; j1=0; -- lower triangle, XY order: (0,0)->(1,0)->(1,1)
	else 
	i1=0; j1=1; -- upper triangle, YX order: (0,0)->(0,1)->(1,1)
	end
	
	-- A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
	-- a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
	-- c = (3-sqrt(3))/6
	local x1 = x0 - i1 + G2; -- Offsets for middle corner in (x,y) unskewed coords
	local y1 = y0 - j1 + G2;
	local x2 = x0 - 1.0 + 2.0 * G2; -- Offsets for last corner in (x,y) unskewed coords
	local y2 = y0 - 1.0 + 2.0 * G2;
	
	-- Wrap the integer indices at 256, to avoid indexing perm[] out of bounds
	local ii = i % 256
	local jj = j % 256
	
	-- Calculate the contribution from the three corners
	local t0 = 0.5 - x0*x0-y0*y0
	if t0 < 0 then
	n0 = 0.0
	else
	t0 = t0 * t0
	local gi0 = perm[ii+perm[jj]] % 12
	n0 = t0 * t0 * dot(grad3[gi0+1], x0, y0) -- (x,y) of grad3 used for 2D gradient
	end
	
	local t1 = 0.5 - x1*x1-y1*y1
	if t1 < 0 then
	n1 = 0.0
	else
	t1 = t1 * t1
	local gi1 = perm[ii+i1+perm[jj+j1]] % 12
	n1 = t1 * t1 * dot(grad3[gi1+1], x1, y1)
	end
	
	local t2 = 0.5 - x2*x2-y2*y2
	if t2 < 0 then
	n2 = 0.0
	else
	t2 = t2 * t2
	local gi2 = perm[ii+1+perm[jj+1]] % 12
	n2 = t2 * t2 * dot(grad3[gi2+1], x2, y2)
	end
	
	-- Add contributions from each corner to get the final noise value.
	-- The result is scaled to return values in the interval [-1,1].
	return 70.0 * (n0 + n1 + n2) * amplitude
end



--[[ 
	generate 3D multi-octave Perlin noise with randomseed variable using lua version 5.1 
	based on the code at http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
	see also: http://www.itn.liu.se/~stegu/simplexnoise/SimplexNoise.java
]]

math.randomseed(randomseed)

local F3 = 1/math.sqrt(3)
local G3 = 1/math.sqrt(3)

local perm = {}

for i = 0, 255 do
	perm[i] = math.random(0, 255)
end

-- This is a lookup table to speed up gradient computations
-- for 3D Perlin noise
local grad3 = {
	{1,1,0},
	{-1,1,0},
	{1,-1,0},
	{-1,-1,0},
	{1,0,1},
	{-1,0,1},
	{1,0,-1},
	{-1,0,-1},
	{0,1,1},
	{0,-1,1},
	{0,1,-1},
	{0,-1,-1},
}

-- This is the 3D simplex noise function

local function noise(x,y,z,octaves)
	local total = 0
	local frequency = 1
	local maxValue = 0  -- Used for normalizing result to 0.0 - 1.0
	for i = 0, octaves-1 do
		local amplitude = math.pow(2,i)
		maxValue = maxValue + amplitude
		total = total + getPerlinNoise3D(x * frequency, y * frequency, z * frequency) * amplitude
		frequency = frequency * 2
	end
 
	return total/maxValue
end

local function getPerlinNoise3D(x, y, z)
	-- Find unit grid cell containing point
	local X = math.floor(x)
	local Y = math.floor(y)
	local Z = math.floor(z)
 
	-- Get relative xyz coordinates of point within that cell
	x = x - X
	y = y - Y
	z = z - Z
 
	-- Wrap the integer cells at 255 (smaller integer period can be introduced here)
	X = X & 255
	Y = Y & 255
	Z = Z & 255
 
	-- Calculate a set of eight hashed gradient indices
	local gi000 = perm[X+perm[Y+perm[Z]]] % 12
	local gi001 = perm[X+perm[Y+perm[Z+1]]] % 12
	local gi010 = perm[X+perm[Y+1+perm[Z]]] % 12
	local gi011 = perm[X+perm[Y+1+perm[Z+1]]] % 12
	local gi100 = perm[X+1+perm[Y+perm[Z]]] % 12
	local gi101 = perm[X+1+perm[Y+perm[Z+1]]] % 12
	local gi110 = perm[X+1+perm[Y+1+perm[Z]]] % 12
	local gi111 = perm[X+1+perm[Y+1+perm[Z+1]]] % 12
 
	-- Calculate noise contributions from each of the eight corners
	local n000 = dot(grad3[gi000], x, y, z)
	local n100 = dot(grad3[gi100], x-1, y, z)
	local n010 = dot(grad3[gi010], x, y-1, z)
	local n110 = dot(grad3[gi110], x-1, y-1, z)
	local n001 = dot(grad3[gi001], x, y, z-1)
	local n101 = dot(grad3[gi101], x-1, y, z-1)
	local n011 = dot(grad3[gi011], x, y-1, z-1)
	local n111 = dot(grad3[gi111], x-1, y-1, z-1)
 
	-- Compute the fade curve value for each of x, y, z
	local u = fade(x)
	local v = fade(y)
	local w = fade(z)
 
	-- Interpolate along x the contributions from each of the corners
	local nx00 = mix(n000, n100, u)
	local nx01 = mix(n001, n101, u)
	local nx10 = mix(n010, n110, u)
	local nx11 = mix(n011, n111, u)
 
	-- Interpolate the four results along y
	local nxy0 = mix(nx00, nx10, v)
	local nxy1 = mix(nx01, nx11, v)
 
	-- Interpolate the two last results along z
	local nxyz = mix(nxy0, nxy1, w)
 
	return nxyz
end

-- Helper functions used for calculating noise contributions
--
local function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end
 
local function lerp(t, a, b)
	return a + t * (b - a)
end
 
local function mix(a, b, t)
	return lerp(t, a, b)
end
 
local function dot(g, x, y, z)
	return g[1]*x + g[2]*y + g[3]*z
end


