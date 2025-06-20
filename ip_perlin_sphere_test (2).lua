-- 3d perlin sphere -- improved perlin noise
function prepare()
 -- constants
	-- AMPLITUDE_CORRECTION_FACTOR = 1.731628995
		-- only used in depricated statement
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001

 -- input values
	local details = get_slider_input(DETAILS) * 10 + 0.0001
	local grain = (get_slider_input(GRAIN) * 5) + 0.0001
	OCTAVES_COUNT = math.floor(details)
	NOISE_SIZE = math.log( get_slider_input(SCALE) + 0.0000000001) 
	-- NOISE_SIZE = (1 - get_slider_input(SCALE)) * (5 * grain) + 0.0001
	
	 -- noise & rotation precalc
	radius = get_slider_input(RADIUS)

	angle = math.rad(get_angle_input(ROTATION))
	cosa1 = math.cos(angle)
	sina1 = math.sin(angle)

	tilt = math.rad(get_angle_input(TILT))
	cosa2 = math.cos(tilt)
	sina2 = math.sin(tilt)

	 --[[
		https://gist.githubusercontent.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed/raw/1c647169a6729713f8987506b2e5c75a23b14969/perlin.lua
		Implemented as described here:
		http://flafla2.github.io/2014/08/09/perlinnoise.html
	]]-- 

	perlin = {}
	perlin.p = {}

	-- hash lookup table as defined by Ken Perlin
	-- this is a randomly arranged array of all numbers from 0 - 255 inclusive
	-- local permutation = {151, 160, 137, 91, 90, 15, 
	 -- 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 
	 -- 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 
	 -- 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 
	 -- 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 
	 -- 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 
	 -- 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 
	 -- 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 
	 -- 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 
	 -- 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 
	 -- 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 
	 -- 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 
	 -- 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
	-- }

	-- p is used to hash unit cube coordinates to [0, 255]
	-- for i = 0, 255 do
		-- convert to 0 based index table
		-- perlin.p[i] = permutation[i + 1]
		-- repeat the array to avoid buffer overflow in hash function
		-- perlin.p[i + 256] = permutation[i + 1]
	-- end

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

	-- gradient function finds dot product between pseudorandom gradient vector
		-- and the vector from input coordinate to a unit cube vertex
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

	-- perlin octaves initialization
	local remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	local roughness = ROUGHNESS_THRESHOLD + 
		get_slider_input(ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	
	OCTAVES = {}
	local cell_size = (0.01 + NOISE_SIZE * 0.99) * grain -- 5
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
end;


function get_sample(x, y)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local n = 0

	-- image generation
	local px = (x * 2.0) - 1.0
	local py = (y * 2.0) - 1.0
	px = px / radius
	py = py / radius
	local len = math.sqrt((px * px) + (py * py))
	if len > 1.0 then return 0, 0, 0, 0 end

	local z = - math.sqrt(1.0 - ((px * px) + (py * py)))

	local tz = (cosa2 * z) - (sina2 * py)
	local ty = (sina2 * z) + (cosa2 * py)
	z = tz
	py = ty

	local tx = (cosa1 * px) - (sina1 * z)
	local tz = (sina1 * px) + (cosa1 * z)
	px = tx
	z = tz

	-- noise generation
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		n = n + opacity * perlin:noise(px * size, py * size, z * size) -- (2 * -- - 1)
	end
	n = (n + 1.0) * 0.5
	-- n = (n * NORM_FACTOR + AMPLITUDE_CORRECTION_FACTOR) * 
		-- (0.5 / AMPLITUDE_CORRECTION_FACTOR)
				-- causes blowout - getting reasonable results without it
	n = truncate(factor * (n - 0.5) + 0.5)
	n = get_sample_curve(x, y, n, PROFILE)
	return n, n, n, 1
end;


function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;