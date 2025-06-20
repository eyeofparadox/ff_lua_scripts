
A breakdown of the `perlin` noise function and its dependencies:

	perlin = {}
	perlin.p = {}

	math.randomseed(get_intslider_input(SEED))
	
	for i = 0, 255 do
		perlin.p[i] = math.random(255)
		perlin.p[256 + i] = perlin.p[i]
	end

	-- return range: [ - 1, 1]
function perlin:noise(x, y, z)
	y = y or 0
	z = z or 0

	-- calculate the "unit cube" that the point asked will be located in
	local xi = bit32.band(math.floor(x), 255)
	local yi = bit32.band(math.floor(y), 255)
	local zi = bit32.band(math.floor(z), 255)

	-- next we calculate the location (from 0 to 1) in that cube
	x = x - math.floor(x)
	y = y - math.floor(y)
	z = z - math.floor(z)

	-- we also fade the location to smooth the result
	local u = self.fade(x)
	local v = self.fade(y)
	local w = self.fade(z)

	-- hash all 8 unit cube coordinates surrounding input coordinate
	local p = self.p
	local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
	A = p[xi ] + yi
	AA = p[A ] + zi
	AB = p[A + 1 ] + zi
	AAA = p[ AA ]
	ABA = p[ AB ]
	AAB = p[ AA + 1 ]
	ABB = p[ AB + 1 ]

	B = p[xi + 1] + yi
	BA = p[B ] + zi
	BB = p[B + 1 ] + zi
	BAA = p[ BA ]
	BBA = p[ BB ]
	BAB = p[ BA + 1 ]
	BBB = p[ BB + 1 ]

	-- take the weighted average between all 8 unit cube coordinates
	return 
		self.lerp(w, 
			self.lerp(v, 
				self.lerp(u, 
					self:grad(AAA, x, y, z), 
					self:grad(BAA, x - 1, y, z)
				), 
				self.lerp(u, 
					self:grad(ABA, x, y - 1, z), 
					self:grad(BBA, x - 1, y - 1, z)
				)
			), 
			self.lerp(v, 
				self.lerp(u, 
					self:grad(AAB, x, y, z - 1), 
					self:grad(BAB, x - 1, y, z - 1)
				), 
				self.lerp(u, 
					self:grad(ABB, x, y - 1, z - 1), 
					self:grad(BBB, x - 1, y - 1, z - 1)
				)
			)
		)
end


break down of the operations of this section:
```

```

A breakdown of the `perlin` noise function describing what each part does:
	adapted from:
		https://gist.githubusercontent.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed/raw/1c647169a6729713f8987506b2e5c75a23b14969/perlin.lua
		Implemented as described here:
		http://flafla2.github.io/2014/08/09/perlinnoise.html
			originally an external, FF requires internal script exclusively.
			block currently only functions inside prepare(); since the function resides in `perlin[noise]`. 

`perlin`: This section of the `perlin:noise` function initializes the empty `perlin` table and its empty `p` field using the syntax `perlin = {}`, `perlin.p = {}`., the latter of which is used to store 512 pseudorandom gradient values. In `perlin.p = {}`, `p` is a field (also called a key or a member) of the `perlin` table, which is being assigned a new empty table `{}` as its value. So `p` is a field that consists of a table. If you have a table `perlin` containing three tables `p1`, `p2`, `p3`, the fields should be accessed as `perlin.p1`, `perlin.p2`, `perlin.p3`.
	perlin = {}
	perlin.p = {}

Next, an arbitrary seed value is obtained using the `get_intslider_input()` function of the Filter Forge Scripting API. This value is used to seed the random number generator using `math.randomseed()`.
	math.randomseed(get_intslider_input(SEED))

A `for` loop is then used to fill the `perlin.p` table with 256 randomly generated values between 0 and 255. These values are generated using the `math.random()` function.
	for i = 0, 255 do
		perlin.p[i] = math.random(255)
		perlin.p[256 + i] = perlin.p[i]
	end

'function perlin:noise(x, y, z)`: The main function that returns the noise value for a given point (x,y,z). This section of the `perlin:noise` function takes in 3 input values: `x`, `y`, and `z`. It calculates the noise value at the given coordinate in 3D space. Here are the breakdowns of the operations:

The `y` and `z` values are set to 0 if they are not provided as input.
	y = y or 0; z = z or 0 -- if y or z are not provided, set them to 0.

