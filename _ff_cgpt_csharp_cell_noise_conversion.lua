--[[C#
	The commented critical code from the demo is listed below. The full source for the demo is hosted at github and can be found at https://github.com/freethenation/CellNoiseDemo. The source code below is not optimized for performance but rather written to be easily understood. 
	
	Required parameters for the CellNoise.CellNoiseFunc function in Lua:

		input: A Vector3 representing the location at which the cell noise function should be evaluated.

		seed: An integer representing the seed for the noise function.

		distanceFunc: A function that calculates the distance between two Vector3 points. This function should take two Vector3 arguments and return a float representing the distance between them.

		distanceArray: A Lua table (array) that will store the distances computed by the Worley noise function. The length of this table determines how many distances will be computed. You need to initialize this table before calling the function.

		combineDistancesFunc: A function that takes the populated distanceArray table as input and returns a float, which is the grayscale value output by the Worley noise function. This function should implement the logic for combining the distances to compute the final output color.

	These parameters are required to call the CellNoiseFunc function and generate cell noise. 
]]
-- Define a CellNoise table
CellNoise = {}

-- Generates Cell Noise
function CellNoise.CellNoiseFunc(input, seed, distanceFunc, distanceArray, combineDistancesFunc)
    -- Initialize some variables
    local lastRandom, numberFeaturePoints
    local randomDiff, featurePoint
    local cubeX, cubeY, cubeZ

    -- Initialize values in the distance array to large values
    for i = 1, #distanceArray do
        distanceArray[i] = 6666
    end

    -- Determine which cube the evaluation point is in
    local evalCubeX = math.floor(input.x)
    local evalCubeY = math.floor(input.y)
    local evalCubeZ = math.floor(input.z)

    for i = -1, 1 do
        for j = -1, 1 do
            for k = -1, 1 do
                cubeX = evalCubeX + i
                cubeY = evalCubeY + j
                cubeZ = evalCubeZ + k

                -- Generate a reproducible random number generator for the cube
                lastRandom = lcgRandom(hash(cubeX + seed, cubeY, cubeZ))
                -- Determine how many feature points are in the cube
                numberFeaturePoints = probLookup(lastRandom)
                -- Randomly place the feature points in the cube
                for l = 1, numberFeaturePoints do
                    lastRandom = lcgRandom(lastRandom)
                    randomDiff.x = lastRandom / 0x100000000

                    lastRandom = lcgRandom(lastRandom)
                    randomDiff.y = lastRandom / 0x100000000

                    lastRandom = lcgRandom(lastRandom)
                    randomDiff.z = lastRandom / 0x100000000

                    featurePoint = Vector3(randomDiff.x + cubeX, randomDiff.y + cubeY, randomDiff.z + cubeZ)

                    -- Find the feature point closest to the evaluation point
                    -- This is done by inserting the distances to the feature points into a sorted list
                    insert(distanceArray, distanceFunc(input, featurePoint))
                end
                -- Check the neighboring cubes to ensure there are no closer evaluation points
                -- This is done by repeating the above steps for each neighboring cube
            end
        end
    end

    local color = combineDistancesFunc(distanceArray)
    if color < 0 then color = 0 end
    if color > 1 then color = 1 end
    return Vector4(color, color, color, 1)
end

-- Define distance functions
function CellNoise.EuclidianDistanceFunc(p1, p2)
    return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y) + (p1.z - p2.z) * (p1.z - p2.z)
end

function CellNoise.ManhattanDistanceFunc(p1, p2)
    return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y) + math.abs(p1.z - p2.z)
end

function CellNoise.ChebyshevDistanceFunc(p1, p2)
    local diff = p1 - p2
    return math.max(math.max(math.abs(diff.x), math.abs(diff.y)), math.abs(diff.z))
end

-- Given a uniformly distributed random number, this function returns the number of feature points in a given cube
function CellNoise.probLookup(value)
    if value < 393325350 then return 1
    elseif value < 1022645910 then return 2
    elseif value < 1861739990 then return 3
    elseif value < 2700834071 then return 4
    elseif value < 3372109335 then return 5
    elseif value < 3819626178 then return 6
    elseif value < 4075350088 then return 7
    elseif value < 4203212043 then return 8
    else return 9
    end
end

-- Inserts value into array using insertion sort. If the value is greater than the largest value in the array,
-- it will not be added to the array.
function CellNoise.insert(arr, value)
    local temp
    for i = #arr, 1, -1 do
        if value > arr[i] then break end
        temp = arr[i]
        arr[i] = value
        if i + 1 <= #arr then
            arr[i + 1] = temp
        end
    end
end

-- LCG Random Number Generator
function CellNoise.lcgRandom(lastValue)
    return (1103515245 * lastValue + 12345) % 0x100000000
end

-- Constants used in FNV hash function
CellNoise.OFFSET_BASIS = 2166136261
CellNoise.FNV_PRIME = 16777619

