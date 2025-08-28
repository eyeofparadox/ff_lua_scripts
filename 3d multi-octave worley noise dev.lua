 --[[
	generate seamless 3d mult-octave worley noise
	using lua version 5.1
	prepare :
	set: randomseed, global variables
		get input variables:
			int seed (1, 30000), int octaves (1, 10), float scale (0, 1), float roughness (0, 100),
			select int distance_type (1 is Euclidean, 2 is Manhattan, 3 is Chebyshev, 4 is Minkowski, 5 is Quadratic),
			select int distance_formula (1	is F1 seed point, 2 is F2seed point, 3 is F3 seed point, 4 is F4 seed point)
	functions :
		function get_sample(x, y)
			calls worley_octaves function
			return r, g, b, a
		function worley_noise(x, y, z, sx, sy, sz)
			generates seed points in array s { x, y, z}
			identifies k nearest neighbors by seed index sorted by distance
			return value
		function worley_octaves(x, y, z, sx, sy, sz)
			calls worley_noise function
			applies distance_type and distance_formula to noise
			return noise
	]]--


function prepare()
	--set random seed
	seed = math.randomseed(SEED)
	metric = get_intslider_input(METRIC) -- range 1 to 5
	formula = get_intslider_input(FORMULA) -- range 1 to 4
	scale = math.max(0.001, get_slider_input(SCALE)) -- [1, 100] - will be replaced by mapped input
	z = 1 - (seed / 30000)
end

--get sample
function get_sample(x, y)
	v = worley_octaves(x, y, z, sx, sy, sz) -- <!> sx, sy, sz undefined
	return v, v, v, 1
end

--generate octaves
function worley_octaves(x, y, z, sx, sy, sz) -- <!> sx, sy, sz undefined
	local noise = worley_noise(x, y, z, sx, sy, sz) -- <!> sx, sy, sz undefined
	local octaves = {}
	
	--perform distance calculation based on type <!> condensed structure
	for i = 1, octaves do
		octaves[i] = {}
		for j = 1, sx do -- <!> may not be consistent with render path
			octaves[i][j] = {}
			for k = 1, sy do
				octaves[i][j][k] = {}
				for l = 1, sz do
					local min_dist = math.huge
					for m = 1, i do
						if metric == 1 then --Euclidean
							local dist = math.sqrt((x - m) ^ 2 + (y - j) ^ 2 + (z - k) ^ 2)
						elseif metric == 2 then --Manhattan
							local dist = math.abs(x - m) + math.abs(y - j) + math.abs(z - k)
						elseif metric == 3 then --Chebyshev
							local dist = math.max(math.abs(x - m), math.abs(y - j), math.abs(z - k))
						elseif metric == 4 then --Minkowski
							local dist = math.pow(math.abs(x - m) ^ 3 + math.abs(y - j) ^ 3 + math.abs(z - k) ^ 3, 1 / 3)
						elseif metric == 5 then --Quadratic
							local dist = math.sqrt(math.abs(x - m) ^ 4 + math.abs(y - j) ^ 4 + math.abs(z - k) ^ 4)
						end
						if dist < min_dist then
							min_dist = dist
						end
					end
				octaves[i][j][k][l] = min_dist * scale * roughness ^ i
				end
			end
		end
	end

	--perform distance formula calculation <!> condensed structure
	for i = 1, sx do -- <!> may not be consistent with render path
		for j = 1, sy do
			for k = 1, sz do
				local min_dist1 = math.huge
				local min_dist2 = math.huge
				local min_dist3 = math.huge
				local min_dist4 = math.huge
				for l = 1, octaves do
					if formula == 1 then -- f1 seed point
						if octaves[l][i][j][k] < min_dist1 then
							min_dist1 = octaves[l][i][j][k]
						end
					elseif formula == 2 then -- f2 seed point
						if octaves[l][i][j][k] < min_dist1 then
							min_dist2 = min_dist1
							min_dist1 = octaves[l][i][j][k]
						elseif octaves[l][i][j][k] < min_dist2 then
							min_dist2 = octaves[l][i][j][k]
						end
					elseif formula == 3 then -- f3 seed point
						if octaves[l][i][j][k] < min_dist1 then
							min_dist3 = min_dist2
							min_dist2 = min_dist1
							min_dist1 = octaves[l][i][j][k]
						elseif octaves[l][i][j][k] < min_dist2 then
							min_dist3 = min_dist2
							min_dist2 = octaves[l][i][j][k]
						elseif octaves[l][i][j][k] < min_dist3 then
							min_dist3 = octaves[l][i][j][k]
						end
					elseif formula == 4 then -- f4 seed point
						if octaves[l][i][j][k] < min_dist1 then
							min_dist4 = min_dist3
							min_dist3 = min_dist2
							min_dist2 = min_dist1
							min_dist1 = octaves[l][i][j][k]
						elseif octaves[l][i][j][k] < min_dist2 then
							min_dist4 = min_dist3
							min_dist3 = min_dist2
							min_dist2 = octaves[l][i][j][k]
						elseif octaves[l][i][j][k] < min_dist3 then
							min_dist4 = min_dist3
							min_dist3 = octaves[l][i][j][k]
						elseif octaves[l][i][j][k] < min_dist4 then
							min_dist4 = octaves[l][i][j][k]
						end
					end
				end
				if formula == 1 then -- f1 seed point
					noise[i][j][k] = min_dist1
				elseif formula == 2 then -- f2 seed point
					noise[i][j][k] = min_dist2
				elseif formula == 3 then -- f3 seed point
					noise[i][j][k] = min_dist3
				elseif formula == 4 then -- f4 seed point
					noise[i][j][k] = min_dist4
				end
			end
		end
	end

	return noise
