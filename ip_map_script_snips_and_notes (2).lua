-- map script snips and notes.lua

function prepare()
	pi, cos, sin = math.pi, math.cos, math.sin
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
end;

function get_sample(x, y)
	local inv, r, g = y, 0, 0
	local x = x * aspect * pi
	local y = y * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y) 
	local nz = cos(y)
	if inv > 0.5 then
		r = 1 - (nx * 0.5 + 0.5)
		g = 1 - (ny * 0.5 + 0.5)
	else
		r = nx * 0.5 + 0.5
		g = ny * 0.5 + 0.5
	end
	local b = sin(y)
	return r, g, b, a
end;

-- gradient remapping
function prepare()
	-- inputs and precalculation
	aspect = OUTPUT_WIDTH / OUTPUT_HEIGHT
end;

function get_sample(x, y)
	-- convert radians to rotations
	local x_rot, y_rot = x / aspect / 0.159155, y / 0.159155
	local r = math.sin(x_rot ) * 0.5 + 0.5
	local g = math.cos(y_rot) * 0.5 + 0.5
	local b = math.cos(x_rot) * 0.5 + 0.5
	local a = y
	return r, g, b, a
end;


-- relief from derivative
function prepare()
	pi = math.pi
end;

function get_sample(x, y)
	local v = math.atan(get_sample_grayscale(x, y, HEIGHT))/pi + 0.5
	local a = 1
	return v, v, v, a
end;


-- seamless perlin
function prepare()
	seamless_width = get_slider_input(SEAMLESS_WIDTH)

	if get_checkbox_input(AUTOMATIC)	then
		set_perlin_noise_seamless(SEAMLESS)
		set_perlin_noise_seamless_region(SEAMLESS_REGION_WIDTH, SEAMLESS_REGION_HEIGHT)
	else
		set_perlin_noise_seamless(true)
		set_perlin_noise_seamless_region(seamless_width, seamless_width)
	end
end;

function get_sample(x, y)
	-- image generation code goes here.
	local v = get_perlin_noise(x, y, 1, 20)
	return v, v, v, a
end;


	-- 2x1 tiled seamless when aspect == 2:1
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
		set_perlin_noise_seamless(true)
		set_perlin_noise_seamless_region(aspect, aspect)
	end


-- get width, height by xirja 
function prepare()
end;

function get_sample(x, y)
	local r = OUTPUT_WIDTH
	local g = OUTPUT_HEIGHT
	return r, g, 1, 1
end;


-- get size, variation by xirja 
function prepare()
end;

function get_sample(x, y)
	local r = SIZE
	local g = VARIATION
	return r, g, 1, 1
end;


-- HDR Normals to Hard Shadows
-- Written by Nathan "jitspoe" Wulf
-- 2011-09-06

function prepare()
	pitch = math.rad(get_angle_input(PITCH))
	yaw = math.rad(get_angle_input(YAW))
	lightX2D = math.cos(yaw)
	lightY2D = math.sin(yaw)
	lightX = math.cos(pitch) * lightX2D
	lightY = math.cos(pitch) * lightY2D
	lightZ = math.sin(pitch)
	stepDist = get_slider_input(SHADOW_STEP_DIST)
	stepCount = 1000 * get_slider_input(SHADOW_STEP_COUNT)
	stepDistX = lightX * stepDist
	stepDistY = -lightY * stepDist
	stepDistZ = lightZ * stepDist
end;

function get_sample(x, y)
	local normX, normY, normZ = get_sample_map(x, y, HDR_NORMAL)
	local v = normX * lightX + normY * lightY + normZ * lightZ
	local h = get_sample_map(x, y, HEIGHT)
	local heightZ = h
	local heightX = x
	local heightY = y

	for i = 1, stepCount do
		heightX = heightX + stepDistX
		heightY = heightY + stepDistY
		heightZ = heightZ + stepDistZ
		h = get_sample_map(heightX, heightY, HEIGHT)
		if (h > heightZ) then
			v = 0
			break
		end
	end

	local r = v
	local g = v
	local b = v
	local a = 1
	return r, g, b, a
