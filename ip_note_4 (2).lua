-- <?> 3.15.2023»01:57

function prepare() -- polar perlin noise loops
	angle = math.rad(get_angle_input(ANGLE))
	radius = get_slider_input(RADIUS) -- remap o, 1 >> n, 2 * n for r <?> may only apply in Processing
end;

function get_sample(x, y)
	a, r = angle, radius
		x_off, y_off = cos(a) +1, sin(a) +1
		x, y = r * cos(a), r * sin(a)
		v = get_sample_grayscale(x, y, SOURCE)
	-- for i = 0, 1 do -- <?> may only apply in Processing
	-- end
	return v, v, v, 1 -- r,g,b,a
end;
--[[
	picked up from coding train in search of reference to making noise periodic for seamlessness
	-- a, r = angle, radius
		-- x_off, y_off = cos(a) +1, sin(a) +1
		-- x, y = r * cos(a), r * sin(a)
	example shows coordinate looping in the plane x, y so it's a z-loop example. need to adapt for x- and y-loops through z space.
	x = y, z remapping (need to determine which is sin, cos)
	y = z, x remapping (need to determine which is sin, cos)
]]
--[[	full note:
The other day, I picked up this method of looping an axis of noise through a higher dimension. It is a one-dimensional example from coding train that came up in a search for useful reference for making noise periodic for seamlessness:
	-- a, r = angle, radius
		-- x_off, y_off = cos(a) +1, sin(a) +1
		-- x, y = r * cos(a), r * sin(a)
	The example shows coordinate looping in the plane x, y so it's a z-loop example. I wondered if it would be feasible to adapt it for x- and y-loops through z space in this manner:
	x_loop = y, z remapping (need to determine which is sin, cos)
	y_loop = z, x remapping (need to determine which is sin, cos)	
	]]