end

--generate worley noise
function worley_noise(x, y, z, sx, sy, sz) -- <!> sx, sy, sz undefined
	local noise = {}

	for i = 1, sx do -- <!> may not be consistent with render path
		noise[i] = {}
		for j = 1, sy do
			noise[i][j] = {}
			for k = 1, sz do
				--generate random points
				local point = math.random() -- <!> not in `prepare` - use `get_noise`
				noise[i][j][k] = point
			end
		end
	end

	return noise
end


 --[[
	expand worley_octaves and worley_noise functions to generate seamless tiling noise
	]]--


 --[[	archive - code does not conform to ff standards
function get_seamless_tiling_noise(x, y, z, sx, sy, sz, roughness) -- <!> prototype
	local wrap_x = 0, wrap_y = 0, wrap_z = 0
	if wrap == true then
		wrap_x = wrap_function(x)
		wrap_y = wrap_function(y)
		wrap_z = wrap_function(z)
	end
	return get_octaves(wrap_x, wrap_y, wrap_z, sx, sy, sz, roughness)
end
	--seamless tiling


function wrap_function(x) -- <!> prototype
	return math.fmod(x, 1.0)
end
	--seamless tiling assist


function get_distance(sx, sy, sz, dx, dy, dz) -- <!> prototype
	local distance = 0
	if distance_type == 1 then
		distance = math.sqrt((sx - dx) ^ 2 + (sy - dy) ^ 2 + (sz - dz) ^ 2)
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
	-- using int distance_type (1 is Euclidean, 2 is Manhattan, 3 is Chebyshev, 4 is Minkowski, 5 is Quadratic)
	-- using int distance_formula (1 is first closest seed point, 2 is second closest seed point, 3 is third closest seed point, 4 is fourth closest seed point)
	-- formulas not implemented


function get_worley_noise(x, y, z, sx, sy, sz) -- <!> prototype
	local sx, sy, sz = math.fmod(x / sx , 1) , math.fmod(y / sy, 1) , math.fmod(z / sz, 1) -- <!> makes cells -- in the wrong way
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local offset_x, offset_y, offset_z
	local noise = 10000
	for offset_x = - 1, 1 do
		for offset_y = - 1, 1 do
			for offset_z = - 1, 1 do
				-- note use of fmod; does not work in ff
				local dx = math.fmod(cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z), 1)
				local dy = math.fmod(cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z), 1)
				local dz = math.fmod(cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z), 1)
				local distance = get_distance(sx, sy, sz, dx, dy, dz)
				noise = math.min(distance, noise)
			end
		end
	end
	noise = 1.0 - noise
	return noise
end


--set random seed <!> prototype
math.randomseed(seed)

--function to generate 3D worley noise
function worley_noise(x, y, z, sx, sy, sz) -- <!> prototype
	local seed_points = {}
	for i = 1, sx * sy * sz do
		local x_val = math.random(x) -- <!> not in `prepare` - use `get_noise`
		local y_val = math.random(y) -- <!> not in `prepare` - use `get_noise`
		local z_val = math.random(z) -- <!> not in `prepare` - use `get_noise`
		table.insert(seed_points, {x_val, y_val, z_val})
	end
	
	local noise = 0
	for i = 1, sx * sy * sz do
		local x_val = seed_points[i][1]
		local y_val = seed_points[i][2]
		local z_val = seed_points[i][3]

		local dist = 0
		if distance_type == "Euclidean" then
			dist = math.sqrt(math.pow(x_val - x, 2) + math.pow(y_val - y, 2) + math.pow(z_val - z, 2))
		elseif distance_type == "Manhattan" then
			dist = math.abs(x_val - x) + math.abs(y_val - y) + math.abs(z_val - z)
		elseif distance_type == "Chebyshev" then
			dist = math.max(math.abs(x_val - x), math.abs(y_val - y), math.abs(z_val - z))
		elseif distance_type == "Minkowski" then
			dist = math.pow(math.pow(math.abs(x_val - x), 4) + math.pow(math.abs(y_val - y), 4) + math.pow(math.abs(z_val - z), 4), 0.25)
		elseif distance_type == "Quadratic" then
			dist = math.max(math.abs(x_val - x), math.abs(y_val - y), math.abs(z_val - z)) * math.sqrt(x_val ^ 2 + y_val ^ 2 + z_val ^ 2)
		end

		if distance_formula == "first" then
			noise = math.min(noise, dist)
		elseif distance_formula == "second" then
			noise = math.max(noise, dist)
		elseif distance_formula == "third" then
			noise = noise + dist
		elseif distance_formula == "fourth" then
			noise = noise - dist
		end
	end
	
	return noise
