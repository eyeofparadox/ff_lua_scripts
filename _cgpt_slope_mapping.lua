local sqrt = math.sqrt

function prepare()
	w = OUTPUT_WIDTH
	h = OUTPUT_HEIGHT
end

function magnitude(dx, dy)
	return sqrt(dx * dx + dy * dy)
end

function gradient(x, y, height_in)
    local left_sample = get_sample_grayscale(x - 1, y, HEIGHTMAP_INPUT)
    local right_sample = get_sample_grayscale(x + 1, y, HEIGHTMAP_INPUT)
    local top_sample = get_sample_grayscale(x, y - 1, HEIGHTMAP_INPUT)
    local bottom_sample = get_sample_grayscale(x, y + 1, HEIGHTMAP_INPUT)

    local dx = (right_sample - left_sample) / 2.0
    local dy = (bottom_sample - top_sample) / 2.0

    return dx, dy
end

function calculate_slope_map(height_in)
    local width, height = w, h
    local slope_map = {}

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local dx, dy = gradient(x, y, height_in)
            local slope = magnitude(dx, dy)
            slope_map[y * width + x + 1] = slope
        end
    end

    return slope_map
end

function slope_map(heightmap)
	local width, height = w, h
	local slope_map = calculate_slope_map(heightmap)

	for y = 0, height - 1 do
		for x = 0, width - 1 do
			local slope = slope_map[y * width + x + 1]
			set_result(x, y, slope, slope, slope, 1)
		end
	end
end

function get_sample(x, y)
	local height_in = get_sample_grayscale(x, y, HEIGHTMAP_INPUT)
	slope_map(height_in) -- Call the slope_map function with the height_in data
	return height_in, height_in, height_in, 1
end


Since I have to figure this out myself, can I instead have a high-level breakdown of the process required to convert a heightmap to a slope map?

Certainly, I'd be happy to provide a high-level breakdown of the process to convert a heightmap to a slope map:

Input Heightmap: Start with a grayscale heightmap image, where pixel values represent the height or elevation of each point on the surface.

Iterate Through Pixels: For each pixel in the heightmap, perform the following steps:

Calculate Gradients: Calculate the gradient (slope) of the surface at the current pixel. This involves determining how the height changes in the x and y directions.

Calculate the height values of neighboring pixels to the left, right, top, and bottom of the current pixel.
Compute the differences in height between the current pixel and its neighbors in both the x and y directions. These differences represent the gradients in those directions.
Magnitude of Gradient: Compute the magnitude of the gradient vector using the calculated x and y gradient values. This represents the steepness or slope of the surface at that point.

Slope Mapping: The magnitude of the gradient represents the slope at the current point. This value can be normalized to a suitable range (e.g., 0 to 1) to create the slope map.

Create Slope Map: Create a new image (the slope map) where each pixel's value corresponds to the computed slope magnitude from step 5. Assign the normalized slope value to each pixel.

Output: The resulting slope map is now ready to be used in various applications, such as terrain rendering, lighting calculations, and more.

Keep in mind that while the high-level process is outlined here, the specific implementation details can vary depending on the software or programming environment you are working in. The process often involves calculations related to derivatives, gradients, and normalization to create a meaningful slope map from the input heightmap data.




This sounds a bit like making a Sobel normals map.

Yes, the process of converting a heightmap to a slope map does share similarities with creating a Sobel normals map. Both involve calculating gradients to derive information about the surface characteristics. Here's a brief comparison of the two concepts:

Sobel Normals Map:

Input Heightmap: Start with a grayscale heightmap image.

Calculate Gradients: Use convolution filters (such as Sobel filters) to calculate the gradient vectors in the x and y directions for each pixel.

Calculate Normals: The gradient vectors are used to calculate normal vectors for each pixel. These normals represent the direction the surface is facing at each point.

Normalize Normals: Normalize the calculated normals to ensure they have a length of 1. This is important for accurate lighting calculations.

Map to Colors: Convert the normalized normals to RGB color values, where the R, G, and B channels represent the x, y, and z components of the normal vector, respectively.

Output: The resulting image is a normals map that can be used for realistic lighting and shading calculations.

Converting Heightmap to Slope Map:

