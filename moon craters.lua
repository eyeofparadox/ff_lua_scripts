-- 3d noise on a sphere with craters/spherical height maps
function prepare()
	--noise precalc
	-- toRad = 180/math.pi

	radius = math.rad(get_slider_input(RADIUS))

	p = {}
	math.randomseed( get_intslider_input(SEED) )
	for i=0,255 do
		p[i] = math.random(255)
		p[256+i] = p[i]
	end

--	Noise Constants
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001

--	Noise Input values
	local details = get_slider_input(DETAILS) * 10 + 1
	OCTAVES_COUNT = math.floor(details)

	NOISE_SIZE = get_slider_input(SCALE)
	local remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	local roughness = ROUGHNESS_THRESHOLD + 
		get_slider_input(ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	
	OCTAVES = {}
	local cell_size = (0.01 + NOISE_SIZE * 0.99) * 10
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
		NORM_FACTOR = NORM_FACTOR + OCTAVES[octave_index][2]-- ^ 2
	end

	--other
	bumpiness = get_slider_input(BUMPINESS)
	unbump = 1.0-bumpiness

	crater_roughness = get_slider_input(CRATER_ROUGHNESS)* 0.8
	crater_overlap = 1.0 - (get_slider_input(CRATER_OVERLAP)* 0.9)
	max_crater_size = get_slider_input(MAX_CRATER_SIZE)* 0.2

	--make craters
	cx = {}
	cy = {}
	cz = {}
	ra = {}
	rsq = {}
	ckill = {}

	count = get_intslider_input(CRATER_COUNT)

	max_crater = 0.15
	
	local dead = 0

	for i=1,count do
		dead = 1
		while(dead == 1) do
		local x = 0
		local y = 0
		local z = 0
		while x == 0 and y == 0 and z == 0 do
			x = -1.0 + (math.random()*2.0)
			y = -1.0 + (math.random()*2.0)
			z = -1.0 + (math.random()*1.0)
		end
		local len = math.sqrt((x*x)+(y*y)+(z*z))
		cx[i] = x/len
		cy[i] = y/len
		cz[i] = z/len
	
		ra[i] = 0.01+(math.random()*max_crater_size)
		rsq[i] = ra[i]*ra[i]

		ckill[i] = 0

		--too close to another?
		if i > 1 then
			for j = 1, i-1 do
				local xd = cx[i] - cx[j]
				local yd = cy[i] - cy[j]
				local zd = cz[i] - cz[j]
				local d = (xd*xd)+(yd*yd)+(zd*zd)
				local d2 = (ra[i]+ra[j])*crater_overlap
				if d < d2*d2 then 
					ckill[i] = 1 
					break 
				end
			end
		end
		dead = ckill[i]
		end
	end

end;


function get_sample(x, y)
	-- Image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))

	local n = 0
	local octave_index 
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		local noise_z = octave_index
		n = n + (opacity * noise(px*size,py*size,(z*size)+noise_z))
	end
	n = (n+1.0)/2.0
	n = get_sample_curve(x, y, n, HEIGHT_CURVE)
	local n1 = n

	local crater = get_sample_curve(x,y, 0, CRATER_CURVE)
	local base_height = crater
	for i=1,count do
		local r = ra[i] - (crater_roughness*ra[i]*n1)
		local xd = px - cx[i]
		local yd = py - cy[i]
		local zd = z - cz[i]
		local d = (xd*xd)+(yd*yd)+(zd*zd)
		if d < r*r then
			d = 1.0 - (math.sqrt(d)/r)
			local crater2 = get_sample_curve(x, y, d, CRATER_CURVE)-- * (r/max_crater)
			if crater2 < base_height then 
				crater = crater2
			else
				crater = crater+(crater2-base_height)
			end
		end
	end

	n = (crater * 0.5) + (n*0.5)
	n1 = n
	n = -z*unbump+(n*bumpiness)

	return n,n,n,n1
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

  A   = p[X  ]+Y
  AA  = p[A]+Z
  AB  = p[A+1]+Z
  B   = p[X+1]+Y
  BA  = p[B]+Z
  BB  = p[B+1]+Z

  return lerp(w, lerp(v, lerp(u, grad(p[AA  ], x  , y  , z   ), 
                                 grad(p[BA  ], x-1, y  , z   )), 
                         lerp(u, grad(p[AB  ], x  , y-1, z   ), 
                                 grad(p[BB  ], x-1, y-1, z   ))),
                 lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  
                                 grad(p[BA+1], x-1, y  , z-1 )),
                         lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
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