end


--function to generate multi-octave worley noise <!> prototype
function worley_octaves(x, y, z, sx, sy, sz) -- <!> prototype
	local noise = 0
	local frequency = 1
	local amplitude = 1
	for i = 1, octaves do
		noise = noise + worley_noise(x * frequency, y * frequency, z * frequency, sx, sy, sz) * amplitude
		frequency = frequency * 2
		amplitude = amplitude * roughness
	end
	noise = noise * scale
	return noise
end


--function to generate multi-octave worley noise <!> prototype
function worley_noise(seed, octaves, scale, roughness, distance_type, distance_formula) -- <!> prototype
	local noise = 0.0
	local amplitude = 1.0
	local frequency = 1.0
	for i = 1, octaves do
	noise = noise + worley_octaves(seed, frequency, amplitude, distance_type, distance_formula)
	amplitude = amplitude * roughness
	frequency = frequency * 2
	end
	noise = noise * scale
	return noise
end


function get_worley_octaves(seed, frequency, amplitude, distance_type, distance_formula) -- <!> prototype
	local noise = 0.0

	local x = math.floor(seed * frequency)
	local y = math.floor(seed * frequency + 1)
	local z = math.floor(seed * frequency + 2)

	local sx = math.floor(seed * frequency + 3)
	local sy = math.floor(seed * frequency + 4)
	local sz = math.floor(seed * frequency + 5)

	noise = noise + get_worley_noise(x, y, z, sx, sy, sz, distance_type, distance_formula)
	noise = noise * amplitude

	return noise
end


function get_worley_noise(x, y, z, sx, sy, sz, distance_type, distance_formula) -- <!> prototype
	local noise = 0.0

	if distance_type == "Euclidean" then
	noise = get_worley_noise_euclidean(x, y, z, sx, sy, sz, distance_formula)
	elseif distance_type == "Manhattan" then
	noise = get_worley_noise_manhattan(x, y, z, sx, sy, sz, distance_formula)
	elseif distance_type == "Chebyshev" then
	noise = get_worley_noise_chebyshev(x, y, z, sx, sy, sz, distance_formula)
	elseif distance_type == "Minkowski" then
	noise = get_worley_noise_minkowski(x, y, z, sx, sy, sz, distance_formula)
	elseif distance_type == "Quadratic" then
	noise = get_worley_noise_quadratic(x, y, z, sx, sy, sz, distance_formula)
	end

	return noise
end


function get_worley_noise_euclidean(x, y, z, sx, sy, sz, distance_formula) -- <!> prototype
	local noise = 0.0

	if distance_formula == "first" then
	noise = math.sqrt((x - sx) ^ 2 + (y - sy) ^ 2 + (z - sz) ^ 2)
	elseif distance_formula == "second" then
	noise = math.sqrt((x - sx - 1) ^ 2 + (y - sy) ^ 2 + (z - sz) ^ 2)
	elseif distance_formula == "third" then
	noise = math.sqrt((x - sx) ^ 2 + (y - sy - 1) ^ 2 + (z - sz) ^ 2)
	elseif distance_formula == "fourth" then
	noise = math.sqrt((x - sx - 1) ^ 2 + (y - sy - 1) ^ 2 + (z - sz) ^ 2)
	end

	return noise
end

function get_worley_noise_manhattan(x, y, z, sx, sy, sz, distance_formula) -- <!> prototype
	local noise = 0.0

	if distance_formula == "first" then
	noise = math.abs(x - sx) + math.abs(y - sy) + math.abs(z - sz)
	elseif distance_formula == "second" then
	noise = math.abs(x - sx - 1) + math.abs(y - sy) + math.abs(z - sz)
	elseif distance_formula == "third" then
	noise = math.abs(x - sx) + math.abs(y - sy - 1) + math.abs(z - sz)
	elseif distance_formula == "fourth" then
	noise = math.abs(x - sx - 1) + math.abs(y - sy - 1) + math.abs(z - sz)
	end

	return noise
