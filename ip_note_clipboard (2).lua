
Look into "domain warping", using fBm to warp a space of a fBm. Also, dig into "flow noise", where coordinates are displaced with the derivative (gradient) of the noise, and distance mapping via "signed distance field"; in particular, look for ways to use image input as the seed. 

good overview of noise concepts:https://www.redblobgames.com/articles/noise/introduction.html, https://www.redblobgames.com/maps/terrain-from-noise/

--[[
	-- ch_factor = set_ch_factor(ch_contrast)
, factor = 0,
-- function  set_ch_factor(ch_contrast)
	-- ch_factor = (259 * (ch_contrast + 1)) / (1 * (259 - ch_contrast))
	-- return ch_factor
-- end;
]]--


	nx = nx * (sx * sa) + osx + dx
	ny = ny * (sy * sa) + osy + dy
	nz = nz * (sz * sa) + osz + dz
	
	nx_r = nx + 1
	ny_r = ny + 1
	nz_r = nz + 1
	
	nx_g = nx + 2
	ny_g = ny + 2
	nz_g = nz + 2
	
	nx_b = nx + 3
	ny_b = ny + 3
	nz_b = nz + 3
	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		dr = dr + opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size)
		dg = dg + opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size)
		db = db + opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size)

		nr = nr + opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size)
		ng = ng + opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size)
		nb = nb + opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size)


--[[
	distortion 0.0
]]--
	function prepare()
	mode = get_checkbox_input(MODE)
	p = get_slider_input(PERCENTAGE)
end;

function get_sample(x, y)
	rd, gd, bd, ad = get_sample_map(x, y, DISTORTER)
	if mode then rd, gd, bd = rd * 2 + 1, gd * 2 + 1, bd * 2 + 1 end  
	samplex = x + ((rd + bd/2) * ad * p)
	sampley = y + ((gd + bd/2) * ad * p)

	r, g, b, a = get_sample_map(samplex, sampley, SOURCE)
	return r, g, b, a
end;
--[[
	distortion 0.1
]]--
function prepare()
	mode = get_checkbox_input(MODE)
	-- p = get_slider_input(PERCENTAGE)
end;

function get_sample(x, y)
	rd, gd, bd, ad = get_sample_map(x, y, DISTORTER)
	p = get_sample_grayscale(x, y, PERCENTAGE)
	if mode then rd, gd, bd = rd * 2 + 1, gd * 2 + 1, bd * 2 + 1 end  
	dx = x + ((rd + bd/2) * ad * p)
	dy = y + ((gd + bd/2) * ad * p)

	r, g, b, a = get_sample_map(dx, dy, SOURCE)
	return r, g, b, a
end;

-- constrain values to an arbitrary, set range
function wrap(x, min_val, max_val)
	local range = max_val - min_val + 1
	return ((x - min_val) % range) + min_val
end;

-- debugging for 'ff_api_spherical_worley_noise_v009.lua'
function estimate_num_points(distance, width, height)
    num_points = 0
    for x in range(width) do
        for y in range(height) do
            dist = get_distance(x, y, distance, width, height)
            if dist < distance then
                 num_points = num_points + 1
            end
        end
    return num_points
    end
end 

function generate_table()
    distances = {2, 4, 8, 16, 32, 64}
    sizes = {512, 1024, 2048, 4096}
    for d in distances do
        print(f"Distance: {d}")
        print("Size\tEstimate")
        for s in sizes do
            num_points = estimate_num_points(d, s, s)
            print(f"{s}\t{num_points}")
        print()
        end
    end
end

--[[
]]--
-- XY Remap
function prepare()
ox = get_slider_input(X_OFFSET)
oy = get_slider_input(Y_OFFSET)
ux = get_checkbox_input(USE_X_REMAP)
uy = get_checkbox_input(USE_Y_REMAP)
end;

function get_sample(x, y)

ofx = 0.5 - ox
ofy = -0.5 + oy

xr, xg, xb, xa = get_sample_map(x, y, X_REMAP)
yr, yg, yb, ya = get_sample_map(x, y, Y_REMAP)

local cx = x
local cy = y

if ux then
	cx = (xr+xg+xb)/3
else
	cx = x
end;

if uy then
	cy = (yr+yg+yb)/3
else
	cy = y
end;

r, g, b, a = get_sample_map(ofx+cx, ofy+cy, SOURCE)

	return r, g, b, a
end;

James
So far I haven't tried using arrays in a script and I wanted to use one in a function, however the following code returns a error, any reason why?

function prepare()
end;