end;


-- Image Mandelbrot from https://filterforge.com/filters/15564.html
-- reference from http://linas.org/art-gallery/escape/escape.html
-- and http://warp.povusers.org/Mandelbrot/
-- Adapted to Filter Forge Lua Map Script
-- by Nathan "jitspoe" Wulf
-- with extensive modifications and bug fixes
-- by Rick Duim July 2015

function prepare()

	zoom = get_slider_input(ZOOM)

	if zoom < -0.05 then
		zoom = -0.05
	end

	zoom = 1 + (zoom * 20000)

	superzoom = get_checkbox_input(SUPER_ZOOM)

	if superzoom then
		zoom = zoom * 100
	end

	offsetX = (get_slider_input(OFFSET_X) - .66) * 4
	offsetY = (get_slider_input(OFFSET_Y) - .5) * 4

	finetuneX = (get_slider_input(FINE_TUNE_X) - .5) * .01
	finetuneY = (get_slider_input(FINE_TUNE_Y) - .5) * .01

	finerX = (get_slider_input(FINER_TUNE_X) - .5) * .001
	finerY = (get_slider_input(FINER_TUNE_Y) - .5) * .001

	finestX = (get_slider_input(FINEST_TUNE_X) - .5) * .0001
	finestY = (get_slider_input(FINEST_TUNE_Y) - .5) * .0001

	microX = (get_slider_input(MICRO_TUNE_X) - .5) * .00005
	microY = (get_slider_input(MICRO_TUNE_Y) - .5) * .00005

	offsetX = offsetX + finetuneX + finerX + finestX + microX
	offsetY = offsetY + finetuneY + finerY + finestY + microY

	minX = -1.5 / zoom + offsetX
	maxX = 1.5 / zoom + offsetX
	minY = -1.5 / zoom + offsetY
	maxY = 1.5 / zoom + offsetY
	factorX = maxX - minX
	factorY = maxY - minY

	maxIterations = get_intslider_input(NUMBER_OF_ITERATIONS)
	escapeRadius = get_intslider_input(ESCAPE_RADIUS)
	colorVariation = get_checkbox_input(COLOR_VARIATION)
end;

function get_sample(x, y)

	if init == 0 then
		init = 1
	end

	local cY = maxY - (y * factorY);
	local cX = minX + (x * factorX);
	local zX = cX
	local zY = cY;
	local found = 0
	local zX2
	local zY2
	local iterationCount = 0

	for i = 0, maxIterations do
		zX2 = zX * zX
		zY2 = zY * zY;

		if zX2 + zY2 > escapeRadius then
			found = 1
			break
		end

		zY = (2 * zX * zY) + cY;
		zX = zX2 - zY2 + cX;
		iterationCount = iterationCount + 1
	end

	--	error(logColoring)
	local val = 1

	-- For smooth color transitions
	if colorVariation == 1 then
	val = iterationCount + math.log(math.log(zX2 + zY2)) / math.log(2)
	else
	val = iterationCount - math.log(math.log(zX2 + zY2)) / math.log(2)
	end

	val = val / maxIterations

	if found == 0 then
		val = 0
		else
				if val > 1 then val = 1 end
		if val < 0 then val = 0 end

		-- get rid of the invalid value error
		if (val >= 0 and val <= 1) then
		else
			val = 0
		end  
	end

	local a = 1
	local r, g, b = get_sample_map(val, val, COLOR)

	if found == 0 then
		r, g, b = get_sample_map(x, y, COLOR_INNER)
		--	else
		--		r = r * gr * brightness
		--		g = g * gg * brightness
		--		b = b * gb * brightness
	end

	return r, g, b, a
end;


-- Mandelbrot from https://www.filterforge.com/filters/9397.html
-- reference from http://linas.org/art-gallery/escape/escape.html
-- and http://warp.povusers.org/Mandelbrot/
-- Adapted to Filter Forge Lua Map Script
-- by Nathan "jitspoe" Wulf