end


function get_worley_noise_chebyshev(x, y, z, sx, sy, sz, distance_formula) -- <!> prototype
	local noise = 0.0

	if distance_formula == "first" then
	noise = math.max(math.abs(x - sx), math.abs(y - sy), math.abs(z - sz))
	elseif distance_formula == "second" then
	noise = math.max(math.abs(x - sx - 1), math.abs(y - sy), math.abs(z - sz))
	elseif distance_formula == "third" then
	noise = math.max(math.abs(x - sx), math.abs(y - sy - 1), math.abs(z - sz))
	elseif distance_formula == "fourth" then
	noise = math.max(math.abs(x - sx - 1), math.abs(y - sy - 1), math.abs(z - sz))
	end

	return noise
end

function get_worley_noise_minkowski(x, y, z, sx, sy, sz, distance_formula) -- <!> prototype
	local noise = 0.0

	if distance_formula == "first" then
	noise = math.pow(math.pow(math.abs(x - sx), 3) + math.pow(math.abs(y - sy), 3) + math.pow(math.abs(z - sz), 3), 1 / 3)
	elseif distance_formula == "second" then
	noise = math.pow(math.pow(math.abs(x - sx - 1), 3) + math.pow(math.abs(y - sy), 3) + math.pow(math.abs(z - sz), 3), 1 / 3)
	elseif distance_formula == "third" then
	noise = math.pow(math.pow(math.abs(x - sx), 3) + math.pow(math.abs(y - sy - 1), 3) + math.pow(math.abs(z - sz), 3), 1 / 3)
	elseif distance_formula == "fourth" then
	noise = math.pow(math.pow(math.abs(x - sx - 1), 3) + math.pow(math.abs(y - sy - 1), 3) + math.pow(math.abs(z - sz), 3), 1 / 3)
	end

	return noise
end


function get_worley_noise_quadratic(x, y, z, sx, sy, sz, distance_formula) -- <!> prototype
	local noise = 0.0

	if distance_formula == "first" then
	noise = math.sqrt(math.pow(x - sx, 4) + math.pow(y - sy, 4) + math.pow(z - sz, 4))
	elseif distance_formula == "second" then
	noise = math.sqrt(math.pow(x - sx - 1, 4) + math.pow(y - sy, 4) + math.pow(z - sz, 4))
	elseif distance_formula == "third" then
	noise = math.sqrt(math.pow(x - sx, 4) + math.pow(y - sy - 1, 4) + math.pow(z - sz, 4))
	elseif distance_formula == "fourth" then
	noise = math.sqrt(math.pow(x - sx - 1, 4) + math.pow(y - sy - 1, 4) + math.pow(z - sz, 4))
	end

	return noise
end


function prepare() -- <!> prototype
	math.randomseed(SEED)
	metric = get_intslider_input(METRIC) -- range 1 to 5
	local size = 64
	local seed = {}
	for i = 1, size * size * size + 2 do
		seed[i] = {math.random(size), math.random(size), math.random(size)}
	end
end

function metric(metric) -- <!> prototype
	if metric == 1 then --Euclidean
		local noise = worley3d(size, seed, "euclidean")
	elseif metric == 2 then --Manhattan
		local noise = worley3d(size, seed, "manhattan")
	elseif metric == 3 then --Chebyshev
		local noise = worley3d(size, seed, "chebyshev")
	elseif metric == 4 then --Minkowski
		local noise = worley3d(size, seed, "minkowski")
	elseif metric == 5 then --Quadratic
		local noise = worley3d(size, seed, "quadratic")
	end
end

