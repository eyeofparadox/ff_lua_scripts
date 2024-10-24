function prepare()
--<!> include
	-- call get_intslider_input with the distance_point key to get the distance point from the user
	distance_point = get_intslider_input(DISTANCE_POINT)
	-- call get_distance function and pass the distance_point variable as an argument
	distance = get_distance(distance_point)
end;

function get_distance(sx,sy,sz,dx,dy,dz)
	local d = {}
	-- compute distances to all 4 closest points
	for i = 1, 4 do
		local px, py, pz = get_point(i, dx, dy, dz)
		if distance_type == 1 then
			-- Euclidean distance
			d[i] = math.sqrt((sx - px)^2 + (sy - py)^2 + (sz - pz)^2)	
		elseif distance_type == 2 then
			-- Manhattan distance
			d[i] = math.abs(sx - px) + math.abs(sy - py) + math.abs(sz - pz)
		elseif distance_type == 3 then
			-- Chebyshev distance
			d[i] = math.max(math.abs(sx - px), math.abs(sy - py), math.abs(sz - pz))
		elseif distance_type == 4 then
			-- Minkowski distance
			d[i] = (math.abs(sx - px)^p + math.abs(sy - py)^p + math.abs(sz - pz)^p)^(1/p)
		elseif distance_type == 5 then
			-- Quadratic distance
			d[i] = ((sx - px)^2 + (sy - py)^2 + (sz - pz)^2) / (1 + (sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
		end
	end
	-- return the distance to the fourth closest point
	table.sort(d)
	return d[4]
end
	-- This version of the get_distance function computes the distance to the four closest points. It also includes support for four different F type distance methods: Euclidean, Manhattan, Chebyshev, and Minkowski (with input parameter p). Finally, it includes support for the Quadratic distance method. The function uses the get_point helper function to compute the coordinates of the i-th closest point to the input coordinates (dx, dy, dz). The helper function is used to compute the distances to all four closest points.

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
	-- Optimize the get_distance function to only keep the i-th closest point for the selected distance_point. It appears that the variable is not currently being used. The non-relevant points can be discarded. Or, they can simply not be calculated by passing the index I of the point to calculate the distance to. For example, to calculate the distance to the third closest point, call get_distance(sx, sy, sz, dx, dy, dz, 3). Change `local distance = get_distance(sx,sy,sz,dx,dy,dz)` to `local distance = get_distance(sx,sy,sz,dx,dy,dz,distance_point)` and make use of `distance_point` from the prepare function.

	-- Distance formula
	-- Euclidean
	sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2)
	sqrt((x1-x3)^2 + (y1-y3)^2 + (z1-z3)^2)
	sqrt((x1-x4)^2 + (y1-y4)^2 + (z1-z4)^2)
	sqrt((x1-x5)^2 + (y1-y5)^2 + (z1-z5)^2)
	-- Manhattan
	abs(x1-x2) + abs(y1-y2) + abs(z1-z2)
	abs(x1-x3) + abs(y1-y3) + abs(z1-z3)
	abs(x1-x4) + abs(y1-y4) + abs(z1-z4)
	abs(x1-x5) + abs(y1-y5) + abs(z1-z5)
	-- Chebyshev
	max(abs(x1-x2), abs(y1-y2), abs(z1-z2))
	max(abs(x1-x3), abs(y1-y3), abs(z1-z3))
	max(abs(x1-x4), abs(y1-y4), abs(z1-z4))
	max(abs(x1-x5), abs(y1-y5), abs(z1-z5))
	-- Minkowski (p=3)
	(abs(x1-x2)^3 + abs(y1-y2)^3 + abs(z1-z2)^3)^(1/3)
	(abs(x1-x3)^3 + abs(y1-y3)^3 + abs(z1-z3)^3)^(1/3)
	(abs(x1-x4)^3 + abs(y1-y4)^3 + abs(z1-z4)^3)^(1/3)
	(abs(x1-x5)^3 + abs(y1-y5)^3 + abs(z1-z5)^3)^(1/3)
	-- Quadratic
	(x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2
	(x1-x3)^2 + (y1-y3)^2 + (z1-z3)^2
	(x1-x4)^2 + (y1-y4)^2 + (z1-z4)^2
	(x1-x5)^2 + (y1-y5)^2 + (z1-z5)^2

-- Update the get_distance() function to only keeps the i-th closest point for the selected distance point. Revised args to pass the distance_point variable to get_distance(), and then use it to select which of the four distances to keep.

function get_distance(sx, sy, sz, dx, dy, dz, formula, i)
	-- Compute distance to i-th closest point using selected formula
	local px, py, pz = get_point(i, dx, dy, dz)
	local distance = formula(sx, sy, sz, px, py, pz)
-- ...
end
	-- In your main script, call get_distance() like this:(where formula is the selected distance formula (e.g. Euclidean distance), and distance_point is the index of the i-th closest point you want to use.)

local distance = get_distance(sx, sy, sz, dx, dy, dz, formula, distance_point)


-- x, y, z, octaves, period. frequency, amplitude, lacunarity, gain, threshold, power
	-- define the number of octaves you want to generate.
		--<!> to be revised to generate periodic, tilable noise, accounting for the provided number of octaves, persistence, and lacunarity. The function takes in the same arguments as before, but two additional arguments period_x and period_y get added to specify the period of the noise in the x and y directions, respectively. If set to nil or not provided, the noise will be non-periodic.
			-- • to generate seamless noise, a few additional steps are required:
			-- • when generating the gradient vectors, ensure that the vectors at opposite edges of the grid are the same. this will ensure that the gradient calculations wrap around seamlessly at the edges of the noise grid.
			-- • when calculating the dot product between the gradient vector and the distance vector, use a modulo operation to wrap the result around at the edges of the noise grid.
			-- • add an additional step to blend the noise values at the edges of the grid with the noise values at the opposite edges, so that the noise pattern appears seamless. this can be achieved by calculating the noise values at the edges of the grid using the same formula as for the interior points, and then blending the edge values with the opposite edge values using a smooth interpolation function like cosine interpolation.
	-- for each octave, define a frequency and amplitude value. the frequency determines how quickly the noise values change, while the amplitude determines the relative strength of the noise.
	-- for each octave, generate the noise with a noise function, but multiply the frequency by a factor that increases with each octave and the amplitude by a factor that decreases with each octave.
	-- combine the noise values from each octave by summing them up and normalizing the result to the range [0,1].
	
-- closest_points for noise function
function cell_noise(x, y, z, frequency, distance_func, num_points)
		local closest_points = {}
		for i = 1, num_points do
				local point = hash_3d(x, y, z)
				table.insert(closest_points, point)
		end
		table.sort(closest_points, function(a, b) return distance_func(x, y, z, a[1], a[2], a[3]) < distance_func(x, y, z, b[1], b[2], b[3]) end)
		local dist1 = distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3])
		local dist2 = distance_func(x, y, z, closest_points[2][1], closest_points[2][2], closest_points[2][3])
		local dist3 = distance_func(x, y, z, closest_points[3][1], closest_points[3][2], closest_points[3][3])
		-- default return distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3])
		return dist3 / (dist1 + dist2 + dist3)