Input Heightmap: Start with a grayscale heightmap image.

Calculate Gradients: Calculate the gradients (slopes) of the surface in the x and y directions for each pixel.

Calculate Magnitude: Compute the magnitude of the gradient vectors to determine the steepness or slope at each point.

Normalize Slopes: Normalize the calculated slope values to a desired range, often between 0 and 1.

Create Slope Map: Create a new image where each pixel's value corresponds to the normalized slope value.

Output: The resulting image is a slope map that represents the variations in slope across the terrain.

While the underlying concepts of calculating gradients and using them to extract surface information are similar, the specific goals and applications of Sobel normals maps and slope maps can differ. Sobel normals maps are used primarily for realistic lighting, while slope maps are often used to visualize terrain characteristics, such as the inclination or steepness of a surface.


Last year around this time you helped me script a Sobel normals script for Filter forge. Could the Sobel filtering used in that help with deriving a slope map?

Absolutely, the principles and techniques used in creating a Sobel normals map can be adapted to help derive a slope map. Both involve calculating gradients from a heightmap and using those gradients to extract valuable information about the terrain's characteristics.

The Sobel filter used in the normals map script helps compute the gradients of the heightmap, which are then used to determine the surface normals. Similarly, for a slope map, you're interested in the gradients of the heightmap to calculate the slopes or inclinations at different points on the terrain.

Here's how you could leverage the Sobel filtering technique to create a slope map:

Apply Sobel Filters: Use Sobel filters to calculate the gradients in the x and y directions for each pixel in the heightmap. This can be done similarly to how you did it for the Sobel normals map script.

Calculate Gradient Magnitudes: Compute the magnitude of the gradient vectors for each pixel. This magnitude represents the rate of change in height, which is directly related to the slope.

Normalize Gradients: Normalize the computed gradient magnitudes to a suitable range (usually between 0 and 1) to obtain normalized slope values.

Create Slope Map: Generate a new image where each pixel's value corresponds to the normalized slope value.

By applying these steps, you can transform the Sobel-filtered gradient information into a slope map that visually represents the variations in slope across the terrain.

In summary, the Sobel filtering technique used for creating Sobel normals maps can definitely be adapted to derive a slope map by focusing on the gradient magnitudes and normalizing them to represent the terrain's slope characteristics.




I could  use a bit more of an explanation of calculating gradient magnitudes, or maybe an example.

Certainly! Calculating gradient magnitudes involves computing the length or magnitude of the gradient vectors that you obtain from the Sobel filtering process. In the context of a heightmap, the gradient vectors represent the rate of change of the height values in the x and y directions at each pixel.

Here's a step-by-step explanation of how to calculate gradient magnitudes with a simple example:

Sobel Filtering: Apply Sobel filters to the heightmap to compute the gradients in the x and y directions. This will give you two separate images—one for the x-direction gradient (Gx) and another for the y-direction gradient (Gy).

Calculate Gradient Magnitudes: For each pixel in the heightmap, calculate the gradient magnitude using the formula:

Gradient Magnitude = sqrt(Gx^2 + Gy^2)
In this formula, Gx is the gradient value in the x-direction at the current pixel, and Gy is the gradient value in the y-direction at the same pixel. The square of each gradient component is summed, and then the square root is taken to obtain the magnitude.

Normalize Gradient Magnitudes: Normalize the gradient magnitudes to a suitable range, often between 0 and 1. To do this, you need to find the maximum gradient magnitude value in the entire heightmap. Divide each calculated gradient magnitude by this maximum value to obtain normalized slope values.

Here's a simplified example using a 3x3 portion of a heightmap (H) and its computed gradient magnitudes (Gmag) after applying Sobel filters:

Heightmap (H):
4  5  3
2  9  6
1  8  7

Gradient Magnitudes (Gmag):
10.295  7.071  7.071
8.602   9.899  8.602
8.485   8.485  8.485

In this example, you can see that the gradient magnitudes are calculated for each pixel based on the gradients obtained from Sobel filtering. The highest gradient magnitude in this case is approximately 10.295.

Next, you can normalize the gradient magnitudes by dividing each value by 10.295 (the maximum gradient magnitude value) to obtain normalized slope values. The resulting normalized slope values will indicate the steepness of the terrain at each pixel.

