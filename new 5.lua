-- 3d perlin sphere map v.1.0.1-- improved perlin noise
	acos, asin, atan2, cos, floor, log, max, min, pi, pi_div, rad, random, randomseed, sin, sqrt, tan = 
		math.acos, math.asin, math.atan2, math.cos, math.floor, math.log, math.max, math.min, 
		math.pi, 1 / math.pi, math.rad, math.random, math.randomseed, math.sin, math.sqrt, math.tan

function prepare()
-- constants
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	resolution = min(OUTPUT_WIDTH, OUTPUT_HEIGHT)
	amp_c = 1.731628995
	rough_c = 0.000000001
	min_c = 0.000000001
	min_p = 0.001666667 -- 1 / resolution-- 

-- input values
	details = max(get_slider_input(DETAILS) * 10, min_c)
	grain = max((get_slider_input(GRAIN) * 5), min_c)
	
-- sphere block
	radius = max(get_slider_input(RADIUS), min_c)
	persp = math.max(0, min_c) -- get_slider_input(PERSP) * .25 * pi
	cp, sp = cos_sin(persp)
	sp_div = 1 / math.max(sp, min_c)
	z1 = rad(get_angle_input(ROLL_1))-- z axis
	cz1, sz1 = cos_sin(z1)
	x1 = rad(get_angle_input(TILT_1))-- x axis
	cx1, sx1 = cos_sin(x1)
	y1 = rad(get_angle_input(ROTATION_1))-- y axis
	cy1, sy1 = cos_sin(y1)

-- noise block
	--[[
		https://gist.githubusercontent.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed/raw/1c647169a6729713f8987506b2e5c75a23b14969/perlin.lua
		Implemented as described here:
		http://flafla2.github.io/2014/08/09/perlinnoise.html
			originally an external, FF requires internal script exclusively.
			block only functions inside prepare(), appended to the end it throws a nil global value 'perlin' error. 
	]]--

	perlin = {}
	perlin.p = {}

	randomseed(get_intslider_input(SEED))
	for i = 0, 255 do
		perlin.p[i] = random(255)
		perlin.p[256 + i] = perlin.p[i]
	end;

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
	-- return range: [ - 1, 1]
	end;

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
	end;

	-- fade function is used to smooth final output
	function perlin.fade(t)
		return t * t * t * (t * (t * 6 - 15) + 10)
	end;

	function perlin.lerp(t, a, b)
		return a + t * (b - a)
	end;
	-- end perlin

	-- end noise block
	mode = 1
end;


function get_sample(x, y)
-- key variables
	local v, z = 0, 0
	local px, py, pz = 0, 0, 0
	local nx, ny, nz = 0, 0, 0
	local dr, dg, db, da = 0, 0, 0, 0
	local dx, dy, dz, da = 0, 0, 0, 0
	local sx, sy, sz, sa = 0, 0, 0, 0
	
-- image generation
	local px_1, py_1, pz_1, pv = get_sphere(x, y)
	-- local px_1, py_1, pz_1, pv = get_sphere_xyz(x, y, z, 1)
	px_1, py_1, pz_1 = px_1 * 0.5 + 0.5, py_1 * 0.5 + 0.5, pz_1 * 0.5 + 0.5
	if pv == 0 then alpha = 0 end;

	if mode <= 2 then
	-- sphere block
		px = (x * 2.0) - 1.0
		px = px / radius
		py = (y * 2.0) - 1.0
		py = py / radius
		local len = sqrt((px * px) + (py * py))
		if len > 1.0 then return 0,0,0,0 end
		pz = -sqrt(1.0 - ((px * px) + (py * py)))
		
	--  roll
		local tx = (cz1 * px) - (sz1 * py)
		local ty = (sz1 * px) + (cz1 * py)
		px = tx
		py = ty
		
	-- tilt
		local tz = (cx1 * pz) - (sx1 * py)
		local ty = (sx1 * pz) + (cx1 * py)
		pz = tz
		py = ty
		
	-- rotation
		local tx = (cy1 * px) - (sy1 * pz)
		local tz = (sy1 * px) + (cy1 * pz)
		px = tx
		pz = tz

		x, y, z = px, py, pz
	else
	-- spherical map block
		local x = x * aspect * pi
		local y = y * pi
		nx = cos(x) * sin(y)
		ny = sin(x) * sin(y)
		nz = cos(y)

		x, y, z = nx, ny, nz
	end;
	-- end

-- input maps
	roughness = rough_c + get_sample_grayscale(x, y, ROUGHNESS) * 
		(1.0 - rough_c)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION)
	local osx, osy, osz, osa = get_sample_map(x, y, OFFSET)
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	if sx > 100 then sx = 100 end;
	if sy > 100 then sy = 100 end;
	if sz > 100 then sz = 100 end;
	if sa > 100 then sa = 100 end;
	-- end
	grain = math.max(((get_slider_input(GRAIN) * 0.975 * 5.125), 0.1))

