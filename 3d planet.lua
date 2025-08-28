-- 3d planet v.1
	-- sphere mapped and shaded with atmosphere
function prepare()
	-- tilt & rotation precalc
	radius = get_slider_input(RADIUS)

	angle_0 = math.rad(90)
	cosa_a0 = math.cos(angle_0)
	sina_a0 = math.sin(angle_0)

	tilt_0 = math.rad(360)
	cosa_t0 = math.cos(tilt_0)
	sina_t0 = math.sin(tilt_0)

	angle = get_angle_input(ROTATION)
	angle_r = math.rad(angle)
	angle_g = math.rad(angle + 240)
	angle_b = math.rad(angle + 120)
	cosa_r = math.cos(angle_r)
	sina_r = math.sin(angle_r)
	cosa_g = math.cos(angle_g)
	sina_g = math.sin(angle_g)
	cosa_b = math.cos(angle_b)
	sina_b = math.sin(angle_b)

	tilt = math.rad(get_angle_input(TILT))
	cosa_t = math.cos(tilt)
	sina_t = math.sin(tilt)

	phase = math.rad(get_angle_input(PHASE))
	cosa_p = math.cos(phase)
	sina_p = math.sin(phase)

	angle_e = math.rad(get_angle_input(ELEVATION)) -- SUN_TILT
	cosa_e = math.cos(angle_e)
	sina_e = math.sin(angle_e)

	-- intended for screen relative rotation; produced tilt instead
   -- ox,oy = 0.5, 0.5
	-- roll = math.rad(get_angle_input(ROLL)-180)
	-- sina_r,cosa_r = math.sin(roll), math.cos(roll)

	-- add lighting
	shaded = get_checkbox_input(SHADED)

	-- aspect ratio - 1;1 or 2.1
	aspect = get_checkbox_input(ASPECT)
	
	-- blend as hdr?
	hdr = true
	opacity = 1
	atmospheric = get_checkbox_input(ATMOSPHERE_ON)
end;


function get_sample(x, y)
	-- image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	local px_p = (x*2.0) - 1.0
	local py_e = (y*2.0) - 1.0
	local x_ao = (x*2.0) - 1.0
	local y_to = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	px_p = px_p/radius
	py_e = py_e/radius
	x_ao = x_ao/radius
	y_to = y_to/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end
   -- local ox,oy = px,py

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))
	local pz = -math.sqrt(1.0 - ((px_p*px_p)+(py_e*py_e)))
	local z_to = -math.sqrt(1.0 - ((x_ao*x_ao)+(y_to*y_to)))

	local tz = (cosa_t * z) - (sina_t * py)
	local ty = (sina_t * z) + (cosa_t * py)
	z = tz
	py = ty

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

	local tpz = (cosa_e * pz) - (sina_e * py_e)
	local tpy_e = (sina_e * pz) + (cosa_e * py_e)
	pz = tpz
	py_e = tpy_e

	local tpz = (cosa_p * px_p) - (sina_p * pz)
	local tpx_p = (sina_p * px_p) + (cosa_p * pz)
	px_p = tpx_p
	pz = tpz

	local tz_to = (cosa_t0 * z_to) - (sina_t0 * y_to)
	local ty_to = (sina_t0 * z_to) + (cosa_t0 * y_to)
	z_to = tz_to
	y_to = ty_to

	local tx_ao = (cosa_a0 * x_ao) - (sina_a0 * z_to)
	local tz_to = (sina_a0 * x_ao) + (cosa_a0 * z_to)
	x_ao = tx_ao
	z_to = tz_to

	-- intended for screen relative rotation; produced tilt instead
	-- local nx = cosa_r * (x-ox) - sina_r * (y-oy) + ox
	-- local ny = sina_r * (x-ox) + cosa_r * (y-oy) + oy
	-- original line; not applicable here but defines what gets rotated
	-- local r,g,b,a = get_sample_map(nx, ny, SOURCE)

	h,s,l = fromrgb(px_r,px_g,px_b)
	if aspect then h = h * 2 - 1 end

	--	input image
	local r, g, b, a = get_sample_map(h, py/2+.5, SOURCE)
	local ar, ag, ab, aa = get_sample_map(x, y, ATMOSPHERE_COLOR)
	--	ar, ag, ab, aa = x_ao/2+.5, x_ao/2+.5, x_ao/2+.5, 1-x_ao
	aa = 1-x_ao
	--	input curve
	px_p = get_sample_curve(x,y,px_p/2+.5,PROFILE)
	-- ar = get_sample_curve(x, y,ar/2+.5, ATMOSPHERE)
	-- ag = get_sample_curve(x, y,ag/2+.5, ATMOSPHERE)
	-- ab = get_sample_curve(x, y,ab/2+.5, ATMOSPHERE)
	aa = get_sample_curve(x, y,aa/2+.5, ATMOSPHERE)
	opacity = 1 -((a*px_p)+px)-- 

	-- add atmosphere to planet
	ar, ag, ab, aa = blend_normal((r*px_p)+px_p, (g*px_p)+px_p, (b*px_p)+px_p, a, ar, ag, ab, aa, opacity, hdr)
	-- return h,py/2+.5,px_p,1
	-- return ar*x_ao, ag*x_ao, ab*x_ao, aa*x_ao -- atmosphere only
	if shaded then
		if atmospheric then
			return ar, ag, ab, aa
		else
			return (r*px_p)+px_p, (g*px_p)+px_p, (b*px_p)+px_p, a 
		end 
	else
		return r, g, b, a
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
end