end
	-- Uses the hash_3d function to generate the random points. Relies on user input to adjust the frequency, distance_func, and num_points parameters to achieve the desired noise effect. Refereence function; calls to undocumented functions included.

	-- The num_points parameter controls the number of random points used to calculate the noise. Increasing this value will result in a more complex noise pattern.
	-- The frequency parameter controls the scale of the noise. Increasing this value will result in larger blocks and a more uniform pattern, while decreasing this value will result in smaller blocks and a more chaotic pattern.
	-- The exponent parameter controls the steepness of the falloff curve. Increasing this value will result in a sharper falloff and a more uniform pattern, while decreasing this value will result in a smoother falloff and a more chaotic pattern.
	-- The radius parameter controls the size of each chaff patch. Increasing this value will result in larger patches and a more uniform pattern, while decreasing this value will result in smaller patches and a more chaotic pattern.
	-- The sharpness parameter controls the steepness of the pyramid sides. Increasing this value will result in sharper pyramid sides and a more uniform pattern, while decreasing this value will result in smoother pyramid sides and a more chaotic pattern.
	
-- hash function for 3d coordinates -- demo
function hash_3d(x, y, z)
		local seed = 131
		local hash = seed
		hash = (hash * 311) % 65536
		hash = (hash * 271 + x) % 65536
		hash = (hash * 271 + y) % 65536
		hash = (hash * 271 + z) % 65536
		return { (hash % 1024) / 1024 - 0.5, (hash / 1024 % 1024) / 1024 - 0.5, (hash / 1024 / 1024) / 1024 - 0.5 }
