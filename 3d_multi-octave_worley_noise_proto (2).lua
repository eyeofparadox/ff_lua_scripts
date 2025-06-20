-- lua version 5.1
-- 3d worley base
function prepare()
	amp = 1
	distance_type = get_intslider_input(DISTANCE_TYPE) -- [1, 5]
	distance_formula = get_intslider_input(DISTANCE_FORMULA) -- [1, 4]
	details = get_intslider_input(DETAILS) -- [1, 10]
	scale = math.max(0.001, get_slider_input(SCALE)) -- [1, 100] - will be replaced by mapped input
	set_noise_seed(get_intslider_input(SEED) + 1) -- [1, 30000] + 1
	-- z = 1 - (SEED / 30000)
end;

function get_sample(x, y)
	local z = get_sample_grayscale(x, y, Z)
	local r,g,b,a -- will be sampled
	local roughness = 3.75 -- - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	-- local sx, sy, sz, sa = get_sample_map(x, y, SCALE)-- [[0, 1], [1, 100]]
	-- sx, sy, sz = sx * sa * 2.5, sy * sa * 2.5, sz * sa * 2.5
	local sx, sy, sz = x / scale , y / scale, z / scale
	-- local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz) - prototype block
	-- local offset_x, offset_y, offset_z
	-- local min_dist = 100
	-- for offset_x=-1,1 do
		-- for offset_y=-1,1 do
			-- for offset_z=-1,1 do
				-- local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				-- local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				-- local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				-- local dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)
				-- min_dist = math.min(dist, min_dist)
			-- end
		-- end
	-- end
	-- min_dist = 1.0 - min_dist
	-- return min_dist, min_dist, min_dist, a
	local noise = worley(x,y,z,sx,sy,sz,roughness)
	r,g,b,a = noise, noise, noise, 1

	return r,g,b,a
end;

function worley(x,y,z,sx,sy,sz, roughness)
	-- seamless tiling noise
	local x_wrap = x % sx
	local y_wrap = y % sy
	local z_wrap = z % sz
	local noise = worley_octaves(x_wrap,y_wrap,z_wrap,sx,sy,sz,roughness)
	return noise
end

function worley_octaves(x,y,z,sx,sy,sz,roughness)
	for oct = 1,details do
		if oct == 1 then 
			octaves = worley_noise(x,y,z,sx,sy,sz)
		else
			octaves = (octaves + worley_noise(x/oct,y/oct,z/oct,sx,sy,sz) * amp ) / (1 + amp)
		end
		z = z * 2
		sx, sy, sz = sx / 2, sy / 2, sz / 2
		amp = amp / roughness
	end
	return octaves
end

function worley_noise(x,y,z,sx,sy,sz)
	local sx, sy, sz = sx, sy, sz
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local offset_x, offset_y, offset_z
	local noise = 10000
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local distance = worley_distance(sx,sy,sz,dx,dy,dz)
				noise = math.min(distance, noise)
			end
		end
	end
	noise = 1.0 - noise
	return noise
end;

function worley_distance(sx,sy,sz,dx,dy,dz)
	local distance = 0
	-- using int distance_type (1 is Euclidean, 2 is Manhattan, 3 is Chebyshev, 4 is Minkowski, 5 is Quadratic)
	-- using int distance_formula (1 is first closest seed point, 2 is second closest seed point, 3 is third closest seed point, 4 is fourth closest seed point)
	-- distance_formula options still needed
	if distance_type == 1 then
		distance = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)
	elseif distance_type == 2 then
		distance = math.abs(sx - dx) + math.abs(sy - dy) + math.abs(sz - dz)
	elseif distance_type == 3 then
		distance = math.max(math.abs(sx - dx), math.abs(sy - dy), math.abs(sz - dz))
	elseif distance_type == 4 then
		distance = math.pow(math.pow(math.abs(sx - dx), 3) + math.pow(math.abs(sy - dy), 3) + math.pow(math.abs(sz - dz), 3), 0.3333333333)
	elseif distance_type == 5 then
		distance = math.sqrt(math.pow(sx - dx, 4) + math.pow(sy - dy, 4) + math.pow(sz - dz, 4))
	end
	return distance
end