-- rotation functions js to lua
--[[
	https://www.khanacademy.org/computing/computer-programming/programming-games-visualizations/programming-3d-shapes/a/rotating-3d-shapes#:~:text=Writing%20a%20rotate%20function

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

function prepare()
	-- input
	local theta = math.rad(get_angle_input(THETA))
	-- precalc, global vars for yaw functions
	sin_theta = sin(theta);
	cos_theta = cos(theta);
	
	--[[
	-- next steps
	pitch = math.rad(get_angle_input(PITCH)) 
	-- x-axis = pitch
	cosa_x = math.cos(pitch)
	sina_x = math.sin(pitch)
	
	yaw = math.rad(get_angle_input(YAW)) 
	-- y-axis = yaw
	cosa_y = math.cos(yaw)
	sina_y = math.sin(yaw)
	
	-- hue rotations
	yaw_r = math.rad(yaw)
	cosa_r = math.cos(yaw_r)
	sina_r = math.sin(yaw_r)
	
	yaw_g = math.rad(yaw + 240)
	cosa_g = math.cos(yaw_g)
	sina_g = math.sin(yaw_g)

	yaw_b = math.rad(yaw + 120)
	cosa_b = math.cos(yaw_b)
	sina_b = math.sin(yaw_b)

	roll = math.rad(get_angle_input(ROLL)) 
	-- z-axis = roll
	cosa_z = math.cos(roll)
	sina_z = math.sin(roll)
	]]--
end;


function get_sample(x, y)
	local z = get_sample_grayscale(DEPTH)
	-- incomplete, construct obj array, pass array as var?
	x, y, z = rotate_z3d(x,y), rotate_x3d(x,y), rotate_y3d(x,y)
end;


function rotate_z3d(x,y)
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
   

function rotate_x3d(x,y)
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
   

function rotate_y3d(x,y)
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
