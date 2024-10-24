-- 3d sphere mapped and shaded v.1
	-- explore option of an angle gradient in the x-axis (around the y-axis)
	-- explore rendering 3 spheres with offset rotations (120 degrees)
		-- succeeded in this version, extract hue to obtain an angle gradient
	-- produces rgb gradient mapped to a 3d sphere with y-axis in the alpha channel 
function prepare()
	-- tilt & rotation precalc
	radius = get_slider_input(RADIUS)

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

	angle_e = math.rad(get_angle_input(ELEVATION))
	cosa_e = math.cos(angle_e)
	sina_e = math.sin(angle_e)

	-- intended for screen relative rotation; produced tilt instead
   -- ox,oy = 0.5, 0.5
	-- roll = math.rad(get_angle_input(ROLL)-180)
	-- sina_t,cosa_t = math.sin(roll), math.cos(roll)

	-- add lighting
	shaded = get_checkbox_input(SHADED)
end;


function get_sample(x, y)
	-- image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	local px_p = (x*2.0) - 1.0
	local py_e = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	px_p = px_p/radius
	py_e = py_e/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end
   -- local ox,oy = px,py

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))
	local pz = -math.sqrt(1.0 - ((px_p*px_p)+(py_e*py_e)))

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

	-- intended for screen relative rotation; produced tilt instead
	-- local nx = cosa_t * (x-ox) - sina_t * (y-oy) + ox
	-- local ny = sina_t * (x-ox) + cosa_t * (y-oy) + oy
	-- original line; not applicable here but defines what gets rotated
	-- local r,g,b,a = get_sample_map(nx, ny, SOURCE)

	h,s,l = fromrgb(px_r,px_g,px_b)

	--	input image
	local r, g, b, a = get_sample_map(h, py/2+.5, SOURCE)
	--	input curve
	px_p = get_sample_curve(x,y,px_p/2+.5,PROFILE)

	-- return h,py/2+.5,px_p,1
	if shaded then
		return (r*px_p)+px_p, (g*px_p)+px_p, (b*px_p)+px_p, a
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