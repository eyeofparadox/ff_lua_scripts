-- perlin4d -- <?> 3.10.2023»03:03
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
end;

function get_sample(x, y)
	-- inputs and calculation.
	z = get_sample_grayscale(x,y,Z)
	w = get_sample_grayscale(x,y,W)
	t = get_sample_grayscale(x,y,T)

	-- vars, n = test_vars(p[x], p[y], p[z], p[w])

	-- image generation code
	local r = perlin4d(x, y, z, w, lacunarity, octaves, frequency, amplitude, persistence, t, p4)
	local g = 0 -- perlin4d(x+1, y-1,z+1, w-1, lacunarity, octaves, frequency, amplitude, persistence, t, p4)
	local b = 0 -- perlin4d(x-2, y+2, z-2, w+2, lacunarity, octaves, frequency, amplitude, persistence, t, p4)
	local a = 1
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
	-- local amplitude = amplitude -- might have been intended for scale.
	
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
	
function noise4d(x, y, z, w, p4)
	-- adjusted to integer coordinates from float inputs `(x,y,z,w)` = [0,1]. this alone does not prevent `i` == `0`, so adjustment needed for proper indexing. simple addition or subtration will always put `i` == `0` at some point. what is needed is a ground to wheel relationship where `p4` = [1,256] and interaction with coordinates drive `p4` in a circle over any distance without risk of `-i` == `0`. 
	-- coordinate operations:
	local ix = offset_index(p4, 1, math.floor(x * 255) + 1)
	local iy = offset_index(p4, 1, math.floor(y * 255) + 1)
	local iz = offset_index(p4, 1, math.floor(z * 255) + 1)
	local iw = offset_index(p4, 1, math.floor(w * 255) + 1)
	test_args(p4, ix, iy, iz, iw)
	
	local fx = (x * 255) - ix
	local fy = (y * 255) - iy
	local fz = (z * 255) - iz
	local fw = (w * 255) - iw
	test_args(p4, fx, fy, fz, fw)
	
	local u = fade(fx)
	local v = fade(fy)
	local uu = fade(fz)
	local vv = fade(fw)
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

	local x1 = lerp(u, dot4d(in1, fx, fy, fz, fw), dot4d(in5, fx - 1, fy, fz, fw)) -- coordinate and indexing operations
	local x2 = lerp(u, dot4d(in2, fx, fy, fz - 1, fw), dot4d(in6, fx - 1, fy, fz - 1, fw)) -- coordinate and indexing operations
	local y1 = lerp(v, x1, x2) -- coordinate operation

	local x3 = lerp(u, dot4d(in3, fx, fy - 1, fz, fw), dot4d(in7, fx - 1, fy - 1, fz, fw)) -- coordinate and indexing operations
	local x4 = lerp(u, dot4d(in4, fx, fy - 1, fz - 1, fw), dot4d(in8, fx - 1, fy - 1, fz - 1, fw)) -- coordinate and indexing operations
	local y2 = lerp(v, x3, x4) -- coordinate operation

	local z1 = lerp(uu, y1, y2) -- coordinate operation
	return z1
end;
	--[[
	this implementation uses the grad4d function to calculate the dot products based on the gradient vectors obtained from the p4 table using the hash4d function.
	]]--

-- function to offset index within range [1, table_size]
function offset_index(tbl, current_index, offset)
    local table_size = #tbl
    local new_index = current_index + offset
    if new_index > table_size then
        new_index = new_index - table_size
    elseif new_index < 1 then
        new_index = new_index + table_size
    end
    return new_index