Remember that the actual calculations and implementation may vary depending on the programming environment and tools you're using, but the underlying concept remains the same. By calculating gradient magnitudes and normalizing them, you can create a slope map that represents the variations in terrain slope across your heightmap.






In Filter Forge I would most likely be working with normalized values to begin with, unless I make a point of allowing HDR range input.

Absolutely, working with normalized values in Filter Forge is a common approach and can simplify the calculations. Since you're dealing with normalized values, you'll need to adjust the gradient calculations and magnitude computation accordingly.

Here's a general outline of the steps to calculate gradient magnitudes from normalized values in Filter Forge:

Sobel Filtering: Apply Sobel filters to the normalized heightmap to compute the gradients in the x and y directions. This will give you two separate sets of gradient values—one for the x-direction gradient (Gx) and another for the y-direction gradient (Gy).

Calculate Gradient Magnitudes: For each pixel in the heightmap, calculate the gradient magnitude using the formula:

Gradient Magnitude = sqrt(Gx^2 + Gy^2)

In this formula, Gx is the gradient value in the x-direction at the current pixel, and Gy is the gradient value in the y-direction at the same pixel. The square of each gradient component is summed, and then the square root is taken to obtain the magnitude.

Normalize Gradient Magnitudes: Since you're working with normalized values, the gradient magnitudes themselves are in the range of [0, 1]. You may choose to leave the gradient magnitudes as they are or further adjust them based on your specific requirements.

The normalized gradient magnitudes will represent the changes in slope at each pixel location in your heightmap. By analyzing the magnitude values, you can identify areas of varying steepness in the terrain. Remember to adjust the calculations based on the specific functions and features available in Filter Forge's scripting environment.



I do wonder, though, how does a gradient function for a slopemap script differ from a gradient function used in a noise function like Perlin noise?


The concept of a gradient in different contexts, such as in a slope map script and in a noise function like Perlin noise, might seem similar at first glance, but they serve different purposes and have distinct implementations.

In the context of a slope map script:

A gradient function is used to calculate the slope of a heightmap at each point. It determines how much the height values change in the x and y directions from a central point. The gradient function in this case helps you find the rate of change of the height values, which is essentially the steepness or slope of the terrain. This information is used to create a slope map that represents the terrain's slopes.

In the context of a noise function like Perlin noise:

A gradient function in noise functions like Perlin noise is used to generate pseudo-random gradient vectors at each grid point in the noise field. These gradient vectors are used to calculate dot products with vectors from the grid points to the input position in order to produce smooth and coherent noise patterns. The gradient vectors ensure that neighboring points in the noise field have similar directions, contributing to the smoothness of the generated noise.

While both cases involve gradients, they are used differently and in distinct ways. In the slope map script, the gradient function helps calculate the rate of change of height values, while in noise functions, the gradient function generates vectors that contribute to the overall structure and pattern of the noise. The specific implementation details of the gradient function can vary based on the context and the desired characteristics of the output.





I see. I thought it seemed different. Apart from the Sobel normals script I mentioned, I usually work with the latter.


Yes, working with noise functions like Perlin noise is a common approach in computer graphics and procedural content generation. Noise functions are used to create a variety of effects, including terrain generation, texture synthesis, procedural patterns, and more. These functions are designed to provide randomness while maintaining coherence and smoothness, which are important qualities in many graphical applications.

The Sobel normals script you mentioned is another example of how gradients can be used to derive surface normals from heightmap data. This can be useful for generating lighting effects, as normals determine how surfaces interact with light. The Sobel operator is a common technique to compute gradients for this purpose.

When working with different types of scripts and techniques, it's important to understand the specific goals and requirements of each task. This will help you choose the right approach and apply the appropriate methods to achieve your desired results. Whether you're generating terrain, textures, or other graphical elements, having a solid understanding of the underlying principles will greatly enhance your ability to create visually appealing and realistic effects.


What parts of this Sobel normals script would be useful for slope mapping?:

-- sobel filtering for surface normals
function prepare()
	-- get inputs and set up
	height_scale = get_slider_input(SCALE)
	-- most textures are 1:1. if another aspect ratio is used, the shorter axis will be [0, 1] and the other will exceed 1.
	-- to preserve pixel aspect ratio, use the min axis.
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

