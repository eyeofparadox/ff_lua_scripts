-- map script snippets

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



