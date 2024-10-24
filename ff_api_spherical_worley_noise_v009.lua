function prepare()
	-- v.009
	amp = 1
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	distance_type = get_intslider_input(DISTANCE_TYPE) -- range 1 to 5
	distance_formula = get_intslider_input(DISTANCE_FORMULA) -- range 1 to 4
	distance_point = get_intslider_input(DISTANCE_POINT)
	p = get_intslider_input(P)
	details = get_intslider_input(DETAILS)
	set_noise_seed(get_intslider_input(SEED))
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local roughness = 3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	local osx, osy,  osz, osa = get_sample_map(x, y, OFFSET)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION)
	local v = 0
	
	sx, sy, sz = sx * sa * 2.5, sy * sa * 2.5, sz * sa * 2.5
	if sx == 0 then sx = 0.001 end;
	if sy == 0 then sy = 0.001 end;
	if sz == 0 then sz = 0.001 end;

	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) + (osx * osa)
	local ny = math.sin(x) * math.sin(y) + (osy * osa) 
	local nz = math.cos(y) + (osz * osa)
	
	for oct = 1, details do
		local d1 = get_worley_noise(nx+1,ny,nz,sx,sy,sz) * (dx * da)
		local d2 = get_worley_noise(nx+2,ny,nz,sx,sy,sz) * (dy * da)
		local d3 = get_worley_noise(nx+3,ny,nz,sx,sy,sz) * (dz * da)
		if oct == 1 then
			v = get_worley_noise(nx+d1,ny+d2,nz+d3,sx,sy,sz) else
			v = (v + get_worley_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,sx,sy,sz) * amp ) / (1 + amp)
		end
		nz = nz * 2
		sx, sy, sz = sx / 2, sy / 2, sz / 2
		amp = amp / roughness
	end
	-- v = truncate(factor * (v - 0.5) + 0.5)
	-- v = get_sample_curve(x, y, v, PROFILE)
	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, v, hdr)
	-- return r, g, b, a
	return v, v, v, 1
end;

function get_worley_noise(x,y,z,sx,sy,sz)
	local sx, sy, sz = x / sx , y / sy, z / sz
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local offset_x, offset_y, offset_z
	local min_dist = 10000
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local distance = get_distance(sx, sy, sz, dx, dy, dz, distance_point) 
				min_dist = math.min(distance, min_dist)
			end
		end
	end
	min_dist = 1.0 - min_dist
	return min_dist
end;

--[[
	This version of the get_distance function now computes the distance to the i-th closest point, rather than all four. 
	It also includes support for four different F type distance methods: Euclidean, Manhattan, Chebyshev, and Minkowski (with parameter p). 
	Finally, it includes support for the Quadratic distance method. The function uses the get_point helper function to compute the coordinates 
	of the i-th closest point to the input coordinates (dx, dy, dz).
]]--
function get_distance(sx, sy, sz, dx, dy, dz, distance_point)
	local px, py, pz = get_point(distance_point, dx, dy, dz)
	
	if distance_type == 1 then
		-- Euclidean distance
		local distance = math.sqrt((sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
		return distance
	elseif distance_type == 2 then
		-- Manhattan distance
		local distance = math.abs(sx - px) + math.abs(sy - py) + math.abs(sz - pz)
		return distance
	elseif distance_type == 3 then
		-- Chebyshev distance
		local distance = math.max(math.abs(sx - px), math.abs(sy - py), math.abs(sz - pz))
		return distance
	elseif distance_type == 4 then
		-- Minkowski distance
		local distance = (math.abs(sx - px)^p + math.abs(sy - py)^p + math.abs(sz - pz)^p)^(1/p)
		return distance
	elseif distance_type == 5 then
		-- Quadratic distance
		local distance = ((sx - px)^2 + (sy - py)^2 + (sz - pz)^2) / (1 + (sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
		return distance
	end
end

function get_point(i, dx, dy, dz)
	-- get coordinates of the i-th closest point to (dx, dy, dz)
	local px, py, pz
	if i == 1 then
		px, py, pz = math.floor(dx), math.floor(dy), math.floor(dz)
	elseif i == 2 then
		px, py, pz = math.ceil(dx), math.floor(dy), math.floor(dz)
	elseif i == 3 then
		px, py, pz = math.floor(dx), math.ceil(dy), math.floor(dz)
	else
		px, py, pz = math.ceil(dx), math.ceil(dy), math.floor(dz)
	end
	return px, py, pz
end

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;