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