end


-- an example function in Lua that takes a list of HDR values and normalizes them to the range of 0 to 1:
function normalize(hdr_list)
	local max_val = math.max(unpack(hdr_list))
	local min_val = math.min(unpack(hdr_list))
	local range = max_val - min_val
	local normalized_list = {}
	
	for i, val in ipairs(hdr_list) do
		local normalized_val = (val - min_val) / range
		table.insert(normalized_list, normalized_val)
	end
	
	return normalized_list
end
	-- Use this function to normalize the estimated HDR values for each distance formula for the first through fourth nearest point:

-- Estimated HDR values for each distance formula:
local euclidean_hdr = 1000
local manhattan_hdr = 1200
local chebyshev_hdr = 800
local minkowski_hdr = 1100
local quadratic_hdr = 900

-- Put the values in a list
local hdr_list = {euclidean_hdr, manhattan_hdr, chebyshev_hdr, minkowski_hdr, quadratic_hdr}

-- Normalize the list
local normalized_list = normalize(hdr_list)

-- Print the normalized values
for i, val in ipairs(normalized_list) do
	print(string.format("Distance formula %d: %.2f", i, val))
end
	-- Note that the values are now in the range of 0 to 1. You can use these normalized values to compare the relative strengths of the different distance formulas.

	-- Normalized values derived from distance mapping. The function for applying DUH (Display-Referenced Units for HDR) adjustments to the result of	the get_distance function.

	-- Euclidean,	0.891,	0.640,	0.466,	0.378
	-- Manhattan,	0.868,	0.623,	0.455,	0.370
	-- Chebyshev,	0.905,	0.640,	0.466,	0.378
	-- Minkowski (p=3),	0.870,	0.624,	0.455,	0.370
	-- Quadratic,	0.868,	0.623,	0.455,	0.370,	

	-- To apply the normalization to the result of the get_distance function, modify the function to include a normalization step. Example:

function get_distance(x1, y1, z1, x2, y2, z2, formula)
	-- Calculate distance using selected formula
	local distance = formula(x1, y1, z1, x2, y2, z2)
	
	-- Normalize distance to range 0-1
	local max_distance = formula(0, 0, 0, 1, 1, 1)
	local normalized_distance = distance / max_distance
	
	return normalized_distance
end
	-- Calculate the distance using the selected formula. Then calculate the maximum possible distance in the 0-1 range by calculating the distance between the points (0,0,0) and (1,1,1) using the selected formula. Finally, normalize the calculated distance by dividing it by the maximum possible distance. This ensures that the normalized distance is in the range of 0-1, which allows us to compare distances between different formulas.

function gamma_correction(image_data, gamma)
  -- Apply gamma correction to image data
  for i = 1, #image_data do
	image_data[i] = image_data[i]^gamma
  end
  
  return image_data
end
	-- A simple gamma correction function in lua. Use a gamma correction function to increase the brightness of the image. Gamma correction is a nonlinear operation that maps the input values to output values according to a power law function.

	-- This function takes in the image data (as a one-dimensional array) and a gamma value as inputs, and applies the gamma correction to each pixel value in the array. Adjust the gamma value to control the brightness of the output image.

	-- To use this function, pass in the result of the get_distance function (after normalization) as the image_data argument, and set the gamma value to a desired value (e.g., 1.0 for no correction, or a higher value for increased brightness). The output of this function can then be passed into the code that generates the final image.


-- define the Perlin noise function
function perlin2d_periodic(x, y, octaves, persistence, lacunarity, period_x, period_y)
	local total = 0
	local frequency = 1
	local amplitude = 1
	local max_value = 0

	-- loop over the octaves and add up the noise values
	for i = 1, octaves do
		local noise_value = perlin2d(x * frequency, y * frequency, period_x, period_y)
		total = total + noise_value * amplitude
		max_value = max_value + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * lacunarity
	end

	-- normalize the result to the range [-1, 1]
	total = total / max_value

	return total