end;
    --[[
    the `offset_index` function takes care of ensuring that the indices are within the range [1, table_size] and returns a valid index, so, for example, the indices used in `i1`, `i2`, `i3`, `i4`, `i5`, and `i6` should be valid indices for the `p4` table.
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

function grad4d(inp, x, y, z, w)
	test_vars(inp, x, y, z, w) -- no msg
	-- error(string.format("Error: Invalid value %d for inp parameter in grad4d()", inp))
	local hash = (inp - 1) % 32 + 1
	-- error(string.format("`hash` value: %d.", hash))
    if hash > 32 or hash < 1 then
        error("grad4d_hash: invalid hash value " .. tostring(hash) .. " for input values " .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z) .. ", " .. tostring(w))
    end
	-- local hash = bit32.band(inp - 1, 31) + 1
	-- convert inp to the range [1,32]
	local g = grad4d_hash[hash]
	test_g_and_hash(g, grad4d_hash, 1)
	return {
		g[1]*x + 
		g[2]*y + 
		g[3]*z + 
		g[4]*w, 
		g[5]*x + 	-- "attempt to perform arithmetic on a nil value" error
		g[6]*y + 
		g[7]*z + 
		g[8]*w, 
		g[9]*x + 
		g[10]*y + 
		g[11]*z + 
		g[12]*w, 
		g[13]*x + 
		g[14]*y + 
		g[15]*z + 
		g[16]*w
	}
end

function test_g_and_hash(g, hash, test_number)
    local elements, hash_nil, hash_oob = 0, 0, 0
    local index_count, g_nil, g_oob = 0, 0, 0
    local invalid_indices = {}
    
    for i = 1, #hash do
        local idx = hash[i]
        if not g[idx] then
            hash_nil = hash_nil + 1
            g_nil = g_nil + 1
            table.insert(invalid_indices, i)
        elseif idx < 0 or idx >= #g then
            hash_oob = hash_oob + 1
            g_oob = g_oob + 1
            table.insert(invalid_indices, i)
        else
            index_count = index_count + 1
        end
        elements = elements + 1
    end
    
    local g_result = string.format("#%d:#%d:#%d", index_count, g_nil, g_oob)
    local hash_result = string.format("#%d:#%d:#%d", elements, hash_nil, hash_oob)
    local invalid_indices_str = table.concat(invalid_indices, ", ")
    local report = string.format("%d. Hash %s. Gradient %s. Invalid indices: %s", test_number, hash_result, g_result, invalid_indices_str)
    
    if hash_nil > 0 or hash_oob > 0 or g_nil > 0 or g_oob > 0 then
        error(string.format("Error: Invalid values detected - " .. report))
    else
        return false
    end
end
	--[[
	a function that tests the g array and hash values, sums their states, and reports the result in one line. call this function with the g and hash arrays as arguments and it will return a string with the result. You can also use the test_number variable to keep track of which test is being performed.
	]]--

	--[[
	grad4d_hash is a table (specifically, a lua table) that contains pre-computed values that are used to generate the gradient vectors in 4d space. the table is a 2d array that has 32 rows and 4 columns. each row represents a specific gradient vector, which is a 4-element array containing the x, y, z, and w components of the vector.
	
	for example, the first row of grad4d_hash is {0,1,1,1}, which represents the gradient vector (0, 1, 1, 1) in 4d space. the second row is {0,1,1,-1}, which represents the gradient vector (0, 1, 1, -1), and so on. the grad function uses these pre-computed values to generate the appropriate gradient vector for a given input value and 4d coordinates.
	]]--

-- function grad4d(hash, x, y, z, w)
	-- local h = hash % 32
	-- return grad4d_hash[h+1][1]*x + grad4d_hash[h+1][2]*y + grad4d_hash[h+1][3]*z + grad4d_hash[h+1][4]*w
-- end;
	--[[
	the grad4d function takes a hash value and four input coordinates x, y, z, and w. it computes a hash value modulo 32 to get an index into the grad4d table, and uses the corresponding gradient vector to compute the dot product with the input coordinates.
	]]--

	--[[
	this is a revised grad4d function that takes a single input value inp and returns a table g containing the 4d gradient vector. this function uses the % operator to wrap the input value inp to the range of valid indices for the grad4d_hash table, and then adds 1 to convert from lua's 1-based indexing to the 0-based indexing used by the table. the resulting index is used to retrieve the appropriate gradient vector from the grad4d_hash table, and this vector is multiplied by the input values x, y, z, and w to generate the final 4d gradient vector g.
	
	this function calls on the `grad4d_hash` tableand uses it to lookup the appropriate gradient vector g based on the value of inp and a bitmask of 31. it then returns the dot product of g and the input (x, y, z, w) coordinates.
	]]--

function dot4d(g, x, y, z, w)
	return g[1]*x + g[2]*y + g[3]*z + g[4]*w
end;
	--[[
	this function takes in four coordinates x, y, z, w and a gradient vector g and returns the dot product of the gradient vector and the input coordinates. this is used in the noise4d function to calculate the dot product of the gradient vector and the distance vector in each of the 16 corners of the 4d hypercube.
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

function wrap(x, min_val, max_val)
	local range = max_val - min_val + 1
	return ((x - min_val) % range) + min_val
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


