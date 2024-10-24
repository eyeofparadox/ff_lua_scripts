-- 3d sphere 
	-- produces rgb gradient mapped to a 3d sphere. 
	-- an angle gradient can be derived using an extract hue component for x lookup
	-- a get alpha component provides for y lookup
function prepare()
	-- tilt & rotation precalc
	radius = math.rad(get_slider_input(RADIUS))
	angle = math.rad(get_angle_input(ROTATION))
	angle1 = math.rad((angle + 120))
	angle2 = math.rad((angle + 240))

	cosa0 = math.cos(angle)
	sina0 = math.sin(angle)

	cosa1 = math.cos(angle1)
	sina1 = math.sin(angle1)

	cosa2 = math.cos(angle2)
	sina2 = math.sin(angle2)

	tilt = get_angle_input(TILT))
	cosa3 = math.cos(tilt)
	sina3 = math.sin(tilt)
end;


function get_sample(x, y)
	--	input image; requires uvw mapping...
	local r, g, b, a = get_sample_map(x, y, SOURCE)
	a = 1

	-- image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	px1 = px/radius
	px2 = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))
	local z1 = z
	local z2 = z

	local tz = (cosa3 * z) - (sina3 * py)
	local ty = (sina3 * z) + (cosa3 * py)
	py = ty
	z = tz

	local tx = (cosa0 * px) - (sina0 * z)
	local tz = (sina0 * px) + (cosa0 * z)
	px = tx
	z = tz
	
	local tx1 = (cosa1 * px1) - (sina1 * z)
	local tz1 = (sina1 * px1) + (cosa1 * z)
	px1 = tx1
	z1 = tz1

	local tx2 = (cosa2 * px2) - (sina2 * z)
	local tz2 = (sina2 * px2) + (cosa2 * z)
	px2 = tx2
	z2 = tz2

	-- to do
		-- internal hue extraction (hsb): 
		-- internal lookup on source image
		-- add screen relative z-axis rotation (spin)

	return px/2+.5,px1/2+.5,px2/2+.5,py/2+.5 
	-- return px/2+.5,px/2+.5,px/2+.5,0 
	-- return px1/2+.5,px1/2+.5,px1/2+.5,0 
	-- return px2/2+.5,px2/2+.5,px2/2+.5,0 
	-- return r, g, b, a
end;