--[[	discussion
Yes, it's definitely possible to adapt the method you described to loop noise through higher dimensions. The basic idea is to use trigonometric functions to transform the coordinates of the noise in a way that creates a looping effect.

For example, to loop the noise through the x-axis, you could use the cosine function to transform the y and z coordinates, and keep the x coordinate unchanged:

	x_loop = noise(x, y + amplitude * math.cos(x * frequency), z + amplitude * math.cos(x * frequency))

This would create a looping effect along the x-axis, with the noise repeating itself periodically in the y and z directions.

Similarly, to loop the noise through the y-axis, you could use the sine function to transform the z and x coordinates, and keep the y coordinate unchanged:

	y_loop = noise(x + amplitude * math.sin(y * frequency), y, z + amplitude * math.sin(y * frequency))

This would create a looping effect along the y-axis, with the noise repeating itself periodically in the z and x directions.

Of course, the specific trigonometric functions and coordinate transformations you use will depend on the particular looping effect you want to achieve. But the basic idea is to use trigonometric functions to "bend" the coordinates of the noise in a way that creates a looping effect.

•• Well, the idea is to use it for seamless tiling in Perlin or Worley noise. This 3d notion is one I came up with and have not tested out. Usually, 4d space is what people tend to use for 2d seamless noise.
I see. If you want to use this method for seamless tiling of 2D noise, then you could use a similar approach as in the Coding Train example but in 2D space. To loop the x-axis, you would need to use the y and z coordinates to calculate the x-coordinate for each point, and similarly for looping the y-axis, you would need to use the z and x coordinates to calculate the y-coordinate for each point.

For example, to loop the x-axis through y and z space, you could use the following equations:

	x = r * cos(y + z)
	y = y
	z = z

And to loop the y-axis through z and x space, you could use:

	x = x
	y = r * cos(z + x)
	z = z

Note that in both cases, the radius r determines the scale of the noise, and the values of y and z are used to loop the x and y axes, respectively.

However, it's worth noting that this approach may not work well with all types of noise, and it may require some experimentation and tweaking to get the desired results. Additionally, there are other approaches to seamless tiling of noise, such as using seamless noise algorithms or using multiple octaves with different frequencies and amplitudes to create a more complex and varied pattern.

There are several seamless noise algorithms that are commonly used in computer graphics and game development. Here are a few examples:

Perlin Noise with Seamless Tiling: Perlin noise is a popular algorithm used for generating procedural textures and terrain. It is possible to tile Perlin noise seamlessly by using a technique called domain repetition. The idea is to take the original noise function and tile it repeatedly in all directions. To ensure that the transition between the tiles is seamless, the noise function is modified so that it fades to zero at the edges of each tile. This technique can be used to create an infinite landscape or a repeating texture.

Simplex Noise: Simplex noise uses a higher-dimensional lattice structure to generate smoother and more natural-looking noise. Simplex noise is faster and requires less memory than Perlin noise, making it a popular choice for real-time applications.

Worley Noise: Worley noise, also known as cellular noise, is a type of noise algorithm that simulates a pattern of Voronoi cells. Each cell is defined by a point in space, and the value of the noise function at any given point is determined by the distance to the nearest cell. Worley noise can be used to generate complex textures and patterns, and it is also useful for creating natural-looking terrain.

Fractal Brownian Motion: Fractal Brownian Motion (FBM) is a technique used to generate complex and realistic textures by combining multiple layers of noise. Each layer is scaled and offset to create a different frequency of noise, and the results are combined to create a more detailed and varied texture. FBM can be used to create natural-looking terrain, clouds, and other organic shapes.

These are just a few examples of the many different noise algorithms that are available. Each algorithm has its strengths and weaknesses, and the choice of algorithm depends on the specific application and the desired result.

•• I've worked with all of those and they don't tile seamlessly, with the partial exception of domain repetition, which sort-of works but has issues. As for higher dimensionality, that's possible with any noise if you code it yourself and work in the desired number of dimensions. But, that method of generating truly seamless tiling by looping through higher dimensions can double the workload. The examples I know of require 4d to do 2d noise and 6d to do 3d noise.

Traditional noise algorithms do not produce seamless tiling. Looping through higher dimensions is indeed one method to achieve seamless tiling, and it is often used in practice. Working in higher dimensions can quickly become computationally expensive, however, so it's better to use the fewest number of dimensions necessary to achieve the desired effect.

Another method that has gained popularity in recent years is called "gradient domain noise" or "seamless noise." This technique works by constructing gradients in a way that ensures they match up seamlessly across the edges of the domain. The gradients are then used to generate noise in the usual way, but the resulting noise pattern will tile seamlessly.

There are several implementations of gradient domain noise available, including Simplex Gradient Domain Noise and OpenSimplex Gradient Domain Noise. These implementations use simplex noise and OpenSimplex noise as the underlying noise functions, respectively, but modify the gradients to achieve seamless tiling.

In addition to looping and gradient domain noise, there are other methods for generating seamless noise, such as using Voronoi diagrams or combining multiple noise functions in various ways. However, these methods can be more complex to implement and may not always produce the desired results.

•• I actually thought of something like gradient domain noise, but I forgot to ask you about it. I had wondered if you could make 2d noise tile seamlessly by making gradient or distance calculations look at samples at the relative terminals of a given axis. Is that the method used in gradient domain noise?

Yes, that's correct! In gradient domain noise, the gradients are calculated by sampling the noise at four corners of a square, and the resulting gradient vectors are used to interpolate the noise values between those corners. By doing this, the resulting noise is continuous and tileable, which makes it ideal for use in seamless textures and patterns.

The key difference between gradient domain noise and other types of noise is that it operates in the gradient domain rather than the value domain. This means that instead of directly calculating the noise values at each point, it calculates the gradients between neighboring points and uses those to interpolate the noise values. This results in a smoother, more continuous noise pattern that can be tiled seamlessly.
]]




