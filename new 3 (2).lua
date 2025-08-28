function prepare()
	radius = 1 / math.max(get_slider_input(RADIUS), 0.00001)
end;

function get_sample(x, y)
	x, y = x * 2 - 1, y * 2 - 1
	x, y = x * radius, y * radius
	local alpha, r = 1, 1 - math.sqrt(x * x + y * y)
	if r > 1.0 then alpha = 0 end;
	local th = math.atan2(y, x) * 0.159155
	local r_1 = get_sample_curve(th, r, r, B_PROFILE)
	return th + 0.5, r, r_1, alpha
end;

function map_equirectangular(x, y)
	local nx = math.cos(x) * math.sin(y)
	local ny = math.sin(x) * math.sin(y)
	local nz = math.cos(y)
	return nx, ny, nz
end;
--	local nx, ny, nz = map_equirectangular(x, y)