-- 3d sphere shadow
	-- produces a light shadow mapped to a 3d sphere 
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
	--	input image; requires uvw mapping...
	local r, g, b, a = get_sample_map(x, y, SOURCE)
	a = 1

	-- image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	if len > 1.0 then return 0,0,0,0 end

	local z = -math.sqrt(1.0 - ((px*px)+(py*py)))

	local tz = (cosa2 * z) - (sina2 * py)
	local ty = (sina2 * z) + (cosa2 * py)
	z = tz
	py = ty

	local tx = (cosa * px) - (sina * z)
	local tz = (sina * px) + (cosa * z)
	px = tx
	z = tz

	p = get_sample_curve(x,y,px/2+.5,PROFILE)

	return p,p,p,a 
	-- return px/2+.5,px/2+.5,px/2+.5,a 
	-- return r, g, b, a
end;