function mat4({r1,r2,r3,r4})
    local matrix = {}
    matrix[1], matrix[2], matrix[3], matrix[4] = r1, r2, r3, r4
    return matrix[1], matrix[2], matrix[3], matrix[4]
end

function get_sample(x, y)
   return mat4({1.0,0.5,0.25,1})
end;


I'm using FF3, perhaps this is due to the version I am using or maybe a limitation in map scripts? or hopefully just an error in my code.

When using an array in the prepare function it seems to work though.

function prepare()
   matrix = {1.0,0.5,0.25,1.0}
end;

function get_sample(x, y)
   return matrix[1],matrix[2],matrix[3],matrix[4]
end;
Posted: June 27, 2021 3:47 am	 

_Agentslimepunk

function prepare()

end;

function get_sample(x, y)
   -- image generation
   mat4(1.0, 0.5, 0.25, 1)
   local r = matrix[2]
   local g = matrix[3]
   local b = matrix[2] + y
   local a = 1
   return r, g, b, a
end;

function mat4(r1, r2, r3, r4)
   matrix = {r1, r2, r3, r4}
   return matrix
end;


Is this basically what you were after?
Posted: January 14, 2023 7:57 am


emme wrote:
Here is a script that rotates an image around a point:

function prepare()
   ox,oy = get_slider_input(ORIGIN_X),get_slider_input(ORIGIN_Y)
   d = math.rad(get_angle_input(ROTATION))
   s,c = math.sin(d), math.cos(d)
end;

function get_sample(x, y)
   local nx = c * (x-ox) - s * (y-oy) + ox
   local ny = s * (x-ox) + c * (y-oy) + oy
   local r,g,b,a = get_sample_map(nx, ny, SOURCE)
   return r,g,b,a
end;


David Roberson
Artist
Posts: 366
Filters: 36
I have spent the past few days working on adding better rotation controls to map scripts derived fr om Planet Maker 3D by andyz. Along the way I visited Rotating 3D shapes wh ere I was able to fill in the blanks in my understanding of 3D rotations. I applied that to the script used in my current project, but I'm also interested in using the functions from that page to emulate the Angle control of Perlin Noise in a 3D Perlin Noise map script.

I made an attempt to convert the JS to Lua, but I think I need a more experienced set of eyes to tell if I'm on the right track. At the moment, I only have a vague idea how I'd use the functions in question.

Take a look:

-- rotation functions js to lua
function prepare()
   -- input
   local theta = math.rad(get_angle_input(THETA))
   -- precalc, global vars for rotation functions
   sin_theta = sin(theta);
   cos_theta = cos(theta);
end;


function get_sample(x, y)
   -- incomplete, pass array as var?
   x, y, z = rotate_z3d(x,y,sin_theta,cos_theta), rotate_x3d(x,y,sin_theta,cos_theta), rotate_y3d(x,y,sin_theta,cos_theta)
end;


function rotate_z3d(x,y,sin_theta,cos_theta)
   for node_index = 0, NODE_COUNT  do
   local NODE = {}
   local NODE_COUNT
   local node_index
      if (node_index < nodes_length) then
         NODE_COUNT = node_index - 1
         break
      NODE[node_index] = {x,y}
      y = y * cos_theta - z * sin_theta
      z = z * cos_theta + y * sin_theta
   end
  
  
end;
function rotate_x3d(x,y,sin_theta,cos_theta)
   local NODE = {}
   local NODE_COUNT
   local node_index
  for node_index = 0, NODE_COUNT  do
      if (node_index < nodes_length) then
         NODE_COUNT = node_index - 1
         break
      NODE[node_index] = {x,y}
      y = y * cos_theta - z * sin_theta
      z = z * cos_theta + y * sin_theta
   end
  
  
end;
= function rotate_y3d(x,y,sin_theta,cos_theta)
   local NODE = {}
   local NODE_COUNT
   local node_index
  for node_index = 0, NODE_COUNT  do
      if (node_index < nodes_length) then
         NODE_COUNT = node_index - 1
         break
      NODE[node_index] = {x,y}
      y = y * cos_theta - z * sin_theta
      z = z * cos_theta + y * sin_theta
   end
end;


Here is the JS:

