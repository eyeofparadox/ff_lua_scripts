-- 3d perlin sphere map v.1.0.0 -- improved perlin noise
function prepare()
 -- constants
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

 -- input values
	details = get_slider_input(DETAILS) * 10 + 0.0001
	grain = (get_slider_input(GRAIN) * 5) + 0.0001
	OCTAVES_COUNT = math.floor(details)
	
-- sphere block
	radius = get_slider_input(RADIUS)

	-- fresnel / atmosphere fixed tilt and rotation -- locked to view. 
	angle_0 = math.rad(90)
	cosa_a0 = math.cos(angle_0)
	sina_a0 = math.sin(angle_0)

	tilt_0 = math.rad(360)
	cosa_t0 = math.cos(tilt_0)
	sina_t0 = math.sin(tilt_0)

	angle = get_angle_input(ROTATION)
	angle_r = math.rad(angle)
	angle_g = math.rad(angle + 240)
	angle_b = math.rad(angle + 120)
	cosa_r = math.cos(angle_r)
	sina_r = math.sin(angle_r)
	cosa_g = math.cos(angle_g)
	sina_g = math.sin(angle_g)
	cosa_b = math.cos(angle_b)
	sina_b = math.sin(angle_b)

	tilt = math.rad(get_angle_input(TILT))
	cosa_t = math.cos(tilt)
	sina_t = math.sin(tilt)

	phase = math.rad(get_angle_input(PHASE))
	cosa_p = math.cos(phase)
	sina_p = math.sin(phase)

	angle_e = math.rad(get_angle_input(ELEVATION) + 180)
	cosa_e = math.cos(angle_e)
	sina_e = math.sin(angle_e)
-- end

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
	-- perlin.offset = {}
	-- to contain instances of called noise

	math.randomseed(get_intslider_input(SEED))
	
	--[[
		embed in function called for each channel of noise generated. 
		function get_seed(); needs to provide viable offsets based on seed slider for each call. how is this implemented?
	]]-- 
	for i = 0, 255 do
		perlin.p[i] = math.random(255)
		perlin.p[256 + i] = perlin.p[i]
	end

	--[[
		model already exists for get_perlin_octaves() per loop in get_sample().
		get_perlin_octaves() can call perlin:noise(); will need revision based on determination of necessary arguments for intended use.
		x, y, z passthru, q instance variable
	]]-- 
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
	

-- mode block
		mode = get_intslider_input(MODE)
	--[[
		states transferred from checkboxes to mode intslider; flags set as follows:
		if mode == 1 then
			sphere = true
		elseif mode == 2 then
			sphere = true
			rgban = true
		elseif mode == 3 then
			sphere = true
			shaded = true
			fresnel = true
		elseif mode == 4 then
			sphere = true
			shaded = true
			fresnel = true
			planet = true
		elseif mode == 5 then
			sphere = true
			vectors = true
		elseif mode == 6 then
			map = true
		else
			map = true
			rgban = true
		end
	]]--
-- end

	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;