function worley3d(size, seed, metric) -- <!> prototype
	local noise = {}
	for z = 1, size do
		noise[z] = {}
		for y = 1, size do
			noise[z][y] = {}
			for x = 1, size do
				local min_dist = math.huge
				local second_dist = math.huge
				local third_dist = math.huge
				local fourth_dist = math.huge
				for sx = 0, size + 1 do
					for sy = 0, size + 1 do
						for sz = 0, size + 1 do
							local i = sx * size + sy * size * size + sz
							local seed_x = seed[i][1]
							local seed_y = seed[i][2]
							local seed_z = seed[i][3]
							local dist = 0
							if metric == "euclidean" then
								dist = math.sqrt((x - seed_x) ^ 2 + (y - seed_y) ^ 2 + (z - seed_z) ^ 2)
							elseif metric == "manhattan" then
								dist = math.abs(x - seed_x) + math.abs(y - seed_y) + math.abs(z - seed_z)
							elseif metric == "chebyshev" then
								dist = math.max(math.abs(x - seed_x), math.abs(y - seed_y), math.abs(z - seed_z))
							elseif metric == "minkowski" then
								dist = math.pow(math.pow(math.abs(x - seed_x), 4) + math.pow(math.abs(y - seed_y), 4) + math.pow(math.abs(z - seed_z), 4), 0.25)
							elseif metric == "quadratic" then
								dist = math.sqrt((x - seed_x) ^ 2 + (y - seed_y) ^ 2 + (z - seed_z) ^ 2 + 0.001)
							end
							if dist < min_dist then
								fourth_dist = third_dist
								third_dist = second_dist
								second_dist = min_dist
								min_dist = dist
							elseif dist < second_dist then
								fourth_dist = third_dist
								third_dist = second_dist
								second_dist = dist
							elseif dist < third_dist then
								fourth_dist = third_dist
								third_dist = dist
							elseif dist < fourth_dist then
								fourth_dist = dist
							end
						end
					end
				end
				noise[z][y][x] = {min_dist, second_dist, third_dist, fourth_dist}
			end
		end
	end
	return noise
end
 --[[
	generates seamless 3d mult-octave worley noise with randomseed, int seed (1, 30000), int octaves (1, 10), float scale (0, 1), float roughness (0, 100), using Euclidean, Manhattan, Chebyshev, Minkowski, and Quadratic distance formulas to the first, second, third, and fourth closest seed point using lua version 5.1
	composed with help from https://platform.openai.com/playground?mode=complete
	] ]--


function prepare() -- <!> prototype
	-- seed the random number generator
	math.randomseed(randomseed)

	-- define the scale
	local scale = get_intslider_input(SCALE)

	-- define the Worley noise array
	local noise = {}

	-- define the distance formulas
	local method = get_intslider_input(METHOD)
	local formula = get_intslider_input(FORMULA)

	-- define the number of octaves
	local octaves = get_intslider_input(OCTAVES)

-- <!>:merge noise functions with dist if block, implement input variables and samples
end

--get sample
function get_sample(x, y)
	...
	return v, v, v, 1
end

-- Euclidean

local function get_euclidean_3d_worley_noise(x, y, z, octaves) -- <!> prototype
	 local noise = 0.0
	 local scale = 1.0
	 local total_weight = 0.0

	 for o = 1, octaves do
		local seed_x, seed_y, seed_z = math.random(x), math.random(y), math.random(z) -- <!> not in `prepare` - use `get_noise`
		local min_dist1 = math.huge
		local min_dist2 = math.huge
		local min_dist3 = math.huge
		local min_dist4 = math.huge

		for x_offset = - 1, 1 do
		 for y_offset = - 1, 1 do
			for z_offset = - 1, 1 do
				 local nx = seed_x + (x_offset * x)
				 local ny = seed_y + (y_offset * y)
				 local nz = seed_z + (z_offset * z)
				 local dist = math.sqrt( (x - nx) ^ 2 + (y - ny) ^ 2 + (z - nz) ^ 2 )
				 if dist < min_dist1 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = min_dist1
					min_dist1 = dist
				 elseif dist < min_dist2 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = dist
				 elseif dist < min_dist3 then
					min_dist4 = min_dist3
					min_dist3 = dist
				 elseif dist < min_dist4 then
					min_dist4 = dist
				 end
			end
		 end
		end

		noise = noise + (min_dist1 + min_dist2 + min_dist3 + min_dist4) * scale
		total_weight = total_weight + scale
		scale = scale * 0.5
	 end

	 return noise / total_weight
end

-- Manhattan

local function get_manhattan_3d_worley_noise(x, y, z, octaves) -- <!> prototype
	 local noise = 0.0
	 local scale = 1.0
	 local total_weight = 0.0

	 for o = 1, octaves do
		local seed_x, seed_y, seed_z = math.random(x), math.random(y), math.random(z) -- <!> not in `prepare` - use `get_noise`
		local min_dist1 = math.huge
		local min_dist2 = math.huge
		local min_dist3 = math.huge
		local min_dist4 = math.huge

		for x_offset = - 1, 1 do
		 for y_offset = - 1, 1 do
			for z_offset = - 1, 1 do
				 local nx = seed_x + (x_offset * x)
				 local ny = seed_y + (y_offset * y)
				 local nz = seed_z + (z_offset * z)
				 local dist = math.abs(x - nx) + math.abs(y - ny) + math.abs(z - nz)
				 if dist < min_dist1 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = min_dist1
					min_dist1 = dist
				 elseif dist < min_dist2 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = dist
				 elseif dist < min_dist3 then
					min_dist4 = min_dist3
					min_dist3 = dist
				 elseif dist < min_dist4 then
					min_dist4 = dist
				 end
			end
		 end
		end

		noise = noise + (min_dist1 + min_dist2 + min_dist3 + min_dist4) * scale
		total_weight = total_weight + scale
		scale = scale * 0.5
	 end

	 return noise / total_weight
