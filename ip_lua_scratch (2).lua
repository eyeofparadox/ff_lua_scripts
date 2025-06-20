


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


--[[
-- rotation functions from js

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
]]--


bias(b,x)

function bias(b,x)
    return x / ((1 / b - 2) * (1 - x) + 1)
end;

gain(g,x)

function gain(g,x)
	local p
	if (g == 0) then g = 0.001 end
	p = (1 / g - 2) * (1 - 2 * x)
	if (x < 0.5) then
		return x / (p + 1)
	else 
		return (p - x) / (p - 1)
	end
end;

bias(bias, x)
gain(gain, x)

function bias(bias, x) 
	return x / ( (1 / bias - 2) * (1 - x)  + 1)
end;
 
function gain(gain, x)  
  if (x < 0.5) then
	return bias(x * 2, gain)/2
else
	return bias(x * 2 - 1, 1 - gain)/2 + 0.5
end;

gamma(gamma,x);

function gamma(gamma,x)
    return math.pow(x, 1 / gamma);
end;
	
sigmoid(x)

function sigmoid(x)
	-- maps -inf to +inf range to  0 to 1 range
	return 1 / (1 + math.exp (-x))
end

-- alternate compression mapping

function prepare()
	-- maps -inf to +inf to -1 to +1 
	-- mode checked maps 0 to 1 range
	mode = get_checkbox_input(MODE)
end;

function get_sample(x, y)
	local v = get_sample_grayscale(x, y, SOURCE)
	v = compress(v)
	if mode then
		v = v / 2 + 0.5
	end
	return v, v, v, 1
end;

function compress(v)
	return math.atan (v) * 2  /  math.pi
end

	if (get_checkbox_input(BIDIR)) then
		bidirectional = true
	else
		bidirectional = false
	end
	-- if bidirectional then
		-- dx = range(dx,0,1,-1,1)
		-- dy = range(dy,0,1,-1,1)
		-- dz = range(dz,0,1,-1,1)
		-- osx = range(osx,0,1,-1,1)
		-- osy = range(osy,0,1,-1,1)
		-- osz = range(osz,0,1,-1,1)
		-- sx = range(sx,0,1,-1,1)
		-- sy = range(sy,0,1,-1,1)
		-- sz = range(sz,0,1,-1,1)
	-- end

function range(n, smin, smax, tmin, tmax)
	n = (n - smin) / (smax - smin) * (tmax - tmin) + tmin 
			-- f(x) = (x - input_start) / (input_end - input_start) * (output_end - output_start) + output_start
	return n
end;


function disttype()
	-- no dist declaration, function will return nil
	if dtype == 1 then
		-- Euclidean 
		local dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)	
	elseif dtype == 2 then
		-- Chebyshev
		local dist = math.max(math.abs(sx - dx), math.abs(sy - dy), math.abs(sz - dz))	
	elseif dtype == 3 then
		-- Manhattan
		local dist = (math.abs(sx - dx) + math.abs(sy - dy) + math.abs(sz - dz)) / 1.5	
	else
		-- Minkowski 
		local pe = 1/p
		local dist = (math.abs(sx - dx)^p + math.abs(sy - dy)^p + math.abs(sz - dz)^p)^pe
	end	
	return dist
end;

-- anonymous function snip
	index = x + y * width
	for x = 0, 1 do	
		for y = 0, 1 do
		-- insert snip
		end	
	end	
			
	pixels[index] = get_noise(x,y,z)

	-- not native; create random points
	points{}
	distances {}
	for i = 0, points.length do
		d = dist(x, y, points[i].x, points[i].y)
		distances[i] = d
		-- not native; point vectors; translate
		points[i] = (random(x), random(y))
		-- not native; point vectors; place
		(x[i], y[i]) --?
	end
	
	sorted {} = sort(distances)
-- end