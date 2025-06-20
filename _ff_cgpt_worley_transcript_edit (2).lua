
•• In Lua, what is a helper function?

A helper function is a function that is created to perform a specific task within a larger program or function. The purpose of a helper function is to simplify code, make it more readable, and reduce the amount of duplicated code. Helper functions are not intended to be called directly by the user, but instead are called from within other functions in order to carry out a specific task. They are used to abstract away implementation details and make the code easier to understand and maintain.

•• the get_distance function is supposed to compute the distance to the i-th closest point for a worley noise function. to optimize a bit, I was going to identify and keep track of only the point selected (elsewhere) out of the four closest points, rather than all four closest points. The get_distance function uses the get_point helper function to compute the coordinates of the i-th closest point to the input coordinates (dx, dy, dz). I do not have the code for it, or the `formula` function to normalize the computed distances. Can you help with that, building on the distance function I have?:

function get_distance(sx, sy, sz, dx, dy, dz, i)
	-- Compute coordinates of the i-th closest point
	local px, py, pz = get_point(i, dx, dy, dz)

	-- Calculate distance using selected formula
	if distance_type == 1 then
		-- Euclidean distance
		local distance = math.sqrt((sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
	elseif distance_type == 2 then
		-- Manhattan distance
		local distance = math.abs(sx - px) + math.abs(sy - py) + math.abs(sz - pz)
	elseif distance_type == 3 then
		-- Chebyshev distance
		local distance = math.max(math.abs(sx - px), math.abs(sy - py), math.abs(sz - pz))
	elseif distance_type == 4 then
		-- Minkowski distance
		local distance = (math.abs(sx - px)^p + math.abs(sy - py)^p + math.abs(sz - pz)^p)^(1/p)
	elseif distance_type == 5 then
		-- Quadratic distance
		local distance = ((sx - px)^2 + (sy - py)^2 + (sz - pz)^2) / (1 + (sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
	end
	
	-- Normalize distance to range 0-1
	local max_distance = formula(0, 0, 0, 1, 1, 1)
	local normalized_distance = distance / max_distance

	return normalized_distance
end

Based on the code you provided, it seems like get_point is a helper function that takes an index i and the input coordinates dx, dy, dz, and returns the coordinates of the i-th closest point in the Worley noise function.

Here's an example implementation of the get_point function that uses a 3D array to store the positions of the closest points:

-- Initialize the closest points array
local num_points = 16
local closest_points = {}
for i = 1, num_points do
  closest_points[i] = {math.random(), math.random(), math.random()}
end

function get_point(i, dx, dy, dz)
  local closest_point = closest_points[i]
  local px, py, pz = closest_point[1], closest_point[2], closest_point[3]
  return px + dx, py + dy, pz + dz
end

As for the formula function, it's not clear from your code what it does. If you could provide more information or code, I could try to help you implement it.

•• Sadly, the `formula` function was not that clearly defined. All I have to go on is the comment "Normalize distance to range 0-1". That might be a reference to the use of [0, 1] value ranges for samples in Filter Forge.

If the formula function is not defined, then one possible way to normalize the computed distances to the range 0-1 would be to divide each distance by the maximum distance among all the computed distances. Here's an updated version of the get_distance function with this normalization approach:

function get_distance(sx, sy, sz, dx, dy, dz, i)
	-- Compute coordinates of the i-th closest point
	local px, py, pz = get_point(i, dx, dy, dz)

	-- Calculate distance using selected formula
	local distance
	if distance_type == 1 then
		-- Euclidean distance
		distance = math.sqrt((sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
	elseif distance_type == 2 then
		-- Manhattan distance
		distance = math.abs(sx - px) + math.abs(sy - py) + math.abs(sz - pz)
	elseif distance_type == 3 then
		-- Chebyshev distance
		distance = math.max(math.abs(sx - px), math.abs(sy - py), math.abs(sz - pz))
	elseif distance_type == 4 then
		-- Minkowski distance
		distance = (math.abs(sx - px)^p + math.abs(sy - py)^p + math.abs(sz - pz)^p)^(1/p)
	elseif distance_type == 5 then
		-- Quadratic distance
		distance = ((sx - px)^2 + (sy - py)^2 + (sz - pz)^2) / (1 + (sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
	end

	-- Find the maximum distance among all the computed distances
	local max_distance = 0
	for j = 1, num_points do
		local dxj, dyj, dzj = delta_coord(j, dx, dy, dz)
		local distj = get_distance(sx, sy, sz, dxj, dyj, dzj, j)
		max_distance = math.max(max_distance, distj)
	end

	-- Normalize distance to range 0-1
	local normalized_distance = distance / max_distance

	return normalized_distance
end

In this updated version, the max_distance variable is computed as the maximum distance among all the computed distances for the given point. Then, the normalized_distance variable is calculated by dividing the computed distance by max_distance.

•• Okay. I'll see how that works out.


•• Until recently, I did not know there was a perlin interpolation for worley noise; blending based on a perlin noise function between between the two points. Could you tell me more about it? Is it a separate function or a more basic equation like linear interpolation is?

Yes, there is, called Perlin Worley noise. This can create smoother transitions between regions of the noise and provide more natural-looking results. The basic idea behind Perlin Worley noise is to use the distance between the two closest points as a blending factor between the values of those two points. However, instead of using a linear blend, a Perlin noise function is used to weight the blend, creating a smoother transition.It's a clever way to add some randomness and smoothness to the otherwise sharp and abrupt transitions in Worley noise. It's a popular technique in procedural texture generation and has been used in many applications.

The equation for Perlin Worley noise can be expressed as follows:

	distance = distance to closest point, loop thru n-th point
	
	blend = 1 - (distance / distance to second closest point)
	
	perlin = perlin noise at sample point
	
	value = (blend * value at closest point) + ((1 - blend) * value at second closest point)
	
	final value = (perlin * value) + ((1 - perlin) * value at closest point)
	
Here, the blend value is calculated using the distance to the closest and second closest points, and is used to blend between the values at those points. The perlin value is the Perlin noise value at the sample point, and is used to weight the blend between the closest point and the blended value. Finally, the final value is the weighted average of the blended value and the value at the closest point, resulting in a smooth transition between the two.

The Perlin Worley noise equation can be implemented in a Filter Forge map script by combining the Worley noise and Perlin noise functions, and using them to calculate the blended and final values as described above.

•• is there a short-hand for that calculation like: dist = (3 - 2 * t) * t^2 * d1 + t^2 * (t - 1) * d2?

Yes. It is called a smoothstep function and is commonly used in computer graphics for smooth interpolation between two values. The smoothstep function is defined as:

function smoothstep(t)
  return t * t * (3 - 2 * t)
end

Using this function, the blended distance between two Worley points (d1 and d2) can be calculated as follows:

function blend_distance(d1, d2, t)
  local weight = smoothstep(t)
  return lerp(d1, d2, weight)
end

In this code, lerp is a function that performs linear interpolation between two values, which is used to interpolate between the two Worley distances based on the weight calculated by the smoothstep function.

•• I was hoping the pseudo code  to lua:

	distance = distance to closest point
	blend = 1 - (distance / distance to second closest point)
	perlin = perlin noise at sample point
	value = (blend * value at closest point) + ((1 - blend) * value at second closest point)
	final value = (perlin * value) + ((1 - perlin) * value at closest point)
	
	Sure, here's the Lua code for that:

function perlin_interp(t)
	-- compute distance to closest and second closest points
	local d1 = get_d(sx, sy, sz, dx, dy, dz, 1)
	local d2 = get_d(sx, sy, sz, dx, dy, dz, 2)

	-- compute blend factor
	local blend = 1 - (d1 / d2)

	-- compute v at closest and second closest points
	local v1 = get_v(dx, dy, dz, 1)
	local v2 = get_v(dx, dy, dz, 2)

	-- compute interpolation using Perlin noise
	local perlin = get_perlin_noise(dx, dy, dz, frequency, octaves, lacunarity, persistence)
	local v = blend * v1 + (1 - blend) * v2
	local interpolation = perlin * v + (1 - perlin) * v1

  return interpolation
end

•• is this version sound?: dist =  (pxyz * (((1 - (d1 / d2)) * v1) + ((1 - (1 - (d1 / d2))) * v2))) + ((1 - pxyz) * v1)

There seems to be an issue with the expression you provided. Specifically, the term 1 - (1 - (d1 / d2)) simplifies to just (d1 / d2). With that in mind, the revised expression should be:

dist = pxyz * (((1 - (d1 / d2)) * v1) + ((d1 / d2) * v2)) + (1 - pxyz) * v1

This expression should give you the correct distance value based on the inputs you've described.


•• I still get a little confused about the exact relationship between the raw distance calculations termed `Euclidean`, `Manhattan, `Chebyshev`, etc, blend methods defined as `interpolation` (linear, cosine, cubic...), the F type blending modes, and descriptive types (Cell, Block, Chaffs...). I kind of wish I had a comprehensive table that was a bit more explicit about their correlation.

I can provide you with a brief overview of the different components of Worley noise and how they relate to each other:
1
	Distance functions: These determine how distances between points are calculated. The three most common distance functions used in Worley noise are Euclidean, Manhattan, and Chebyshev distance.
2
	Interpolation functions: These are used to blend the values of neighboring points. Linear interpolation is the most commonly used interpolation function in Worley noise, but other functions such as cubic and cosine interpolation can also be used.
3
	F1, F2, and F3 blending: These are formulas used to combine the values of the neighboring points with the interpolated value. They are named after the positions of the three closest points to the sample point. For example, the F1 formula uses the value of the closest point, while the F2 formula uses the value of the second closest point.
4
	Types of Worley noise: There are several different types of Worley noise, including Cellular, Block, and Chaff. These types refer to different arrangements of points and different combinations of distance and blending functions.
5
	Implementation details: Finally, there are various implementation details that can affect the final output of Worley noise, such as the number of points used, the scaling and offset of the sample points, and the normalization of the output values.

Unfortunately, there is no comprehensive table that explicitly correlates all of these components, as there are many possible combinations and variations. However, understanding how each component works can help you choose the appropriate settings for your desired effect.

•• I'm trying to remember the term for the charting method used to map out the relationship of concepts and information as a sort of 2 or 3D network...

The term you might be thinking of is "mind map" or "concept map". These are visual representations of information and relationships between concepts or ideas. They are often used for brainstorming, organizing information, and presenting complex ideas.

•• That's probably a bit over the top. I'm just trying to work out a logical structure for my Worley function. I know that Cells use Euclidean distance calculation. Blocks correspond to Manhattan. The F type blending modes involve raising the distances to some power, summing them together, and then dividing by the number of distances. It's a different way to classify the same noises: F1 for Cells, F2 for Blocks, F3 for Chaffs. Combinations of F type correspond to others. Depending on how you classify it, the same noise can use what looks like a completely different equation.

Yes, it can definitely get confusing when different names are used for similar concepts, and when the same concept can be expressed in different ways. Here's a quick summary of some of the relationships between the concepts you mentioned:

	Distance calculation: Euclidean, Manhattan, and Chebyshev are different methods for calculating distance between points in a grid or lattice. Euclidean calculates the straight-line distance, Manhattan calculates the sum of the absolute differences in x and y coordinates, and Chebyshev calculates the maximum of the absolute differences in x and y coordinates.

	Blend method: Linear, cosine, cubic, etc. are different methods for blending between values at different points in space. Linear interpolation is a simple blend between two values based on the distance between them. Cosine interpolation uses a cosine curve to blend smoothly between values. Cubic interpolation uses a cubic curve to blend smoothly and interpolate more precisely.

	Descriptive type: Cell, block, chaff, etc. are different names for patterns of points in space. A cell pattern consists of a regular grid of points. A block pattern consists of points on a regular grid, but shifted so that the points do not align with the cell grid. A chaff pattern consists of randomly placed points.

	F-type: F1, F2, F3, etc. are different types of distance summation formulas used to combine the distances to neighboring points in a pattern. F1 is the sum of the distances to the closest neighboring points, F2 is the sum of the squared distances to the closest neighboring points, and F3 is the sum of the cubed distances to the closest neighboring points.

Different combinations of these concepts can produce different types of noise patterns. For example, a Worley noise can be generated using a cell pattern with Euclidean distance calculation and F1 blending, or a block pattern with Manhattan distance calculation and F2 blending, or a chaff pattern with Chebyshev distance calculation and F3 blending.

•• And what I want is a chart that breaks the different noises by pattern, distance calculation and blending method. I just don't know how you get a specific equation for a specific combination of `distance,` `formula,` `interpolation` and characteristic implementation or `type`.

The equations for specific combinations of distance, formula, interpolation, and type can be quite complex, and it would be challenging to create a comprehensive chart that covers all possible combinations. However, I can give you a general idea of how each component affects the resulting noise.

	Distance: The choice of distance metric affects how the Voronoi cells are formed and can significantly impact the resulting noise. Euclidean distance tends to produce smoother, more rounded cell shapes, while Manhattan distance creates more blocky, square shapes. Chebyshev distance produces cells with diamond shapes.

	Formula: The formula used to combine the cell values can vary depending on the desired result. F1 corresponds to using the closest cell value, while F2 uses the second-closest value. F3 uses the third-closest value, and so on. Different combinations of F values can produce different noise patterns.

	Interpolation: The interpolation method determines how the cell values are blended together to produce a final value at each sample point. Linear interpolation is the simplest and most common method, while cosine interpolation produces smoother results. Cubic interpolation can be used for even smoother results but is more computationally expensive.

	Type: The type of Worley noise refers to how the Voronoi cells are positioned relative to each other. The simplest type is called "cellular," where each cell corresponds to a point in space. Block noise is a variation where the cells are arranged in a grid pattern. Chaff noise is a type where the cell positions are perturbed randomly.

Combining these components can produce a wide variety of noise patterns. Some common combinations include Euclidean distance with F1 formula and linear interpolation, which produces a classic cell noise pattern. Manhattan distance with F2 formula and cosine interpolation creates block noise, while Chebyshev distance with F3 formula and cubic interpolation produces a chaff noise pattern.

•• Yes, But, I'm trying to figure out how to go from this:

	d = 
		F1: sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2) or 
		F2: sqrt((x1-x3)^2 + (y1-y3)^2 + (z1-z3)^2) or 
		F3: sqrt((x1-x4)^2 + (y1-y4)^2 + (z1-z4)^2)
		... 
and or this:

	F1: (d1 + d2 + d3 + d4) / 4
	F2: (d1^2 + d2^2 + d3^2 + d4^2) / 4
	F3: (d1^3 + d2^3 + d3^3 + d4^3) / 4
	...

and incorporate: 

	d = 
		(1 - t) * d1 + t * d2 or 
		(1 - cos(t * pi)) / 2 * d1 + (1 - cos((1 - t) * pi)) / 2 * d2 or 
		(2 * t^3 - 3 * t^2 + 1) * d1 + (3 * t^2 - 2 * t^3) * d2
		...

to get the actual distance. And, that's not even looking at hybrid formulas. I've gathered a lot of example code, but the different implementations make it harder to figure out the logic of the functions. I'm starting to get the way a metric and formula can be put together, but then I get lost trying to fit interpolation into it in the function. Or is it supposed to be one function calling on another function, calling on another function...? I'm fine with that, but I need to know what info pertains to what function, and what one function needs from another to get the job done.

I understand your confusion. It can be challenging to understand the different combinations of distance metrics, interpolation methods, and other parameters used in noise functions. Here's an attempt to break it down:

	Firstly, there are different distance metrics that can be used, such as Euclidean, Manhattan, Chebyshev, etc. These metrics define how the distance between two points is calculated. For example, Euclidean distance is calculated as the square root of the sum of the squared differences between the coordinates of two points. Manhattan distance is calculated as the sum of the absolute differences between the coordinates.

	Secondly, there are different interpolation methods that can be used to blend the values of the neighboring points. Linear interpolation is a simple method that linearly interpolates between the two closest points. Cosine interpolation is another method that uses a cosine curve to interpolate between the points. Cubic interpolation is a more complex method that uses a cubic function to interpolate between the points.

	Thirdly, there are different combinations of distance metrics and interpolation methods that can be used to create different noise functions. For example, the Worley noise function (also known as Cellular noise) uses Euclidean distance and linear interpolation to determine the distance to the closest neighboring point. On the other hand, the Voronoi noise function (also known as Distance noise) uses Manhattan distance and linear interpolation to determine the distance to the closest neighboring point.

	Fourthly, there are different blending methods that can be used to combine the distances from the closest neighboring points. For example, the F1 blending method used in Worley noise takes the distance to the closest point, while the F2 blending method takes the sum of the squares of the distances to the two closest points.

	Finally, there are different types of noise functions, such as Cell noise, Block noise, and Chaff noise, that are based on different combinations of distance metrics, interpolation methods, and blending methods.

To create a specific noise function, you need to choose the appropriate combination of distance metric, interpolation method, blending method, and noise type. The resulting function will depend on the specific parameters you choose. For example, in the case of Worley noise, you can use Euclidean distance, linear interpolation, and the F1 blending method to create a function that calculates the distance to the closest neighboring point.

•• Mmm. It all just feels like not being able to see the forest for all the trees. I'm trying to get the broader picture, but I just can't make sense of how each of these different trees fits into a collective scheme. There IS a logic to it all. I just haven't come across the rule-set intrinsic to it.

I understand how overwhelming it can be to learn a new subject and make sense of all the information. In the case of noise functions, there are many different ways to combine distance metrics, blending methods, and other factors to create unique noise patterns. It can be challenging to see the overall structure and relationships between the various techniques.

One approach you could take is to break down each component of the noise function and understand its role in the overall pattern. For example, start with the distance metric and learn how it affects the pattern of the noise. Then move on to the blending method and see how it modifies the distance values to create smoother or rougher transitions between points.

Once you have a solid understanding of each component, you can start combining them in different ways to create new noise patterns. This can be an iterative process of trial and error, experimenting with different combinations and tweaking parameters until you achieve the desired effect.

It's also helpful to study examples of noise functions created by others and try to reverse engineer their techniques. This can give you insight into how they combined different components to achieve their results.

Remember that it takes time and practice to fully grasp complex subjects like noise functions. Don't get discouraged if it takes a while to make sense of it all. Keep learning, experimenting, and practicing, and you'll eventually develop a strong understanding of the subject.

•• Well, I'm just trying to figure out simple things like how the interpolation is injected into the metric.

In Worley noise, interpolation is used to blend the distances to the neighboring points together. After finding the distances to each neighboring point using the chosen distance metric, the distances are sorted to determine the closest and second closest points.

Then, the blending function is applied to these distances to determine how much weight to give each distance in the final output. The interpolation function is used here to smoothly blend between the two closest distances.

For example, one popular interpolation function used in Worley noise is cosine interpolation, which is defined as:

cosine_interpolation(a, b, t) = a + (1 - cos(t * pi)) / 2 * (b - a)

In this case, a and b are the two closest distances, and t is a value between 0 and 1 that represents the blend factor. This function will smoothly blend between the two distances as t varies from 0 to 1, with a value of 0.5 representing an equal blend.

Once the blended distances have been calculated, the final output value is determined using the chosen formula, which can include the blended distances in different ways.

•• So, basically, you HAVE to calculate the distance, THEN you use them in the interpolation.

Yes, that's correct. First, you calculate the distance using a metric function like Euclidean, Manhattan, or Chebyshev. Then, you use the resulting distances in the interpolation function, which blends the noise values from the closest feature points to get the final value at the sample point.

The interpolation function is applied to the distances after they have been calculated using the metric function, and it is used to determine the weighting of the noise values from the feature points based on the distance to each point.

•• So, this list of equations:

Euclidean

	sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2)
	sqrt((x1-x3)^2 + (y1-y3)^2 + (z1-z3)^2)
	sqrt((x1-x4)^2 + (y1-y4)^2 + (z1-z4)^2)
	sqrt((x1-x5)^2 + (y1-y5)^2 + (z1-z5)^2)
	
is a set of operations, first do one, then for the second distance do the second equation, etc.?

Yes, that's correct. Each equation in the list is a separate calculation of the Euclidean distance between two points in space, with the coordinates (x1, y1, z1) and (x2, y2, z2) for the first equation, (x1, y1, z1) and (x3, y3, z3) for the second equation, and so on. Each calculation produces a single value that represents the distance between the two points. You would need to perform each calculation separately to obtain a complete set of distances between all of the points.

•• Okay, so some of the code that's confusing me is set up to do a loop through a general statement where the identity of the variables (n-th distance point) change with every loop. I amstill a bit confused by one set of equations for F types where the distances are simply summed and then averaged, and those where an interpolation is injected for each distance in the sum.

I see what you mean. For F types, the basic idea is to take a set of distances between a given point and a set of neighboring points, raise them to some power, sum them together, and then divide by the number of distances. The power to which the distances are raised is determined by the F type:

	F1: distances are not raised to any power; they are simply summed and then divided by the number of distances.
	F2: distances are squared, then summed, and then divided by the number of distances.
	F3: distances are cubed, then summed, and then divided by the number of distances.
	F4: distances are raised to the fourth power, then summed, and then divided by the number of distances.
	etc.

	In general, the F type equation can be written as:

	sum((distance_i)^p) / n

	where distance_i is the distance from the given point to the i-th neighboring point, p is the power to which the distances are raised (i.e., the F type), and n is the number of neighboring points.

Now, when it comes to blending, you can use interpolation to blend between the values of neighboring points. For example, in the case of linear interpolation, you might use the equation:

(1 - t) * value_i + t * value_j

where value_i is the value at the i-th neighboring point, value_j is the value at the j-th neighboring point, and t is a value between 0 and 1 that determines the weighting between the two values. This equation can be used to blend between any two neighboring points, not just for the calculation of distances.

So, in summary, you can use interpolation to blend between the values of neighboring points, and you can use the F type equation to calculate the contribution of each neighboring point to the final output value of the noise function. These two concepts are separate, but they can be used together to create complex and interesting noise functions.

•• they are two distinct steps or operations in the distance function?

Yes, that's correct. Calculating the distance between two points is the first step, and then using that distance in an interpolation formula is the second step. So the distance calculation is a separate operation from the interpolation, but they are both necessary in order to generate the final output of the noise function.

•• what step, exactly, does this pertain to?: (d1 + d2 + d3 + d4) / 4

The step that this equation pertains to is the blending step, where the distances calculated using the chosen metric (e.g. Euclidean, Manhattan) are combined together to create a blended noise.

In this specific case, the equation calculates the average of the distances from four neighboring points (d1, d2, d3, d4) in the F1 blending mode.

•• and how does it interact with this?: (1 - t) * d1 + t * d2

The equation (d1 + d2 + d3 + d4) / 4 is a distance calculation formula, specifically for F1-type noise, which calculates the average distance between a given point and four surrounding points.

The equation (1 - t) * d1 + t * d2 is an interpolation formula that blends between two distances (d1 and d2) based on a given interpolation parameter t, where t ranges from 0 to 1.

In the context of noise generation, the F1-type noise is created by taking the average of the distance between a given point and its four nearest surrounding points, each of which is offset from the original point by some random distance. The interpolation formula is then used to blend the resulting distances based on a given interpolation parameter, which allows for the creation of more complex noise patterns.

•• I guess I'm confused because this `(d1 + d2 + d3 + d4) / 4` was identified as `F1` under `blending` and `sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2)` was identified as a `distance` function, also under `F1`. Also under `blending` the interpolation function applies some modification to the distances as they are being summed. The overlaps are giving me a headache! 

I can understand why it might be confusing to have some overlap between the blending and distance functions. It's helpful to think of them as separate steps in the overall process of calculating a distance value.

	The distance function is responsible for calculating the raw distance values between two points. This is the fundamental operation that underlies any distance metric. In your case, the sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2) equation represents the Euclidean distance metric, which is a commonly used distance metric in many fields.

	The blending function, on the other hand, takes the raw distance values produced by the distance function and combines them in some way to produce a final distance value. This can involve weighting the individual distances, taking the average of the distances, or using some more complex formula to combine them. The (d1 + d2 + d3 + d4) / 4 equation is a simple blending function that takes the average of the four distances.
	
	The interpolation function is another step that can be applied after the blending function, and it involves modifying the blended distance value based on some external variable. In your case, t is the interpolation variable, and (1 - t) * d1 + t * d2 is an example of an interpolation function that linearly interpolates between d1 and d2 based on the value of t.

	The distance function calculates the raw distance values between two points, the blending function combines those raw distance values into a single distance value, and the interpolation function modifies the blended distance value based on an external variable. These steps can be combined in different ways to produce a variety of distance metrics that are tailored to specific applications.

•• okay, so you start by getting distances (d1, d2, d3, d4), you blend them... is this a set of four more operations, or is there one result? If the latter, you move on to interpolation and there you have two distances to interpolate. well, I'm just not seeing how they both persist after blending.

	After blending the distances, you would have a single value that represents the overall distance between the two points. For example, if you blend four distances together using the formula (d1 + d2 + d3 + d4) / 4, you would end up with a single value that represents the average distance between the two points across those four distances.

	Once you have this blended distance value, you can then apply an interpolation method to determine the distance between the two points at a specific point along a path between them. This interpolation would take into account the blended distance value as well as the specific distances between the two points that were used to calculate it.

	So to answer your question, the blended distance value would persist after blending and would be used in the interpolation step to determine the distance at a specific point along the path.

•• so `d1` and `d2` in the interpolation are the original `d1` and `d2`... where is (or what is) the blended distance? I mean I'm missing the variable itself. I don't see it in any of the notes I've made.

	The blended distance is the result of applying the blending function to the original distances d1, d2, d3, and d4. So, for example, if the blending function is (d1 + d2 + d3 + d4) / 4, then the blended distance would be the average of the original distances.

	Once you have the blended distance, you can then apply the interpolation function to it. The interpolation function uses the original distances d1 and d2, but it does not use the blended distance itself. The purpose of blending is to combine multiple distances into a single distance that can then be interpolated.

•• but, I've got a value from the blending. what variable is holding it? is it just something like `blend`, and if it isn't explicitly used in interpolation, how does it influence the operation. or, where does it come into play as part of a following operation or function?

It's possible that the blended distance value is stored in a variable or array, depending on how the code is written. Without seeing the specific code you're working with, it's difficult to say exactly how it's being stored.

However, if the blended distance value is not explicitly used in the interpolation formula, it's possible that it's being used as a weighting factor for the interpolation. For example, the weight of d1 in the interpolation formula could be (1 - blend) while the weight of d2 could be blend. In this way, the blended distance is indirectly influencing the interpolation calculation by adjusting the weights of the original distances.


•• Can you describe the different ways Worley noise is implemented including the formulas and blending methods used?

Worley noise, also known as cellular noise or Voronoi noise, is a type of procedural noise commonly used in computer graphics, simulation, and terrain generation. It generates a pattern of cells or regions in space, with each cell representing a point or seed.

There are several ways to implement Worley noise, each with its own formulas and blending methods. Here are three common methods:

Manhattan Distance Method:
The Manhattan distance method is the simplest way to implement Worley noise. It calculates the distance between each pixel in the output image and the closest point or seed in space, using the Manhattan distance formula:

d = abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)

Where (x1, y1, z1) are the coordinates of the pixel, and (x2, y2, z2) are the coordinates of the closest point. The result is a black and white image where the value at each pixel represents the distance to the closest point. To generate a more interesting pattern, you can apply a blending function to combine the distances from multiple points.

Euclidean Distance Method:
The Euclidean distance method is a more advanced way to implement Worley noise, which uses the Euclidean distance formula to calculate the distance between each pixel and the closest point:

d = sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)

Where (x1, y1, z1) are the coordinates of the pixel, and (x2, y2, z2) are the coordinates of the closest point. This method generates a smoother pattern than the Manhattan distance method, but it is also more computationally expensive.

F1-F2 Method:
The F1-F2 method is a hybrid approach that combines both the Manhattan and Euclidean distance methods. It calculates the distance to the two closest points, and then applies a blending function that takes into account both distances. The blending function can be any function that interpolates between the two values, such as linear, cubic, or cosine. The formula for the F1-F2 method is:

d1 = abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
d2 = abs(x1 - x3) + abs(y1 - y3) + abs(z1 - z3)
f = (d1^2 - d2^2) / (d1^2 + d2^2)
d = (1 - f) * d1 + f * d2

Where (x1, y1, z1) are the coordinates of the pixel, and (x2, y2, z2) and (x3, y3, z3) are the coordinates of the two closest points. The result is a more complex pattern than the previous two methods, with smoother transitions between regions.

To blend the distances together, there are a variety of methods one could use, such as:

Linear interpolation: blending based on a linear function between the two distances.
Cosine interpolation: using a cosine function to blend between the two distances.
Cubic interpolation: using a cubic function to blend between the two distances.

Ultimately, the choice of blending method can have a big impact on the final look of the noise, and different methods may be better suited to different use cases.

•• Please list all the formulas, methods and blending options.

Sure, here are some additional formulas, methods, and blending options that can be used when implementing Worley noise:

Formulas:

	Manhattan distance formula:
	d = abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)

	Euclidean distance formula:
	d = sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)

	Chebyshev distance formula:
	d = max(abs(x1 - x2), abs(y1 - y2), abs(z1 - z2))

Methods:

	Single-point Voronoi: This method generates Voronoi cells based on a set of randomly placed seed points. Each pixel in the output image is assigned to the cell corresponding to its closest seed point.

	Multiple-point Voronoi: This method generates Voronoi cells based on a set of seed points arranged in a grid or other regular pattern. Each pixel in the output image is assigned to the cell corresponding to its closest seed point.

	Jittered grid: This method generates a grid of seed points with a small amount of random displacement. This produces a more irregular pattern than the regular grid method.

	Poisson disk sampling: This method generates a set of seed points that are evenly distributed and have a minimum distance between them. This produces a more naturalistic pattern than the regular or jittered grid methods.

Blending Options:

	Linear interpolation: Blending based on a linear function between the distances to the closest points.

	Cosine interpolation: Blending based on a cosine function between the distances to the closest points.

	Cubic interpolation: Blending based on a cubic function between the distances to the closest points.

	Smoothstep interpolation: Blending based on a smoothstep function between the distances to the closest points. This produces a smoother transition between regions than linear interpolation.

	Perlin interpolation: Blending based on a Perlin noise function between the distances to the closest points. This produces a more organic-looking pattern than the other methods.

It's worth noting that there are many variations and combinations of these formulas, methods, and blending options that can be used to create different types of Worley noise. The choice of which ones to use will depend on the specific application and desired visual effect.

Here is a table that shows the Euclidean, Manhattan, Chebyshev, Minkowski, and Quadratic distance formulas for the first through fourth nearest point:

Distance formula

	F1
	F2
	F3
	F4
	
Euclidean distance

	sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2)
	sqrt((x1-x3)^2 + (y1-y3)^2 + (z1-z3)^2)
	sqrt((x1-x4)^2 + (y1-y4)^2 + (z1-z4)^2)
	sqrt((x1-x5)^2 + (y1-y5)^2 + (z1-z5)^2)
	
Manhattan distance

	abs(x1-x2) + abs(y1-y2) + abs(z1-z2)
	abs(x1-x3) + abs(y1-y3) + abs(z1-z3)
	abs(x1-x4) + abs(y1-y4) + abs(z1-z4)
	abs(x1-x5) + abs(y1-y5) + abs(z1-z5)
	
Chebyshev distance

	max(abs(x1-x2), abs(y1-y2), abs(z1-z2))
	max(abs(x1-x3), abs(y1-y3), abs(z1-z3))
	max(abs(x1-x4), abs(y1-y4), abs(z1-z4))
	max(abs(x1-x5), abs(y1-y5), abs(z1-z5))
	
Minkowski (p=3) distance

	(abs(x1-x2)^3 + abs(y1-y2)^3 + abs(z1-z2)^3)^(1/3)
	(abs(x1-x3)^3 + abs(y1-y3)^3 + abs(z1-z3)^3)^(1/3)
	(abs(x1-x4)^3 + abs(y1-y4)^3 + abs(z1-z4)^3)^(1/3)
	(abs(x1-x5)^3 + abs(y1-y5)^3 + abs(z1-z5)^3)^(1/3)
	
Quadratic distance

	(x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2
	(x1-x3)^2 + (y1-y3)^2 + (z1-z3)^2
	(x1-x4)^2 + (y1-y4)^2 + (z1-z4)^2
	(x1-x5)^2 + (y1-y5)^2 + (z1-z5)^2

Note: This table assumes distances are in three-dimensional space (x, y, and z coordinates). The formulas can be modified for two-dimensional or higher-dimensional spaces as needed.

•• Perfect. Please provide popular blending methods for the entries in that table.

Certainly, here are some popular blending methods that can be used with the distance formulas in the table: 
	(d1 is the distance to the first nearest point, d2 is the distance to the second nearest point, and t is a parameter between 0 and 1 that determines the weighting of each distance. pi is the mathematical constant pi.)

		Linear interpolation: This method blends between the distances to the nearest points using a linear function. For example, to blend between the first and second nearest points using linear interpolation, we would calculate:

		dist = (1 - t) * d1 + t * d2

		Cosine interpolation: This method blends between the distances to the nearest points using a cosine function. For example, to blend between the first and second nearest points using cosine interpolation, we would calculate:

		dist = (1 - cos(t * pi)) / 2 * d1 + (1 - cos((1 - t) * pi)) / 2 * d2

		Cubic interpolation: This method blends between the distances to the nearest points using a cubic function. For example, to blend between the first and second nearest points using cubic interpolation, we would calculate:

		dist = (2 * t^3 - 3 * t^2 + 1) * d1 + (3 * t^2 - 2 * t^3) * d2

		Smoothstep interpolation: This method blends between the distances to the nearest points using a smoothstep function. For example, to blend between the first and second nearest points using smoothstep interpolation, we would calculate:

		dist = (3 - 2 * t) * t^2 * d1 + t^2 * (t - 1) * d2

It's worth noting that there are many other blending methods that can be used with Worley noise, and the choice of which one to use will depend on the specific application and desired visual effect.

•• I am familiar with the F type blending modes and was looking for the first four combinations for the entries in that table. Can you provide them?
Sure! Here are the first four F-type blending modes for the entries in the table, where d1 is the distance to the closest point, d2 is the distance to the second closest point, d3 is the distance to the third closest point, and d4 is the distance to the fourth closest point:

	F1 blending mode:

	(d1 + d2 + d3 + d4) / 4

	F2 blending mode:

	(d1^2 + d2^2 + d3^2 + d4^2) / 4

	F3 blending mode:

	(d1^3 + d2^3 + d3^3 + d4^3) / 4

	F4 blending mode:

	(d1^4 + d2^4 + d3^4 + d4^4) / 4

In general, F-type blending modes involve raising the distances to some power, summing them together, and then dividing by the number of distances.

•• I have seen these used for cell noise, block noise, chaffs noise, pyramids, stones and techno noise. I need functions that can reproduce those using lua 5.1. Can you create those?

Here are Lua 5.1 implementations of some common noise functions that use the F1-F4 blending modes:

-- Cell noise using F1 blending
function cell_noise(x, y, z)
	local xi, yi, zi = math.floor(x), math.floor(y), math.floor(z)
	local dmin = math.huge
	for dx = -1, 1 do
		for dy = -1, 1 do
			for dz = -1, 1 do
				local xp = xi + dx
				local yp = yi + dy
				local zp = zi + dz
				local h = hash_3d(xp, yp, zp)
				local dist = distance(x, y, z, xp + h[1], yp + h[2], zp + h[3])
				dmin = math.min(dmin, dist)
			end
		end
	end
	return dmin
end

-- Block noise using F2 blending
function block_noise(x, y, z)
	local xi, yi, zi = math.floor(x), math.floor(y), math.floor(z)
	local dsum = 0
	for dx = -1, 1 do
		for dy = -1, 1 do
			for dz = -1, 1 do
				local xp = xi + dx
				local yp = yi + dy
				local zp = zi + dz
				local h = hash_3d(xp, yp, zp)
				local dist = distance(x, y, z, xp + h[1], yp + h[2], zp + h[3])
				dsum = dsum + dist^2
			end
		end
	end
	return math.sqrt(dsum / 27)
end

-- Chaffs noise using F3 blending
function chaffs_noise(x, y, z)
	local xi, yi, zi = math.floor(x), math.floor(y), math.floor(z)
	local dsum = 0
	for dx = -1, 1 do
		for dy = -1, 1 do
			for dz = -1, 1 do
				local xp = xi + dx
				local yp = yi + dy
				local zp = zi + dz
				local h = hash_3d(xp, yp, zp)
				local dist = distance(x, y, z, xp + h[1], yp + h[2], zp + h[3])
				dsum = dsum + dist^3
			end
		end
	end
	return dsum / 27
end

-- Pyramid noise using F4 blending
function pyramid_noise(x, y, z)
	local xi, yi, zi = math.floor(x), math.floor(y), math.floor(z)
	local dsum = 0
	for dx = -1, 1 do
		for dy = -1, 1 do
			for dz = -1, 1 do
				local xp = xi + dx
				local yp = yi + dy
				local zp = zi + dz
				local h = hash_3d(xp, yp, zp)
				local dist = distance(x, y, z, xp + h[1], yp + h[2], zp + h[3])
				dsum = dsum + dist^4
			end
		end
	end
	return dsum^(1/4) / 1.712
end

These implementations assume that the distance function and the hash_3d function are defined elsewhere in your code. Here are example implementations of those functions:

-- Euclidean distance function
function euclidean_distance(x1, y1, z1, x2, y2, z2)
	local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
	return math.sqrt(dx^2 + dy^2 + dz^2)
end

function hash_3d(x, y, z)
	-- hash function for 3d coordinates
	local seed = 131
	local hash = seed
	hash = (hash * 311) % 65536
	hash = (hash * 271 + x) % 65536
	hash = (hash * 271 + y) % 65536
	hash = (hash * 271 + z) % 65536
	return { (hash % 1024) / 1024 - 0.5, (hash / 1024 % 1024) / 1024 - 0.5, (hash / 1024 / 1024) / 1024 - 0.5 }
end

Note that these implementations are for illustrative purposes only and may not be suitable for production use. Additionally, you may need to adjust the constants and scaling factors in the noise functions to achieve the desired output.

Here are examples of functions for generating stone and techno noise using Worley noise:

-- Stone noise function
function stone_noise(x, y, z, frequency, lacunarity, gain, octaves)
	local sum = 0
	local amplitude = 1
	local max_amplitude = 0

	for i = 1, octaves do
		local noise = worley_noise(x * frequency, y * frequency, z * frequency, 1)
		noise = math.abs(noise) * 2 - 1
		sum = sum + noise * amplitude
		amplitude = amplitude * gain
		frequency = frequency * lacunarity
		max_amplitude = max_amplitude + amplitude
	end

	return sum / max_amplitude
end

In stone_noise, the Worley noise is transformed to the range [-1, 1] and then scaled to [0, 1] using math.abs(noise) * 2 - 1. The output is then computed as the sum of the octaves divided by the maximum amplitude.


-- Techno noise function
function techno_noise(x, y, z, frequency, lacunarity, gain, octaves, threshold, power)
	local sum = 0
	local amplitude = 1
	local max_amplitude = 0

	for i = 1, octaves do
		local noise = worley_noise(x * frequency, y * frequency, z * frequency, 1)
		noise = math.abs(noise) * 2 - 1
		noise = (noise > threshold) and math.pow((noise - threshold) / (1 - threshold), power) or 0
		sum = sum + noise * amplitude
		amplitude = amplitude * gain
		frequency = frequency * lacunarity
		max_amplitude = max_amplitude + amplitude
	end

	return sum / max_amplitude
end

In techno_noise, a threshold is applied to the Worley noise, and any values above the threshold are raised to a power using math.pow. The output is then computed in the same way as stone_noise.


Again, note that these implementations are for illustrative purposes only and may need to be adjusted to achieve the desired output.

Here are the implementations for the remaining noise types:

-- Cell noise function
function cell_noise(x, y, z, frequency, distance_func, num_points)
	local closest_points = {}
	for i = 1, num_points do
		local point = hash_3d(x, y, z)
		table.insert(closest_points, point)
	end
	table.sort(closest_points, function(a, b) return distance_func(x, y, z, a[1], a[2], a[3]) < distance_func(x, y, z, b[1], b[2], b[3]) end)
	return distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3])
end

-- Block noise function
function block_noise(x, y, z, frequency, distance_func, num_points)
	local closest_points = {}
	for i = 1, num_points do
		local point = hash_3d(x, y, z)
		table.insert(closest_points, point)
	end
	table.sort(closest_points, function(a, b) return distance_func(x, y, z, a[1], a[2], a[3]) < distance_func(x, y, z, b[1], b[2], b[3]) end)
	return (distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3]) < frequency) and 1 or 0
end

-- Chaffs noise function
function chaffs_noise(x, y, z, frequency, distance_func, num_points)
	local closest_points = {}
	for i = 1, num_points do
		local point = hash_3d(x, y, z)
		table.insert(closest_points, point)
	end
	table.sort(closest_points, function(a, b) return distance_func(x, y, z, a[1], a[2], a[3]) < distance_func(x, y, z, b[1], b[2], b[3]) end)
	local dist1 = distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3])
	local dist2 = distance_func(x, y, z, closest_points[2][1], closest_points[2][2], closest_points[2][3])
	return (dist1 < frequency and dist2 > frequency) and 1 or 0
end

-- Pyramid noise function
function pyramid_noise(x, y, z, frequency, distance_func, num_points)
	local closest_points = {}
	for i = 1, num_points do
		local point = hash_3d(x, y, z)
		table.insert(closest_points, point)
	end
	table.sort(closest_points, function(a, b) return distance_func(x, y, z, a[1], a[2], a[3]) < distance_func(x, y, z, b[1], b[2], b[3]) end)
	local dist1 = distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3])
	local dist2 = distance_func(x, y, z, closest_points[2][1], closest_points[2][2], closest_points[2][3])
	return (dist1 < frequency and dist2 > frequency) and 1 - (dist1 / frequency) or 0
end

-- Stones noise function
function stones_noise(x, y, z, frequency, distance_func, num_points)
	local closest_points = {}
	for i = 1, num_points do
		local point = hash_3d(x, y, z)
		table.insert(closest_points, point)
	end
	table.sort(closest_points, function(a, b) return distance_func(x, y, z, a[1], a[2], a[3]) < distance_func(x, y, z, b[1], b[2], b[3]) end)
	local dist1 = distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3])
	local dist2 = distance_func(x, y, z, closest_points[2][1], closest_points[2][2], closest_points[2][3])
	local dist3 = distance_func(x, y, z, closest_points[3][1], closest_points[3][2], closest_points[3][3])
	return dist3 / (dist1 + dist2 + dist3)
end

-- Techno noise function
function techno_noise(x, y, z, frequency, distance_func, num_points)
	local closest_points = {}
	for i = 1, num_points do
		local point = hash_3d(x, y, z)
		table.insert(closest_points, point)
	end
	table.sort(closest_points, function(a, b) return distance_func(x, y, z, a[1], a[2], a[3]) < distance_func(x, y, z, b[1], b[2], b[3]) end)
	local dist1 = distance_func(x, y, z, closest_points[1][1], closest_points[1][2], closest_points[1][3])
	local dist2 = distance_func(x, y, z, closest_points[2][1], closest_points[2][2], closest_points[2][3])
	local dist3 = distance_func(x, y, z, closest_points[3][1], closest_points[3][2], closest_points[3][3])
	local dist4 = distance_func(x, y, z, closest_points[4][1], closest_points[4][2], closest_points[4][3])
	local max_dist = math.max(dist1, dist2, dist3, dist4)
	return max_dist / frequency
end

Note that these functions use the hash_3d function that we defined earlier to generate the random points. You may need to adjust the frequency, distance_func, and num_points parameters to achieve the desired noise effect.



function get_distance(sx, sy, sz, dx, dy, dz, i)
	-- Compute coordinates of the i-th closest point
	local px, py, pz = get_point(i, dx, dy, dz)

	-- Calculate distance using selected formula
	local distance
	if distance_type == 1 then
		-- Euclidean distance
		distance = math.sqrt((sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
	elseif distance_type == 2 then
		-- Manhattan distance
		distance = math.abs(sx - px) + math.abs(sy - py) + math.abs(sz - pz)
	elseif distance_type == 3 then
		-- Chebyshev distance
		distance = math.max(math.abs(sx - px), math.abs(sy - py), math.abs(sz - pz))
	elseif distance_type == 4 then
		-- Minkowski distance
		distance = (math.abs(sx - px)^p + math.abs(sy - py)^p + math.abs(sz - pz)^p)^(1/p)
	elseif distance_type == 5 then
		-- Quadratic distance
		distance = ((sx - px)^2 + (sy - py)^2 + (sz - pz)^2) / (1 + (sx - px)^2 + (sy - py)^2 + (sz - pz)^2)
	end

	-- Find the maximum distance among all the computed distances
	local max_distance = 0
	for j = 1, num_points do
		local dxj, dyj, dzj = delta_coord(j, dx, dy, dz)
		local distj = get_distance(sx, sy, sz, dxj, dyj, dzj, j)
		max_distance = math.max(max_distance, distj)
	end

	-- Normalize distance to range 0-1
	local normalized_distance = distance / max_distance

	return normalized_distance
end
--[[
	This version of the get_distance function now computes the distance to the i-th closest point, rather than all four closest points. It also includes support for four different F type distance methods: Euclidean, Manhattan, Chebyshev, and Minkowski (with parameter p). Finally, it includes support for the Quadratic distance method. The function uses the get_point helper function to compute the coordinates of the i-th closest point to the input coordinates (dx, dy, dz). One possible way to normalize the computed distances to the range 0-1 would be to divide each distance by the maximum distance among all the computed distances. 
]]--


-- Initialize the closest points array
local num_points = 16
local closest_points = {}
for i = 1, num_points do
  closest_points[i] = {math.random(), math.random(), math.random()}
end

function get_point(i, dx, dy, dz)
  local closest_point = closest_points[i]
  local px, py, pz = closest_point[1], closest_point[2], closest_point[3]
  return px + dx, py + dy, pz + dz
end
--[[
	This is a helper function that takes an index i and the input coordinates dx, dy, dz, and returns the coordinates of the i-th closest point in the Worley noise function. (originally described as, a function to compute the coordinates of the i-th closest point to the input coordinates (dx, dy, dz). 
]]--


function get_seamless_tiling_noise(x,y,z,sx,sy,sz, roughness)
	-- generates seamless tiling noise applied respective to octave scales and distance mapping
	local x_wrap = x % sx
	local y_wrap = y % sy
	local z_wrap = z % sz
	local noise = 0.0
	local amp = 1.0
	for oct = 1,details do
		noise = noise + get_worley_noise(x_wrap/oct,y_wrap/oct,z_wrap/oct,sx,sy,sz) * amp
		amp = amp / roughness
	end
	return noise
end

function get_worley_noise(x,y,z,sx,sy,sz)
	--- scaling in 3 dimensions
	local sx, sy, sz = x / sx , y / sy, z / sz
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local offset_x, offset_y, offset_z
	local noise = 10000
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				-- expanded distances function
				local distance = get_distance(sx,sy,sz,dx,dy,dz)
				noise = math.min(distance, noise)
			end
		end
	end
	noise = 1.0 - noise
	return noise
end

function get_distance(sx,sy,sz,dx,dy,dz) 
	-- standard distances to first closest point
	local distance = 0
	-- using int distance_type (1 is Euclidean, 2 is Manhattan, 3 is Chebyshev, 4 is Minkowski, 5 is Quadratic)
	if distance_type == 1 then
		distance = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)
	elseif distance_type == 2 then
		distance = math.abs(sx - dx) + math.abs(sy - dy) + math.abs(sz - dz)
	elseif distance_type == 3 then
		distance = math.max(math.abs(sx - dx), math.abs(sy - dy), math.abs(sz - dz))
	elseif distance_type == 4 then
		distance = math.pow(math.pow(math.abs(sx - dx), 3) + math.pow(math.abs(sy - dy), 3) + math.pow(math.abs(sz - dz), 3), 0.3333333333)
	elseif distance_type == 5 then
		distance = math.sqrt(math.pow(sx - dx, 4) + math.pow(sy - dy, 4) + math.pow(sz - dz, 4))
	end
	return distance
end