end

-- Chebyshev

local function get_chebyshev_3d_worley_noise(x, y, z, octaves) -- <!> prototype
	 local noise = 0.0
	 local scale = 1.0
	 local total_weight = 0.0

	 for o = 1, octaves do
		local seed_x, seed_y, seed_z = math.random(x), math.random(y), math.random(z) -- <!> not in `prepare` - use `get_noise`
		local min_dist1 = math.huge
		local min_dist2 = math.huge
		local min_dist3 = math.huge
		local min_dist4 = math.huge

		for x_offset = - 1, 1 do
		 for y_offset = - 1, 1 do
			for z_offset = - 1, 1 do
				 local nx = seed_x + (x_offset * x)
				 local ny = seed_y + (y_offset * y)
				 local nz = seed_z + (z_offset * z)
				 local dist = math.max( math.abs(x - nx), math.abs(y - ny), math.abs(z - nz))
				 if dist < min_dist1 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = min_dist1
					min_dist1 = dist
				 elseif dist < min_dist2 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = dist
				 elseif dist < min_dist3 then
					min_dist4 = min_dist3
					min_dist3 = dist
				 elseif dist < min_dist4 then
					min_dist4 = dist
				 end
			end
		 end
		end

		noise = noise + (min_dist1 + min_dist2 + min_dist3 + min_dist4) * scale
		total_weight = total_weight + scale
		scale = scale * 0.5
	 end

	 return noise / total_weight
end

-- Minkowski

local function get_minkowski_3d_worley_noise(x, y, z, octaves) -- <!> prototype
	 local noise = 0.0
	 local scale = 1.0
	 local total_weight = 0.0

	 for o = 1, octaves do
		local seed_x, seed_y, seed_z = math.random(x), math.random(y), math.random(z) -- <!> not in `prepare` - use `get_noise`
		local min_dist1 = math.huge
		local min_dist2 = math.huge
		local min_dist3 = math.huge
		local min_dist4 = math.huge

		for x_offset = - 1, 1 do
		 for y_offset = - 1, 1 do
			for z_offset = - 1, 1 do
				 local nx = seed_x + (x_offset * x)
				 local ny = seed_y + (y_offset * y)
				 local nz = seed_z + (z_offset * z)
				 local dist = math.pow( math.abs(x - nx), 3 ) + math.pow( math.abs(y - ny), 3 ) + math.pow(math.abs(z - nz), 3 )
				 if dist < min_dist1 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = min_dist1
					min_dist1 = dist
				 elseif dist < min_dist2 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = dist
				 elseif dist < min_dist3 then
					min_dist4 = min_dist3
					min_dist3 = dist
				 elseif dist < min_dist4 then
					min_dist4 = dist
				 end
			end
		 end
		end

		noise = noise + (min_dist1 + min_dist2 + min_dist3 + min_dist4) * scale
		total_weight = total_weight + scale
		scale = scale * 0.5
	 end

	 return noise / total_weight
end

-- Quadratic

local function get_quadratic_3d_worley_noise(x, y, z, octaves) -- <!> prototype
	 local noise = 0.0
	 local scale = 1.0
	 local total_weight = 0.0

	 for o = 1, octaves do
		local seed_x, seed_y, seed_z = math.random(x), math.random(y), math.random(z) -- <!> not in `prepare` - use `get_noise`
		local min_dist1 = math.huge
		local min_dist2 = math.huge
		local min_dist3 = math.huge
		local min_dist4 = math.huge

		for x_offset = - 1, 1 do
		 for y_offset = - 1, 1 do
			for z_offset = - 1, 1 do
				 local nx = seed_x + (x_offset * x)
				 local ny = seed_y + (y_offset * y)
				 local nz = seed_z + (z_offset * z)
				 local dist = math.sqrt( math.pow(x - nx, 4) + math.pow(y - ny, 4) + math.pow(z - nz, 4))
				 if dist < min_dist1 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = min_dist1
					min_dist1 = dist
				 elseif dist < min_dist2 then
					min_dist4 = min_dist3
					min_dist3 = min_dist2
					min_dist2 = dist
				 elseif dist < min_dist3 then
					min_dist4 = min_dist3
					min_dist3 = dist
				 elseif dist < min_dist4 then
					min_dist4 = dist
				 end
			end
		 end
		end

		noise = noise + (min_dist1 + min_dist2 + min_dist3 + min_dist4) * scale
		total_weight = total_weight + scale
		scale = scale * 0.5
	 end

	 return noise / total_weight