end
	-- the functions in the full revised script:

	-- fade(t)
	-- lerp(a, b, t)
	-- grad(hash, x, y)
	-- perlin2d(x, y, persistence, lacunarity, octaves, period_x, period_y)
	-- perlin2d_octave(x, y, persistence, lacunarity, period_x, period_y, octaves)
	-- perlin2d_edge(x, y, period_x, period_y)

-- define the edge function to interpolate between adjacent grid points
function perlin2d_edge(x, y, period_x, period_y)
	local x0 = math.floor(x)
	local x1 = x0 + 1
	local y0 = math.floor(y)
	local y1 = y0 + 1

	local fx = x - x0
	local fy = y - y0

	-- wrap around the edges of the grid if necessary
	x0 = x0 % period_x
	x1 = x1 % period_x
	y0 = y0 % period_y
	y1 = y1 % period_y

	-- calculate the noise values at the corners of the grid cell
	local c00 = gradient2d(hash2d(x0, y0), fx, fy)
	local c10 = gradient2d(hash2d(x1, y0), fx - 1, fy)
	local c01 = gradient2d(hash2d(x0, y1), fx, fy - 1)
	local c11 = gradient2d(hash2d(x1, y1), fx - 1, fy - 1)

	-- interpolate the values along the x-axis
	local ix0 = lerp(c00, c10, fade(fx))
	local ix1 = lerp(c01, c11, fade(fx))

	-- interpolate the values along the y-axis
	local value = lerp(ix0, ix1, fade(fy))

	return value
end

-- define the gradient function to calculate the dot product between the gradient vector and the offset vector
function gradient2d(hash, x, y)
	local h = hash % 4

	if h == 0 then
		return x + y
	elseif h == 1 then
		return -x + y
	elseif h == 2 then
		return x - y
	elseif h == 3 then
		return -x - y
	end
end

-- define the hash function to generate a pseudorandom value between 0 and 255
function hash2d(x, y)
	local a = 1103515245
	local b = 8463
	local c = 2147483648

	local hash = math.floor((a * x + b * y) % c)

	return hash % 256
end

-- define the fade function to smooth out the interpolation
function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

-- alternate gradient function to calculate dot product of gradient vector and distance vector
local function gradient2d(hash, x, y)
	-- convert the low 4 bits of the hash code into 4 gradient directions
	local h = hash % 4
	local u = h == 0 or h == 2 and x or y
	local v = h == 0 or h == 2 and y or x
	-- compute dot product between the gradient vector and distance vector
	return ((h % 2 == 0) and -u or u) + ((h >= 2) and -v or v)
end
	-- This function takes in a hash code and two coordinates x and y and computes the dot product of the gradient vector and the distance vector between the grid point and the input coordinates. The gradient vector points in one of four directions depending on the low 2 bits of the hash code, and the distance vector is the vector between the input coordinates and the grid point. The dot product is computed by projecting the gradient vector onto the distance vector.

function noise_octaves(x, y, period_x, period_y, octaves, persistence, lacunarity)
	local total = 0
	local amplitude = 1
	local frequency = 1
	local max_value = 0

	-- iterate over the octaves and sum their contributions
	for i = 1, octaves do
		local noise_value = perlin2d(x * frequency / period_x, y * frequency / period_y)
		total = total + noise_value * amplitude
		max_value = max_value + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * lacunarity
	end

	-- normalize the result
	total = total / max_value

	-- interpolate the edge values to make the noise seamless
	local edge_x0 = lerp(perlin2d_edge(x, y, period_x, period_y), 
		perlin2d_edge(x + period_x, y, period_x, period_y), fade(x / period_x))
	local edge_x1 = lerp(perlin2d_edge(x + period_x, y, period_x, period_y), 
		perlin2d_edge(x + 2 * period_x, y, period_x, period_y), fade((x + period_x) / period_x))
	local edge_y0 = lerp(edge_x0, edge_x1, fade(y / period_y))
	local edge_y1 = lerp(perlin2d_edge(x, y + period_y, period_x, period_y), 
		perlin2d_edge(x + period_x, y + period_y, period_x, period_y), fade(x / period_x))
	local edge_y2 = lerp(perlin2d_edge(x + period_x, y + period_y, period_x, period_y), 
	perlin2d_edge(x + 2 * period_x, y + period_y, period_x, period_y), fade((x + period_x) / period_x))
	local edge_y3 = lerp(edge_y1, edge_y2, fade(y / period_y + 1))
	return lerp(edge_y0, edge_y3, fade(y / period_y))
