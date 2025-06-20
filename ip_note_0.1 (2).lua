-- <?> 3.17.2023»05:34
-- permutation table
perlin = {}
perlin.p = {}

function prepare()
	-- inputs and precalculation.
	seed = get_intslider_input(SEED)
	lacunarity = get_slider_input(LACUNARITY)
	octaves = get_intslider_input(OCTAVES)
	-- octaves = get_slider_input(OCTAVES)
	frequency = get_slider_input(FREQUENCY)
	amplitude = get_slider_input(AMPLITUDE)
	amplitude = math.max(amplitude, 0.0000001)
	persistence = get_slider_input(PERSISTENCE)
	octaves = math.floor(octaves) + 0.0001

-- initialize the `perlin.p` table with the given `seed`
	math.randomseed(seed)
	for i = 1, 256 do 
		perlin.p[i] = math.random(256)
		perlin.p[256 + i] = perlin.p[i]
	end;
end;

function get_sample(x, y)
	-- inputs and calculation.
	z = get_sample_grayscale(x,y,Z)
	w = get_sample_grayscale(x,y,W)
	t = get_sample_grayscale(x,y,T)

	-- image generation code
	-- local noise = perlin.noise4d(x, y, z, w)
	local noise = perlin.octaves4d(x, y, z, w, lacunarity, octaves, frequency, amplitude, persistence, t)
	noise = noise * 0.5 + 0.5

	return noise, noise, noise, 1 -- r, g, b, a -- 
end;
	--[[
	the input parameters for the `perlin.noise4d` function and their respective data types:
		`x:` float
		`y`: float
		`z`: float (optional)
		`w`: float (optional)
		`t`: float (optional)
		`lacunarity`: float
		`octaves`: int
		`frequency`: float
		`amplitude`: float
		`persistence`: float
			• `z`, `w` and `t` are optional parameters. 
			¤ if they are not provided, the function will generate 2d noise.

	Seed, Lacunarity, Octaves, Frequency, Amplitude, Persistence, Z, W, T
	]]--

function perlin.grad4d(hash, x, y, z, w)
	-- take a hash value and the input coordinates, and return a gradient vector
	local h = hash % 32 + 1
	local u = h < 8 and x or y
	local v = h < 4 and y or (h == 12 or h == 14) and x or z
	local r = (h % 2 == 0) and u or v
	local h2 = hash % 16
	local u2 = h2 < 8 and y or z
	local v2 = h2 < 4 and x or (h2 == 12 or h2 == 14) and y or w
	local r2 = (h2 % 2 == 0) and u2 or v2
	return ((hash % 2 == 0) and r or -r) + ((h2 % 2 == 0) and r2 or -r2)
end;

function perlin.dot4d(hash, x, y, z, w)
	-- determine the direction of the vector 
	local h = hash % 32 + 1
	local gx = perlin.grad4d(h, x, y, z, w)
	local gy = perlin.grad4d(h + 1, x - 1, y, z, w)
	local gz = perlin.grad4d(h + 2, x - 1, y - 1, z, w)
	local gw = perlin.grad4d(h + 3, x - 1, y - 1, z - 1, w)
	return gx * x + gy * y + gz * z + gw * w
end;

function perlin.fade(t)
	-- return smooth interpolation of 0 and 1 based on `t`
	return t * t * t * (t * (t * 6 - 15) + 10)
end;

function perlin.lerp(a, b, t)
	-- return a linear interpolation of `a` and `b` based on the weight `t`
	return a + t * (b - a)
end;

