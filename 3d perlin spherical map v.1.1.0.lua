-- 3d perlin spherical map v.1.1.0
	-- improved perlin noise
	-- good for clouds
local log, sqrt, min, max, floor, rad, pi = math.log, math.sqrt, math.min, math.max, math.floor, math.rad, math.pi
local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
 -- constants
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

	-- inputs and precalculation.
	ang_x = rad(get_angle_input(ANGLE_X)) 
	ang_y = rad(get_angle_input(ANGLE_Y))
	ang_z = rad(get_angle_input(ANGLE_Z) - 180)

	cos_ax, sin_ax  = cos(ang_x), sin(ang_x)
	cos_ay, sin_ay = cos(ang_y), sin(ang_y)
	cos_az, sin_az = cos(ang_z), sin(ang_z)
	
	grain = (get_slider_input(GRAIN) * 5) + 0.0001
	details = get_slider_input(DETAILS) * 10 + 0.0001
	OCTAVES_COUNT = floor(details)

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

	function perlin:noise(x, y, z)
		y = y or 0
		z = z or 0

		-- calculate the "unit cube" that the point asked will be located in
		local xi = bit32.band(floor(x), 255)
		local yi = bit32.band(floor(y), 255)
		local zi = bit32.band(floor(z), 255)

		-- next we calculate the location (from 0 to 1) in that cube
		x = x - floor(x)
		y = y - floor(y)
		z = z - floor(z)

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
	-- return range: [ - 1, 1]

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

	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end

-- mode block
	mode = get_checkbox_input(MODE)
-- end
end;


function get_spherical_perlin(x, y, nr, ng, nb, nv, ni, sx, sy, sz, sa, osx, osy, osz, dr, dg, db, da, dx, dy, dz, dn)
	-- key variables
	-- local nr, ng, nb, nv, ni, sx, sy, sz, sa, osx, osy, osz, dr, dg, db, da, dx, dy, dz, dn = 
		-- 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	-- end

	-- coordinate transformation
	local x = x * aspect * pi
	local y = y * pi
	if sx > 100 then sx = 100 end
	if sy > 100 then sy = 100 end
	if sz > 100 then sz = 100 end
	if sa > 100 then sa = 100 end
	nx = cos(x) * sin(y) * (sx * sa) + osx
	ny = sin(x) * sin(y) * (sy * sa) + osy
	nz = cos(y) * (sz * sa) + osz
	-- return nx, ny, nz, 1

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
	NORM_FACTOR = 1 / sqrt(NORM_FACTOR)
	
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		ni = log(octave_index) % 1
		da = dx + dy + dz * 0.333333333
		dn = dn + (opacity * perlin:noise((nx * size) - ni,(ny * size) + (ni * 0.5),((nz * size) + ni))) * da
		dr = dr + (opacity * perlin:noise(nx * size,ny * size,((nz * size) + ni))) * dx
		dg = dg + (opacity * perlin:noise(((nx * size) + ni),ny * size,nz * size)) * dy
		db = db + (opacity * perlin:noise(nx * size,((ny * size) + ni),nz * size)) * dz
		nv = nv + opacity * perlin:noise((nx * size) + ni, (ny * size) + da, (nz * size) - ni)
		nr = nr + (opacity * perlin:noise((nx * size) + ni, (ny * size) , nz * size + dr))
		ng = ng + (opacity * perlin:noise(nx * size + dg, (ny * size) + ni, (nz * size) + 120))
		nb = nb + (opacity * perlin:noise((nx * size) + 240, ny * size + db, (nz * size) + ni))
	end

	return nr, ng, nb, nv
end;


function map_spherical_rotations(x, y)
	-- coordinate rotations
	local x = x * aspect * pi
	local y = y * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y)
	local nz = cos(y)
	-- local r, g, b, a = nx, ny, 0, 1
	local ax1, ax2 = (nx * cos_ax) + (ny * sin_ax), (nx * sin_ax) - (ny * cos_ax)
	local ay1, ay2 = (ax1 * cos_ay) - (cos(y) * sin_ay), (ax1 * sin_ay) + (cos(y) * cos_ay)
	local az1, az2 = (ax2 * cos_az) + (ay2 * sin_az), (ax2 * sin_az) - (ay2 * cos_az)
	nx = atan2(az1, ay1) * 0.159155 + 0.5
	ny = acos(az2) * 0.159155 * 2
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		nx = nx * 2 - 1
	end
	return nx, ny
end;


function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;


function get_sample_gradient(x, y)
   local nr, ng, nb, na = x, y, (x + y) / 2, 1
   return nr, ng, nb, na
end;


 function get_sample_perlin(x, y, nr, ng, nb, nv)
   local nr, ng, nb, nv = nr, ng, nb, nv
   return nr, ng, nb, nv
end;


function get_sample(x, y)
	-- image generation

	-- key variables
	local nr, ng, nb, nv, ni, sx, sy, sz, sa, dr, dg, db, da 
	= 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	-- end

	-- input maps
	local r1, g1, b1, a1 = get_sample_map(x, y, HIGH)
	local r2, g2, b2, a2 = get_sample_map(x, y, LOW)
	roughness = ROUGHNESS_THRESHOLD + 	get_sample_grayscale(x, y, ROUGHNESS) * 
		(1.0 - ROUGHNESS_THRESHOLD)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	local osx, osy, osz, osa = get_sample_map(x, y, OFFSET)
	local dx, dy, dz, dn = get_sample_map(x, y, DISTORTION) 
	-- end

	-- noise generation
	local nx, ny = map_spherical_rotations(x, y)
	nr, ng, nb, nv = get_spherical_perlin(x, y, nr, ng, nb, nv, ni, sx, sy, sz, sa, osx, osy, osz, dr, dg, db, da, dx, dy, dz, dn)

	-- contrast adjustments
	nv = (nv + 1.0) * 0.5
	nr = (nr + 1.0) * 0.5
	ng = (ng + 1.0) * 0.5
	nb = (nb + 1.0) * 0.5
	nv = truncate(factor * (nv - 0.5) + 0.5)
	nr = truncate(factor * (nr - 0.5) + 0.5)
	ng = truncate(factor * (ng - 0.5) + 0.5)
	nb = truncate(factor * (nb - 0.5) + 0.5)

	-- input curves
	nv = get_sample_curve(x, y, nv, PROFILE)
	nr = get_sample_curve(x, y, nr, PROFILE)
	ng = get_sample_curve(x, y, ng, PROFILE)
	nb = get_sample_curve(x, y, nb, PROFILE)
	
	-- output
	-- local r, g, b, a = get_sample_gradient(nx, ny) -- x, y
	local r, g, b, a = get_sample_perlin(nx, ny, nr, ng, nb, nv)
	-- local r, g, b, a = nx, ny, 0, 1
	
	if mode then
		-- rgban = true
		return r, g, b, 1
	else
		-- map = true
		-- blends forground HIGH and background LOW
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, nv, hdr)
		return r, g, b, a 
		-- return nr, ng, nb, nv
		-- return x, y, 0, 1 
		-- return nx, ny, 0, 1 
	end
	-- return r, g, b, a 
	-- debug
end;