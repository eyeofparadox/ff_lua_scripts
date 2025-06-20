-- 3d vector sphere 
	-- produces rgb gradient mapped to a 3d sphere. 
	-- an angle gradient in r for x lookup
		-- derived from hue (rgb to hsl conversion) 
	-- a linear gradient in g for y lookup
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

	-- atan2 = math.atan2
	-- cos = math.cos
	-- sin = math.sin
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
		-- internal lookup on source image
		-- add screen relative z-axis rotation (spin)
		
	h,s,l = fromrgb(px,px1,px2)

	return h,py/2+.5,0,1
	-- return px/2+.5,px1/2+.5,px2/2+.5,py/2+.5 
	-- rgb component gradients 
		-- return px/2+.5,px/2+.5,px/2+.5,0 
		-- return px1/2+.5,px1/2+.5,px1/2+.5,0 
		-- return px2/2+.5,px2/2+.5,px2/2+.5,0 
	-- return r, g, b, a
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