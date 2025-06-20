-- 3d perlin sphere v.3.1
	-- produces grayscale or rgb noise mapped to a 3d sphere 
	-- adds internal rgb distortion with grayscale control
function prepare()
	--	constants
	ROUGHNESS_THRESHOLD = 0.00000001
	REMAINDER_THRESHOLD = 0.00000001

	details = get_intslider_input(DETAILS)
	NOISE_SIZE = get_slider_input(SCALE)
	frame = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

	--	input values
	OCTAVES_COUNT = math.floor(details)

	remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	-- tilt & rotation precalc
	radius = get_slider_input(RADIUS)

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

	p = {}
	math.randomseed(get_intslider_input(SEED))
	for i=0,255 do
		p[i] = math.random(255)
		p[256+i] = p[i]
	end

	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
	if (get_checkbox_input(RGBA_NOISE)) then
		rgban = true
	else
		rgban = false
	end
	if ( get_checkbox_input(MAP)) then
		map = true
	else
		map = false
	end
end;



function get_sample(x, y)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))

	-- noise generation
	local roughness = (ROUGHNESS_THRESHOLD + 
		(get_sample_grayscale(x, y, ROUGHNESS) * 0.5 + 0.5) * 
		(1.0 - ROUGHNESS_THRESHOLD)) -- * 1.875 
	
	OCTAVES = {}
	local cell_size = (math.log(NOISE_SIZE + 0.0001) * 0.99)
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
	
	if (remainder >= 0.00000001) then
		OCTAVES[OCTAVES_COUNT][2] = OCTAVES[OCTAVES_COUNT][2] * remainder
	end

	NORM_FACTOR = 0
	for octave_index = 1, OCTAVES_COUNT do
		NORM_FACTOR = NORM_FACTOR + OCTAVES[octave_index][2]-- ^ 2
	end

	-- map generation 
	local dispx = x * frame * math.pi
	local dispy = y * math.pi
	mx = math.cos(dispx) * math.sin(dispy)
	my = math.sin(dispx) * math.sin(dispy)
	mz = math.cos(dispy)

		-- distortion by neighboring channel noise, modified by color input (power)
		local dx, dy, dz, da = get_sample_map(x, y, DISTORTION) -- * 2
		-- noise or gradient calculations can be assigned to variables here 
		local mr, mg, mb, ma = 0, 0, 0, 0
		local dr, dg, db, da = 0, 0, 0, 0
		local octave_index 
		for octave_index = 1, (OCTAVES_COUNT/10) do
			local size = OCTAVES[octave_index][1]
			local opacity = OCTAVES[octave_index][2]
			local noise_z = octave_index
			dr = dr + (opacity * noise(mx*size,my*size,((mz*size)+noise_z)+OUTPUT_WIDTH * -1)) * dx
			dg = dg + (opacity * noise(mx*size,my*size,((mz*size)+noise_z)+OUTPUT_WIDTH * -2)) * dy
			db = db + (opacity * noise(mx*size,my*size,((mz*size)+noise_z)+OUTPUT_WIDTH * -3)) * dz
			mr = mr + (opacity * noise(mx*size+dr,my*size+dg,((mz*size)+noise_z+db)+OUTPUT_WIDTH))
			mg = mg + (opacity * noise(mx*size+dg,my*size+db,((mz*size)+noise_z+dr)+OUTPUT_WIDTH * 2))
			mb = mb + (opacity * noise(mx*size+db,my*size+dr,((mz*size)+noise_z+dg)+OUTPUT_WIDTH *3))
		end
		mr = (mr+1.0)/2.0
		mg = (mg+1.0)/2.0
		mb = (mb+1.0)/2.0

		ma = ((mr+mg+mb)/2)^2

	-- sphere generation and manipulation
	-- origin to center
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	local px_0 = px
	local py_0 = py
	-- set sphere radius (max == screen height)
	-- displaces but only in circumference; 
	-- rotation and tilt have to be applied, must also apply x,y,z influence on shape
	px = px/radius -- ((radius+mr)/2) 
	py = py/radius -- ((radius+mg)/2)
	-- px = px/((radius+mr)/2) 
	-- py = py/((radius+mg)/2)
	local len = math.sqrt((px*px)+(py*py))
	-- check radius and clip
	if len > 1.0 then return 0,0,0,0 end

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))
	-- local z = ((radius+mb)/2) -- -math.sqrt(1.0 - ((px*px)+(py*py)))

	px_0 = px_0/((radius+mr)/2) 
	py_0 = py_0/((radius+mg)/2)
	z_0 = ((radius+mb)/2) -- -math.sqrt(1.0 - ((px*px)+(py*py)))

	-- mapping for rotation and tilt
	local tz_0 = (cosa_t * z) - (sina_t * py)
	local ty_0 = (sina_t * z) + (cosa_t * py)
	z_0 = tz_0
	py_0 = ty_0

	local tx_0 = (cosa_r * px) - (sina_r * z)
	local tz_r0= (sina_r * px) + (cosa_r * z)
	px_0 = tx_0
	z_0= tz_0

	-- displaces but only in circumference; 
	-- rotation and tilt have to be applied, must also apply x,y,z influence on shape
	-- px = px/radius -- ((radius+mr)/2) 
	-- py = py/radius -- ((radius+mg)/2)
	-- mapping for rotation and tilt
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

	h,s,l = fromrgb(px_r,px_g,px_b)
	if aspect then h = h * 2 - 1 end

	-- distortion by neighboring channel noise, modified by grayscale input (power)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION) -- * 2
	-- noise or gradient calculations can be assigned to variables here 
	local nr, ng, nb, na = 0, 0, 0, 0
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		local noise_z = octave_index
		dr = dr + (opacity * noise(px_r*size,py*size,((z_r*size)+noise_z)+OUTPUT_WIDTH * -1)) * dx
		dg = dg + (opacity * noise(px_g*size,py*size,((z_g*size)+noise_z)+OUTPUT_WIDTH * -2)) * dy
		db = db + (opacity * noise(px_b*size,py*size,((z_b*size)+noise_z)+OUTPUT_WIDTH * -3)) * dz
		nr = nr + (opacity * noise(px_r*size+dr,py*size+dg,((z_r*size)+noise_z+db)+OUTPUT_WIDTH))
		ng = ng + (opacity * noise(px_g*size+dg,py*size+db,((z_g*size)+noise_z+dr)+OUTPUT_WIDTH * 2))
		nb = nb + (opacity * noise(px_b*size+db,py*size+dr,((z_b*size)+noise_z+dg)+OUTPUT_WIDTH * 3))
	end
	nr = (nr+1.0)/2.0
	ng = (ng+1.0)/2.0
	nb = (nb+1.0)/2.0

	na = ((nr+ng+nb)/2)^2
	nr = truncate(factor * (nr - 0.5) + 0.5)
	ng = truncate(factor * (ng - 0.5) + 0.5)
	nb = truncate(factor * (nb - 0.5) + 0.5)
	na = truncate(factor * (na - 0.5) + 0.5)

	nr = get_sample_curve(x,y,nr,PROFILE)
	ng = get_sample_curve(x,y,ng,PROFILE)
	nb = get_sample_curve(x,y,nb,PROFILE)
	na = get_sample_curve(x,y,na,PROFILE)

	-- map inputs to sphere
	local r1, g1, b1, a1 = get_sample_map(h, py/2+0.5, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(h, py/2+0.5, FOREGROUND)
	r, g, b, a = blend_normal(r1, g1, b1, a1, r2, g2, b2, a2, na, hdr)
	
	-- return nr,nr,nr,1
	-- return ng,ng,ng,1
	-- return nb,nb,nb,1
	-- return px/2+.5,0,0,1
	if rgban then
		return nr,ng,nb,na 
	elseif map then
		return mr,mg,mb,1
	else
		return r, g, b, a 
	end

end;

function noise(x, y, z) 
	local X = math.floor(x) % 256
	local Y = math.floor(y) % 256
	local Z = math.floor(z) % 256
	x = x - math.floor(x)
	y = y - math.floor(y)
	z = z - math.floor(z)
	local u = fade(x)
	local v = fade(y)
	local w = fade(z)

	A = p[X ]+Y
	AA = p[A]+Z
	AB = p[A+1]+Z
	B = p[X+1]+Y
	BA = p[B]+Z
	BB = p[B+1]+Z

	return lerp(w, lerp(v, lerp(u, grad(p[AA ], x , y , z ), 
			grad(p[BA ], x-1, y , z )), 
		lerp(u, grad(p[AB ], x , y-1, z ), 
			grad(p[BB ], x-1, y-1, z ))), 
		lerp(v, lerp(u, grad(p[AA+1], x , y , z-1 ), 
			grad(p[BA+1], x-1, y , z-1 )), 
		lerp(u, grad(p[AB+1], x , y-1, z-1 ), 
			grad(p[BB+1], x-1, y-1, z-1 )))
	)
end;

function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end;

function lerp(t,a,b)
	return a + t * (b - a)
end;

function grad(hash,x,y,z)
	local h = hash % 16
	local u 
	local v 

	if (h<8) then u = x else u = y end
	if (h<4) then v = y elseif (h==12 or h==14) then v=x else v=z end
	local r

	if ((h%2) == 0) then r=u else r=-u end
	if ((h%4) == 0) then r=r+v else r=r-v end
	return r
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
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