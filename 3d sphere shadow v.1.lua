-- 3d sphere shadow v.1
	-- produces a light shadow mapped to a 3d sphere 
local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi
local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2

function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	radius = get_slider_input(RADIUS)
	per = get_slider_input(PERSP) * .25 * pi;
	sin_persp, cos_persp = sin(per), cos(per);
	tilt = - (get_slider_input(TILT) * 2 - 1) * pi;
	rotation = - (get_slider_input(ROTATION) * 2 - 1) * pi;
	sin_tilt, cos_tilt = sin(tilt), cos(tilt);
	roll = rad(get_angle_input(ROLL)) -- z - axis = roll
	sin_roll = sin(roll)
	cos_roll = cos(roll)
end;

local function get_sphere_th_ph(th, ph)
	local x, y, z = cos(th) * sin(ph), sin(th) * sin(ph), cos(ph);
	x, z = x * cos_tilt - z * sin_tilt, x * sin_tilt + z * cos_tilt;
	th, ph = atan2(y, x) + rotation, acos(z);
	return (th / pi + 1) * .5, ph / pi;
end;

local function get_sphere(x, y)
	x, y = min(max(x, - 1), 1), - min(max(y, - 1), 1);
	local ph = asin(y);
	local th = 0
	local cos_ph = cos(ph);
	x = min(max(x, - cos_ph), cos_ph);
	if cos_ph~=0 then
		th = asin(x / cos_ph);
	end;
	return get_sphere_th_ph(th, .5 * pi - ph);
end;

function get_sample(x, y)
	x, y = x * 2 - 1, y * 2 - 1;
	x = x / radius
	y = y / radius
	local r = sqrt(x * x + y * y);
	if r > 1.0 then return 0, 0, 0, 0 end
	local th = atan2(y, x);
	if per > 0 then
		local ph = min(1, r) * per;
		local sin_ph, cos_ph = sin(ph), cos(ph);
		r = sin_ph * (cos_ph / sin_persp - sqrt((cos_ph * cos_ph - cos_persp * cos_persp) / sin_persp / sin_persp));
	else
		r = min(1, r);
	end;
	x, y = r * cos(th), r * sin(th);
	-- roll : changes in x and y
	local tx = (cos_roll * x) - (sin_roll * y)
	local ty = (sin_roll * x) + (cos_roll * y)
	x = tx
	y = ty
	x, y = get_sphere(x, y);
	-- if aspect then x = x * 2 - 1 end
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		x = x * 2 - 1
	end
	--	input image
	r, g, b, a = get_sample_map(x, y, SOURCE)
	--	return x%1, y%1, 0, 1;
	-- return x%1, x%1, x%1, 1;
	return r, g, b, a
end;


	local sqrt, min, max, rad, pi = math.sqrt, math.min, math.max, math.rad, math.pi;
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2;

function prepare()
	radius = 1  / get_slider_input(RADIUS)

	-- tilt & rotation precalc
	rotation = rad(get_angle_input(ROTATION)) 
	-- y-axis = yaw
	cos_y = cos(rotation)
	sin_y = sin(rotation)
	
	tilt = rad(get_angle_input(TILT)) 
	-- x-axis = pitch
	cos_x = cos(tilt)
	sin_x = sin(tilt)
	
	roll = rad(get_angle_input(ROLL)) 
	-- z-axis = roll
	sin_z = sin(roll)
	cos_z = cos(roll)
end;


function get_sample(x, y)
	-- image generation
	local px = (x * 2.0) - 1.0
	local py = (y * 2.0) - 1.0
	px = px * radius
	py = py * radius
	local len = sqrt((px * px)+(py * py))
	if len > 1.0 then return 0, 0, 0, 0 end

	local pz = -sqrt(1.0 - ((px * px)+(py * py)))

	-- roll : changes in x and y
	local tx = (cos_z * px) - (sin_z * py)
	local ty = (sin_z * px) + (cos_z * py)
	px = tx
	py = ty

	-- tilt : changes in y and z
	local tz = (cos_x * pz) - (sin_x * py)
	local ty = (sin_x * pz) + (cos_x * py)
	pz = tz
	py = ty

	-- rotation : changes in x and z
	local tx = (cos_y * px) - (sin_y * pz)
	local tz = (sin_y * px) + (cos_y * pz)
	px = tx
	pz = tz

	-- local r, g, b, a = 1, 1, 1, 1
	
	p = get_sample_curve(px * 0.5 + 0.5, py * 0.5 + 0.5, pz * 0.5 + 0.5, PROFILE)

	return p, p, p, a 
	-- return px * 0.5 + 0.5, px * 0.5 + 0.5, px * 0.5 + 0.5, a 
	-- return r, g, b, a
end;