end
	-- 2D perlin noise with periodicity and tilability
	-- x, y: the coordinates to sample at
	-- period_x, period_y: the period of the noise in each dimension
	-- octaves: the number of octaves to sum
	-- persistence: the persistence value for each octave
	-- lacunarity: the lacunarity value for each octave
	-- returns: the noise value at the given coordinates


-- seamless, periodic, tiling simplex noise - draft
local function simplex_noise(x, y, period_x, period_y)
	-- compute the four corners of the simplex in 2d
	local s = (x + y) * f2
	local i = floor(x + s)
	local j = floor(y + s)

	local t = (i + j) * g2
	local x0 = i - t
	local y0 = j - t
	local x0 = x - x0
	local y0 = y - y0

	local i1, j1
	if x0 > y0 then
		i1 = 1
		j1 = 0
	else
		i1 = 0
		j1 = 1
	end

	local x1 = x0 - i1 + g2
	local y1 = y0 - j1 + g2
	local x2 = x0 - 1 + 2 * g2
	local y2 = y0 - 1 + 2 * g2

	local ii = i % 256
	local jj = j % 256

	-- compute the gradients
	local gi0 = perm[ii + perm[jj]] % 12
	local gi1 = perm[ii + i1 + perm[jj + j1]] % 12
	local gi2 = perm[ii + 1 + perm[jj + 1]] % 12

	-- calculate the contribution from the corners
	local t0 = 0.5 - x0 * x0 - y0 * y0
	local n0 = t0 * t0 * t0 * t0 * dot(grad3[gi0], x0, y0)

	local t1 = 0.5 - x1 * x1 - y1 * y1
	local n1 = t1 * t1 * t1 * t1 * dot(grad3[gi1], x1, y1)

	local t2 = 0.5 - x2 * x2 - y2 * y2
	local n2 = t2 * t2 * t2 * t2 * dot(grad3[gi2], x2, y2)

	local sum = n0 + n1 + n2

	-- periodic tiling
	if period_x > 0 then
		sum = lerp(sum, simplex_noise(x - period_x, y, period_x, period_y), smoothstep(0, period_x, x))
	end

	if period_y > 0 then
		sum = lerp(sum, simplex_noise(x, y - period_y, period_x, period_y), smoothstep(0, period_y, y))
	end

	if period_x > 0 and period_y > 0 then
		sum = lerp(sum, simplex_noise(x - period_x, y - period_y, period_x, period_y), smoothstep(0, sqrt(period_x * period_x + period_y * period_y), sqrt(x * x + y * y)))
	end

	return sum
end

function noise_octaves(noise_function, x, y, octaves, frequency, amplitude, persistence, scale, seamless)
  local total = 0
  local maxAmplitude = 0

  for i = 1, octaves do
	local noise = noise_function(x * frequency, y * frequency) -- call the noise function with adjusted frequency
	total = total + noise * amplitude
	frequency = frequency * scale -- adjust the frequency for next octave
	maxAmplitude = maxAmplitude + amplitude
	amplitude = amplitude * persistence -- adjust the amplitude for next octave
  end

  if seamless then
	-- adjust the noise to make it seamless
	local nx = math.sin(x * math.pi * 2) * 0.5 + 0.5
	local ny = math.sin(y * math.pi * 2) * 0.5 + 0.5
	local corner = noise_function(0, 0)
	local x_edge = (noise_function(nx, 0) - corner) * nx
	local y_edge = (noise_function(0, ny) - corner) * ny
	local xy_edge = (noise_function(nx, ny) - corner) * nx * ny
	total = total + x_edge + y_edge - xy_edge
  end

  return total / maxAmplitude -- normalize the result
end
	-- a general purpose noise_octaves function that will accept and pass the variables required for an internal noise_function_call that is just a placeholder for specific noises inserted later, as well as x, y, octaves, frequency, amplitude, persistence, scale, etc. necessary to generate octaves with the option of accommodating seamless, tilable, periodic multi-octave noise in lua 5.1.
	
	
