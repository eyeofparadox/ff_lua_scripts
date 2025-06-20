-- 3d sphere v.0.0
	-- produces gradients mapped to the x, y and z axis 
	-- y rotation, x tilt, z roll
function prepare()
	-- tilt & rotation precalc
--[[
	x =x × cos(ß) - y × sin(ß)
	y= y × cos(ß) + x × sin(ß)
]]--
	radius = get_slider_input(RADIUS)

	rotation = math.rad(get_angle_input(ROTATION)) -- y-axis = yaw
	cosa_a = math.cos(rotation)
	sina_a = math.sin(rotation)

	tilt = math.rad(get_angle_input(TILT)) -- x-axis = pitch
	cosa_t = math.cos(tilt)
	sina_t = math.sin(tilt)
	
   roll = math.rad(get_angle_input(ROLL)) -- z-axis = roll
   sina_r = math.sin(roll)
   cosa_r = math.cos(roll)
end;

function get_sample(x, y)
	local r,g,b,a = 1,1,1,1
	
	-- image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	local pz = -math.sqrt(1.0 - ((px*px)+(py*py)))

	-- roll  : changes in x and y
	local tx = (cosa_r * px) - (sina_r * py)
	local ty = (sina_r * px) + (cosa_r * py)
	px = tx
	py = ty

	-- tilt  : changes in y and z
	local tz = (cosa_t * pz) - (sina_t * py)
	local ty = (sina_t * pz) + (cosa_t * py)
	pz = tz
	py = ty

	-- rotation : changes in x and z
	local tx = (cosa_a * px) - (sina_a * pz)
	local tz = (sina_a * px) + (cosa_a * pz)
	px = tx
	pz = tz

	px = get_sample_curve(x,y,px/2+.5,PROFILE)
	py = get_sample_curve(x,y,py/2+.5,PROFILE)
	pz = get_sample_curve(x,y,pz/2+.5,PROFILE)

	--	input image
	r, g, b, a = get_sample_map(x, y, SOURCE)

	return px,py,pz,a 
	-- return r, g, b, a
end;