function prepare()
	zoom = 1 + get_slider_input(ZOOM) * 200
	offsetX = (get_slider_input(OFFSET_X) - .5) * 4
	offsetY = (get_slider_input(OFFSET_Y) - .5) * 4
	minX = -2.2 / zoom + offsetX
	maxX = .8 / zoom + offsetX
	minY = -1.5 / zoom + offsetY
	maxY = 1.5 / zoom + offsetY
	factorX = maxX - minX
	factorY = maxY - minY
	brightness = get_slider_input(BRIGHTNESS) * 10
	maxIterations = 200
	escapeRadius = 20
end;

function get_sample(x, y)
	local cY = maxY - (y * factorY);
	local cX = minX + (x * factorX);
	local zX = cX
	local zY = cY;
	local found = 0
	local zX2
	local zY2
	local iterationCount = 0

	for i = 0, maxIterations do
		zX2 = zX * zX
		zY2 = zY * zY;

		if zX2 + zY2 > escapeRadius then
			found = 1
		break
		end

		zY = (2 * zX * zY) + cY;
		zX = zX2 - zY2 + cX;
		iterationCount = iterationCount + 1
	end

	-- It was suggested to do a couple more iterations for precision
	zY = (2 * zX * zY) + cY;
	zX = zX2 - zY2 + cX;
	zY = (2 * zX * zY) + cY;
	zX = zX2 - zY2 + cX;
	iterationCount = iterationCount + 2

	-- For smooth color transitions
	local val = iterationCount - math.log(math.log(zX2 + zY2)) / math.log(2)
	val = val / maxIterations

	if found == 0 then
		val = 0
	else
			if val > 1 then val = 1 end
			if val < 0 then val = 0 end

		-- get rid of the invalid value error
		if (val >= 0 and val <= 1) then
		else
			val = 0
		end  
	end

	local gr = get_sample_curve(x, y, val, GAMMA_RED)
	local gg = get_sample_curve(x, y, val, GAMMA_GREEN)
	local gb = get_sample_curve(x, y, val, GAMMA_BLUE)

	local a = 1
	local r, g, b = get_sample_map(x, y, COLOR)

	if found == 0 then
		r, g, b = get_sample_map(x, y, COLOR_INNER)
	else
		r = r * gr * brightness
		g = g * gg * brightness
		b = b * gb * brightness
	end

	return r, g, b, a
end;


-- Julia Fractals from https://www.filterforge.com/filters/9407.html
-- reference from http://linas.org/art-gallery/escape/escape.html
-- and http://warp.povusers.org/Mandelbrot/
-- Adapted to Filter Forge Lua Map Script
-- by Nathan "jitspoe" Wulf

function prepare()
	zoom = get_slider_input(ZOOM) * 200
	offsetX = (get_slider_input(OFFSET_X) - .5) * 4
	offsetY = (get_slider_input(OFFSET_Y) - .5) * 4
	minX = -1 / zoom + offsetX
	maxX = 1 / zoom + offsetX
	minY = -1 / zoom + offsetY
	maxY = 1 / zoom + offsetY
	factorX = maxX - minX
	factorY = maxY - minY
	brightness = get_slider_input(BRIGHTNESS) * 10
	maxIterations = 200
	escapeRadius = 400
	cX = get_slider_input(CX)
	cY = get_slider_input(CY)
end;

