-- 3d sphere 
	-- produces rgb gradient mapped to a 3d sphere, but not correctly. 
	-- this is basically missing an angle gradient around the y-axis...
function prepare()
	-- tilt & rotation precalc
	radius = math.rad(get_slider_input(RADIUS))
	angle = math.rad(get_angle_input(ROTATION))
	cosa = math.cos(angle)
	sina = math.sin(angle)
	tilt = math.rad(get_angle_input(TILT))
	cosa2 = math.cos(tilt)
	sina2 = math.sin(tilt)
end;


function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, SOURCE)
	-- spherical mapping formulae (polar to cartesian, apparently)
		-- local x = x * math.pi -- * aspect 
		-- local y = y * math.pi
		-- conversion from r, lat, long to x, y, z
		-- local nx = math.cos(x) * math.sin(y) 
		-- local ny = math.sin(x) * math.sin(y) 
		-- local nz = math.cos(y) 
	-- cartesian to polar (reference)
		-- radius : distance from focus to surface
		-- latitude : -90 to 90 degrees (math.pi/2), along y-axis (phi)
		-- longitude : -180 to 180 degrees (math.pi) around y-axis (theta)
	--	example 1
		-- r = math.sqrt(((x * x) + (y * y) + (z * z))) 
		-- long = math.acos(x / math.sqrt((x * x) + (y * y))) * (y < 0 ? -1 : 1) 
		-- lat = math.acos(z / radius) * (z < 0 ? -1 : 1) 
	--	example 2
		-- r = math.sqrt((x * x) + (y * y) + (z * z)) 
		-- long = math.acos(x / math.sqrt((x * x) + (y * y))) * (y < 0 ? -1 : 1) 
		-- lat = math.acos(z / r) 
   
	-- image generation
	-- shift origin to center and set radius limits
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))

	-- cartesian to polar
		-- r = math.sqrt((x * x) + (y * y) + (z * z))
		-- lat = math.acos(z / r) 
			-- invalid z for this; what is correct source?
		-- long = math.acos(x / math.sqrt((x * x) + (y * y))) * (y < 0) ? -1 : 1) 
			-- equations cannot accept boolean comparison
			-- boolean syntax may not be valid in lua
			 -- map -1 : 1 needed
		-- long = math.acos(x / math.sqrt((x * x) + (y * y))) 
			 -- map -1 : 1 needed
		-- long = (sina * px) + (cosa * z) -- ok;  2 full rotations

	-- apply rotation and tilt (order is important)
	local tz = (cosa2 * z) - (sina2 * py) -- not used before overridden
	local ty = (sina2 * z) + (cosa2 * py) -- gradient along y-axis is correct
	z = tz -- not used before overridden
	py = ty

	local tx = (cosa * px) - (sina * z) -- gradient needs to go around y-axis
	local tz = (sina * px) + (cosa * z)
	px = tx
	z = tz

	-- return r, g, b, a
	-- return px,py,z,a 
	return px/2+.5,py/2+.5,z/2+.5,a 
	-- return px/2+.5,px/2+.5,px/2+.5,a 
	-- return long,long,long,a 
	-- return px/2+.5,py/2+.5,long,a 
end;