-- Hashes three integers into a single integer using FNV hash
function CellNoise.hash(i, j, k)
    return ((((CellNoise.OFFSET_BASIS ~ i) * CellNoise.FNV_PRIME ~ j) * CellNoise.FNV_PRIME ~ k) * CellNoise.FNV_PRIME) % 0x100000000
end

-- Create Vector3 and Vector4 classes (assuming they are not defined elsewhere)
Vector3 = {}
Vector4 = {}

-- Define the main program logic here
-- ...

-- Example usage:
-- local input = Vector3(1.0, 2.0, 3.0)
-- local seed = 12345
-- local distanceArray = {}
-- local result = CellNoise.CellNoiseFunc(input, seed, CellNoise.EuclidianDistanceFunc, distanceArray, function(distances)
--     -- Combine distances and return the color value
--     -- Implement your combineDistancesFunc logic here
--     return 0.5
-- end)
-- print(result)

--[[
	Please note that this code assumes the existence of a Vector3 and Vector4 class with appropriate constructors (Vector3(x, y, z) and Vector4(x, y, z, w)) and that you will need to implement the logic for combineDistancesFunc according to your needs. Additionally, you may need to adapt the code to match the Lua libraries and data structures you are using.
	
	•• Can you show me examples of Vector3 or Vector4 classes in Lua 5.1?

	In Lua 5.1, there are no built-in classes like in some other languages, such as C#. However, you can create your own custom Vector3 and Vector4-like structures using Lua tables. Here's a simple example of how you can define Vector3 and Vector4-like structures in Lua 5.1:

		-- Define a custom Vector3-like structure
		local Vector3 = {}
		Vector3.__index = Vector3

		function Vector3.new(x, y, z)
			local self = setmetatable({}, Vector3)
			self.x = x or 0
			self.y = y or 0
			self.z = z or 0
			return self
		end

		-- Define a custom Vector4-like structure
		local Vector4 = {}
		Vector4.__index = Vector4

		function Vector4.new(x, y, z, w)
			local self = setmetatable({}, Vector4)
			self.x = x or 0
			self.y = y or 0
			self.z = z or 0
			self.w = w or 0
			return self
		end

		-- Create instances of Vector3 and Vector4
		local v3 = Vector3.new(1.0, 2.0, 3.0)
		local v4 = Vector4.new(0.5, 0.5, 0.5, 1.0)

		-- Accessing elements
		print("Vector3:", v3.x, v3.y, v3.z)
		print("Vector4:", v4.x, v4.y, v4.z, v4.w)
	
	In this example, we define custom Vector3 and Vector4 structures using Lua tables and metatables. The Vector3.new and Vector4.new functions are used to create instances of these structures with initial values for their components (x, y, z, and w). You can access the individual components of these vectors using dot notation (e.g., v3.x).

	Keep in mind that this is a basic example, and you can extend these structures to include additional methods and functionalities as needed for your specific use case.
	
	•• I am not familiar with instancing in Lua. Can you explain that for me?
	
	In Lua, there's no concept of "class instances" in the same way as you might find in object-oriented languages like Python or C#. Instead, Lua uses tables and metatables to create objects and implement object-oriented programming (OOP) patterns. Here's how it works:

	Tables: In Lua, tables are used as the fundamental data structure for creating objects or custom data structures. Tables can store key-value pairs and are versatile enough to represent objects, arrays, and more.

	Metatables: Metatables are used to define the behavior of tables, effectively giving tables their own "class-like" properties. A metatable can contain special methods, called metamethods, that define how a table behaves when certain operations are performed on it (e.g., arithmetic operations, indexing, etc.).

	Creating Instances: To create instances of custom objects or structures, you typically define a table as a template (or "class") and then create new tables based on that template. These new tables will share the same metatable and, therefore, the same behavior.

	Here's a step-by-step explanation of how you create instances in Lua using tables and metatables:
	
		-- Step 1: Define a table as a template (or "class")
		local Vector = {}  -- This is like a class definition
		Vector.__index = Vector  -- Set the metatable to itself

		-- Step 2: Define constructor function to create instances
		function Vector.new(x, y, z)
			local self = setmetatable({}, Vector)  -- Create a new table and set its metatable to Vector
			self.x = x or 0
			self.y = y or 0
			self.z = z or 0
			return self
		end

		-- Step 3: Define methods for the Vector "class"
		function Vector:add(otherVector)
			return Vector.new(self.x + otherVector.x, self.y + otherVector.y, self.z + otherVector.z)
		end

		-- Step 4: Create instances using the constructor function
		local v1 = Vector.new(1, 2, 3)
		local v2 = Vector.new(4, 5, 6)

		-- Step 5: Use methods on instances
		local result = v1:add(v2)
		print(result.x, result.y, result.z)

	In this example:

	`Vector `serves as the template for creating Vector objects.
	`Vector.new` is the constructor function used to create new Vector instances.
	Methods like `add` can be defined on the `Vector` "class" and used on instances.

	This is a basic example of how you can create custom structures and objects in Lua using tables and metatables. The key idea is to define a template (the "class") and then create instances from that template.
]]