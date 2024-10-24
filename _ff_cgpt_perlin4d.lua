-- global variables
local map = {}

function prepare()
	-- inputs and precalculation.
	seed = get_intslider_input(SEED)
	lacunarity = get_slider_input(LACUNARITY)
	octaves = get_intslider_input(OCTAVES)
	frequency = get_slider_input(FREQUENCY)
	amplitude = get_slider_input(AMPLITUDE)
	amplitude = math.max(amplitude, 0.0001)
	persistence = get_slider_input(PERSISTENCE)

-- initialize the permutation table with the given `seed`
	math.randomseed(seed)
	p = {}
	for i = 1, 256 do
		p[i] = i - 1
	end;
	for i = 256, 2, -1 do
		local j = math.random(i)
		p[i], p[j] = p[j], p[i]
	end;

	-- extend the `p` table to avoid overflow
	for i = 257, 512 do
		p[i] = p[i - 256]
	end;

	-- initialize permutation table for 2-4 dimensions
	p2 = {}; p3 = {}; p4 = {}
	table.move(p, 1, 512, 1, p2)
	table.move(p, 1, 512, 1, p3)
	table.move(p, 1, 512, 1, p4)

	-- shuffle the permutation table for each dimension
	for i = 256, 2, -1 do
		local j = math.random(i)
		p2[i], p2[j] = p2[j], p2[i]
		p3[i], p3[j] = p3[j], p3[i]
		p4[i], p4[j] = p4[j], p4[i]
	end;
		-- in this update, the initial value of each permutation index changed from 0 to 1, as has the range of the math.random function to be inclusive of the upper bound. the index range for the for loops was updated accordingly.

	-- `try_catch` in `prepare`: initialize global `map` array
	-- local xa = 600 -- OUTPUT_WIDTH	--	syntax check swap
	-- local ya = 600 -- OUTPUT_HEIGHT	--	syntax check swap
	local xa = OUTPUT_WIDTH
	local ya = OUTPUT_HEIGHT
	-- xa = math.floor(xa) already int
	-- ya = math.floor(ya) already int
	for ym = 1, ya do
		map[ym] = {}
		for xm = 1, xa do
			map[ym][xm] = {0, 0, 0, 0}
		end
	end
end;

function get_sample(x, y)
	-- inputs and calculation.
	z = get_sample_grayscale(x,y,Z)
	w = get_sample_grayscale(x,y,W)
	t = get_sample_grayscale(x,y,T)

	-- test_vars(p[x], p[y], p[z], p[w])

	-- image generation code
	local noise = noise4d(x, y, z, w, p4)
	-- local r = perlin4d(x, y, z, w, lacunarity, octaves, frequency, amplitude, persistence, t, p4)
	-- local g = 0 -- perlin4d(x+1, y-1,z+1, w-1, lacunarity, octaves, frequency, amplitude, persistence, t, p4)
	-- local b = 0 -- perlin4d(x-2, y+2, z-2, w+2, lacunarity, octaves, frequency, amplitude, persistence, t, p4)
	-- local a = 1

	-- `try_catch` in `get_sample`: if `noise4d == 77777` then retrieve channels from `map`
	if noise == 77777 then 
		r, g, b, a = map[y][x][1], map[y][x][2], map[y][x][3], map[y][x][4]
	else
		r, g, b, a = x,y,z,w
	end

	return r, g, b, a
end;

function perlin4d(x, y, z, w, lacunarity, octaves, frequency, amplitude, persistence, t, p4)
	-- test_args(p4, x, y, z, w, lacunarity, octaves, frequency, amplitude, persistence, t)
	-- scale the input coordinates based on the `frequency`
	x = x * frequency
	y = y * frequency
	z = z or x+1 * frequency
	w = w or y+1 * frequency
	t = t or 0.0
	
	local total = 0
	local max_value = (1 - persistence ^ octaves) / (1 - persistence) -- was max_value = 0
	local amplitude = amplitude -- might have been intended for scale.
	
	for i = 1, octaves do
		-- calculate the value of each octave
		local value = noise4d(x, y, z, w, p4)
		
		-- scale the value by the `amplitude` and add to the total
		total = total + value * amplitude
		
		-- update the maximum value and reduce the amplitude for the next octave
		max_value = max_value + amplitude
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
	
	return total -- was total / max_value -- normalize the result by dividing by the maximum value
