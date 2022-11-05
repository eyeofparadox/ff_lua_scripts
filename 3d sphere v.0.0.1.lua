-- 3d sphere v.0.0.1
	-- produces gradients mapped to the x, y and z axis 
	-- y rotation, x tilt, z roll
		-- roll is detached from pitch and yaw - suspect order of operations
function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	-- tilt & rotation precalc
--[[
	x =x × cos(ß) - y × sin(ß)
	y= y × cos(ß) + x × sin(ß)
]]--
	radius = get_slider_input(RADIUS)

	rotation = math.rad(get_angle_input(ROTATION)) 
	-- y-axis = yaw
	cosa_y = math.cos(rotation)
	sina_y = math.sin(rotation)
	
	-- hue rotations
	angle_r = math.rad(rotation)
	cosa_r = math.cos(angle_r)
	sina_r = math.sin(angle_r)
	
	angle_g = math.rad(rotation + 240)
	cosa_g = math.cos(angle_g)
	sina_g = math.sin(angle_g)
	
	angle_b = math.rad(rotation + 120)
	cosa_b = math.cos(angle_b)
	sina_b = math.sin(angle_b)

	tilt = math.rad(get_angle_input(TILT)) 
	-- x-axis = pitch
	cosa_x = math.cos(tilt)
	sina_x = math.sin(tilt)
	
   roll = math.rad(get_angle_input(ROLL)) 
   -- z-axis = roll
   sina_z = math.sin(roll)
   cosa_z = math.cos(roll)
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

	-- tilt  : changes in y and z
	local tz = (cosa_x * pz) - (sina_x * py)
	local ty = (sina_x * pz) + (cosa_x * py)
	pz = tz
	py = ty

	-- rotation : changes in x and z
	local tx = (cosa_y * px) - (sina_y * pz)
	local tz = (sina_y * px) + (cosa_y * pz)
	px = tx
	pz = tz

		--[[
			-- hue componants function with rotation and tilt. adding roll breaks something. 
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
		]]--

	-- roll  : changes in x and y
	local tx = (cosa_z * px) - (sina_z * py)
	local ty = (sina_z * px) + (cosa_z * py)
	px = tx
	py = ty

	h,s,l = fromrgb(px_r,px_g,px_b)
	if aspect == 1 then h = h * 2 - 1 end
	x, y = h, py / 2 + 0.5

	--	input image
	r, g, b, a = get_sample_map(x, y, SOURCE)

	-- return px,py,pz,a 
	-- return r, g, b, a
	return h, py, 0, a
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
end;