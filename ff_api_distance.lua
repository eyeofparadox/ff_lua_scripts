function prepare()
	dtype = get_intslider_input(DISTANCE_TYPE)
	p = get_intslider_input(P)
	s = get_slider_input(SCALE)
end;

function get_sample(x, y)
	local sx, sy = x / s , y / s,
	local cell_x, cell_y = math.floor(sx), math.floor(sy)
	local offset_x, offset_y, offset_z
	local v = get_sample_grayscale(x, y, SOURCE)
	local min_dist = 10000
	for x = 0, 1 do
		for y = 0, 1 do
			local dx = cell_x + offset_x -- + get_noise(cell_x + offset_x, cell_y + offset_y)
			local dy = cell_y + offset_y -- + get_noise(cell_x + offset_x, cell_y + offset_y)
			-- local dist =  distcalc(x, y, v, v)
			dist = math.sqrt((sx - dx)^2 + (sy - dy)^2)	
			min_dist = math.min(dist, min_dist) -- 
		end -- 
	end -- 
	-- min_dist = 1.0 - min_dist
	v = min_dist

	return v, v, v, a
end;

function distcalc(sx,sy,dx,dy)
	local dist = 0
	if dtype == 1 then
		-- Euclidean 
		dist = math.sqrt((sx - dx)^2 + (sy - dy)^2)	
	elseif dtype == 2 then
		-- Chebyshev
		dist = math.max(math.abs(sx - dx), math.abs(sy - dy))	
	elseif dtype == 3 then
		-- Manhattan
		dist = (math.abs(sx - dx) + math.abs(sy - dy)) / 1.5	
	else
		-- Minkowski 
		local pe = 1/p
		dist = (math.abs(sx - dx)^p + math.abs(sy - dy)^p)^pe
	end	
	return dist
end;