end
 --[[
	generates 3d mult-octave worley noise with randomseed using Euclidean, Manhattan, Chebyshev, Minkowski, and Quadratic distance formulas to the first, second, third, and fourth closest seed point using lua version 5.1
	composed with help from https://platform.openai.com/playground?mode=complete
	] ]--



-- first, we define our distance function, which will be used to calculate the distance between each seed point and the point being evaluated.
local function distance(x1, y1, z1, x2, y2, z2) -- <!> prototype
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) + math.pow(z2 - z1, 2))
end

-- we then define our noise function, which will generate our mult-octave worley noise.
function worleynoise(x, y, z) -- <!> prototype
	local seeds = {}
	local closest = {math.huge, math.huge, math.huge, math.huge}
	local closestseed = {0, 0, 0, 0}
	local octaves = 8
	local frequency = 1
	local scale = 1
	local result = 0
	
	-- generate our random seed points
	for octave = 1, octaves do
		for i = 1, frequency do
			table.insert(seeds, {math.random(0, 1000000), math.random(0, 1000000), math.random(0, 1000000)}) -- <!> not in `prepare` - use `get_noise`
		end
		frequency = frequency * 2
	end
	
	-- calculate the distances and find the closest four points
	for i, seed in ipairs(seeds) do
		local dist = distance(x, y, z, seed[1], seed[2], seed[3])
		if dist < closest[1] then
			closest[4] = closest[3]
			closest[3] = closest[2]
			closest[2] = closest[1]
			closest[1] = dist
			closestseed[4] = closestseed[3]
			closestseed[3] = closestseed[2]
			closestseed[2] = closestseed[1]
			closestseed[1] = i
		elseif dist < closest[2] then
			closest[4] = closest[3]
			closest[3] = closest[2]
			closest[2] = dist
			closestseed[4] = closestseed[3]
			closestseed[3] = closestseed[2]
			closestseed[2] = i
		elseif dist < closest[3] then
			closest[4] = closest[3]
			closest[3] = dist
			closestseed[4] = closestseed[3]
			closestseed[3] = i
		elseif dist < closest[4] then
			closest[4] = dist
			closestseed[4] = i
		end
	end
	
	-- calculate the noise value based on the four closest points
	result = result + (closest[1] / scale)
	result = result + (closest[2] / scale / 2)
	result = result + (closest[3] / scale / 4)
	result = result + (closest[4] / scale / 8)
	
	return result
end


function prepare() -- <!> prototype
	--set random seed
	seed = math.randomseed(SEED)
	-- define the number of octaves
	local octaves = get_intslider_input(OCTAVES)
	z = 1 - (seed / 30000)
end

--get sample
function noise(x, y) -- <!> prototype
	-- generate the noise
	for x = 0, 1 do
		noise[x] = {}
		for y = 0, 1 do
		noise[x][y] = {}
		for z = 0, 1 do
			local value = 0
			-- local scale = 1
			for octave = 1, octaves do
			local seedx = math.random() -- <!> not in `prepare` - use `get_noise`
			local seedy = math.random() -- <!> not in `prepare` - use `get_noise`
			local seedz = math.random() -- <!> not in `prepare` - use `get_noise`
			local dist = math.huge
			for _, distfn in ipairs(distfns) do
				local d = distfn(x, y, z, seedx, seedy, seedz)
				if d < dist then
				dist = d
				end
			end
			value = value + (1 - dist) * scale
			scale = scale * 0.5
			end
			noise[x][y][z] = value
		end
		end
	end
	-- return noise
end
	]]--


-- 3d worley base -- <!> prototype
function prepare()
	amp = 1
	distance_type = get_intslider_input(DISTANCE_TYPE) -- range 1 to 5
	distance_formula = get_intslider_input(DISTANCE_FORMULA) -- range 1 to 4
	details = get_intslider_input(DETAILS) -- range 1 to 10
	scale = math.max(0.001, get_slider_input(SCALE)) -- range 1 to 100 - will be replaced by mapped input
	set_noise_seed(get_intslider_input(SEED) + 1) -- range 1 to 30000 + 1
	-- z = 1 - (SEED / 30000)
end;

function get_sample(x, y)
	local z = get_sample_grayscale(x, y, Z)
	local r,g,b,a -- will be sampled
	local roughness = 3.75
 --[[
	local r, g, b, a = get_sample_map(x, y, HIGH)
	local r, g, b, a = get_sample_map(x, y, LOW)
	get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	get_sample_grayscale(x, y, CONTRAST)
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	-- sx, sy, sz = sx * x, sy * y, sz * z -- * 2.5
	sx, sy, sz = x / sx , y / sy, z / sz -- scales will need a non-zero modification
	]]--
	local sx, sy, sz = x / scale , y / scale, z / scale
	local noise = worley(sx,sy,sz,roughness)
	r,g,b,a = noise, noise, noise, 1
	return r,g,b,a