end;
	--[[
	note that the function now checks if `z` and `t` are provided and uses `noise3d` instead of `noise2d` if `z` is provided. also, `lacunarity` is used to scale the input coordinates for each octave and `t` is also scaled by `lacunarity` if it is provided.
	
	the input parameters for the perlin4d function and their respective data types:
		x: float
		y: float
		z: float (optional)
		t: float (optional)
		lacunarity: float
		octaves: int
		frequency: float
		amplitude: float
		persistence: float
			• `z` and `t` are optional parameters and if they are not provided, the function will generate 2d noise.

	Lacunarity, Octaves, Frequency, Amplitude, Persistence, Z, T, Seed
	]]--

	--[[
function noise2d(x, y, p)
	local xi = math.floor(x) % 256
	local yi = math.floor(y) % 256

	local xf = x - math.floor(x)
	local yf = y - math.floor(y)

	local u = fade(xf)
	local v = fade(yf)

	local aa, ab, ba, bb = p[p[xi]+yi], p[p[xi+1]+yi], p[p[xi]+yi+1], p[p[xi+1]+yi+1]

	local x1 = lerp(grad(aa, xf, yf), grad(ba, xf-1, yf), u)
	local x2 = lerp(grad(ab, xf, yf-1), grad(bb, xf-1, yf-1), u)

	return lerp(x1, x2, v)
end;
	]]--

	--[[
function noise3d(x, y, z, p)
	local X = math.floor(x) % 256
	local Y = math.floor(y) % 256
	local Z = math.floor(z) % 256

	x = x - math.floor(x)
	y = y - math.floor(y)
	z = z - math.floor(z)

	local u = fade(x)
	local v = fade(y)
	local w = fade(z)

	local A = p[X] + Y
	local AA = p[A] + Z
	local AB = p[A + 1] + Z
	local B = p[X + 1] + Y
	local BA = p[B] + Z
	local BB = p[B + 1] + Z

	return lerp(w, lerp(v, lerp(u, grad(p[AA], x, y, z),
									grad(p[BA], x - 1, y, z)),
							lerp(u, grad(p[AB], x, y - 1, z),
									grad(p[BB], x - 1, y - 1, z))),
					lerp(v, lerp(u, grad(p[AA + 1], x, y, z - 1),
									grad(p[BA + 1], x - 1, y, z - 1)),
							lerp(u, grad(p[AB + 1], x, y - 1, z - 1),
									grad(p[BB + 1], x - 1, y - 1, z - 1))))
end;
	--[[
	this version of the function includes the changes to the fade and grad functions you requested, as well as the changes to the noise2d function. the noise3d function now uses the fade function to calculate the interpolation weights for the x, y, and z coordinates, and uses the grad function to calculate the gradients at each of the eight corners of the cube surrounding the input point. the gradients are then linearly interpolated to produce the final noise value.
	]]--
	
--  error--debugging: error occurs. in the `dot4d` function, an "attempt to index a number value (local 'g') error `return g[1]*x + g[2]*y + g[3]*z + g[4]*w`

function noise4d(x, y, z, w, p4)
	test_args(p4, x, y, z, w)

	-- adjusted to integer coordinates from float inputs `(x,y,z,w)` = [0,1].
	-- coordinate operations:
	local ix = math.floor(x * 255) + 1
	local iy = math.floor(y * 255) + 1
	local iz = math.floor(z * 255) + 1
	local iw = math.floor(w * 255) + 1
	test_args(p4, ix, iy, iz, iw)
	
	-- `try_catch` in `noise4d`: include 
	-- catch_1 = try_catch(x, y, p4, ix, iy, iz, iw)
	-- if catch_1 then return -77777 end

	-- test_args(p4, ix, iy, iz, iw) -- getting `o,o,o.o,o.o` when each should be int [1,256].
	local fx = (x * 255) - ix
	local fy = (y * 255) - iy
	local fz = (z * 255) - iz
	local fw = (w * 255) - iw
	test_args(p4, fx, fy, fz, fw)
	
	-- `try_catch` in `noise4d`: include 
	-- catch_2 = try_catch(x, y, p4, fx, fy, fz, fw)
	-- if catch_2 then return -77777 end

	local u = fade(fx)
	local v = fade(fy)
	local uu = fade(fz)	--conflict `w`
	local vv = fade(fw)	--conflict `x` and does not appear to get used
	test_args(p4, u, v, uu, vv)
	
	-- indexing operations
	local i1 = (p4[ix] + iy % 255) + 1
	local i2 = (p4[ix + 1] + iy % 255) + 1
	local i3 = (p4[i1] + iz % 255) + 1
	local i4 = (p4[i2] + iz % 255) + 1
	local i5 = (p4[i3] + iw % 255) + 1
	local i6 = (p4[i4] + iw % 255) + 1
	test_args(p4, i1, i2, i3, i4, i5, i6)

	-- indexing operations
	local in1 = grad4d(p4[i5], fx, fy, fz, fw)
	local in2 = grad4d(p4[i6], fx - 1, fy, fz, fw)
	local in3 = grad4d(p4[(i5 + 1 % 255) + 1], fx, fy - 1, fz, fw)
	local in4 = grad4d(p4[(i6 + 1 % 255) + 1], fx - 1, fy - 1, fz, fw)
	local in5 = grad4d(p4[(i5 + 1 + 256 % 255) + 1], fx, fy, fz - 1, fw)
	local in6 = grad4d(p4[(i6 + 1 + 256 % 255) + 1], fx - 1, fy, fz - 1, fw)
	local in7 = grad4d(p4[(i5 + 1 + 256 * 2 % 255) + 1], fx, fy - 1, fz - 1, fw)
	local in8 = grad4d(p4[(i6 + 1 + 256 * 2 % 255) + 1], fx - 1, fy - 1, fz - 1, fw)
	test_args(p4, in1, in2, in3, in4, in5, in6, in7, in8)

	-- coordinate and indexing operations
	local x1 = lerp(u, dot4d(in1, fx, fy, fz, fw), dot4d(in5, fx - 1, fy, fz, fw))
	local x2 = lerp(u, dot4d(in2, fx, fy, fz - 1, fw), dot4d(in6, fx - 1, fy, fz - 1, fw))
	local y1 = lerp(v, x1, x2) -- coordinate operation

	local x3 = lerp(u, dot4d(in3, fx, fy - 1, fz, fw), dot4d(in7, fx - 1, fy - 1, fz, fw))
	local x4 = lerp(u, dot4d(in4, fx, fy - 1, fz - 1, fw), dot4d(in8, fx - 1, fy - 1, fz - 1, fw))
	local y2 = lerp(v, x3, x4) -- coordinate operation

	local z1 = lerp(uu, y1, y2) -- coordinate operation--conflict `w`
	return z1
end;
	--[[
	the `noise4d` function generates perlin noise values for any given set of input coordinates in 4 dimensions, using modular arithmetic to index into the `p4` table, to create seamless noise patterns. breakdown of the different parts of the code:
	•• coordinate adjustments: the input coordinates `x`, `y`, `z`, and `w` are first scaled to integer coordinates in the range [1, 256].
	•• input value error checking: two instances of a `try_catch` function are used to check for potential input value errors before proceeding with the noise generation. if an error is detected, the function returns a default value of -`77777`.
	•• coordinate adjustments (continued): the fractional parts of the input coordinates are computed for later use.
	•• coordinate fade function: the `fade` function is called to compute the fade values for the fractional coordinates. this function is used to smooth the noise between integer coordinates.
	•• indexing operations: the integer coordinates are used to index into a permutation table `p4`, using the modulo operator to ensure that they remain within the range of the `p4` table, to obtain gradient vectors for each of the 16 corners of the 4d hypercube.
	•• gradient computations: the gradient vectors are used in the `grad4d` function to compute dot products with the fractional coordinates for each of the 16 corners. these dot products are then interpolated using the `lerp` function to obtain a noise value for each of the 8 vertices of the hypercube.
	•• coordinate adjustments (continued): the noise values at the 8 vertices are further interpolated using the `lerp` function and the fractional coordinate in the 4th dimension to obtain the final noise value at the input coordinates.
	]]--

local grad4d_hash = {
	{0,1,1,1}, {0,1,1,-1}, {0,1,-1,1}, {0,1,-1,-1},
	{0,-1,1,1}, {0,-1,1,-1}, {0,-1,-1,1}, {0,-1,-1,-1},
	{1,0,1,1}, {1,0,1,-1}, {1,0,-1,1}, {1,0,-1,-1},
	{-1,0,1,1}, {-1,0,1,-1}, {-1,0,-1,1}, {-1,0,-1,-1},
	{1,1,0,1}, {1,1,0,-1}, {1,-1,0,1}, {1,-1,0,-1},
	{-1,1,0,1}, {-1,1,0,-1}, {-1,-1,0,1}, {-1,-1,0,-1},
	{1,1,1,0}, {1,1,-1,0}, {1,-1,1,0}, {1,-1,-1,0},
	{-1,1,1,0}, {-1,1,-1,0}, {-1,-1,1,0}, {-1,-1,-1,0}
}

-- function grad4d(hash, x, y, z, w)
	-- local h = (hash % 32)+1
	-- return grad4d_hash[h][1]*x + grad4d_hash[h][2]*y + grad4d_hash[h][3]*z + grad4d_hash[h][4]*w
-- end;
	--[[
	the grad4d function takes a hash value and four input coordinates x, y, z, and w. it computes a hash value modulo 32 to get an index into the grad4d table, and uses the corresponding gradient vector to compute the dot product with the input coordinates.
	]]--

function grad4d(hash, x, y, z, w)
    local h = hash % 32
    local u, v, a, b, c, d = 0, 0, 0, 0, 0, 0
    if h < 16 then 
        u = x
        v = y
        a = z
        b = w
    else 
        u = y
        v = z
        a = w
        b = x
    end
    if h % 8 < 4 then c = u else c = -u end
    if h % 4 == 0 or h % 4 == 3 then d = v else d = -v end
    if type(g[hash]) == "table" then
        return g[hash][1] * c + g[hash][2] * d + g[hash][3] * a + g[hash][4] * b
    else
        return 0
    end
end
	--[[
	in this updated version, type(g[hash]) checks if the value of g[hash] is a table. if it is a table, then the function indexes g[hash] as before. otherwise, the function returns 0 as a fallback value. this should prevent the attempt to index a number value (local 'g') error from occurring.
	]]--

function dot4d(g, x, y, z, w)
	return g[1]*x + g[2]*y + g[3]*z + g[4]*w
end;
	--[[
	this function takes in four coordinates `x`, `y`, `z`, `w` and a gradient vector `g` and returns the dot product of the gradient vector and the input coordinates. this is used in the `noise4d` function to calculate the dot product of the gradient vector and the distance vector in each of the 16 corners of the 4d hypercube.
	]]--

function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end;
	--[[
	the fade function is a mathematical function used in noise generation algorithms to smooth out the transitions between different levels of noise. it takes a single parameter t, which is a value between 0 and 1. the fade function typically returns a value that is interpolated between 0 and 1 based on the input value t. this implementation is known as perlin's quintic polynomial. it is commonly used in perlin noise algorithms and other noise generation algorithms.
	]]--

function lerp(x, y, t)
	-- linearly interpolates between two values `x` and `y` by a given amount `t`
	return x + (y - x) * t
end;

function test_args(p, ...)
	local args = {...}
	local n = #args
	local p_range = #p
	local arg_errors = {}
	
	for i = 1, n do
		local v = args[i]
		if v == nil then
			arg_errors[#arg_errors + 1] = "V|" .. i .. " is nil."
		elseif type(v) ~= "table" and type(v) == "number" then
			if (v%1 == 0) and (v < 1 or v > p_range) then
				arg_errors[#arg_errors + 1] = "V|" .. i .. " = " .. v .. " OOB: [1," .. p_range .. "]."
			end;
		end;
	end;
	
	if #arg_errors > 0 then
		local all_args = ""
		for i, v in ipairs(args) do
			all_args = all_args .. tostring(v) .. ", "
		end
		all_args = all_args:sub(1, -3)
		error("<!> " .. table.concat(arg_errors, " ") .. "All arguments: " .. all_args)
	end;
	
	return unpack(args, 1, n)
end;
	--[[
	`test_args` keeps track of any errors in a table, and then if there are any errors, it concatenates all of the arguments together and includes them in the error message.
	]]--

function test_vars(...)
	local vars = {...}
	local var_errors = {}
	local n = # vars
	local errors = false
	
	for i = 1, n do
		local v = vars[i]
		if v == nil then
			var_errors[#var_errors + 1] = "V|" .. i .. " nil."
			errors = true
		elseif type(v) ~= "number" then
			var_errors[#var_errors + 1] = "V|" .. i .. " nan."
			errors = true
		elseif v % 1 ~= 0 then
			var_errors[#var_errors + 1] = "V|" .. i .. " int."
		elseif v ~= math.floor(v) then
			var_errors[#var_errors + 1] = "V|" .. i .. " float."
		end
	end
	
	if errors then
		local all_vars = ""
		for i, v in ipairs(vars) do
			all_vars = all_vars .. tostring(v) .. ", "
		end
		all_vars = all_vars:sub(1, -3)
		error("<!> " .. table.concat(var_errors, " ") .. "All variables: " .. all_vars)
	end
	
	return vars, n
end
	--[[
	`test_vars` tests for nil values and sets the appropriate error message and sets errors to true. it also tests for numbers and checks if they are integers or floats, and sets the appropriate error message if needed. finally, if there are any errors, it concatenates all of the variables together and includes them in the error message.
	]]--

	--[[
-- `try_catch` function
function try_catch(x, y, p, inx, iny, inz, inw)
	local length = # p
	local catch = false
	local ra, ga, ba, aa
	
	-- test each arg for `nil` or out-of-bounds
	-- set fail values or normalize arg values
	if not p[inx] then
		ra = 0
		catch = true
	elseif (p[inx] < 1 or p[inx] > length) then
		ra = 1
		catch = true
	elseif p[inx] then
		ra = p[inx] / 255
	end
	if not p[iny] then
		ga = 0
		catch = true
	elseif (p[iny] < 1 or p[iny] > length) then
		ga = 1
		catch = true
	elseif p[iny] then
		ga = p[iny] / 255
	end
	if not p[inz] then
		ba = 0
		catch = true
	elseif (p[inz] < 1 or p[inz] > length) then
		ba = 1
		catch = true
	elseif p[inz] then
		ba = p[inz] / 255
	end
	if not p[inw] then
		catch = true
		ra = 1
	elseif (p[inw] < 1 or p[inw] > length) then
		ra = 1
		catch = true
	elseif p[inw] then
		aa = p[inw] / 255
	end
	-- store values for `r`, `g`, `b`, `a` channels of the current sample of get_sample function in `map`
	map[ym][xm] = {ra, ga, ba, aa}
	
	-- check for errors
	if catch then
		return catch
	end
end
	]]--
	--[[
	instance in `noise4d`: rename `catch_`..instance#.. and include 
	catch_n = try_catch(x, y, p, inx, iny, inz, inw)
	if catch_n then return -77777 end

	call this function from `noise4d` function with the appropriate arguments. the `map` global variable will be updated with each call to `try_catch`. `map` will store values for the `r`, `g`, `b`, `a` channels of the current sample based on the test results. if an error is detected, the `catch` variable will be set to true, and returned to `noise4d`. the statementafter `try_catch` should monitor `catch_n`; if `true` a special value of `77777` will be returned by `noise4d`, bypassing any remaining function code.
	]]--