--[[	seamless, periodic, tiling noise
	 •• the reason I started investigating 4-dimensional noise was so I could loop x and y through hyperspace to generate 2-dimensional, seamless tiling noises. the add_vector_gradients function was needed to provide valid z and w coordinates to such a noise. assuming it works, the next step is to apply it to the creation of 2-dimensional, seamless tiling noise.

	for example: a 2d (x, y) point mapped to a point on a ellipse in 4d space as: (sin(x), cos(x), sin(y), cos(y)). this should produce a smooth, continuous loop of both x and y in 2d space.

	That sounds like an interesting project! You could use the add_vector_gradients function to generate the z and w coordinates for your 4D noise. Then you could use a noise function, such as Perlin noise or Simplex noise, to generate the noise values at each point in 4D space.

	•• to produce true, seamless noise in 2d, you need to loop the x and y through 4d space, as I proposed, and make sure to adjust the period of the noise to the frequency of the octaves. the start and end of the loops would be the left and right, or top and bottom, of the image tile. octave one would have a period of one, octave two would have a period of two, octave three would have a period of four, etc.

	You are correct! To achieve seamless tiling in 2D noise, you would need to loop the x and y coordinates through 4D space using a mapping function as you described. Additionally, adjusting the period of the noise to match the frequency of the octaves is necessary to ensure seamless tiling. This means that each octave's period should be double the previous octave's period.

	Using 4D noise to generate seamless 2D noise is a common technique and can produce very pleasing results. Good luck with your implementation!

	The coordinates x,y exist on an infinite plain though the frame of the image is bound between (0,0),(1,1). Point samples made within those bounds are typically also within the standard range of 0,1 but their r,g,b,a values can go on infinitely in hdr. 

	A noise algorithm can work with input values outside the range of [0, 1]. In fact, it can be used to generate noise for any arbitrary range of values. The key is to scale the input values to the desired range before passing them to the noise function.

	One approach to scaling the input values is to use a linear transformation. For example, if you have input values in the range [a, b], you can scale them to the range [0, 1] using the following formula:
		x' = (x - a) / (b - a)
		where x is the original input value, x' is the scaled value, and a and b are the minimum and maximum values in the original range.

	To scale the noise function output back to the original range, you can use the inverse transformation:
		x = a + (b - a) * x'
		where x' is the noise function output, x is the scaled value in the original range, and a and b are the minimum and maximum values in the original range.

	Alternatively, you can use a non-linear transformation, such as a power function, to scale the input values. The key is to choose a scaling function that maps the input range to a reasonable range for the noise function to work with.

	Using modulo operations can result in visible and undesirable tiling of the product noise. The reason is that modulo operations can cause repetition in the noise pattern, which can lead to a noticeable grid-like pattern in the output.

	To avoid this issue, there are several techniques that can be used. One approach is to use a larger permutation table that is designed to minimize the repetition of values. Another approach is to use a larger grid size and interpolate the noise values between grid points, which can help to smooth out any repeating patterns. Additionally, using a more advanced noise algorithm, such as Perlin noise or Simplex noise, can also help to reduce the visibility of tiling in the output.

	 The use of the grad function helps reduce the visibility of tiling in the output of the simplex noise. The grad function is used to calculate the gradient vectors for each of the corners of the simplex cell, and it ensures that the gradient vectors are evenly distributed, which helps to reduce the visibility of tiling in the output.

	Additionally, the use of the lerp function, which interpolates between values, also helps to reduce the visibility of tiling in the output by smoothing out the transitions between values.

	In noise converted to Lua from other languages, differences in table standards can result in nil or out-of-bounds contitions.To avoid these errors, one option is to use a technique called "wrapping" or "periodic boundary conditions" to make sure that the coordinates always fall within the expected range. One way to do this is to modify the hash function to wrap the input coordinates using the math.fmod function, which calculates the floating-point remainder of a division operation. For example, if the perm array has length n, you can wrap the input coordinates like this:

	local function hash(...)
	  local args = {...}
	  for i, x in ipairs(args) do
		args[i] = x % n
	  end
	  return perm[(args[1] + perm[(args[2] + perm[ args[3] ]) % n]) % n]
	end
		-- This modification ensures that the input coordinates are always within the range of the perm array, and should help to reduce out-of-bounds errors.
]]