// rotation functions from js

   var rotateZ3D = function(theta) {
      var sinTheta = sin(theta);
      var cosTheta = cos(theta);
      for (var n = 0; n < nodes.length; n++) {
        var node = nodes[n];
        var x = node[0];
        var y = node[1];
        node[0] = x * cosTheta - y * sinTheta;
        node[1] = y * cosTheta + x * sinTheta;
      }
   };
   var rotateX3D = function(theta) {
      var sinTheta = sin(theta);
      var cosTheta = cos(theta);
      for (var n = 0; n < nodes.length; n++) {
        var node = nodes[n];
        var y = node[1];
        var z = node[2];
        node[1] = y * cosTheta - z * sinTheta;
        node[2] = z * cosTheta + y * sinTheta;
      }
   };
   var rotateY3D = function(theta) {
      var sinTheta = sin(theta);
      var cosTheta = cos(theta);
      for (var n = 0; n < nodes.length; n++) {
        var node = nodes[n];
        var x = node[0];
        var z = node[2];
        node[0] = x * cosTheta + z * sinTheta;
        node[2] = z * cosTheta - x * sinTheta;
      }
   };
Posted: November 6, 2022 7:18 am	


updated via ChatGPT:

-- rotation functions js to lua
function prepare()
   -- input
   local x_theta = math.rad(get_angle_input(XTHETA))
   local y_theta = math.rad(get_angle_input(YTHETA))
   local z_theta = math.rad(get_angle_input(ZTHETA))
   -- precalc, global vars for rotation functions
   sin_x_theta = math.sin(x_theta);
   cos_x_theta = math.cos(x_theta);
   sin_y_theta = math.sin(y_theta);
   cos_y_theta = math.cos(y_theta);
   sin_z_theta = math.sin(z_theta);
   cos_z_theta = math.cos(z_theta);
end;

function rotate3d(x, y, z)
   x, y, z = rotate_z3d(x, y, z, sin_z_theta, cos_z_theta), rotate_x3d(x, y, z, sin_x_theta, cos_x_theta), rotate_y3d(x, y, z, sin_y_theta, cos_y_theta)
   return x, y, z
end;

function rotate_z3d(x, y, z, sin_theta, cos_theta)
   local NODE_COUNT = #nodes
   local NODE = {}
   for node_index = 1, NODE_COUNT do
      NODE[node_index] = {x, y, z}
      x = x * cos_theta - y * sin_theta
      y = y * cos_theta + x * sin_theta
   end
   return NODE[NODE_COUNT][1], NODE[NODE_COUNT][2], NODE[NODE_COUNT][3]
end;

function rotate_x3d(x, y, z, sin_theta, cos_theta)
   local NODE_COUNT = #nodes
   local NODE = {}
   for node_index = 1, NODE_COUNT do
      NODE[node_index] = {x, y, z}
      y = y * cos_theta - z * sin_theta
      z = z * cos_theta + y * sin_theta
   end
   return NODE[NODE_COUNT][1], NODE[NODE_COUNT][2], NODE[NODE_COUNT][3]
end;

function rotate_y3d(x, y, z, sin_theta, cos_theta)
   local NODE_COUNT = #nodes
   local NODE = {}
   for node_index = 1, NODE_COUNT do
      NODE[node_index] = {x, y, z}
      x = x * cos_theta - z * sin_theta
      z = z * cos_theta + x * sin_theta
   end
   return NODE[NODE_COUNT][1], NODE[NODE_COUNT][2], NODE[NODE_COUNT][3]
end;
--[[
	These three functions rotate_z3d, rotate_x3d, and rotate_y3d implement the rotation around the z-axis, x-axis, and y-axis, respectively. Each function takes in the x, y, and z coordinates of a 3D point, as well as the sine and cosine of the rotation angle theta. The functions return the rotated x, y, and z coordinates of the point.

	The implementation of each function is similar: first, the function creates an array of NODES that will store the rotated coordinates of the input point. Then, the function loops through each node and calculates its rotated coordinates using the appropriate rotation formula. Finally, the function returns the rotated coordinates of the last node in the array.

	Once these functions have been defined, the get_sample function uses them to rotate the x, y, and z coordinates of each point in the nodes array before returning the transformed coordinates. The prepare function calculates the sine and cosine of the rotation angle theta based on user input.

	Overall, this code defines a set of functions for rotating 3D points around the x-axis, y-axis, and z-axis, and uses these functions to transform a set of 3D points stored in an array.
	
	If you have successfully generated 3D Perlin noise with equirectangular mapping by transforming the coordinates first, then it's likely that these rotation functions would be compatible with that particular noise function.

	As long as the input coordinates to the noise function are correctly transformed before being passed to the function, any rotations that are applied to those coordinates should be reflected in the resulting noise. The rotation functions you provided are designed to apply rotations to 3D coordinates, so they should work for any function that takes 3D coordinates as input.

	However, it's worth noting that the specific implementation of the 3D Perlin noise algorithm you are using may have its own requirements or constraints on the input coordinates, so you should make sure that the rotations you apply to the coordinates are consistent with those requirements.
]]--