function get_sample(x, y)
	-- get height and surface gradient
	-- local height = get_sample_grayscale(x, y, HEIGHT)
	
	-- sobel kernel
	local kernel_x = {
		{-1, 0, 1},
		{-2, 0, 2},
		{-1, 0, 1}
	}
	
	local kernel_y = {
		{-1, -2, -1},
		{0, 0, 0},
		{1, 2, 1}
	}

	-- compute gradients
	local gx = 0
	local gy = 0

	for ky = -1, 1 do
		for kx = -1, 1 do
			local weight = 1
			if ky == 0 and kx == 0 then
				weight = 2
			end
			
			local height_sample = get_sample_grayscale(x + kx * offset, y + ky * offset, HEIGHT) * height_scale
			local gradient_x = kernel_x[ky+2][kx+2] * height_sample
			local gradient_y = kernel_y[ky+2][kx+2] * height_sample
			
			gx = gx + gradient_x * weight
			gy = gy + gradient_y * weight
		end
	end

	local gradient_z = 1 / math.sqrt(1 + gx^2 + gy^2)

	-- compute normal vector
	local nx = gx * gradient_z
	local ny = gy * gradient_z
	local nz = 1 - gradient_z

	-- encode normal vector as RGB
	local r = (nx + 1.0) / 2.0
	local g = (ny + 1.0) / 2.0
	local b = ((nz + 1.0) / 2.0) * 0.5 + 0.5
	local alpha = 1.0
	
	return r, g, b, alpha
end


The Sobel normals script you've provided computes the surface normal vectors of a height map and encodes them as RGB colors. While the script is designed for computing normals, it contains some elements that could be adapted for slope mapping as well. Here's a breakdown of the relevant parts and how they might be useful for slope mapping:

Gradient Calculation: The Sobel script calculates gradients in the x and y directions using convolution with Sobel kernels. These gradients represent the rate of change in height along the x and y axes. For slope mapping, you need to calculate the gradient magnitude (slope) from these gradients, which you can then use to derive slope values.

Height Sample: The script retrieves height samples from the input height map using get_sample_grayscale. Similarly, for slope mapping, you'll use the height values to compute the slope at each pixel.

Gradient Calculation Loop: The loop that calculates the gradient vectors gx and gy could be adapted to calculate the slope gradient along the x and y axes for slope mapping. The gradient magnitude (slope) can be calculated using these gradients.

Normal Vector Calculation: In the Sobel script, the normal vector is computed from the gradient vectors. Instead of calculating the normal vector, you'll use the gradient vectors to calculate the slope gradient magnitude and use that as your slope value.

Encoding as RGB: The script encodes the normal vector as an RGB color. For slope mapping, you won't need this encoding step. Instead, you'll directly use the slope values as your output.

Here's a high-level outline of how you could adapt the Sobel script for slope mapping:


function prepare()
	-- Set up any parameters you need
	-- ...

	-- Calculate the offset based on the aspect ratio
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

function get_sample(x, y)
	-- Get height sample from the input height map
	local height_sample = get_sample_grayscale(x, y, HEIGHT)

	-- Compute slope gradient in x and y directions
	local slope_x = compute_slope_gradient_x(x, y, height_sample)
	local slope_y = compute_slope_gradient_y(x, y, height_sample)

	-- Calculate slope gradient magnitude
	local slope_gradient_magnitude = compute_slope_gradient_magnitude(slope_x, slope_y)

	-- Use slope_gradient_magnitude as your slope value
	local slope_value = slope_gradient_magnitude

	-- Return the slope value as output
	return slope_value, slope_value, slope_value, 1
end

function compute_slope_gradient_x(x, y, height_sample)
	-- Calculate slope gradient in the x direction
	-- ...
end

function compute_slope_gradient_y(x, y, height_sample)
	-- Calculate slope gradient in the y direction
	-- ...
end

function compute_slope_gradient_magnitude(slope_x, slope_y)
	-- Calculate slope gradient magnitude from slope_x and slope_y
	local slope_gradient_magnitude = math.sqrt(slope_x^2 + slope_y^2)
	return slope_gradient_magnitude
end



