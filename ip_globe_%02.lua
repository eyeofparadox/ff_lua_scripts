-- 3d sphere -- how is the noise mapped to a 3d sphere? how would one map x:red and y:green gradients instead?
function prepare()
	-- tilt & rotation precalc
	radius = math.rad(get_slider_input(RADIUS))
	angle = math.rad(get_angle_input(ROTATION))
	cosa = math.cos(angle)
	sina = math.sin(angle)
	tilt = math.rad(get_angle_input(TILT))
	cosa2 = math.cos(tilt)
	sina2 = math.sin(tilt)

	-- p = {}
	-- math.randomseed(get_intslider_input(SEED))
	-- for i=0,255 do
		-- p[i] = math.random(255)
		-- p[256+i] = p[i]
	-- end

-- --	constants
	-- ROUGHNESS_THRESHOLD = 0.00001
	-- REMAINDER_THRESHOLD = 0.00001

-- --	input values
	-- local details = get_slider_input(DETAILS) * 10 + 1
	-- OCTAVES_COUNT = math.floor(details)

	-- NOISE_SIZE = get_slider_input(SCALE)
	-- local remainder = details - OCTAVES_COUNT
	-- if (remainder > REMAINDER_THRESHOLD) then
		-- OCTAVES_COUNT = OCTAVES_COUNT + 1
	-- end
	
	-- local roughness = ROUGHNESS_THRESHOLD + 
		-- get_slider_input(ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	
	-- OCTAVES = {}
	-- local cell_size = (0.01 + NOISE_SIZE * 0.99) * 10
	-- local scale = roughness
	-- local octave_index
	-- for octave_index = 1, OCTAVES_COUNT do
		-- if (scale < ROUGHNESS_THRESHOLD) then
			-- OCTAVES_COUNT = octave_index - 1
			-- break
		-- end
		-- OCTAVES[octave_index] = {cell_size, scale}
		-- cell_size = cell_size * 2.0
		-- scale = scale * roughness
	-- end
	
	-- if (remainder >= 0.001) then
		-- OCTAVES[OCTAVES_COUNT][2] = OCTAVES[OCTAVES_COUNT][2] * remainder
	-- end

	-- NORM_FACTOR = 0
	-- for octave_index = 1, OCTAVES_COUNT do
		-- NORM_FACTOR = NORM_FACTOR + OCTAVES[octave_index][2]-- ^ 2
	-- end
end;


function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, SOURCE)
	-- color gradient example
	-- 	local r = x
	-- 	local g = y
	-- 	local b = (x + y) / 2
	-- 	local a = 1
	-- image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))

	local tz = (cosa2 * z) - (sina2 * py)
	local ty = (sina2 * z) + (cosa2 * py)
	z = tz
	py = ty

	local tx = (cosa * px) - (sina * z)
	local tz = (sina * px) + (cosa * z)
	px = tx
	z = tz

	-- local n = 0
	-- local octave_index 
	-- for octave_index = 1, OCTAVES_COUNT do
		-- local size = OCTAVES[octave_index][1]
		-- local opacity = OCTAVES[octave_index][2]
		-- local noise_z = octave_index
		-- n = n + (opacity * noise(px*size,py*size,(z*size)+noise_z))
	-- end
	-- n = (n+1.0)/2.0

	-- return n,n,n,1
		return px/2+.5,py/2+.5,z/2+.5,a
end;

-- function noise(x, y, z) 
  -- local X = math.floor(x) % 256
  -- local Y = math.floor(y) % 256
  -- local Z = math.floor(z) % 256
  -- x = x - math.floor(x)
  -- y = y - math.floor(y)
  -- z = z - math.floor(z)
  -- local u = fade(x)
  -- local v = fade(y)
  -- local w = fade(z)

  -- A   = p[X  ]+Y
  -- AA  = p[A]+Z
  -- AB  = p[A+1]+Z
  -- B   = p[X+1]+Y
  -- BA  = p[B]+Z
  -- BB  = p[B+1]+Z

  -- return lerp(w, lerp(v, lerp(u, grad(p[AA  ], x  , y  , z   ), 
                                 -- grad(p[BA  ], x-1, y  , z   )), 
                         -- lerp(u, grad(p[AB  ], x  , y-1, z   ), 
                                 -- grad(p[BB  ], x-1, y-1, z   ))),
                 -- lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  
                                 -- grad(p[BA+1], x-1, y  , z-1 )),
                         -- lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
                                 -- grad(p[BB+1], x-1, y-1, z-1 )))
  -- )
-- end;


-- function fade(t)
  -- return t * t * t * (t * (t * 6 - 15) + 10)
-- end;


-- function lerp(t,a,b)
  -- return a + t * (b - a)
-- end;


-- function grad(hash,x,y,z)
  -- local h = hash % 16
  -- local u 
  -- local v 

  -- if (h<8) then u = x else u = y end
  -- if (h<4) then v = y elseif (h==12 or h==14) then v=x else v=z end
  -- local r

  -- if ((h%2) == 0) then r=u else r=-u end
  -- if ((h%4) == 0) then r=r+v else r=r-v end
	-- return r