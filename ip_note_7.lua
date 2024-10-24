


size 50
size chaos 50
h chaos 100
v chaos 100
roughness 10
multiply
small on top
simple layering
across layers
details 30
repeat crater scaledensity crater density
variation



function prepare() 
	pi2 = math.pi*2
	iterations = get_intslider_input(ROUGHNESS)
	seed = VARIATION;
end

function random()
	rnd = ((rnd + 14504597) * 1942146) % 1000000;
	return rnd / 1000000;
end

function get_sample(x, y)
	local v,angle = 1,0
	rnd = seed
	for i=1,iterations do
		angle = pi2*random()
		v = math.abs(v-math.abs((((x-random()-0.5)*math.cos(angle)-(y-random()-0.5)*math.sin(angle))%1)*2-1))	
	end
	return v,v,v
end

apply different octave blending modes...

-- 3d perlin spherical map v.1.1.1
	-- improved perlin noise - grayscale
function prepare()
 -- constants
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

 -- input values
	details = get_slider_input(DETAILS) * 10 + 0.0001
	grain = (get_slider_input(GRAIN) * 5) + 0.0001
	OCTAVES_COUNT = math.floor(details)

-- noise block
	--[[
		https://gist.githubusercontent.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed/raw/1c647169a6729713f8987506b2e5c75a23b14969/perlin.lua
		Implemented as described here:
		http://flafla2.github.io/2014/08/09/perlinnoise.html
	]]-- 

	perlin = {}
	perlin.p = {}

	math.randomseed(get_intslider_input(SEED))
	
	for i = 0, 255 do
		perlin.p[i] = math.random(255)
		perlin.p[256 + i] = perlin.p[i]
	end

	-- return range: [ - 1, 1]
	function perlin:noise(x, y, z)
		y = y or 0
		z = z or 0

		-- calculate the "unit cube" that the point asked will be located in
		local xi = bit32.band(math.floor(x), 255)
		local yi = bit32.band(math.floor(y), 255)
		local zi = bit32.band(math.floor(z), 255)

		-- next we calculate the location (from 0 to 1) in that cube
		x = x - math.floor(x)
		y = y - math.floor(y)
		z = z - math.floor(z)

		-- we also fade the location to smooth the result
		local u = self.fade(x)
		local v = self.fade(y)
		local w = self.fade(z)

		-- hash all 8 unit cube coordinates surrounding input coordinate
		local p = self.p
		local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
		A = p[xi ] + yi
		AA = p[A ] + zi
		AB = p[A + 1 ] + zi
		AAA = p[ AA ]
		ABA = p[ AB ]
		AAB = p[ AA + 1 ]
		ABB = p[ AB + 1 ]

		B = p[xi + 1] + yi
		BA = p[B ] + zi
		BB = p[B + 1 ] + zi
		BAA = p[ BA ]
		BBA = p[ BB ]
		BAB = p[ BA + 1 ]
		BBB = p[ BB + 1 ]

		-- take the weighted average between all 8 unit cube coordinates
		return self.lerp(w, 
			self.lerp(v, 
				self.lerp(u, 
					self:grad(AAA, x, y, z), 
					self:grad(BAA, x - 1, y, z)
				), 
				self.lerp(u, 
					self:grad(ABA, x, y - 1, z), 
					self:grad(BBA, x - 1, y - 1, z)
				)
			), 
			self.lerp(v, 
				self.lerp(u, 
					self:grad(AAB, x, y, z - 1), self:grad(BAB, x - 1, y, z - 1)
				), 
				self.lerp(u, 
					self:grad(ABB, x, y - 1, z - 1), self:grad(BBB, x - 1, y - 1, z - 1)
				)
			)
		)
	end

	--[[ 
		gradient function finds dot product between pseudorandom gradient vector
		and the vector from input coordinate to a unit cube vertex.
	]]-- 
	perlin.dot_product = {
		[0x0] = function(x, y, z) return x + y end, 
		[0x1] = function(x, y, z) return -x + y end, 
		[0x2] = function(x, y, z) return x - y end, 
		[0x3] = function(x, y, z) return -x - y end, 
		[0x4] = function(x, y, z) return x + z end, 
		[0x5] = function(x, y, z) return -x + z end, 
		[0x6] = function(x, y, z) return x - z end, 
		[0x7] = function(x, y, z) return -x - z end, 
		[0x8] = function(x, y, z) return y + z end, 
		[0x9] = function(x, y, z) return -y + z end, 
		[0xA] = function(x, y, z) return y - z end, 
		[0xB] = function(x, y, z) return -y - z end, 
		[0xC] = function(x, y, z) return y + x end, 
		[0xD] = function(x, y, z) return -y + z end, 
		[0xE] = function(x, y, z) return y - x end, 
		[0xF] = function(x, y, z) return -y - z end
	}
	function perlin:grad(hash, x, y, z)
		return self.dot_product[bit32.band(hash, 0xF)](x, y, z)
	end

	-- fade function is used to smooth final output
	function perlin.fade(t)
		return t * t * t * (t * (t * 6 - 15) + 10)
	end

	function perlin.lerp(t, a, b)
		return a + t * (b - a)
	end
	-- end perlin

	-- perlin octaves initialization
	remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