end;

function worley(sx,sy,sz, roughness) -- <!> purged - should be seamless but not having the right effect
	-- seamless tiling noise -- <!> unimplemented - may be incorporated into noise function, or may become a subordinate function
	...
	local noise = worley_octaves(sx,sy,sz,roughness)
	return noise
end
 --[[
	worley function, initial controller function called to generate fractal noise <!> basic prototype
	this prototype of the controller is depricated, but could be useful to test dependencies
	]]--

function worley_octaves(sx,sy,sz,roughness)
	for oct = 1,details do
		if oct == 1 then 
			octaves = worley_noise(sx,sy,sz)
		else
			octaves = (octaves + worley_noise(x/oct,y/oct,z/oct,sx,sy,sz) * amp ) / (1 + amp)
		end
		z = z * 2
		sx, sy, sz = sx / 2, sy / 2, sz / 2
		amp = amp / roughness
	end
	return octaves
end
 --[[
	worley octaves function, generates fractal noise influenced by scale and roughness <!> basic prototype
	this prototype of the octaves generator is enough to test dependencies
	]]--

function worley_noise(sx,sy,sz)
	local sx, sy, sz = sx , sy, sz
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
 --[[
	worley noise function, computes a distance for one metric and formula <!> basic prototype
	this prototype of the noise generator is enough to test a specific calculation
	]]--

function worley_distance(x1, y1, z1, x2, y2, z2) -- <!> prototype - needs k nearest points
	local distance = 0
	if distance_type == 1 then
		-- Euclidean distance formulas
		if distance_formula == 1 then
		distance = math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2)
		elseif distance_formula == 2 then
		distance = math.sqrt((x1 - x3) ^ 2 + (y1 - y3) ^ 2 + (z1 - z3) ^ 2)
		elseif distance_formula == 3 then
		distance = math.sqrt((x1 - x4) ^ 2 + (y1 - y4) ^ 2 + (z1 - z4) ^ 2)
		elseif distance_formula == 4 then
		distance = math.sqrt((x1 - x5) ^ 2 + (y1 - y5) ^ 2 + (z1 - z5) ^ 2)
		end
	elseif distance_type == 2 then
		-- Manhattan distance formulas
		if distance_formula == 1 then
		distance = math.abs(x1 - x2) + math.abs(y1 - y2) + math.abs(z1 - z2)
		elseif distance_formula == 2 then
		distance = math.abs(x1 - x3) + math.abs(y1 - y3) + math.abs(z1 - z3)
		elseif distance_formula == 3 then
		distance = math.abs(x1 - x4) + math.abs(y1 - y4) + math.abs(z1 - z4)
		elseif distance_formula == 4 then
		distance = math.abs(x1 - x5) + math.abs(y1 - y5) + math.abs(z1 - z5)
		end
	elseif distance_type == 3 then
		-- Chebyshev distance formulas
		if distance_formula == 1 then
		elseif distance_formula == 2 then
		distance = math.max(math.abs(x), math.abs(y), math.abs(z))
		elseif distance_formula == 3 then
		distance = math.max(math.abs(x - 1), math.abs(y - 1), math.abs(z - 1))
		distance = math.max(math.abs(x - 2), math.abs(y - 2), math.abs(z - 2))
		elseif distance_formula == 4 then
		distance = math.max(math.abs(x - 3), math.abs(y - 3), math.abs(z - 3))
		end
	elseif distance_type == 4 then
		-- Minkowski distance formulas
		if distance_formula == 1 then
		distance = math.pow((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2, 0.5)
		elseif distance_formula == 2 then
		distance = math.pow((x1 - x3) ^ 2 + (y1 - y3) ^ 2 + (z1 - z3) ^ 2, 0.5)
		elseif distance_formula == 3 then
		distance = math.pow((x1 - x4) ^ 2 + (y1 - y4) ^ 2 + (z1 - z4) ^ 2, 0.5)
		elseif distance_formula == 4 then
		distance = math.pow((x1 - x5) ^ 2 + (y1 - y5) ^ 2 + (z1 - z5) ^ 2, 0.5)
		end
	end
	return distance
end
 --[[
	distance multi-function, computes a distance based on selected distance_type and distance_formula <!> compress further
	this is more a prototype of the selection conditional than the required model
	]]--

function worley_distance(sx,sy,sz,dx,dy,dz)
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
	return distance
end
 --[[
	distance multi-function, computes a distance based on selected distance_type and distance_formula <!> compressed prototype
	this prototype of the selection conditional is closer to the required model
	]]--


