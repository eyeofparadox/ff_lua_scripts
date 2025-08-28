-- 3d sphere v.0
	-- polar to cartesian
		-- local x = x * aspect * math.pi 
		-- local y = y * math.pi
		-- conversion from r, lat (phi), lon (theta) to x, y, z
		-- local nx = math.cos(x) * math.sin(y) 
		-- local ny = math.sin(x) * math.sin(y) 
		-- local nz = math.cos(y) 

function prepare()
	-- sphere tilt & rotation precalc
	radius = get_slider_input(RADIUS)

	angle = math.rad(get_angle_input(ROTATION))
	cosa_a = math.cos(angle)
	sina_a = math.sin(angle)

	tilt = math.rad(get_angle_input(TILT))
	cosa_t = math.cos(tilt)
	sina_t = math.sin(tilt)

	angle_r = math.rad(angle + 360)
	cosa_r = math.cos(angle_r)
	sina_r = math.sin(angle_r)
	angle_g = math.rad(angle + 240)
	cosa_g = math.cos(angle_g)
	sina_g = math.sin(angle_g)
	angle_b = math.rad(angle + 120)
	cosa_b = math.cos(angle_b)
	sina_b = math.sin(angle_b)

	if (get_checkbox_input(MAP)) then
		map = true
	else
		map = false
	end
	if (get_checkbox_input(TEST_SAMPLE)) then
		test = true
	else
		test = false
	end
end;


function get_sample(x, y)
	local r,g,b,a = 1,1,1,1

	-- sphere generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))

	local tz = (cosa_t * z) - (sina_t * py)
	local ty = (sina_t * z) + (cosa_t * py)
	z = tz
	py = ty

	local tx = (cosa_a * px) - (sina_a * z)
	local tz = (sina_a * px) + (cosa_a * z)
	px = tx
	z = tz

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

	local py_t = py
	local px_a = px

	h,s,l = fromrgb(px_r,px_g,px_b)
	-- if aspect then h = h * 2 - 1 end
		-- waiting on aspect checkbox

	local lat, lon = py/2+0.5, h

	-- load sample mapped to sphere lon, lat
	local sr, sg, sb, sa = get_sample_map(lon, lat, SAMPLE)
	
	local r, phi, theta = cartesian_to_polar(sr,sg,sb)

	if test then 
	-- override rotation and tilt
		radius = r

		angle_n = theta
		cosa_an = math.cos(angle_n)
		sina_an = math.sin(angle_n)

		tilt_n = phi
		cosa_tn = math.cos(tilt_n)
		sina_tn = math.sin(tilt_n)

	-- modify rotation and tilt
		px, py, z = px*sr, py*sg, z*sb
		local tz = (cosa_tn * z) - (sina_tn * py)
		local ty = (sina_tn * z) + (cosa_tn * py)
		z = tz
		py = ty
		py_t = py

		local tx = (cosa_an * px) - (sina_an * z)
		local tz = (sina_an * px) + (cosa_an * z)
		px = tx
		z = tz
		px_a = px
	end
	
	--	input image and map to sphere
	local r, g, b, a = get_sample_map(lon, lat, SOURCE)

	r = get_sample_curve(x,y,r,PROFILE)
	g = get_sample_curve(x,y,g,PROFILE)
	b = get_sample_curve(x,y,b,PROFILE)
	a = get_sample_curve(x,y,a,PROFILE)
	px = get_sample_curve(x,y,px/2+.5,PROFILE)
	py = get_sample_curve(x,y,py/2+.5,PROFILE)
	z = get_sample_curve(x,y,z/2+.5,PROFILE)
	px_a = get_sample_curve(x,y,px_a,PROFILE)
	py_t = get_sample_curve(x,y,py_t,PROFILE)

	if map then
		return r, g, b, a
	else
		if test then
		   return r, phi, theta, 1
		--	return px, py, z, 1 
		end
		-- return px, px, px, 1 
			-- original output; produces monochrome gradient mapped to the x axis 
		-- return px_a, py_t, z, 1 -- py_t returning black instead of axis gradient
		-- return px_a, py, z, 1 -- py works, but not py_t or ty
		return px, py, z, 1 
	end;
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


function cartesian_to_polar(x,y,z)
	-- invalid floating-point values when 0, 0, 0
	x, y, z = check_zero(x), check_zero(y), check_zero(z)
    local r = math.sqrt((x * x) + (y * y) + (z * z))
    local phi = math.atan(y/x)
        -- math.cos(phi) = x / (math.sqrt((x * x) + (y * y)))  
        -- math.sin(phi) = y / (math.sqrt((x * x) + (y * y)))  
        -- math.tan(phi) = y / x
            -- which is used when?
    local theta = math.atan(math.sqrt(x^2+y^2)/z)
        -- math.cos(theta) = z / radius = z / math.sqrt((x * x) + (y * y) + (z * z))
            -- if the second equation is equivalent, do you skip straight to the second?
    return r, phi, theta
end;


function check_zero(v)
	if v == 0 then v = 0.000000001 end
	return v
end;