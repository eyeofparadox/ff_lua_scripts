function prepare()
	-- inputs and precalculation.
end;

function get_sample(x, y)
	-- image generation code.
	-- define the width and height of the noise image
	local width = 512
	local height = 512

	-- define the "grid" size for the noise
	local grid_size = 32

	-- define the "falloff" for the Gaussian distance mapping
	local falloff = 2

	-- create a table to store the noise values
	local noise = {}

	-- seed the random number generator
	math.randomseed(get_intslider_input(SEED))

	-- iterate over the pixels in the image
	for x = 0, width - 1 do
	  for y = 0, height - 1 do
		-- determine the grid coordinates for this pixel
		local grid_x = math.floor(x / grid_size)
		local grid_y = math.floor(y / grid_size)
		
		-- generate a random value between 0 and 1
		local value = math.random()
		
		-- calculate the distance of the pixel from the center of its grid cell
		local dx = x - (grid_x * grid_size + grid_size / 2)
		local dy = y - (grid_y * grid_size + grid_size / 2)
		local distance = math.sqrt(dx * dx + dy * dy)
		
		-- apply the Gaussian falloff to the value
		value = value * math.exp(-distance * distance / (2 * falloff * falloff))
		
		-- store the modified value in the noise table
		noise[x + y * width] = value
	  end
	end

	-- return the noise table
	return noise

end;