-- end noise block
	
	hdr = false
end;


function get_sample(x, y)
	-- key variables
	local n, ni = 0, 0
	local dr, dg, db, da = 0, 0, 0, 0
	local dx, dy, dz, dn = 0, 0, 0, 0
	local sx, sy, sz, sa = 0, 0, 0, 0
	
	-- image generation
	-- input maps
	roughness = ROUGHNESS_THRESHOLD + 	get_sample_grayscale(x, y, ROUGHNESS) * 
		(1.0 - ROUGHNESS_THRESHOLD)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local r1, g1, b1, a1 = get_sample_map(x, y, HIGH)
	local r2, g2, b2, a2 = get_sample_map(x, y, LOW)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION) 
	local osx, osy, osz, osa = get_sample_map(x, y, OFFSET)
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	if sx > 100 then sx = 100 end
	if sy > 100 then sy = 100 end
	if sz > 100 then sz = 100 end
	if sa > 100 then sa = 100 end
	-- end

	-- spherical map block
	local x = x * aspect * math.pi
	local y = y * math.pi
	nx = math.cos(x) * math.sin(y) * (sx * sa) + osx
	ny = math.sin(x) * math.sin(y) * (sy * sa) + osy
	nz = math.cos(y) * (sz * sa) + osz
	-- end

	-- noise generation
	NOISE_SIZE = (((sx + sy + sz + sa) * 0.25) ^ 2) 
	OCTAVES = {}
	local cell_size = (0.01 + NOISE_SIZE * 0.99) * grain
	local scale = roughness
	local octave_index
	for octave_index = 1, OCTAVES_COUNT do
		if (scale < ROUGHNESS_THRESHOLD) then
			OCTAVES_COUNT = octave_index - 1
			break
		end
		OCTAVES[octave_index] = {cell_size, scale}
		cell_size = cell_size * 2.0
		scale = scale * roughness
	end
	
	if (remainder >= 0.001) then
		OCTAVES[OCTAVES_COUNT][2] = OCTAVES[OCTAVES_COUNT][2] * remainder
	end

	NORM_FACTOR = 0
	for octave_index = 1, OCTAVES_COUNT do
		NORM_FACTOR = NORM_FACTOR + OCTAVES[octave_index][2] ^ 2
	end
	NORM_FACTOR = 1 / math.sqrt(NORM_FACTOR)
	
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		ni = math.log(octave_index) % 1
		da = dx + dy + dz * 0.333333333
		dn = dn + (opacity * perlin:noise((nx * size) - ni,(ny * size) + (ni * 0.5),((nz * size) + ni))) * da
		n = n + opacity * perlin:noise((nx * size) + ni, (ny * size) + da, (nz * size) - ni)
	end

	-- contrast adjustment
	n = (n + 1.0) * 0.5
	n = truncate(factor * (n - 0.5) + 0.5)

	-- input curve
		
	n = get_sample_curve(x, y, n, PROFILE)
	-- blends forground HIGH and background LOW
	r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, n, hdr)
	return r, g, b, a 
	-- debug
end;


function fromrgb(r, g, b)
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, l

	l = (max + min) / 2

	if max == min then
		h, s = 0, 0 -- achromatic
	else
		local d = max - min
		local s
	if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
	if max == r then
		h = (g - b) / d
	if g < b then h = h + 6 end
	elseif max == g then h = (b - r) / d + 2
	elseif max == b then h = (r - g) / d + 4
	end
	h = h / 6
 end

 return h, s, l or 1
end


function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;