The function calculates the "unit cube" that the point will be located in by using the `math.floor` function to round down the input coordinates to integers and then performing a bitwise AND operation with 255 (which is equivalent to taking the modulo 256). This is done for each coordinate (x, y, and z) to obtain the indices of the cube vertices surrounding the input point.
	local xi = bit32.band(math.floor(x), 255); local yi = bit32.band(math.floor(y), 255); local zi = bit32.band(math.floor(z), 255)

After calculating the unit cube that the point will be located in, the function calculates the relative positions of the input point within the unit cube by subtracting the floored values from the input values. This gives `x`, `y`, and `z` values in the range [0, 1] that represent the position of the input point within the unit cube.
	local xf = x - math.floor(x); local yf = y - math.floor(y); local zf = z - math.floor(z)

The fractional part of the coordinates of the point within the unit cube are calculated by subtracting the floored (integer part) coordinates from the original coordinates.
	x = x - math.floor(x); y = y - math.floor(y); z = z - math.floor(z)

The `fade` function is applied to each of `x`, `y`, and `z` to smooth the result. The `fade` function is a 6th-degree polynomial that interpolates smoothly between 0 and 1.
	local u = self.fade(x); local v = self.fade(y); local w = self.fade(z)

The function then declares several variables that will be used later: `u`, `v`, and `w` are the smoothed `x`, `y`, and `z` values, respectively. `p` is a lookup table that stores the permutation of 256 integers used in the calculation of the `noise` function. The remaining variables (`A`, `AA`, `AB`, etc.) will hold the pseudorandom gradient vectors corresponding to the 8 unit cube vertices surrounding the input point.

Note that the function has not yet calculated the gradient vectors or the noise value itself. These will be calculated in the following steps of the function.

We can now calculate the dot product of each corner vector and the distance vector from the point to that corner. We can also use the fade curve to blend the contributions of each corner vector together. 

In this section of the `perlin:noise` function, the eight corner points of the unit cube surrounding the input point are identified using a hash function. The operations involved are:

Retrieve the permutation table from the `self` table.
	local p = self.p: 

Declare 14 local variables to store the values of the corner points.
	local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB: 

	A = p[xi] + yi -- retrieve the value of the permutation table at the position [xi], and add yi to it. Store the result in A.
	AA = p[A] + zi -- retrieve the value of the permutation table at the position [A], and add zi to it. Store the result in AA.
	AB = p[A + 1] + zi -- retrieve the value of the permutation table at the position [A+1], and add zi to it. Store the result in AB.
	AAA = p[AA] -- retrieve the value of the permutation table at the position [AA]. Store the result in AAA.
	ABA = p[AB] -- retrieve the value of the permutation table at the position [AB]. Store the result in ABA.
	AAB = p[AA + 1] -- retrieve the value of the permutation table at the position [AA+1]. Store the result in AAB.
	ABB = p[AB + 1] -- retrieve the value of the permutation table at the position [AB+1]. Store the result in ABB.

	B = p[xi + 1] + yi -- retrieve the value of the permutation table at the position [xi+1], and add yi to it. Store the result in B.
	BA = p[B] + zi -- retrieve the value of the permutation table at the position [B], and add zi to it. Store the result in BA.
	BB = p[B + 1] + zi -- retrieve the value of the permutation table at the position [B+1], and add zi to it. Store the result in BB.
	BAA = p[BA] -- retrieve the value of the permutation table at the position [BA]. Store the result in BAA.
	BBA = p[BB] -- retrieve the value of the permutation table at the position [BB]. Store the result in BBA.
	BAB = p[BA + 1] -- retrieve the value of the permutation table at the position [BA+1]. Store the result in BAB.
	BBB = p[BB + 1] -- retrieve the value of the permutation table at the position [BB+1]. Store the result in BBB.

Overall, these operations perform a series of table lookups to retrieve the values of the corner points of the unit cube surrounding the input point. These corner points are used in the subsequent interpolation steps to calculate the final `perlin:noise` value.

This section of the `perlin:noise` function performs the final step of calculating the noise value for the input coordinates by taking the weighted average between all 8 unit cube coordinates surrounding the input coordinate.