-- sphere block
	radius = get_slider_input(RADIUS)

	-- fresnel / atmosphere fixed tilt and rotation -- locked to view. 
	angle_0 = math.rad(90)
	cosa_a0 = math.cos(angle_0) -- = 0
	sina_a0 = math.sin(angle_0) -- = 1

	tilt_0 = math.rad(360)
	cosa_t0 = math.cos(tilt_0) -- = 1
	sina_t0 = math.sin(tilt_0) -- = 0

	angle = get_angle_input(ROTATION) -- y-axis
	angle_r = math.rad(angle)
	angle_g = math.rad(angle + 240)
	angle_b = math.rad(angle + 120)
	cosa_r = math.cos(angle_r)
	sina_r = math.sin(angle_r)
	cosa_g = math.cos(angle_g)
	sina_g = math.sin(angle_g)
	cosa_b = math.cos(angle_b)
	sina_b = math.sin(angle_b)

	tilt = math.rad(get_angle_input(TILT)) -- z-axis
	cosa_t = math.cos(tilt)
	sina_t = math.sin(tilt)

	phase = math.rad(get_angle_input(PHASE))
	cosa_p = math.cos(phase)
	sina_p = math.sin(phase)

	angle_e = math.rad(get_angle_input(ELEVATION) + 180) -- illuminated facing
	cosa_e = math.cos(angle_e)
	sina_e = math.sin(angle_e)
	
	--[[
   roll = math.rad(get_angle_input(ROLL))
   sina_roll = math.sin(roll)
   cosa_roll = math.cos(roll)
	-- example
		function prepare()
		   ox,oy = get_slider_input(ORIGIN_X),get_slider_input(ORIGIN_Y)
		   d = math.rad(get_angle_input(ROTATION))
		   s,c = math.sin(d), math.cos(d)
		end;
		function get_sample(x, y)
		   local nx = c * (x-ox) - s * (y-oy) + ox
		   local ny = s * (x-ox) + c * (y-oy) + oy
		   local r,g,b,a = get_sample_map(nx, ny, SOURCE)
		   return r,g,b,a
		end;
	-- derivitive
		function set_roll(x, y)
			x = cosa_roll * (x-cx) - sina_roll * (y-cy) + cx
			y = sina_roll * (x-cx) + cosa_roll * (y-cy) + cy
		end;
	-- result; not viable after spherical projection	
	]]--
-- end


		-- light and shadow
		local tpz = (cosa_e * pz) - (sina_e * py_e)
		local tpy_e = (sina_e * pz) + (cosa_e * py_e)
		pz = tpz
		py_e = tpy_e

		local tpz = (cosa_p * px_p) - (sina_p * pz)
		local tpx_p = (sina_p * px_p) + (cosa_p * pz)
		px_p = tpx_p
		pz = tpz


	-- hue rotations : changes in x and z
	local tx_r = (cosa_r * px) - (sina_r * pz)
	local tz_r = (sina_r * px) + (cosa_r * pz)
	px_r = tx_r
	pz_r = tz_r

	local tx_g = (cosa_g * px) - (sina_g * pz)
	local tz_g = (sina_g * px) + (cosa_g * pz)
	px_g = tx_g
	pz_g = tz_g

	local tx_b = (cosa_b * px) - (sina_b * pz)
	local tz_b = (sina_b * px) + (cosa_b * pz)
	px_b = tx_b
	pz_b = tz_b

	-- hue tilt  : changes in y and z
	-- local tz_r = (cosa_r * pz) - (sina_r * py)
	-- local ty_r = (sina_r * pz) + (cosa_r * py)
	-- pz_r = tz_r
	-- py_r = ty_r

	-- local tz_g = (cosa_g * pz) - (sina_g * py)
	-- local ty_g = (sina_g * pz) + (cosa_g * py)
	-- pz_g = tz_g
	-- py_g = ty_g

	-- local tz_b = (cosa_b * pz) - (sina_b * py)
	-- local ty_b = (sina_b * pz) + (cosa_b * py)
	-- pz_b = tz_b
	-- py_b = ty_b

	-- hue roll  : changes in x and y
	-- local tx_r = (cosa_r * px) - (sina_r * py)
	-- local ty_r = (sina_r * px) + (cosa_r * py)
	-- px_r = tx_r
	-- py_r = ty_r

	-- local tx_g = (cosa_g * px) - (sina_g * py)
	-- local ty_g = (sina_g * px) + (cosa_g * py)
	-- px_g = tx_g
	-- py_g = ty_g

	-- local tx_b = (cosa_b * px) - (sina_b * py)
	-- local ty_b = (sina_b * px) + (cosa_b * py)
	-- px_b = tx_b
	-- py_b = ty_b

	-- px = get_sample_curve(x,y,px/2+.5,PROFILE)
	-- py = get_sample_curve(x,y,py/2+.5,PROFILE)
	-- pz = get_sample_curve(x,y,pz/2+.5,PROFILE)


