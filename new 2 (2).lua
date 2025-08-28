function prepare()
--	constants
	resolution = math.min(OUTPUT_WIDTH, OUTPUT_HEIGHT)
	amp_c = 1.731628995
	rough_c = 0.00001
	min_c = 0.00001

--	input values
	radius = 1 / math.max(get_slider_input(RADIUS), 0.00001)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seamless_region(aspect, aspect)
	details = 1 -- math.max(get_slider_input(DETAILS), 0.000011)
	details = details + (details * 25)
	noise_size = 3 -- get_slider_input(SCALE)
	set_perlin_noise_seamless(true)
end;

function get_sample(x, y)
	local z = 0
	local xx,yy, zz = add_vector_gradients(x, y, 1, resolution)
	for x = 0, 1 do
		for y = 0, 1 do
			for z = 0, resolution do
				x, y, z = xx[x], yy[y], zz[z]
			end;
		end;
	end;
	roughness = math.max(0.575, rough_c) -- math.max(get_sample_grayscale(x, y, ROUGHNESS), 0.000011)
	roughness = roughness + (roughness * 0.5)
	x, y = x * 2 - 1, y * 2 - 1, z * 2 - 1
	x, y = x * radius, y * radius, z * radius
	local alpha, r = 1, 1 - math.sqrt(x * x + y * y)
	if r < 0 then alpha = 0 end;
	local th = (math.atan2(y, x) * 0.159155 + 0.5) * 2
	local r = get_sample_curve(th, r, r, PROFILE)
	local v = get_perlin_octaves(th, r, z, 1)
	return v, v, v, alpha
	--  return th, r, r_1, alpha
end;

function add_vector_gradients(x, y, num_dimensions, resolution)
	local gradients = {{1, 0}, {0, 1}} -- x and y gradients
	for i = 1, num_dimensions do
		table.insert(gradients, {1 / resolution, -1 / resolution})
	end
	return unpack(gradients)
end
	-- resolution = math.min(OUTPUT_WIDTH, OUTPUT_HEIGHT)
	-- x, y, z, w = add_vector_gradients(x, y, 2, resolution)
	-- x, y, z = add_vector_gradients(x, y, 1, resolution)
	--<!> returns tables; add loop to access sample coordinates


function map_equirectangular(x, y)
	local nx = math.cos(x) * math.sin(y)
	local ny = math.sin(x) * math.sin(y)
	local nz = math.cos(y)
	return nx, ny, nz
end;
--	local nx, ny, nz = map_equirectangular(x, y)

function get_perlin_octaves(x, y, z, channel)
	local v, x, y, z, channel = 0, x, y, z, channel
	octaves_n = math.floor(details)
	local remainder = details - octaves_n
	if (remainder > min_c) then
		octaves_n = octaves_n + 1
	end
	octaves = {}
	local cell_size = (0.00001 + (noise_size * 0.99999))
	cell_size = cell_size + (cell_size * 1000)
	local scale = roughness
	local octave_index
	for octave_index = 1, octaves_n do
		if (scale < rough_c) then
			octaves_n = octave_index - 1
			break
		end
		octaves[octave_index] = {cell_size, scale}
		cell_size = cell_size * 0.5
		scale = scale * roughness
	end
	
	if (remainder >= 0.001) then
		octaves[octaves_n][2] = octaves[octaves_n][2] * remainder
	end

	norm = 0
	for octave_index = 1, octaves_n do
		norm = norm + octaves[octave_index][2] ^ 2
	end
	norm = 1 / math.sqrt(norm)

	local octave_index 
	for octave_index = 1, octaves_n do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		v = v + opacity * (2 * get_perlin_noise(x, y, z, size) - 1)
		-- v = v + opacity * (2 * get_perlin_noise(x, y, octave_index, size) - 1)
	end
	v = (v * norm + amp_c) * (0.5 / amp_c)
	return v
end;