`self.lerp`: The function is used for linear interpolation. It takes two values `a` and `b`, and a weight `w` and returns the linearly interpolated value between `a` and `b` based on the weight `w`. The nested `self.lerp` functions are used to calculate the weighted average between all 8 unit cube coordinates. The inputs to these functions are the 8 unit cube coordinates and the input coordinate. These 8 unit cube coordinates are labeled with different variable names that correspond to their position in the unit cube, such as `AAA`, `AAB`, `ABA`, etc. Inside each `self.lerp` function, there are two more nested `self.lerp` functions, which are used to interpolate the gradient vectors at each of the 4 corners of the unit cube. The gradient vectors are calculated using the `self:grad` function, which takes a hash value and the input coordinates, and returns a gradient vector.
	return 
		self.lerp(w, 
			self.lerp(v, 
				self.lerp(u, 
					self:grad(AAA, x, y, z), 
					self:grad(BAA, x - 1, y, z)
				), 
				self.lerp(u, 
					self:grad(ABA, x, y - 1, z), 
					self:grad(BBA, x - 1, y - 1, z)
				)
			), 
			self.lerp(v, 
				self.lerp(u, 
					self:grad(AAB, x, y, z - 1), 
					self:grad(BAB, x - 1, y, z - 1)
				), 
				self.lerp(u, 
					self:grad(ABB, x, y - 1, z - 1), 
					self:grad(BBB, x - 1, y - 1, z - 1)
				)
			)
		)

Overall, the final output of this section is a weighted average of the gradient vectors at the 8 corners of the unit cube, which is the `perlin:noise` value for the input coordinates.

This section of the `perlin:noise` function defines a lookup table for the `dot_product` function and a gradient function that finds the dot product between a pseudorandom gradient vector and the vector from an input coordinate to a unit cube vertex.

`perlin.dot_product`: This table contains 16 entries, each corresponding to one of the 16 possible bit patterns that can be formed by three bits. Each entry is a function that takes three arguments `x`, `y`, and `z`, which represent the coordinates of a point, and returns the dot product between the pseudorandom gradient vector and the vector from the input point to a unit cube vertex in a particular direction. The directions are determined by the bit pattern associated with the function in the table.
	perlin.dot_product = {
		[0x0] = function(x, y, z) return x + y end, 
		[0x1] = function(x, y, z) return -x + y end, 
		[0x2] = function(x, y, z) return x - y end, 
		[0x3] = function(x, y, z) return -x - y end, 
		[0x4] = function(x, y, z) return x + z end, 
		[0x5] = function(x, y, z) return -x + z end, 
		[0x6] = function(x, y, z) return x - z end, 
		[0x7] = function(x, y, z) return -x - z end, 
		[0x8] = function(x, y, z) return y + z end, 
		[0x9] = function(x, y, z) return -y + z end, 
		[0xA] = function(x, y, z) return y - z end, 
		[0xB] = function(x, y, z) return -y - z end, 
		[0xC] = function(x, y, z) return y + x end, 
		[0xD] = function(x, y, z) return -y + z end, 
		[0xE] = function(x, y, z) return y - x end, 
		[0xF] = function(x, y, z) return -y - z end
	}

`perlin:grad(hash, x, y, z)`: This method takes four arguments: `hash`, an integer value between 0 and 255; and `x`, `y`, and `z`, which represent the coordinates of a point. The method computes the dot product between the pseudorandom gradient vector associated with the given `hash` value and the vector from the input point to a unit cube vertex. The `hash` value determines which gradient vector to use, and the direction of the vector is determined by the dot product function corresponding to the last three bits of the hash value. The method returns the computed dot product.
	function perlin:grad(hash, x, y, z)
		return self.dot_product[bit32.band(hash, 0xF)](x, y, z)
	end

`perlin.fade(t)`: The `fade` function is used to smooth the final output of the `perlin:noise` function. It takes a single parameter `t`, which represents the input value to be smoothed. The function uses a quintic (degree-5) polynomial to gradually transition from 0 to 1 as `t` increases from 0 to 1. This helps to reduce the appearance of sharp edges and discontinuities in the output of the `perlin:noise` function.
	function perlin.fade(t)
		return t * t * t * (t * (t * 6 - 15) + 10)
	end

`perlin.lerp(t, a, b)`: The `lerp` function is a linear interpolation function that is used to combine the weighted average of the dot products of gradient vectors and the input coordinate. It takes three parameters: `t`, `a`, and `b`. The function returns the linear interpolation of `a` and `b` at the ratio of `t`, where `t` ranges from 0 to 1. The resulting value is a weighted average of `a` and `b` where `t` determines the weighting of the two values.
	function perlin.lerp(t, a, b)
		return a + t * (b - a)
	end

`noise`, `dot_product`, `grad`, `fade` and `lerp` are all functions defined within the `perlin` table using the colon syntax (`perlin:function()`). This makes them methods of the `perlin` table, so they can be called using the `:` syntax (`perlin:method()`).

	local p = permutation
	local grad = gradients

	local dot = function(a, b, c, x, y, z)
	return a * x + b * y + c * z
	end