-- 3d perlin sphere map v.1.0.1 -- improved perlin noise
function prepare()
 -- constants
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	cx, cy = 0.5, 0.5

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
	
   roll = math.rad(get_angle_input(ROLL))
   sina_roll = math.sin(roll)
   cosa_roll = math.cos(roll)
	-- example
		-- function prepare()
		   -- ox,oy = get_slider_input(ORIGIN_X),get_slider_input(ORIGIN_Y)
		   -- d = math.rad(get_angle_input(ROTATION))
		   -- s,c = math.sin(d), math.cos(d)
		-- end;
		-- function get_sample(x, y)
		   -- local nx = c * (x-ox) - s * (y-oy) + ox
		   -- local ny = s * (x-ox) + c * (y-oy) + oy
		   -- local r,g,b,a = get_sample_map(nx, ny, SOURCE)
		   -- return r,g,b,a
		-- end;
	-- derivitive
		-- function set_roll(x, y)
			-- x = cosa_roll * (x-cx) - sina_roll * (y-cy) + cx
			-- y = sina_roll * (x-cx) + cosa_roll * (y-cy) + cy
		-- end;
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
		--[[
		-- local tpz = (cosa_a0 * pz) - (sina_a0 * py_e)
		local tpz = (cosa_e * pz) - (sina_e * py_e)
		-- local tpy_e = (sina_a0 * pz) + (cosa_a0 * py_e)
		local tpy_e = (sina_e * pz) + (cosa_e * py_e)
		pz = tpz
		py_e = tpy_e

		local tpz = (cosa_p * px_p) - (sina_p * pz)
		-- local tpz = (cosa_t0 * px_p) - (sina_t0 * pz)
		local tpx_p = (sina_p * px_p) + (cosa_p * pz)
		-- local tpx_p = (sina_t0* px_p) + (cosa_t0 * pz)
		px_p = tpx_p
		pz = tpz
		]]--

		-- this locks phase in z-axis - roll
		-- local tpz = (cosa_a0 * pz) - (sina_a0 * py_e)
		local tpz = (cosa_e * pz) - (sina_e * py_e)
		local tpy_e = (sina_a0 * pz) + (cosa_a0 * py_e)
		-- local tpy_e = (sina_e * pz) + (cosa_e * py_e)
		pz = tpz
		py_e = tpy_e

		-- invert these with no change
		local tpz = (cosa_p * px_p) - (sina_p * pz)
		-- local tpz = (cosa_t0 * px_p) - (sina_t0 * pz)
		-- invert these and phase and elevation are locked out
		local tpx_p = (sina_p * px_p) + (cosa_p * pz)
		-- local tpx_p = (sina_t0* px_p) + (cosa_t0 * pz)
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
		if aspect == 1 then h = h * 2 - 1 end
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
			-- dr = dr + (opacity * perlin:noise(nx * size,ny * size, nz * size)) * dx
			-- dg = dg + (opacity * perlin:noise(nx * size,ny * size, nz * size)) * dy
			-- db = db + (opacity * perlin:noise(nx * size, ny * size, nz * size)) * dz

			dr = dr + (opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size)) * dx
			dg = dg + (opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size)) * dy
			db = db + (opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size)) * dz
			
			-- dr = dr + (opacity * perlin:noise(nx_r * size,ny_r * size, nz_r * size)) * dx
			-- dg = dg + (opacity * perlin:noise(nx_g * size,ny_g * size, nz_g * size)) * dy
			-- db = db + (opacity * perlin:noise(nx_b * size, ny_b * size, nz_b * size)) * dz

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

   -- x = cosa_roll * (x-cx) - sina_roll * (y-cy) + cx
   -- y = sina_roll * (x-cx) + cosa_roll * (y-cy) + cy
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
			-- r, g, b, a = blend_linear_dodge(r, g, b, a, sh, sh, sh, 0.1, 1, hdr)
			r, g, b, a = blend_screen(r, g, b, a, sh, sh, sh, 0.1, 1)
			-- fresnel = true
			r, g, b, a = blend_normal(r, g, b, a, r3, g3, b3, a3, atm, hdr)
			-- blends in atmosphere overlay
			r, g, b, a = blend_normal(r, g, b, a, r3, g3, b3, a3, 0.15 * sh, hdr)
			-- return px_p, px_p, px_p, 1
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