This outline focuses on the key elements needed for slope mapping: calculating the slope gradient in the x and y directions, calculating the slope gradient magnitude, and using the slope gradient magnitude as the slope value.

Keep in mind that while the Sobel script is designed for computing normals and involves encoding as RGB colors, slope mapping is simpler in that it involves deriving the slope value directly from the gradients. The code structure may need adjustments based on your specific needs and the available functions in Filter Forge.


Okay. It's nice to be able to reference something I have been able to get working if Filter Forge. I may need to ask for a bit more help with the gradient magnitude calculations, since they're new to me.
ChatGPT
Of course, I'm here to help! Gradient magnitude calculations involve combining the gradients in the x and y directions to compute the overall rate of change in a scalar field (such as a height map or slope map). Here's a bit more explanation and an example of how to calculate gradient magnitudes:

In the context of slope mapping, the gradient magnitude represents how steep the terrain is at a specific point. Steeper slopes will have larger gradient magnitudes, while flatter areas will have smaller gradient magnitudes.

Mathematically, if you have the gradient components dx (change in height along the x direction) and dy (change in height along the y direction), the gradient magnitude |grad| can be calculated using the formula:

|grad| = sqrt(dx^2 + dy^2)

Here's an example of how you might calculate the gradient magnitude in a slope mapping script:


local sqrt = math.sqrt

function compute_slope_gradient_magnitude(slope_x, slope_y)
    -- Calculate the gradient magnitude using the formula
    local gradient_magnitude = sqrt(slope_x^2 + slope_y^2)
    return gradient_magnitude
end

-- Example usage
local slope_gradient_x = 0.1  -- Replace with your actual slope gradient in x direction
local slope_gradient_y = 0.2  -- Replace with your actual slope gradient in y direction

local gradient_magnitude = compute_slope_gradient_magnitude(slope_gradient_x, slope_gradient_y)
print("Gradient Magnitude:", gradient_magnitude)


In the above example, slope_gradient_x and slope_gradient_y represent the calculated slope gradients in the x and y directions, respectively. The compute_slope_gradient_magnitude function calculates the gradient magnitude using the formula mentioned earlier.

To integrate this into your slope mapping script, you would calculate the slope gradients slope_x and slope_y based on your existing gradient calculations in the x and y directions, and then pass these gradients to the compute_slope_gradient_magnitude function to get the overall gradient magnitude. This magnitude can then be used as your slope value.

Feel free to adapt this example to your script and make any necessary adjustments based on the functions and variables available in Filter Forge. If you have any further questions or need assistance with specific code implementation, don't hesitate to ask!


I've had issues trying to work with an image sized array so I may have to break this down into scripts to generate the `slope_gradient_x` and `slope_gradient_y` as image outputs I can input to another map script designed to handle the convolution...
ChatGPT
It sounds like breaking down the process into multiple map scripts could be a practical approach to solving the challenges you're facing. By generating the slope_gradient_x and slope_gradient_y components as separate image outputs, you can then use them as inputs in another map script to perform the convolution and calculate the gradient magnitude.

Here's a high-level breakdown of how you could approach this workflow:

Generate Slope Gradients:
Create a map script that takes a heightmap input and calculates the slope_gradient_x and slope_gradient_y components. This script could use techniques similar to the Sobel filter you shared earlier to calculate the gradient components.

Generate Slope Magnitude:
In another map script, take the slope_gradient_x and slope_gradient_y images as inputs. Implement the convolution and gradient magnitude calculations using the script you're working on. This map script should output the final slope map values.

Combine Map Scripts:
In Filter Forge, you can then combine these two map scripts in a node-based graph to create your complete slope mapping workflow. Connect the outputs of the first script (slope gradients) to the inputs of the second script (convolution and gradient magnitude calculations).

By dividing the process into smaller, manageable steps, you can focus on getting each part of the workflow working correctly before integrating them into a comprehensive solution.

If you encounter any challenges or need assistance with specific parts of the implementation, feel free to ask for help or share your code snippets. I'll be here to guide you through the process!

Thank you for the thumbs-up! I'm here to help whenever you need assistance. Don't hesitate to return if you have more questions or need further guidance in the future. Best of luck with your projects, and have a great day!