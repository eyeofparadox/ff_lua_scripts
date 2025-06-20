-- 3d sphere v.0.0.3
	-- produces gradients mapped to the x, y and z axis 
	-- hsl conversion of hue rotations gradients allows mapping of sphere
	-- y rotation, x tilt, z roll
function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	
	-- tilt & rotation precalc
	--[[
		-- https://www.khanacademy.org/computing/computer-programming/programming-games-visualizations/programming-3d-shapes/a/rotating-3d-shapes#:~:text=times%20%5Csin(%5Cbeta)-,x,sin(%CE%B2),-Writing%20a%20rotate
		x =x × cos(ß) - y × sin(ß)
		y= y × cos(ß) + x × sin(ß)
	]]--
	radius = get_slider_input(RADIUS)

	--[[
	-- fresnel / atmosphere fixed tilt and rotation -- locked to view. 
	angle_0 = math.rad(90)
	cosa_a0 = math.cos(angle_0) -- = 0
	sina_a0 = math.sin(angle_0) -- = 1

	tilt_0 = math.rad(360)
	cosa_t0 = math.cos(tilt_0) -- = 1
	sina_t0 = math.sin(tilt_0) -- = 0
	]]--

	rotation = math.rad(get_angle_input(ROTATION)) 
	-- y-axis = yaw
	cosa_y = math.cos(rotation)
	sina_y = math.sin(rotation)
	
	-- hue rotations
	rotation_r = math.rad(rotation)
	cosa_r = math.cos(rotation_r)
	sina_r = math.sin(rotation_r)
	
	rotation_g = math.rad(rotation + 240)
	cosa_g = math.cos(rotation_g)
	sina_g = math.sin(rotation_g)

	rotation_b = math.rad(rotation + 120)
	cosa_b = math.cos(rotation_b)
	sina_b = math.sin(rotation_b)

	tilt = math.rad(get_angle_input(TILT)) 
	-- x-axis = pitch
	cosa_x = math.cos(tilt)
	sina_x = math.sin(tilt)
	
	roll = math.rad(get_angle_input(ROLL)) 
	-- z-axis = roll
	cosa_z = math.cos(roll)
	sina_z = math.sin(roll)

	-- oriented to view. 
	phase = math.rad(get_angle_input(PHASE) + 90 )
	-- y-axis = yaw
	cosa_p = math.cos(phase)
	sina_p = math.sin(phase)

	elevation = math.rad(360 - (get_angle_input(ELEVATION) - 270))
	-- z-axis = roll -- locked to view. 
	cosa_e = math.cos(elevation)
	sina_e = math.sin(elevation)
-- end

	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	-- key variables
	local px, py, pz = 0, 0, 0
	local px_r, px_g, px_b = 0, 0, 0
	local z_r, z_g, z_b = 0, 0, 0
	local px_p, py_e = 0, 0
	local r,g,b,a = 1, 1, 1, 1
	
	-- image generation
	px = (x * 2.0) - 1.0
	px = px / radius
	py = (y * 2.0) - 1.0
	py = py / radius
	px_p = (x * 2.0) - 1.0
	px_p = px_p / radius
	py_e = (y * 2.0) - 1.0
	py_e = py_e / radius
	x_r0 = (x * 2.0) - 1.0
	x_r0 = x_r0 / radius
	y_t0 = (y * 2.0) - 1.0
	y_t0 = y_t0 / radius

	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	z_t0 = -math.sqrt(1.0 - ((x_r0 * x_r0) + (y_t0 * y_t0)))
	pz = -math.sqrt(1.0 - ((px_p * px_p) + (py_e * py_e)))
	pz_p = -math.sqrt(1.0 - ((px_p * px_p) + (py_e * py_e)))

	-- light and shadow
	-- elevation (roll)
	local tx_e = (cosa_e * px_p) - (sina_e * py_e)
	local ty_e = (sina_e * px_p) + (cosa_e * py_e)
	px_p = tx_e
	py_e = ty_e

	-- phase (rotation)
	local tx_p = (cosa_p * px_p) - (sina_p * pz_p)
	local tz_p = (sina_p * px_p) + (cosa_p * pz_p)
	px_p = tx_p
	pz_p = tz_p

	-- roll  : changes in x and y
	local tx = (cosa_z * px) - (sina_z * py)
	local ty = (sina_z * px) + (cosa_z * py)
	px = tx
	py = ty

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

	-- fresnel or atmosphere
	local tz_t0 = (1 * z_t0) - (0 * y_t0)
	local ty_t0 = (0 * z_t0) + (1 * y_t0)
	z_t0 = tz_t0
	y_t0 = ty_t0

	local tx_r0 = (0 * x_r0) - (1 * z_t0)
	local tz_t0 = (1 * x_r0) + (0 * z_t0)
	x_r0 = tx_r0
	z_t0 = tz_t0
		--[[
		]]--

	h,s,l = fromrgb(px_r,px_g,px_b)
	if aspect == 1 then h = h * 2 - 1 end
	x, y = h, py / 2 + 0.5

	-- input image
	local r, g, b, a = get_sample_map(x, y, SOURCE)
	local r3, g3, b3, a3 = get_sample_map(x, y, OVERLAY)
	
	f = 1 - (x_r0 * 0.8)
	f = get_sample_curve(x, y, f, FRESNEL)
	sh = px_p  / 2 + 0.5
	sh = get_sample_curve(px_p, py_e, sh, PROFILE)
	atm = f - ((1 - sh) ^ 2)

	-- compositing and return
	-- blends in shadow overlay
	r, g, b, a = blend_multiply(r, g, b, a, sh, sh, sh, 1, 1, hdr)
	-- blends in lighting overlay
	r, g, b, a = blend_linear_dodge(r, g, b, a, sh, sh, sh, 0.125, 1, hdr)
	-- r, g, b, a = blend_screen(r, g, b, a, sh, sh, sh, 0.5, 1)
	-- fresnel = true
	r, g, b, a = blend_normal(r, g, b, a, r3, g3, b3, a3, atm, hdr)
	-- blends in atmosphere overlay
	r, g, b, a = blend_normal(r, g, b, a, r3, g3, b3, a3, 0.15 * sh, hdr)

	return r, g, b, a
	-- return px,py,pz,a 
	-- return h, py, pz / 2 + 0.5, a
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
