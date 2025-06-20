-- 3d worley base
function prepare()
	amp = 1
	distance_type = get_intslider_input(DISTANCE_TYPE) -- range 1 to 5
	distance_formula = get_intslider_input(DISTANCE_FORMULA) -- range 1 to 4
	details = get_intslider_input(DETAILS) -- range 1 to 10
	scale = math.max(0.001, get_slider_input(SCALE)) -- range 1 to 100 - will be replaced by mapped input
	set_noise_seed(get_intslider_input(SEED) + 1) -- range 1 to 30000 + 1
	-- z = 1 - (SEED / 30000)
end;

function get_sample(x, y)
	local z = get_sample_grayscale(x, y, Z)
	local r,g,b,a -- will be sampled
	local roughness = 3.75
 --[[
	local r, g, b, a = get_sample_map(x, y, HIGH)
	local r, g, b, a = get_sample_map(x, y, LOW)
	get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	get_sample_grayscale(x, y, CONTRAST)
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	sx, sy, sz = sx * sa * 2.5, sy * sa * 2.5, sz * sa * 2.5
	]]--
	local sx, sy, sz = x / scale , y / scale, z / scale
	local noise = worley(sx,sy,sz,roughness)
	r,g,b,a = noise, noise, noise, 1
	return r,g,b,a
end;

function worley(sx,sy,sz, roughness) -- <!> purged - should be seamless but not having the right effect
	-- seamless tiling noise
	...
	local noise = worley_octaves(sx,sy,sz,roughness)
	return noise
end

function worley_octaves(sx,sy,sz,roughness)
	for oct = 1,details do
		if oct == 1 then 
			octaves = worley_noise(sx,sy,sz)
		else
			octaves = (octaves + worley_noise(x/oct,y/oct,z/oct,sx,sy,sz) * amp ) / (1 + amp)
		end
		z = z * 2
		sx, sy, sz = sx / 2, sy / 2, sz / 2
		amp = amp / roughness
	end
	return octaves
end

function worley_noise(sx,sy,sz)
	local sx, sy, sz = sx , sy, sz
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local offset_x, offset_y, offset_z
	local noise = 10000
	for offset_x =-1,1 do
		for offset_y =-1,1 do
			for offset_z =-1,1 do
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local distance = worley_distance(sx,sy,sz,dx,dy,dz)
				noise = math.min(distance, noise)
			end
		end
	end
	noise = 1.0 - noise
	return noise
end;

function worley_distance(sx,sy,sz,dx,dy,dz)
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