function get_sample(x, y)
	local zX = maxY - (y * factorY);
	local zY = minX + (x * factorX);
	local found = 0
	local zX2
	local zY2
	local iterationCount = 0

	for i = 0, maxIterations do
		zX2 = zX * zX
		zY2 = zY * zY

		if zX2 + zY2 > escapeRadius then
			found = 1
		break
		end

		zY = (2 * zX * zY) + cY;
		zX = zX2 - zY2 + cX;
		iterationCount = iterationCount + 1
	end

	-- It was suggested to do a couple more iterations for precision
	zX2 = zX * zX
	zY2 = zY * zY
	zY = (2 * zX * zY) + cY;
	zX = zX2 - zY2 + cX;
	zX2 = zX * zX
	zY2 = zY * zY
	zY = (2 * zX * zY) + cY;
	zX = zX2 - zY2 + cX;
	iterationCount = iterationCount + 2

	-- For smooth color transitions
	local val = iterationCount - math.log(math.log(zX2 + zY2)) / math.log(2)
	val = val / maxIterations

	if found == 0 then
		val = 0
	else
		if val > 1 then val = 1 end
		if val < 0 then val = 0 end

		-- get rid of the invalid value error
		if (val >= 0 and val <= 1) then
		else
			val = 0
		end  
	end

	local gr = get_sample_curve(x, y, val, GAMMA_RED)
	local gg = get_sample_curve(x, y, val, GAMMA_GREEN)
	local gb = get_sample_curve(x, y, val, GAMMA_BLUE)

	local a = 1
	local r, g, b = get_sample_map(x, y, COLOR)

	if found == 0 then
		r, g, b = get_sample_map(x, y, COLOR_INNER)
	else
		r = r * gr * brightness
		g = g * gg * brightness
		b = b * gb * brightness
	end

	return r, g, b, a
end;

