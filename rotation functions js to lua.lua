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