--[[	Overview
	The different components of Worley noise and how they relate to each other: 
]]
--[[	1 • Distance: 
	The choice of distance metric affects how the Voronoi cells are formed and can significantly impact the resulting noise. Distance functions determine how distances between points are calculated. The three most common distance functions used in Worley noise are Euclidean, Manhattan, and Chebyshev distance.
	
		Euclidean calculates the straight-line distance and tends to produce smoother, more rounded cell shapes.
		Manhattan calculates the sum of the absolute differences in x and y coordinates and creates more blocky, square shapes.
		Chebyshev calculates the maximum of the absolute differences in x and y coordinatesand produces cells with diamond shapes.
]]
--[[	2 • Formula: 
	The formula used to combine the cell values can vary depending on the desired result. F numbers correspond to the positions of the n closest points to the sample point. Different combinations of F values can produce different noise patterns. They also perform roles in interpolation and blending while providing the characteristics of types.
]]
--[[	3 • Interpolation: 
	The interpolation method determines how the cell values are blended together to produce a final value at each sample point. There are many different methods of blending between values at different points in space. https://en.wikipedia.org/wiki/Interpolation Among these methods of interpolation are: linear interpolation, polynomial interpolation, and spline interpolation. 
	
	In general the interpolation formula is:

		y- y1 = ((y2 - y1) / (x2 - x1)) * (x2 - x1)

		...where y denotes the linear interpolation value, x denotes the independant variable, x1, y1 represent the value of the function at one point, and x2, y2 represent the value an a referenced point relative to the first.

		linear interpolation: blending based on a linear function between two points. Most common.
			dist = (1 - t) * d1 + t * d2

		cosine interpolation: using a cosine function to blend smoothly between two points.
			dist = (1 - cos(t * pi)) / 2 * d1 + (1 - cos((1 - t) * pi)) / 2 * d2

		cubic interpolation: using a cubic function to blend smoothly and interpolate more precisely between two points. Computationally expensive
			dist = (2 * t^3 - 3 * t^2 + 1) * d1 + (3 * t^2 - 2 * t^3) * d2

		smoothstep interpolation: blending based on a smoothstep function between two points.
			this produces a smoother transition between regions than linear interpolation.
			dist = (3 - 2 * t) * t^2 * d1 + t^2 * (t - 1) * d2

		perlin interpolation: blending based on a perlin noise function between between two points. 
			this produces a more organic-looking pattern than the other methods.
			dist = pxyz * (((1 - (d1 / d2)) * v1) + ((d1 / d2) * v2)) + (1 - pxyz) * v1

		...where d1 is the distance to the first nearest point, d2 is the distance to the second nearest point, etc. t is a parameter between 0 and 1 that determines the weighting of each distance. pi is the mathematical constant pi.
		
	Other methods include: (https://intellipaat.com/blog/what-is-interpolation/)
		
		polynomial interpolation: the prediction of a value at a position between two known data points by locating a polynomial that passes between the data points.

		spline interpolation: the prediction of a value at a position between two known data points by locating a smooth curve that passes between the data points and has continuous derivatives up to a particular order.

		b-spline interpolation: the prediction of a value at a position between two known data points by locating a spline that passes through the data points and is depicted as a linear combination of basis functions.

		multivariate interpolation: the prediction of a value at a location in several dimensions between two known data points. thisincludes bilinear interpolation and bicubic interpolation in two dimensions, and trilinear interpolation in three dimensions.

		radial basis function (RBF) interpolation: the estimateof a value at a point between two known data points by finding a radial basis function that passes through the data points and is represented as a linear combination of basis functions.
]]
--[[	4 • F-type: 
	F1, F2, F3, F4 F-types take a set of distances between a given point and a set of neighboring points, raise them to some power, sum them together, and then divide by the number of distances. The power to which the distances are raised is determined by the F type:
	
		F1: distances are not raised to any power; they are simply summed and then divided by the number of distances.
		F2: distances are squared, then summed, and then divided by the number of distances.
		F3: distances are cubed, then summed, and then divided by the number of distances.
		F4: distances are raised to the fourth power, then summed, and then divided by the number of distance,.etc.

	In general, the F type equation can be written as:

		sum((distance_i)^p) / n

		...where distance_i is the distance from the given point to the i-th neighboring point, p is the power to which the distances are raised and n is the number of neighboring points.

	In a blending role they combine the values of the neighboring points with the interpolated value. In the case of linear interpolation, the equation can be written as:

		(1 - t) * value_i + t * value_j

		...where value_i is the value at the i-th neighboring point, value_j is the value at the j-th neighboring point, and t is a value between 0 and 1 that determines the weighting between the two values. This equation can be used to blend between any two neighboring points, not just for the calculation of distances.

	Use interpolation to blend between the values of neighboring points, and use the F type equation to calculate the contribution of each neighboring point to the final output value of the noise function. These two concepts are separate, but they can be used together to create complex and interesting noise functions.
	
	Pattern Type: There are many recognized forms of Worley noise: They have descriptive names like Cellular, Block, and Chaff and refer to different arrangements of points and different combinations of distance and blending functions. They may also be classed as Patterns of points in space. A cell pattern consists of a regular grid of points. A block pattern consists of points on a regular grid, but shifted so that the points do not align with the cell grid. A chaff pattern consists of randomly placed points.
]]
--[[	5 • Implementation:
	Over all, there are various implementation details that can affect the final output of Worley noise, from the number of points used, to the scaling and offset of the sample points, or the normalization of the output values. Different combinations of these concepts can produce different types of noise patterns. 
	
		Cells from Euclidean distance calculation, linear interpolation and F1 blending.
		Blocks from Manhattan distance calculation, cosine interpolation and F2 blending.
		Chaffs from Chebyshev distance calculation, cubic interpolation and F3 blending.
]]

--[[	In addition:
	• octaves: a key factor in the detail of a noise fractal, each octave has, by default, double the frequency of the previous octave.
	• frequency: the number of periodic cycles per unit length of a coherent-noise, impacting feature scale and repetition.
	• lacunarity: a multiplier that determines how quickly the frequency increases for each successive octave in a noise function.
	• amplitude: the maximum absolute value that a specific coherent-noise function can output (influences lacunarity).
	• persistence: a multiplier that determines how quickly the amplitudes diminish for each successive octave in a noise function.
	• turbulence: summing the absolute value of each octave to force negative values positive, creating creases.
	
	the number of octaves determines how many times to call the noise function. the frequency, starting at the domain scale, sets a scaling value to apply to the coordinate values before each call. in addition to this there can be persistence and lacunarity parameters, determining how the amplitude should diminish and frequency increase as the octaves iterate. persistence (also called gain) is a value in the range (0, 1) that controls how quickly the later octaves "die out". something around 0.5 is pretty conventional. lacunarity is a value greater than 1 that controls how much finer a scale each subsequent octave should use. something around 2.0 is a convention. one smart enhancement is to apply an offset to coordinate values at each octave to decorrelate the layers, so you have recurrentfeatures constructively interfering close to zero.
	
	when summing multiple octaves of the same strength the higher frequencies will dominate the result. the idea of fractal noise is that the amplitude of an octave decreases as its frequency increases. so each time we double the frequency we should also halve the amplitude of the noise. summing multiple octaves produces noise that goes outside the −1 to 1 range. normalize the result by dividing the octave sum by the sum of the amplitudes.
	
	use unique seeds per octave rather than just summing the exact same noise pattern at different scales. a consequence of this is that at the domain origin the pattern appears to collapse into a singularity. visually obvious repetition occurs at different scales, converging at the origin. there is an alternative to simply doubling the frequency between successive octaves.lacunarity is the frequency scaling of the noise. persistence: just like lacunarity can be configurable instead of always being 2, so can the amplitude reduction between octaves be configurable instead of always being 0.5. this factor is known as persistence and controls how quickly the amplitude reduces per octave. Turbulence: A common variant of fractal Perlin noise is to sum the absolute value of each octave. This causes the octaves to bounce where they would pass zero, creating a crease. Layering multiple such octaves produces a result that Ken Perlin described as a turbulent pattern, hence it is commonly known as the turbulence variant of Perlin noise. It can also be applied to value noise, so we will create turbulence variants of both noise types.
	
	modulation is the process by which some characteristic (amplitude, frequency, or phase) of the carrier is changed according to amplitude of the input (baseband signal). in electronics and telecommunications, modulation is the process of varying one or more properties of a periodic waveform, called the carrier signal, with a separate signal called the modulation signal that typically contains information to be transmitted. the lower frequency band occupied by the modulation signal is called the baseband, while the higher frequency band occupied by the modulated carrier is called the passband. amplitude modulation is a technique by which the amplitude of the carrier wave is changed according to the signal wave or modulating signal. frequency modulation is the encoding of information in a carrier wave by varying the instantaneous frequency of the wave. frequency modulation (fm) (here the frequency of the carrier signal is varied in accordance with the instantaneous amplitude of the modulating signal). phase modulation (pm) (here the phase shift of the carrier signal is varied in accordance with the instantaneous amplitude of the modulating signal). transpositional modulation (tm), in which the waveform inflection is modified resulting in a signal where each quarter cycle is transposed in the modulation process. tm is a pseudo-analog modulation (am). where an am carrier also carries a phase variable phase f(ǿ). tm is f(am,ǿ).
	
	 for perlin noise the periods parameter determines the number of waves generated, and increasing the number of periods within the same spatial distance increases the spatial frequency of the wave. the amplitude is a measure of the magnitude or strength of a wave determined by how much a wave changes from zero over a single period. by simply varying the number of periods and the amplitude, a variety of different sine waves can be created (fig. 1a to c), the summation of which produces a sound wave (fig. 1d).
	 
	lacunarity is a measure of how fractal patterns fill space (falconer, 2013), and in the context of perlin noise the lacunarity parameter is a multiplier that determines the rate of change in the number of periods between successive waves. for example, when lacunarity = 2, then the number of periods doubles for each successive wave (fig. 1a to c), or when lacunarity = 4, then the number of periods quadruples for each successive wave. the persistence parameter is a multiplier that determines the rate at which the amplitude decreases between successive waves. for example, when persistence = 0.5, then the amplitude halves for each successive wave (fig. 1a to c), or when persistence = 0.25, then the amplitude quarters for each successive wave.
	
	if the frequency of each sine wave represents the spatial scale of each landscape feature in terms of how often it occurs and the amplitude of each sine wave represents the magnitude of each landscape feature in terms of the size of the effect, then the summation of the sine waves into a sound wave can produce a pattern that can be used as the basis of a neutral landscape model (keitt, 2000). for example, mountain ranges would be a low-frequency, high-amplitude landscape feature as the low frequency means there are few mountain ranges per landscape and the high amplitude that the effect of each mountain range on landscape pattern is large. conversely, the occurrence of a particular tree species could be a high-frequency, low-amplitude landscape feature as the occurrence of the species could be highly variable across a landscape and the presence of the species may have a small effect on the overall landscape pattern.

	what are some good resources for more intricate layered procedural terrain generation, encompassing features like:

		rivers and lakes - not local phenomena contrary to noise, generated very locally. noise functions focus on the immediate location, oblivious to factors beyond that scope. a method for giving a context and seeding influence in the noise algorithm would be required. lakes are local places where water is captured. the water comes from elsewhere transported by rain or rivers, none of which are local phenomena. in many other ways, landscapes are tied to biomes, climate, temperature and percipitation, each with maps of their own that are mutually or collaboratively defined. 
			https://simblob.blogspot.com/2018/09/mapgen4-rainfall.html simulating rainfall
			https://simblob.blogspot.com/2018/10/mapgen4-river-representation.html water flow

		cliffs and overhangs - typical fractal noise can make nice looking height maps it's necessary to move to 3d for cliffs, caves and overhangs. pretend the noise is still a heightmap, and move conceptually to 3d noise... the 3d noise becomes a "changing" heightmap over y. sometimes the value will increase just slightly faster than y will increase, and create an overhang. the higher g is, the more overhangs you'll get, but also the more risk for floating islands. generating tunnel-like caves is trickier. a lot of generators use an iterative algorithm to carve them out in a large area, instead of using noise to generate them. you noise can be used to generate them, but it involves derivatives and crazy math.
		
		procedural terrains have traditionally been limited to height fields that are generated by the cpu and rendered by the gpu. however, the serial processing nature of the cpu is not well suited to generating extremely complex terrains—a highly parallel task. plus, the simple height fields that the cpu can process do not offer interesting terrain features (such as caves or overhangs).
		
		conceptually, the terrain surface can be completely described by a single function, called the density function. for any point in 3d space (x, y, z), the function produces a single floating-point value. these values vary over space—sometimes positive, sometimes negative. if the value is positive, then that point in space is inside the solid terrain.
		
		if the value is negative, then that point is located in empty space (such as air or water). the boundary between positive and negative values—where the density value is zero—is the surface of the terrain. it is along this surface that we wish to construct a polygonal mesh.

		height interpolations - a search brings up some interesting results, but mostly in academic papers that require a deeper understanding to summarize.

		look further: procedural phasor noise, gabor noise


]]

--[[	`k`
	In k-nearest-neighbors (k-NN), k refers to the number of neighboring data points that are used to make a prediction or classification for a new data point.

	The letter k is used to represent the number of neighbors because it is derived from the word "k-nearest" in the phrase "k-nearest neighbors". In other words, k represents the number of data points that are nearest to the new data point.

	The choice of k in k-NN algorithm is crucial since it determines how many neighbors will be used to make the prediction. A smaller value of k may lead to overfitting, while a larger value of k may lead to underfitting. Therefore, the value of k should be chosen carefully based on the characteristics of the dataset and the problem at hand.

	The origin of the variable k in k-nearest-neighbors can be traced back to the literature on computational geometry, which has used k to refer to the number of closest neighbors in various algorithms since the 1970s.

	The term "k-nearest neighbors" was first introduced in the 1960s by E. Fix and J. Hodges in their paper "Discriminatory analysis, nonparametric discrimination: consistency properties". However, they did not use the variable k to represent the number of neighbors; instead, they referred to it as the "number of members of the closest class".

	Later, in the 1970s and 1980s, researchers in computational geometry began using the variable k to represent the number of closest neighbors in algorithms such as k-d trees and k-means clustering. This convention carried over to the k-nearest-neighbors algorithm, which was also named based on the concept of k closest neighbors.

	In summary, the variable k was adopted in k-nearest-neighbors due to its established usage in computational geometry literature to represent the number of closest neighbors in algorithms. It has since become a standard convention in machine learning and data science.
]]

Key points for development:
--[[	First, there are five distance metrics and four formulas that can be used.
		The metrics define how the distance between two points is calculated.
			1 Euclidean, 2 Manhattan, 3 Chebyshev, 4 Minkowski, 5 Quadratic
		The formulas define how many points need to be factored.
			1 first closest, 2 second closest, 3 third closest, 4 fourth closest
	...start with the distance metric and formula and learn how theyaffect the patterns of the noise.
]]
--[[	Second, there are five different interpolation methods that can be used to blend the values of the neighboring points.
		Linear, Cosine, Cubic, Smoothstep, Perlin
	...experiment with the method and see how it modifies the distance values to create smoother or rougher transitions between points.
]]
--[[	Third, there are different combinations of distance metrics and interpolation methods that can be used to create different noise functions. 
	...start combining them in different ways to create new noise patterns. 
]]
--[[	Fourth, there are different blending methods that are more generally used to combine the distances from the closest neighboring points. 
	...the blending function is applied to distances to determine how much weight to give each one in the final output.
	...the interpolation function is used to smoothly blend between two specific points.
]]
--[[	Finally, there are different types of noise functions, based on different combinations of distance metrics, interpolation and blending methods.
	...follow an iterative process of trial and error.
	...experiment with different combinations, tweaking parameters to achieve a desired effect.
]]

--[[	a noise function needs
	specific parameters
		process::pro { metric::m, formula::f, interpolation::in { transition::t { ... }, ease::ez { ... } } }, distance::d
			`m` is a number between 1 and 5 -- user input
			`f` is a number between 1 and 4 or a noise `type` -- user input
				`f` > 4 indexes complex noises derived from combinations of `m` and`f` with more than one distance calculation
			`in` is an array containing:
				`t`, an array of functions to compute a number between 0 and 1 representing the transition (or blend weight) 
					>> determined by `m` and `f` combinations
				`ez`, an array of functions to interpolate the distance
			`d` is a distance resulting from the final calculation
		points::pts { coordinates::x, y, and or z, (and or w),k-nearest-neighbors::k { 1, 2, 3, 4} }
				`x` and `y` are the default sample coordinates, `z` and or `w` are added dimensions
				`k` is a set of four pointers representing distance to the four closest points to those coordinate points
				
	formula
		f[1, 4] or [type]
		
	distance metric
		m[1,5]
		
	interpolation 
		in[ t[ function ...], ez[ function ...] ]

	operations
		select a distance metric and formula
		establish cells and seed points
		find the distances from seed points to each neighboring point
		perform the specific distance calculation for each
		sort the distances to determine the four closest points
		apply the blending function to these distances to determine the weight to give each one in the final output
		use the interpolation function to blend the distances to the neighboring points together
		return the final value at the sample point
]]

--[[	--<!> legacy breakdown
global arrays

worley = {} and worley.pro = { m, f }

< global variables >

prepare()

	< input variables >

	select a distance metric m { m1, m2, m3, m4, m5 } and formula f { f1, f2, f3, f4 }

end

get_sample(x, y)

	< local variables, map inputs>

	< fractal variables > <,> might all move to prepare
		<< octaves, period, frequency, amplitude, lacunarity, gain, threshold, power >> <,> might reference better as array

	initialize z, w if used 
	
	initialize point arrays: points::pts{x, y, z, w, k } --> k_nearest_neighbors::k { k1, k2, k3, k4 } <--> f { f1, f2, f3, f4 }

	generate noise = worley()

	return r, g, b, a

worley_noise(x, y, z, w, < fractal variables >)

	for ... do generate seeds in points

		get_point(dx, dy, dz, dw)

	local <seamless>x, <seamless>y, <seamless>z, <seamless>w = seamless(x, y, z, w)

	local noise = worley_octaves()

	return noise

worley_octaves(x, y, z, w, < fractal variables >)

	for ... do generate octaves

		local noise = get_noise()

	end

	return octaves

	end

	for ... do generate noise

		get_noise(x,y,z)

		get_distance();

	end

	return noise

seamless(x, y, z, w)

get_distance(x, y, z, w) 

	local distance

	compute distances to k

	sort k

	compute blend weights for k

	interpolate distances to k

	return distance

get_point(x, y, z, w)
]]


function worley(x, y, z, w, sx, sy, sz, sw, < fractal variables >)--<!> legacy code; controller will be worley.noise
	-- generates seamless tiling noise applied respective to octave scales and distance mapping
	local sx, sy, sz, sw = seamless(x, y, z, w) --<!> not decided on where this belongs; may move to octaves
	local noise = 0.0
	local amp = 1.0
	for oct = 1,details do
		noise = noise + worley_octaves( wx, wy, wz, sx, sy, sz) * amp
		amp = amp / < fractal variables >
	end
	return noise
end


function worley_octaves(x, y, z, w, sx, sy, sz, sw) --<!> legacy code
	for octave = 1, details do local octaves = worley_noise(x, y, z, w, sx, sy, sz, sw)
		...
		return octaves
	end
end


function worley_noise(x, y, z, w, sx, sy, sz, sw)--<!> legacy code
	--- scaling in 2, 3 or 4 dimensions
	local sx, sy, sz = sx(x), sy(y), sz(z)
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local offset_x, offset_y, offset_z
	local noise = 10000
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				for offset_w=-1,1 do
					local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
					local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
					local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
					local dw = cell_w + offset_w + get_noise(cell_x + offset_x, cell_y + offset_y, cell_w + offset_w)
					-- expanded distances function
					local distance = get_distance( sx, sy, sz,sw, dx, dy, dz, dw)
					noise = math.min(distance, noise)
				end
			end
		end
	end
	noise = 1.0 - noise
	return noise
end


function get_distance(sx, sy, sz, dx, dy, dz, dw)
	-- compute coordinates of the i-th closest point
	local px, py, pz = get_point(dx, dy, dz)

	-- calculate distance using selected metric - formula is still undefined
	local distance
	if distance_type == 1 then
		-- Euclidean distance
		distance = math.sqrt((sx - px)^2 + (sy - py)^2 + (sz - pz)^2 + (sw - pw)^2)
	elseif distance_type == 2 then
		-- Manhattan distance
		distance = math.abs(sx - px) + math.abs(sy - py) + math.abs(sz - pz) + math.abs(sw - pw)
	elseif distance_type == 3 then
		-- Chebyshev distance
		distance = math.max(math.abs(sx - px), math.abs(sy - py), math.abs(sz - pz), math.abs(sw - pw))
	elseif distance_type == 4 then
		-- Minkowski distance
		distance = (math.abs(sx - px)^p + math.abs(sy - py)^p + math.abs(sz - pz)^p + math.abs(sw - pw)^p)^(1/p)
	elseif distance_type == 5 then
		-- Quadratic distance
		distance = ((sx - px)^2 + (sy - py)^2 + (sz - pz)^2 + (sw - pw)^2) / (1 + (sx - px)^2 + (sy - py)^2 + (sz - pz)^2 + (sw - pw)^2)
	end

	-- find the maximum distance among all the computed distances--<!> legacy code
	local max_distance = 0
	for j = 1, num_points do
		local dxj, dyj, dzj, dwj = delta_coord(j, dx, dy, dz, dw)
		local distj = get_distance(sx, sy, sz, sw, dxj, dyj, dzj, dwj, j)
		max_distance = math.max(max_distance, distj)
	end

	-- normalize distance to range 0-1--<!> legacy code
	local norm_distance = distance / max_distance

	return norm_distance
end


function get_point(dx, dy, dz, dw)
	-- compute the coordinates of the point closest to the input coordinates (dx, dy, dz, dw). 
	local px, py, pz, pw
	...
	return px + dx, py + dy, pz + dz, pw + dw
end


--[[	log
To bring you back up to speed:This function calculates the distance between two points in 3D space using different distance formulas based on the distance_type and distance_formula selected. The function takes six parameters, which are the x, y, and z coordinates of the two points being compared.

The distance_type variable selects the type of distance formula to be used, where 1 represents Euclidean distance, 2 represents Manhattan distance, 3 represents Chebyshev distance, and 4 represents Minkowski distance.

The distance_formula variable selects the specific formula to be used for the selected distance_type. For example, if distance_type is 1 and distance_formula is 1, then the Euclidean distance formula is used to calculate the distance between the two points.

The function returns the calculated distance between the two points.

The comments in the code remind me that the conditional block used to select the appropriate distance formula for the given distance_type and distance_formula could be further compressed. I have appended the two main arrays that will eventually control everything that happens in the script. First, I need to have a prototype function that calculates the distance between points based on user input (already handled elsewhere) for distance_type and distance_formula. 

I was asking you to condense the conditional block according to my revision notes (in the comments) and the supporting data structure.

]]--

--[[	function worley_distance(x0, y0, z0, x1, y1, z1) -- <!> prototype - needs k nearest points
	local distance = 0
	-- note: five points are represented, but four are references to known points.
	-- F type corresponds with k nearest points. 
	-- conditional block can be compacted to singular formulas once arrays and their coordination are created. 
	-- (expect x, y, z, f[x], f[y], f[z]) but the latter are also indexed by k-nearest-neighbor so may be more like pts[ x ][ k[f] ]
	if distance_type == 1 then
		-- Euclidean distance formulas
		if distance_formula == 1 then
		distance = math.sqrt((x0 - x1) ^ 2 + (y0 - y1) ^ 2 + (z0 - z1) ^ 2)
		elseif distance_formula == 2 then
		distance = math.sqrt((x0 - x2) ^ 2 + (y0 - y2) ^ 2 + (z0 - z2) ^ 2)
		elseif distance_formula == 3 then
		distance = math.sqrt((x0 - x3) ^ 2 + (y0 - y3) ^ 2 + (z0 - z3) ^ 2)
		elseif distance_formula == 4 then
		distance = math.sqrt((x0 - x4) ^ 2 + (y0 - y4) ^ 2 + (z0 - z4) ^ 2)
		end
	elseif distance_type == 2 then
		-- Manhattan distance formulas
		if distance_formula == 1 then
		distance = math.abs(x0 - x1) + math.abs(y0 - y1) + math.abs(z0 - z1)
		elseif distance_formula == 2 then
		distance = math.abs(x0 - x2) + math.abs(y0 - y2) + math.abs(z0 - z2)
		elseif distance_formula == 3 then
		distance = math.abs(x0 - x3) + math.abs(y0 - y3) + math.abs(z0 - z3)
		elseif distance_formula == 4 then
		distance = math.abs(x0 - x4) + math.abs(y0 - y4) + math.abs(z0 - z4)
		end
	elseif distance_type == 3 then
		-- Chebyshev distance formulas
		if distance_formula == 1 then
		distance = math.max(math.abs(x0), math.abs(y0), math.abs(z0))
		elseif distance_formula == 2 then
		distance = math.max(math.abs(x0 - 1), math.abs(y0 - 1), math.abs(z0 - 1))
		elseif distance_formula == 3 then
		distance = math.max(math.abs(x0 - 2), math.abs(y0 - 2), math.abs(z0 - 2))
		elseif distance_formula == 4 then
		distance = math.max(math.abs(x0 - 3), math.abs(y0 - 3), math.abs(z0 - 3))
		end
	elseif distance_type == 4 then
		-- Minkowski distance formulas (with power variable)
		if distance_formula == 1 then
		distance = math.pow((x0 - x1) ^ pwr + (y0 - y1) ^ pwr + (z0 - z1) ^ pwr, 1 / pwr)
		elseif distance_formula == 2 then
		distance = math.pow((x0 - x2) ^ pwr + (y0 - y2) ^ pwr + (z0 - z2) ^ pwr, 1 / pwr)
		elseif distance_formula == 3 then
		distance = math.pow((x0 - x3) ^ pwr + (y0 - y3) ^ pwr + (z0 - z3) ^ pwr, 1 / pwr)
		elseif distance_formula == 4 then
		distance = math.pow((x0 - x4) ^ pwr + (y0 - y4) ^ pwr + (z0 - z4) ^ pwr, 1 / pwr)
		end
	end
	return distance
end
	distance multi-function, computes a distance based on selected distance_type and distance_formula <!> compress further
	this is more a prototype of the selection conditional than the required model
	
	map of array variables and functions the function compatible must be with:

	specific parameters
		process::pro { metric::m, formula::f, interpolation::in { transition::t { ... }, ease::ez { ... } } }, distance::d
			`m` is a number between 1 and 5 -- user input
			`f` is a number between 1 and 4 or a noise `type` -- user input
				`f` > 4 indexes complex noises derived from combinations of `m` and`f` with more than one distance calculation
			`in` is an array containing:
				`t`, an array of functions to compute a number between 0 and 1 representing the transition (or blend weight) 
					>> determined by `m` and `f` combinations
				`ez`, an array of functions to interpolate the distance
			`d` is a distance resulting from the final calculation
		points::pts { coordinates::x, y, and or z, (and or w),k-nearest-neighbors::k { 1, 2, 3, 4} }
				`x` and `y` are the default sample coordinates, `z` and or `w` are added dimensions
				`k` is a set of four pointers representing distance to the four closest points to those coordinate points
]]--

--[[
]]--