--[[ refraction/ior notes ff forum	https://www.filterforge.com/forum/read.php?FID=10&TID=322&MID=153070&sphrase_id=5800402#message153070

Anyone have an explanation of how the refraction component works?
uberzev
Posted: June 6, 2006 3:37 am

The Refraction component simulates the following:

Imagine that you have a "bead" of transparent material (i.e. glass) with flat bottom and a non-flat (specified by Height input) top. "Stick" the Source input image to the flat bottom, specify the 1/IOR (index of refraction aka refraction coefficient indirectly mapped with scaling by 4.0, see your physics book for the explanation, or visit http://scienceworld.wolfram.com/physi...tion.html) with the Refraction input and look at the "bead" from the top -- that's the result.
Unfortunately, there's no ability to specify the IOR relations larger than one, so it's always air-to-surface transfer, not vice versa which may be helpful in simulating layered materials with help of surface filters.
The normal map used for refraction calculations is approximated using 3-tap sampling (anisotropic, right/bottom-oriented, but it does not matter since our supersampling is isotropic and symmetric with centered sampling) using step which is equal to 0.001 pixels, respecting Size slider value. This dependence on Size creates unwanted effects when Image or Selection are used as inputs, but generally is very well suited for all procedural and bitmap-based components. The same algorithm is used for Surface normal map generation which is used then in lighting calculations.
Refraction values used in FF have no direct relation to conventional refraction indices. I've asked the developers to look into the component code, and it seems the [0...100] slider is mapped to the IOR range of [infinity... 1].
((Sphinx: That would make more sense as there is no distortion if FF refraction is 0 (which again is what I would expect with a real world refraction index of 1).))
The exact formula that is fed into the renderer is as follows:
	asin((1 - slider_value)*normal_projection_length).
onyXMaster
Posted: June 6, 2006 4:37 am
--]]


-- function geometric_term(a1, r, n) -- f(geometric_progression:a1, r, n)
	-- calculates the terms of a geometric progression from 5 to 100 in five steps:
		--[[	
		• What it's solving for: 
			The terms of a geometric progression ex: from 5 to 100 in five steps. 
		• Helpful information: 
			The formula for the n-th term of a geometric progression is:
				t_n = a * r^(n - 1)
				• A is the first term 
				• r is the common ratio
				• n is the number of terms 
		• How to solve 
			Use the formula for the n-th term of a geometric progression to find the common ratio, then use that ratio to find the terms of the progression. 
		1 • Identify the first term (a) and the last term (t_n). 
			a = 5
			t_n = 100
		2 • Identify the number of terms (n). 
			n = 6
		3 •  Substitute the known values into the formula for the n-th term of a geometric progression. 
			t_n = a * r^(n - 1)
			100 = 5 * r^(6 - 1)
			100 = 5 * r^5
		4 • Solve for the common ratio (r). 
			100 = 5 * r^5
			20 = r^5
			r = √20
			r ≈ 1.821
		5 • Calculate the terms of the geometric progression. 
			t_1 = 5
			t_2 = 5 * 1.821 ≈ 9.105
			t_3 = 9.105 * 1.821 ≈ 16.59
			t_4 = 16.59 * 1.821 ≈ 30.22
			t_5 = 30.22 * 1.821 ≈ 55.05
			t_6 = 55.05 * 1.821 ≈ 100
		• Solution 
			The terms of the geometric progression from 5 to 100 in five steps are 5, 9.105, 16.59, 30.22, 55.05, and 100.
		--]]
function prepare()
		-- define the initial term and the common ratio (get input values)
		local a1 = 5 
		local r = math.pow(20, 1/5)  -- common ratio calculated as the 5th root of 20

		local function geometric_term(a1, r, n)
		-- function to calculate the n-th term of the geometric progression
			return a1 * math.pow(r, n-1)
		end

		-- calculate and print the terms
		for n = 1, 6 do
			local term = geometric_term(a1, r, n)
			print(string.format("term %d: %.2f", n, term)
		end
	--[[
	• this script defines the initial term ( a1 ) and calculates the common ratio ( r ). it then uses a function to compute each term of the geometric progression and prints the terms from the first to the sixth (including the starting point).
	• when you run this script, it will output the terms of the sequence, showing the progression from 5 to 100 in five steps. 
	--]]



-- perlin noise - get_perlin_octaves(x, y, z, channel) v.1 ~ 20240923
function prepare()
-- constants
	AMPLITUDE_CORRECTION_FACTOR = 1.731628995
	ROUGHNESS_THRESHOLD = 0.00001
	REMAINDER_THRESHOLD = 0.00001
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
		set_perlin_noise_seamless(true)
		set_perlin_noise_seamless_region(aspect, 1)
	else aspect = 1
	end

-- input values
	details = get_slider_input(DETAILS) * 10 + 1
	NOISE_SIZE = get_slider_input(SCALE)
	if (get_checkbox_input(MODE)) then
		mode = true
	else
		mode = false
	end
	set_perlin_noise_seed(get_intslider_input(NOISE_VARIATION))
end;

function get_sample(x, y)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local r1, g1, b1, a1 = get_sample_map(x, y, BACKGROUND)
	local x = x * aspect
	roughness = ROUGHNESS_THRESHOLD + get_sample_grayscale(x, y, ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))

	local alpha = get_perlin_octaves(x,y,0)
	local r = get_perlin_octaves(x,y,1)
	local g = get_perlin_octaves(x,y,2) 
	local b = get_perlin_octaves(x,y,3)
	local a = 1
	
	alpha  = truncate(factor * (alpha - 0.5) + 0.5)
	r  = truncate(factor * (r - 0.5) + 0.5)
	g  = truncate(factor * (g - 0.5) + 0.5)
	b  = truncate(factor * (b - 0.5) + 0.5)
	
	alpha = get_sample_curve(x, y, alpha, PROFILE)
	r = get_sample_curve(x, y, r, PROFILE)
	g = get_sample_curve(x, y, g, PROFILE)
	b = get_sample_curve(x, y, b, PROFILE)
	
	if mode then
		return r, g, b, a
	else
		r, g, b, a = blend_normal(r2, g2, b2, a2, r1, g1, b1, a1 , alpha, true)
		return r, g, b, a
	end
end;

function get_perlin_octaves(x,y,channel)
	cx = x
	cy = y
	local alpha = 0
	local octave_index 

	if channel == 0 then
		z_off = 0
	elseif channel == 1 then
		z_off = 1
	elseif channel == 2 then
		z_off = 2
	elseif channel == 3 then
		z_off = 3
	end;

-- perlin octaves
	OCTAVES_COUNT = math.floor(details)
	local remainder = details - OCTAVES_COUNT
	if (remainder > REMAINDER_THRESHOLD) then
		OCTAVES_COUNT = OCTAVES_COUNT + 1
	end
	
	OCTAVES = {}
	local cell_size = (0.01 + NOISE_SIZE * 0.99) * 1000
	local scale = roughness
	local octave_index
	for octave_index = 1, OCTAVES_COUNT do
		if (scale < ROUGHNESS_THRESHOLD) then
			OCTAVES_COUNT = octave_index - 1
			break
		end
		OCTAVES[octave_index] = {cell_size, scale}
		cell_size = cell_size * 0.5
		scale = scale * roughness
	end
	
	if (remainder >= 0.001) then
		OCTAVES[OCTAVES_COUNT][2] = OCTAVES[OCTAVES_COUNT][2] * remainder
	end

	NORM_FACTOR = 0
	for octave_index = 1, OCTAVES_COUNT do
		NORM_FACTOR = NORM_FACTOR + OCTAVES[octave_index][2] ^ 2
	end
	NORM_FACTOR = 1 / math.sqrt(NORM_FACTOR)

	for octave_index = 1, OCTAVES_COUNT do
		local size = OCTAVES[octave_index][1]
		local opacity = OCTAVES[octave_index][2]
		local oi = octave_index + z_off -- + channel offset
		alpha = alpha + opacity * (2 * get_perlin_noise(cx, cy, oi, size) - 1)
	end
	alpha = (alpha * NORM_FACTOR + AMPLITUDE_CORRECTION_FACTOR) * 
		(0.5 / AMPLITUDE_CORRECTION_FACTOR)
	return alpha
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;


function prepare()
	pi, cos, sin = math.pi, math.cos, math.sin
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	if (get_checkbox_input(MODE)) then
		mode = true
	else
		mode = false
	end
	if (get_checkbox_input(USE_RGB)) then
		use_rgb = true
	else
		use_rgb = false
	end
end;

function get_sample(x, y)
	local r2, g2, b2, a2 = get_sample_map(x, y, SOURCE)
	local inv, r, g = y, 0, 0
	local x = x * aspect * pi
	local y = y * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y) 
	local nz = cos(y)
	if inv > 0.5 then
		r = 1 - (nx * 0.5 + 0.5)
		g = 1 - (ny * 0.5 + 0.5)
	else
		r = nx * 0.5 + 0.5
		g = ny * 0.5 + 0.5
	end
	local b = sin(y)
	if use_rgb then 
		if mode then 
			return r, g, b, a
		else
			r1, g1, b1, a1 = get_sample_map(r, g, SOURCE)
			r0, g0, b0, a0 = blend_normal(r1, r1, r1, a1, g1, g1, g1, a1, y, true)
			r, g, b, a = blend_normal(r0, g0, b0, a0, b2, b2, b2, a2, b, true)
			return r, g, b, a
		end
	else
		if mode then 
			return r, g, b, a
		else
			r1, g1, b1, a1 = get_sample_map(r, g, SOURCE)
			r2, g2, b2, a2 = blend_difference(r2, g2, b2, a2, 1, 1, 1, 1, 1, true)
			r, g, b, a = blend_normal(r1, g1, b1, a1, r2, g2, b2, a2, b, true)
			return r, g, b, a
		end
	end
end;


--[[ 
prepare()
--	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
--		aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
--	end
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seamless(true)
	set_perlin_noise_seamless_region(aspect, 1)
get_sample(x, y)
	local x = x * aspect
	roughness = ROUGHNESS_THRESHOLD + get_sample_grayscale(x, y, ROUGHNESS) * (1.0 - ROUGHNESS_THRESHOLD)
	-- 
	v = get_perlin_octaves((nx + osx) + dx, (ny+ osy) + dy, (nz+ osz) + dz, 1)
-- ]]


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

	for octave_index = 1, octaves_n do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		v = v + opacity * (2 * get_perlin_noise(x, y, octave_index, size) - 1)
	end
	v = (v * norm + amp_c) * (0.5 / amp_c)
	return v
end;



