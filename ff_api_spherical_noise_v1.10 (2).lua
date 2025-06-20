-- spherical perlin noise v.1.10
-- as originally encountered, an artifact appears on the equator using api perlin noise model. 
function prepare()
	--	constants
	AMPLITUDE_CORRECTION_FACTOR = 1.731628995
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001

	details = get_intslider_input(DETAILS)
	NOISE_SIZE = get_slider_input(SCALE)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2

	--	input values
	OCTAVES_COUNT = math.floor(details)

	remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	p = {}
	math.randomseed(get_intslider_input(SEED))
	for i=0,255 do
		p[i] = math.random(255)
		p[256+i] = p[i]
	end

	if (get_checkbox_input(RGBA_NOISE)) then
		rgban = true
	else
		rgban = false
	end
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r1, g1, b1, a1 = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))

	-- noise generation
	local roughness = (ROUGHNESS_THRESHOLD + 
		(get_sample_grayscale(x, y, ROUGHNESS) * 0.5 + 0.5) * 
		(1.0 - ROUGHNESS_THRESHOLD)) 
	
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

	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y)
	local ny = math.sin(x) * math.sin(y)
	local nz = math.cos(y)

	-- distortion by neighboring channel noise, modified by color input (power)
	local dx, dy, dz, dv = get_sample_map(x, y, DISTORTION) -- * 2
	-- noise or gradient calculations can be assigned to variables here 
	local nr, ng, nb, na = 0, 0, 0, 0
	local dr, dg, db, da = 0, 0, 0, 0
	dr = (dx+1.0)/2.0
	dg = (dy+1.0)/2.0
	db = (dz+1.0)/2.0
	da = (dv+1.0)/2.0
	nr = (nr+1.0)/2.0
	ng = (ng+1.0)/2.0
	nb = (nb+1.0)/2.0
	na = (na+1.0)/2.0

	nr = get_perlin_octaves(nx,ny,nz,dr,1)
	ng = get_perlin_octaves(nx,ny,nz,dg,2)
	nb = get_perlin_octaves(nx,ny,nz,db,3)
	na = get_perlin_octaves(nx,ny,nz,da)

	nr = truncate(factor * (nr - 0.5) + 0.5)
	ng = truncate(factor * (ng - 0.5) + 0.5)
	nb = truncate(factor * (nb- 0.5) + 0.5)
	na = truncate(factor * (na- 0.5) + 0.5)

	nr = get_sample_curve(x,y,nr,PROFILE)
	ng = get_sample_curve(x,y,ng,PROFILE)
	nb = get_sample_curve(x,y,nb,PROFILE)
	na = get_sample_curve(x,y,na,PROFILE)

	r, g, b, a = blend_normal(r1, g1, b1, a1, r2, g2, b2, a2, na, hdr)
	if rgban then
		return nr,ng,nb,na
	else
		return r, g, b, a 
	end
	--	return dx, dy, dz, da
end;

function  get_perlin_octaves(x,y,z,d,channel)
	local cx = 0
	local cy = 0
	local cz = 0
	local cd = d
	if channel == 1 then
		cx = x
		cy = y
		cz = z
	elseif channel == 2 then
		cx = x+(OUTPUT_WIDTH*0.65)
		cy = y+(OUTPUT_HEIGHT*0.35)
		cz = z+(OUTPUT_WIDTH*0.25)
	elseif channel == 3 then
		cx = x+(OUTPUT_WIDTH*0.35)
		cy = y+(OUTPUT_HEIGHT*0.65)
		cz = z+(OUTPUT_WIDTH*0.5)
	else
		cx = x+(OUTPUT_WIDTH*0.5)
		cy = y+(OUTPUT_HEIGHT*0.5)
		cz = z+(OUTPUT_WIDTH*0.75)
	end;
	local alpha = 0
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		cd = cd + (opacity * (2*get_perlin_noise(cx, cy, cz, size) - 1)) 
		alpha = alpha + ((opacity * (2*get_perlin_noise(cx, cy, cz, size) - 1)) * cd)
	end
	alpha = (alpha * NORM_FACTOR + AMPLITUDE_CORRECTION_FACTOR) * 
		(0.5 / AMPLITUDE_CORRECTION_FACTOR)
	return alpha
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