function get_sample(x, y)
	-- key variables
	local pr, x_ao, sh = 0, 0, 0
	local nr, ng, nb, ni = 0, 0, 0, 0
	local nx_r, nx_g, nx_b, ny_r, ny_g, ny_b, nz_r, nz_g, nz_b = 0, 0, 0, 0, 0, 0, 0, 0, 0 
	local px, px_p, py_e, px_r, px_g, px_b, py, pz, z_r, z_g, z_b = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local dr, dg, db, da = 0, 0, 0, 0
	local dx, dy, dz, da = 0, 0, 0, 0
	local sx, sy, sz, sa = 0, 0, 0, 0
	
	-- image generation
	-- sphere block
	if mode <= 5 then
		px = (x * 2.0) - 1.0
		px = px / radius
		py = (y * 2.0) - 1.0
		py = py / radius
		px_p = (x * 2.0) - 1.0
		px_p = px_p / radius
		py_e = (y * 2.0) - 1.0
		py_e = py_e / radius
		x_ao = (x * 2.0) - 1.0
		x_ao = x_ao / radius
		y_to = (y * 2.0) - 1.0
		y_to = y_to / radius
		local len = math.sqrt((px * px) + (py * py))
		if len > 1.0 then return 0,0,0,0 end

		z = -math.sqrt(1.0 - ((px * px) + (py * py)))
		pz = -math.sqrt(1.0 - ((px_p * px_p) + (py_e * py_e)))
		z_to = -math.sqrt(1.0 - ((x_ao * x_ao) + (y_to * y_to)))

		local tz = (cosa_t * z) - (sina_t * py)
		local ty = (sina_t * z) + (cosa_t * py)
		z = tz
		py = ty

		local tx_r = (cosa_r * px) - (sina_r * z)
		local tz_r = (sina_r * px) + (cosa_r * z)
		px_r = tx_r
		z_r = tz_r

		local tx_g = (cosa_g * px) - (sina_g * z)
		local tz_g = (sina_g * px) + (cosa_g * z)
		px_g = tx_g
		z_g = tz_g

		local tx_b = (cosa_b * px) - (sina_b * z)
		local tz_b = (sina_b * px) + (cosa_b * z)
		px_b = tx_b
		z_b = tz_b

		-- light and shadow
		local tpz = (cosa_e * pz) - (sina_e * py_e)
		local tpy_e = (sina_e * pz) + (cosa_e * py_e)
		pz = tpz
		py_e = tpy_e

		local tpz = (cosa_p * px_p) - (sina_p * pz)
		local tpx_p = (sina_p * px_p) + (cosa_p * pz)
		px_p = tpx_p
		pz = tpz

		-- fresnel or atmosphere
		local tz_to = (cosa_t0 * z_to) - (sina_t0 * y_to)
		local ty_to = (sina_t0 * z_to) + (cosa_t0 * y_to)
		z_to = tz_to
		y_to = ty_to

		local tx_ao = (cosa_a0 * x_ao) - (sina_a0 * z_to)
		local tz_to = (sina_a0 * x_ao) + (cosa_a0 * z_to)
		x_ao = tx_ao
		z_to = tz_to

		h,s,l = fromrgb(px_r,px_g,px_b)
		if OUTPUT_HEIGHT / OUTPUT_WIDTH == 2 then h = h * 2 - 1 end
		x, y = h, py / 2 + 0.5
	end
	-- end
	
	-- input maps
	roughness = ROUGHNESS_THRESHOLD + 	get_sample_grayscale(x, y, ROUGHNESS) * 
		(1.0 - ROUGHNESS_THRESHOLD)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local r1, g1, b1, a1 = get_sample_map(x, y, HIGH)
	local r2, g2, b2, a2 = get_sample_map(x, y, LOW)
	local r3, g3, b3, a3 = get_sample_map(x, y, OVERLAY)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION) 
	local osx, osy, osz, osa = get_sample_map(x, y, OFFSET)
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	if sx > 100 then sx = 100 end
	if sy > 100 then sy = 100 end
	if sz > 100 then sz = 100 end
	if sa > 100 then sa = 100 end
	-- end

	-- spherical map block
	if mode >= 6 then
		local x = x * aspect * math.pi
		local y = y * math.pi
		nx = math.cos(x) * math.sin(y)
		ny = math.sin(x) * math.sin(y)
		nz = math.cos(y)
		-- nx_r = math.cos(x) * math.sin(y)
		-- ny_r = math.sin(x) * math.sin(y)
		-- nz_r = math.cos(y)
		-- nx_g = math.cos(x + 1) * math.sin(y + 1)
		-- ny_g = math.sin(x + 1) * math.sin(y+ 1)
		-- nz_g = math.cos(y + 1)
		-- nx_b = math.cos(x + 2) * math.sin(y + 2)
		-- ny_b = math.sin(x + 2) * math.sin(y + 2)
		-- nz_b = math.cos(y + 2)
	end
	-- end

	-- noise generation
	NOISE_SIZE = (((sx + sy + sz + sa) * 0.25) ^ 2) 
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
	local octave_index 
	if mode <= 5 then
		px_r = px_r * (sx * sa) + osx
		px_g = px_g * (sx * sa) + osx
		px_b = px_b * (sx * sa) + osx
		
		py = py * (sy * sa) + osy
		
		z_r = z_r * (sz * sa) + osz
		z_g = z_g * (sz * sa) + osz
		z_b = z_b * (sz * sa) + osz
	else
		nx = nx * (sx * sa) + osx
		ny = ny * (sy * sa) + osy
		nz = nz * (sz * sa) + osz
		
		nx_r = nx + 1
		ny_r = ny + 1
		nz_r = nz + 1
		
		nx_g = nx + 2
		ny_g = ny + 2
		nz_g =  nz + 2
		
		nx_b = nx + 3
		ny_b = ny + 3
		nz_b = nz + 3
	end
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		-- ni = math.log(octave_index) % 1
		-- da = da * (dx + dy + dz * 0.333333333)
		if mode <= 5 then
			dr = dr + (opacity * perlin:noise(px_r * size, py * size, z_r * size)) * dx
			dg = dg + (opacity * perlin:noise(px_g * size, py * size, z_g * size)) * dy
			db = db + (opacity * perlin:noise(px_b * size, py * size, z_b * size)) * dz
			
			nr = nr + opacity * perlin:noise(px_r * size , py * size, z_r * size + dr)
			ng = ng + opacity * perlin:noise(px_g * size + dg, py * size, z_g * size)
			nb = nb + opacity * perlin:noise(px_b * size, py * size + db, z_b * size)
		else	
			--[[
				this mode eclipses the spherical modes, so angle input can be used to vary noise by channel. 
				advise users that rgb noise is dependant on rotation value.
			]]--
			-- dr = dr + (opacity * perlin:noise(nx * size,ny * size, nz * size)) * dx
			-- dg = dg + (opacity * perlin:noise(nx * size,ny * size, nz * size)) * dy
			-- db = db + (opacity * perlin:noise(nx * size, ny * size, nz * size)) * dz

			dr = dr + (opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size)) * dx
			dg = dg + (opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size)) * dy
			db = db + (opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size)) * dz
			
			-- dg = dg + (opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size)) * dy
			-- db = db + (opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size)) * dz
			-- dr = dr + (opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size)) * dx

			-- nr = nr + (opacity * perlin:noise(nx * size, ny * size, nz * size )+ dr)
			-- ng = ng + (opacity * perlin:noise(nx * size, ny* size, nz * size) + dg)
			-- nb = nb + (opacity * perlin:noise(nx * size, ny * size, nz * size) + db)
			
			nr = nr + (opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size )+ dr)
			ng = ng + (opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size) + dg)
			nb = nb + (opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size) + db)

			-- nr = nr + (opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size )+ dr)
			-- ng = ng + (opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size) + dg)
			-- nb = nb + (opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size) + db)

		end
	end
	-- contrast adjustments
	nr = (nr + 1.0) * 0.5
	ng = (ng + 1.0) * 0.5
	nb = (nb + 1.0) * 0.5
	nr = truncate(factor * (nr - 0.5) + 0.5)
	ng = truncate(factor * (ng - 0.5) + 0.5)
	nb = truncate(factor * (nb - 0.5) + 0.5)
	-- input curves
	pr = nr
	pr = get_sample_curve(x, y, pr, PROFILE)
	nr = get_sample_curve(x, y, nr, PROFILE)
	ng = get_sample_curve(x, y, ng, PROFILE)
	nb = get_sample_curve(x, y, nb, PROFILE)
	f = 1 - (x_ao * 0.8)
	f = get_sample_curve(x, y, f, FRESNEL)
	sh = px_p / 2 + 0.5
	sh = get_sample_curve(px_p, py_e, sh, PROFILE)
	atm = f - ((1 - sh) ^ 2)
	-- return conditions
	--[[
		input maps have different roles depending on mode. 
	]]--
		if mode == 1 then
			-- sphere = true
			-- blends forground HIGH and background LOW
			r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, pr, hdr)
			return r, g, b, a
		elseif mode == 2 then
			-- sphere = true
			-- rgban = true
			return nr, ng, nb, 1
		elseif mode == 3 then
			-- sphere = true
			r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, pr, hdr)
			-- blends in shadow overlay
			-- PROFILE applied to sh to control shadow sharpness.
			r, g, b, a = blend_multiply(r, g, b, a, sh, sh, sh, 1, 1, hdr)
			-- blends in lighting overlay
			-- r, g, b, a = blend_linear_dodge(r, g, b, a, sh, sh, sh, 0.5, 1, hdr)
			r, g, b, a = blend_screen(r, g, b, a, sh, sh, sh, 0.5, 1)
			-- fresnel = true
			-- blends in color fresnel overlay
			r, g, b, a = blend_normal(r, g, b, a, r3, g3, b3, a3, atm, hdr)
			return r, g, b, a 
		elseif mode == 4 then
			-- sphere = true
			-- planet = true
			-- blends clouds HIGH and surface LOW plus shaded with atmosphere in color fresnel overlay
			r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, 1, hdr)
			-- shaded = true
			-- blends in shadow overlay
			r, g, b, a = blend_multiply(r, g, b, a, sh, sh, sh, 1, 1, hdr)
			-- blends in lighting overlay
			r, g, b, a = blend_linear_dodge(r, g, b, a, sh, sh, sh, 0.5, 1, hdr)
			-- fresnel = true
			r, g, b, a = blend_normal(r, g, b, a, r3, g3, b3, a3, atm, hdr)
			return r, g, b, a 
		elseif mode == 5 then
			-- sphere = true
			-- vectors = true
			-- vectors ignores map inputs 
			return h, py, px_p, 1 
		elseif mode == 6 then
			map = true
			-- blends forground HIGH and background LOW
			r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, pr, hdr)
			return r, g, b, a 
		else
			-- map = true
			-- rgban = true
			return nr, ng, nb, 1
		end
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