-- noise generation
	noise_size = (((sx + sy + sz + sa) * 0.25) ^ 2)
	octaves_n = floor(details)
	remainder = details - octaves_n
	if (remainder > min_c) then
		octaves_n = octaves_n + 1
	end;
	octaves = {}
	local cell_size = (0.00001 + (noise_size * 0.99999)) * grain
	local scale = roughness
	local octave_index
	for octave_index = 1, octaves_n do
		if (scale < rough_c) then
			octaves_n = octave_index - 1
			break
		end;
		octaves[octave_index] = {cell_size, scale}
		-- cell_size = cell_size * 5
		cell_size = cell_size * 2.5
		-- cell_size = cell_size * 0.5
		scale = scale * roughness
	end;
	
	if (remainder >= 0.001) then
		octaves[octaves_n][2] = octaves[octaves_n][2] * remainder
	end;

	norm = 0
	for octave_index = 1, octaves_n do
		norm = norm + octaves[octave_index][2] ^ 2
	end;
	x = x * (sx * sa) + osx
	y = y * (sy * sa) + osy
	z = z * (sz * sa) + osz
	norm = 1 / sqrt(norm)
	local octave_index 
	for octave_index = 1, octaves_n do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		dr = dr + (opacity * perlin:noise(x * size, y * size, z * size)) * dx
		v = v + (opacity * perlin:noise(x * size, y * size, z * size ) + dr)
	end;
	-- v = (v * norm + amp_c) * (0.5 / amp_c) -- not needed for current noise
	
	-- input curves
	v = get_sample_curve(px_1, py_1, v, PROFILE)
	
-- contrast adjustments
	v = (v + 1.0) * 0.5
	v = truncate(factor * (v - 0.5) + 0.5)
	
	local r1, g1, b1, a1 = get_sample_map(px_1, py_1, HIGH)
	local r2, g2, b2, a2 = get_sample_map(px_1, py_1, LOW)
	-- return conditions
	if mode == 1 then
		-- sphere = true
		-- blends forground HIGH and background LOW
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, v, true)
		return r, g, b, a
		-- return v, v, v, 1
	elseif mode == 2 then
		-- sphere = true
		-- vectors = true
		r, g, b, a = px, py, 0, 1
		return r, g, b, a
	-- elseif mode == 3 then
	-- elseif mode == 4 then
	-- elseif mode == 5 then
	-- elseif mode == 6 then
	else
		-- map = true
		-- blends forground HIGH and background LOW
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, v, true)
		return r, g, b, a
	end;
end;
-- debug
--[[
function perlin.octaves(x, y, z) 
	<!> as a function there becomes an issue with `self.` referencing in `perlin.noise`
	return v
end;
	-- call function: v = perlin.noise(x, y, z)
--]]


function get_sphere_xyz(x, y)
	local x, y, z, tx, ty, tz, alpha, rho = x, y, 0, 0, 0, 0, 1, 1
	x, y = (x * 2.0) - 1.0, (y * 2.0) - 1.0
	x, y = x * radius, y * radius
	rho = sqrt((x * x)+(y * y))
	if rho > 1.0 then alpha = 0 end
	z = -sqrt(math.max(1.0 - ((x * x)+(y * y)), min_c))
	tx, ty = (cz1 * x) - (sz1 * y), (sz1 * x) + (cz1 * y)
 	x, y = tx, ty-- roll
	tz, ty = (cx1 * z) - (sx1 * y), (sx * z) + (cx1 * y)
 	z, y = tz, ty -- tilt
	tx, tz= (cy1 * x) - (sy1 * z), (sy1 * x) + (cy1 * z)
 	x, z = tx, tz -- rotation
 	return x, y, z, alpha
end;
	-- px, py, pz, alpha, rho = get_sphere_xyz(x, y, rho)


function cos_sin(angle)
	local cos_angle, sin_angle = cos(angle), sin(angle)
	return cos_angle, sin_angle
end;


function get_sphere(x, y)
	local z, tx, ty, alpha, theta, rho, phi, cphi, cph = 0, 0, 0, 0, 0, 0, 1, 0, 1
	x, y = x * 2 - 1, y * 2 - 1
	x, y = x * radius, y * radius
	rho = sqrt((x * x)+(y * y))
	if rho > 1.0 then alpha = 0 end;
	theta = atan2(y, x)
	if persp > 0 then
		phi = min(1, rho) * persp
		cphi, cph = sin(phi), cos(phi)
		rho = cphi * (cph * sp_div - sqrt((cph * cph - cp * cp) * sp_div * sp_div))
	else
		rho = min(1, rho)
	end;
	x, y = rho * cos(theta), rho * sin(theta)
	tx, ty = (cz1 * x) - (sz1 * y), (sz1 * x) + (cz1 * y)
	x, y = tx, ty
	x, y, z = rotate_xyz(x, y)
	return x, y, z, alpha
end;


function rotate_xyz(x, y)
	local x, y, z = min(max(x, - 1), 1), - min(max(y, - 1), 1), 0
	local phi, theta = asin(y), 0
	local cph = cos(phi)
	x = min(max(x, - cph), cph)
	if cph~=0 then theta = asin(x / cph) end;
	phi = .5 * pi - phi
	x, y, z = cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi)
	x, z = x * cx1 - z * sx1, x * sx1 + z * cx1 -- tilt
	theta, phi = atan2(y, x) + y1, acos(z) -- rotation
	theta, phi = (theta * pi_div + 1) * .5, phi * pi_div
	theta = xratio(theta) -- aspect auto-conversion
	x, y = theta, phi
	return x, y, z
end;


function xratio(x)
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		x = x * 2 - 1 else x = x
	end;
	return x
end;


function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;
