ff forums formatting
[B]bold[/B], [I]italics[/I], [U]underline[/U], [URL=[URL]https://www.filterforge.com/forum/new_topic.php?fid=5]link[/URL], [QUOTE]quote[/QUOTE], [CODE]code[/CODE]


-- 3d perlin spherical map v.0.0.4 - improved perlin noise, distortion power, get_perlin_octaves
function prepare()
 -- constants
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

 -- input values
	details = get_slider_input(DETAILS) * 10 + 0.0001
	grain = (get_slider_input(GRAIN) * 5) + 0.0001
	power = get_slider_input(POWER) * 10
	OCTAVES_COUNT = math.floor(details)
	
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

-- end noise block

-- mode block
	mode = get_intslider_input(MODE)
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
-- end
end;


function get_sample(x, y)
	-- key variables
	local nr, ng, nb = 0, 0, 0
	local nx, ny, nz = 0, 0, 0
	local nx_r, nx_g, nx_b = 0, 0, 0
	local ny_r, ny_g, ny_b = 0, 0, 0
	local nz_r, nz_g, nz_b = 0, 0, 0
	local rc, gc, bc, ac = 0, 0, 0, 0
	rd, gd, bd, ad = 0, 0, 0, 0
	rs, gs, bs, as = 0, 0, 0, 0
	
	local rr, gr, br, ar = get_sample_map(x, y, ROUGHNESS)
	local rc, gc, bc, ac = get_sample_map(x, y, CONTRAST) -- * 2 - 1
	local r1, g1, b1, a1 = get_sample_map(x, y, HIGH)
	local r2, g2, b2, a2 = get_sample_map(x, y, LOW)
	local r3, g3, b3, a3 = get_sample_map(x, y, OVERLAY)
	local ros, gos, bos, osa = get_sample_map(x, y, OFFSET)
	rd, gd, bd, ad = get_sample_map(x, y, DISTORTION) 
	rs, gs, bs, as = get_sample_map(x, y, SCALE)
	if rs > 100 then rs = 100 end
	if gs > 100 then gs = 100 end
	if bs > 100 then bs = 100 end
	if as > 100 then as = 100 end
	rd = rd * power
	gd = gd * power
	bd = bd * power

	-- spherical map block
	local x = x * aspect * math.pi
	local y = y * math.pi
	nx = math.cos(x) * math.sin(y)
	ny = math.sin(x) * math.sin(y)
	nz = math.cos(y)
	-- end

	nx = nx * (rs * as) + (ros * power * 0.1)
	ny = ny * (gs * as) + (gos* power * 0.1)
	nz = nz * (bs * as) + (bos* power * 0.1)
	
	nx_r = nx + 1
	ny_r = ny + 1
	nz_r = nz + 1
	
	nx_g = nx + 2
	ny_g = ny + 2
	nz_g =  nz + 2
	
	nx_b = nx + 3
	ny_b = ny + 3
	nz_b = nz + 3
	
	-- args: o_noise, o_roughness, o_contrast, o_distortion, o_noise_x, o_noise_y, o_noise_z
	nr = gen_perlin_octaves(nr, rr, rc, rd, nx_r, ny_r, nz_r)
	ng = gen_perlin_octaves(ng, gr, gc, gd, nx_g, ny_g, nz_g)
	nb = gen_perlin_octaves(nb, br, bc, bd, nx_b, ny_b, nz_b)
	h,s,l = fromrgb(nr, ng, nb)

	-- input curves
	l = get_sample_curve(x, y, l, PROFILE)
	nr = get_sample_curve(x, y, nr, PROFILE)
	ng = get_sample_curve(x, y, ng, PROFILE)
	nb = get_sample_curve(x, y, nb, PROFILE)

	-- return conditions
	if mode == 1 then
		-- map = true
		-- channel = r
		-- blends forground HIGH and background LOW
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, nr, hdr)
		return r, g, b, a
	elseif mode == 2 then
		-- map = true
		-- channel = g
		-- blends forground HIGH and background LOW
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, ng, hdr)
		return r, g, b, a
	elseif mode == 3 then
		-- map = true
		-- channel = b
		-- blends forground HIGH and background LOW
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, nb, hdr)
		return r, g, b, a
	elseif mode == 4 then
		-- map = true
		-- channel = l -- (luminance)
		-- blends forground HIGH and background LOW
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, l, hdr)
		return r, g, b, a
		-- return nr, ng, nb, 1
	elseif mode == 5 then
		-- map = true
		-- planet = true
		-- blends clouds HIGH and surface LOW plus shaded with atmosphere in color fresnel overlay
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1, 1, hdr)
		-- atmosphere = true
		r, g, b, a = blend_normal(r, g, b, a, r3, g3, b3, a3, 0.8, hdr)
		-- blends in clouds overlay
		r, g, b, a = blend_linear_dodge(r, g, b, a, r1, g1, b1, a1, 0.1, hdr)
		return r, g, b, a 
	else
		-- map = true
		-- rgban = true
		return nr, ng, nb, 1
	end
-- debug
		-- return rc, gc, bc, ac
end;


function gen_perlin_octaves(o_noise, o_roughness, o_contrast, o_distortion, o_noise_x, o_noise_y, o_noise_z)
	local distortion = 0
	o_roughness = set_o_roughness(o_roughness)
	o_contrast = o_contrast  * 2 - 1
	factor = (259 * (o_contrast + 1)) / (1 * (259 - o_contrast))
	NOISE_SIZE = (((rs + gs + bs + as) * 0.25) ^ 2) 
	-- perlin octaves initialization
	remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	OCTAVES = {}
	local cell_size = (0.01 + NOISE_SIZE * 0.99) * grain
	local scale = o_roughness
	local octave_index
	for octave_index = 1, OCTAVES_COUNT do
		if (scale < ROUGHNESS_THRESHOLD) then
			OCTAVES_COUNT = octave_index - 1
			break
		end
		OCTAVES[octave_index] = {cell_size, scale}
		cell_size = cell_size * 2.0
		scale = scale * o_roughness
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
		distortion = opacity * perlin:noise(rd + o_noise_x * size,gd + o_noise_y * size, bd + o_noise_z * size)
		o_noise = o_noise + (opacity * perlin:noise(o_noise_x * size,o_noise_y * size, o_noise_z * size )+ distortion)
	end

	-- contrast adjustments
	o_noise = (o_noise + 1.0) * 0.5
	o_noise = truncate(factor * (o_noise - 0.5) + 0.5)
	return o_noise
end;


function set_o_roughness(o_roughness)
	o_roughness = ROUGHNESS_THRESHOLD +  o_roughness * (1.0 - ROUGHNESS_THRESHOLD)
	return o_roughness
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