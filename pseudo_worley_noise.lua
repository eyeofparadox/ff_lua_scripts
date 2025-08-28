--[[
# convert from pseudo code to lua version 5.1
[
create functions
	prepare()
		create global:
			int set_noise_seed(get_intslider_input(SEED)) -- range 1 to 30000
			int details = get_intslider_input(DETAILS) -- range 1 to 10
			int distance_type -- range 1 to 5
			int distance_formula -- range 1 to 4
			float z = 1 - (1 / 30000)
	end
	get_octaves(x,y,z,sx,sy,sz)
		for 1 to details do 
			octaves = get_worley_noise(x,y,z,sx,sy,sz)
			sx, sy, sz = sx / 2, sy / 2, sz / 2
		end
	get_distance(sx,sy,sz,dx,dy,dz)
		using int distance_type (1 is Euclidean, 2 is Manhattan, 3 is Chebyshev, 4 is Minkowski, 5 is Quadratic),
		using int distance_formula (1 is first closest seed point, 2 is second closest seed point, 3 is third closest seed point, 4 is fourth closest seed point)
		local distance = calculate distance mapping by distance_type and distance_formula
	return noise = distance
	get_worley_noise(x,y,z,sx,sy,sz)
		local sx, sy, sz = x / sx , y / sy, z / sz
		local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
		for x_off, y_off, z_off range -1 to 1 do
			local dx,dy,dz
				generate seamless 3d worley noise -- cell + offset by coordinate
			noise = min(get_distance(sx,sy,sz,dx,dy,dz), 10000)
	return noise
	get_sample(x,y) 
		local float r,g,b,a -- will be sampled
		local float sx, sy, sz = 1 -- will be sampled
		local float x_off, y_off, z_off
		local noise = get_octaves(x,y,z,sx,sy,sz)
		noise = 1 - noise
		r,g,b,a = noise, noise, noise, 1
	return r,g,b,a
]
# end of pseudo code
]]--
-- lua version 5.1

function prepare()
	-- create global
	set_noise_seed(SEED) -- range 1 to 30000
	details = get_intslider_input(DETAILS) -- range 1 to 10
	distance_type = get_intslider_input(DISTANCE_TYPE) -- range 1 to 5
	distance_formula = get_intslider_input(DISTANCE_FORMULA) -- range 1 to 4
	z = 1 - (1 / 30000)
end

function get_octaves(x,y,z,sx,sy,sz)
	for i=1,details do
		octaves = get_worley_noise(x,y,z,sx,sy,sz)
		sx = sx / 2
		sy = sy / 2
		sz = sz / 2
	end
end

function get_distance(sx,sy,sz,dx,dy,dz)
	local distance = 0
	-- using int distance_type (1 is Euclidean, 2 is Manhattan, 3 is Chebyshev, 4 is Minkowski, 5 is Quadratic)
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

	-- using int distance_formula (1 is first closest seed point, 2 is second closest seed point, 3 is third closest seed point, 4 is fourth closest seed point)
	-- formulas not implemented correctly
	-- if distance_formula == 1 then
		-- distance = math.min(distance, 10000)
	-- elseif distance_formula == 2 then
		-- distance = math.min(distance, 10000)
	-- elseif distance_formula == 3 then
		-- distance = math.min(distance, 10000)
	-- elseif distance_formula == 4 then
		-- distance = math.min(distance, 10000)
	-- end
	
	return distance
end

function get_worley_noise(x,y,z,sx,sy,sz)
	local sx, sy, sz = x / sx , y / sy, z / sz
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	for x_off=-1, 1 do
		for y_off=-1, 1 do
			for z_off=-1, 1 do
				-- generate seamless 3d worley noise -- cell + offset by coordinate
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				noise = get_distance(sx,sy,sz,dx,dy,dz)
				noise = math.min(noise, 10000)
			end
		end
	end
	noise = 1 - noise
	return noise
end

function get_sample(x,y)
	local r,g,b,a -- will be sampled
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	local x_off, y_off, z_off
	local noise = get_octaves(x,y,z,sx,sy,sz)
	r,g,b,a = noise, noise, noise, 1
	return r,g,b,a
end