function perlin.noise4d(x, y, z, w)
	x, y, z, w = x *1000, y *1000, z *1000, w *1000
	-- calculate the relative positions of the input point within the unit hypercube
	local ix = (math.floor(x) & 255) + 1
	local iy = (math.floor(y) & 255) + 1
	local iz = (math.floor(z) & 255) + 1
	local iw = (math.floor(w) & 255) + 1
	-- calculate the fractional part of the coordinates of the point within the unit hypercube
	-- local fx = x - ix
	-- local fy = y - iy
	-- local fz = z - iz
	-- local fw = w - iw
	local fx = x - math.floor(x)
	local fy = y - math.floor(y)
	local fz = z - math.floor(z)
	local fw = w - math.floor(w)
	-- apply `fade` function
	local ux = perlin.fade(fx)
	local uy = perlin.fade(fy)
	local uz = perlin.fade(fz)
	local uw = perlin.fade(fw)
	-- retrieve values from the permutation table and
	-- add adjustments from the initial hypercube coordinate positions
	local a = perlin.p[(ix & 255) + 1] + iy
	local b = perlin.p[((ix + 1) & 255) + 1] + iy
	local aa = perlin.p[(a & 255) + 1] + iz
	local aaa = perlin.p[(aa & 255) + 1] + iw
	local ab = perlin.p[((a + 1) & 255) + 1] + iz
	local aba = perlin.p[(ab & 255) + 1] + iw
	local ba = perlin.p[(b & 255) + 1] + iz
	local baa = perlin.p[(ba & 255) + 1] + iw
	local bb = perlin.p[((b + 1) & 255) + 1] + iz
	local bba = perlin.p[(bb & 255) + 1] + iw
	-- calculate the weighted average between all unit hypercube coordinates
	return 
		perlin.lerp(
			perlin.lerp(
				perlin.lerp(
					perlin.dot4d(perlin.p[(aaa & 255) +1], fx, fy, fz, fw),
					perlin.dot4d(perlin.p[(baa & 255) +1], fx - 1, fy, fz, fw),
				ux),
				perlin.lerp(
					perlin.dot4d(perlin.p[(aba & 255) +1], fx, fy - 1, fz, fw),
					perlin.dot4d(perlin.p[(bba & 255) +1], fx - 1, fy - 1, fz, fw),
				ux),
			uy),
			perlin.lerp(
				perlin.lerp(
					perlin.dot4d(perlin.p[(aaa + 1 & 255) +1], fx, fy, fz - 1, fw),
					perlin.dot4d(perlin.p[(baa + 1 & 255) +1], fx - 1, fy, fz - 1, fw),
				ux),
				perlin.lerp(
					perlin.dot4d(perlin.p[(aba + 1 & 255) +1], fx, fy - 1, fz - 1, fw),
					perlin.dot4d(perlin.p[(bba + 1 & 255) +1], fx - 1, fy - 1, fz - 1, fw),
				ux),
			uy),
		uz)
end;

function perlin.octaves4d(x, y, z, w, lacunarity, octaves, frequency, amplitude, persistence, t)
	-- scale the input coordinates based on the `frequency`
	x = x * frequency
	y = y * frequency
	z = z * frequency
	w = w * frequency
	t = t or 0.0

	local fractal = 0
	local max_noise = (1 - persistence ^ octaves) / (1 - persistence)

	for i = 1, octaves do
		-- calculate the noise of each octave
		local noise = perlin.noise4d(x, y, z, w)
		
		-- scale the noise by the `amplitude` and add to the fractal
		fractal = fractal + noise * amplitude
		
		-- update the maximum noise and reduce the amplitude for the next octave
		max_noise = max_noise + amplitude
		amplitude = amplitude * persistence
		
		-- scale the input coordinates for the next octave
		x = x * lacunarity
		y = y * lacunarity
		z = z * lacunarity
		w = w * lacunarity
		
		if t ~= nil then
			t = t * lacunarity
		end;
	end;

	return fractal
end;

function test(...)
	-- take named arguments
	local args = {...}
	local n = #args
	-- use default values in the `options` table for `min`, `max`, and `kind` if they are not provided
	local options = {min=1, max=256, kind="indexed value"}
	-- if `min`, `max`, or `kind` are used as arguments, default values will be overwritten
	local values = {}
	local errors = {}
	-- store both the variable `name` and corresponding`value` in the `values` table
	for i = 1, n, 2 do
		local name = args[i]
		local value = args[i+1]
		-- check `name`
		if type(name) ~= "string" then
			error("Variable name must be a string")
		end
		values[name] = value
	end
	
	for name, value in pairs(values) do
		local result = nil
		-- test and store the `result`
		if value == nil then
			result = "nil"
			errors[name] = true
		elseif value < options.min or value > options.max then
			result = "oob"
			errors[name] = true
		else
			result = "true"
		end
		values[name] = {value=value, result=result}
	end
	-- count errors
	local num_errors = 0
	for name, error in pairs(errors) do
		if error then
			num_errors = num_errors + 1
		end
	end
	
	-- error reporting includes the names, values, and results of all variables tested. 
	if num_errors > 0 then
	local report = ""
	for name, data in pairs(values) do
	report = report .. name .. "=" .. data.value .. "," .. data.result .. "; "
	end
	report = report .. "kind=" .. options.kind
	error("<!> " .. num_errors .. ": " .. report)
	end
	
	return num_errors, options.min, options.max, options.kind
end
	--[[
	to call the `test` function using named arguments:
	• `sum_errors, min, max, kind = test(ix=128, iy=192, iz=64, iw=210, min=1, max=256, kind="permutation")`
	overwrite example: user calls `test("ix"=128, "iy"=192, "iz"=64, "iw"=210, min=10, kind="permutation")`
	• options.min` will be set to `10`, `options.max` will remain `256`, and `options.kind` will be set to `"permutation"`.
	]]--
	
	