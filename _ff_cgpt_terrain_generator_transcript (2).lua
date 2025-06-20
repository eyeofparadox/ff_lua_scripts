
•• My current project is the creation of a filter in Filter Forge that generates Earth-like worlds. It will use a Map Script (and thus, Lua) to generate an equitorial mapped terrain with features like mountain ranges, deserts, hills, valleys, plains, lakes, rivers and ocean beds. A separate method will add oceans, snow packs and ice caps. 

•• I wanted to ask if there is a fractal (besides fractal noise) that closely resembles mountain ranges? 

Yes, there are several fractals that can resemble mountain ranges. One of the most well-known fractals that is often used to generate mountain-like structures is the so-called "Diamond-Square" algorithm, also known as the "Midpoint Displacement" algorithm. This algorithm is commonly used in computer graphics to generate realistic terrain heightmaps.

Another fractal that can be used to create mountain-like structures is the "Brownian Motion" fractal. This fractal is created by adding up multiple layers of noise, each with a higher frequency and lower amplitude than the previous layer. The resulting fractal has a self-similar appearance, and can be used to generate complex and irregular terrain features.

Other fractals that can resemble mountain ranges include the "Mandelbrot Set," which can create a range of complex and highly-detailed shapes that resemble mountainous terrain, and the "Fractal Landscape" algorithm, which is a more complex fractal that can generate detailed landscapes with a range of features such as hills, valleys, and mountain ranges.

•• The "Fractal Landscape" algorithm, sounds like a good place to start. I was hoping to create a Filter Forge map script that could generate a more complex fractal that can generate detailed landscapes with a range of features such as hills, valleys, and mountain ranges. One feature I'd like, if possible, is the ability to map the output in an equirectangular projection (polar to cartesian remapping). I know that noise generators can use the z axis and avoid "mirroring" artifacts that can occur from polar-to-cartesian remapping of normal x, y images.

Fractal Landscape algorithms can certainly generate complex and varied terrain, including mountain ranges. There are also many variations and improvements on the basic algorithm that have been developed over the years. One approach is to use a hybrid algorithm that combines a fractal terrain generator with additional layers of detail, such as erosion and vegetation.

Regarding the equirectangular projection, it is possible to apply a polar-to-cartesian remapping to the output of a fractal landscape generator, but care must be taken to avoid artifacts and distortions. One common approach is to use a noise function that generates values in 3D space, rather than in 2D space. This can help to avoid the "mirroring" artifacts that can occur when remapping a 2D image. Another approach is to use a specialized projection, such as the Hammer projection, which can provide more accurate results for spherical surfaces.

•• Adding up several octaves of the same noise function is known as Fractional Brownian Motion (FBM). This provides a way of generating fractal-like images that look cool when interpreted as a height map. The noise function used influences the character of the resulting fractal noise. (Uses scale or width, height, frequency, amplitude, octaves, lacunarity, gain, and seed). Enhancements include: Introducing a signed distance field to generate an interesting height map; an island or hero mountain. The idea is to specify one or more seed points from which the noise can "grow". 

•• Dendritic fractals may result from some implementations of the "Brownian Motion" fractal, used by some to create mountain-like structures. May be limited to Diffusion Limited Aggregation (DLA). In this model, we begin with a particle (or "seed") at the center of a disk. At the boundary of the disk, a particle is released to begin a random walk. It is not allowed to exit the disk and will eventually hit the seed in the middle. At the point of contact, it sticks. We then release another particle at the boundary and it finds its own random path to join the growing cluster. This is repeated again...and again. As particles build up, moving randomly and sticking to one another in an aggregative process, branchinf fractals can emerge. Because of the lax rules governing the random nature of the particle's placement and motion, no two resulting trees are really expected to be the same, or even necessarily have the same general shape.

	{ x_n + 1 = x^2_n − y2_n + α; y_n + 1 = 2x_n * y_n + β, z_n = xn+y_n^i	C.

	Consider ﬁrst the case where c=i. For this value, the Julia set obtained is known as a dendrite, which are Julia sets with no interior that display a tree-like branching structure. In order to reveal this structure we compute DLDs using p= 1/64 for N= 200 iterations.The output of the method is shown in Fig. 1, where the scalar ﬁeld depicted in A) nicely captures the fractal set. One of the most important features of DLDs is that one can extract the key dynamical features present in the phase space of the map from the ridges of thegradient ||∇D+p||. This is so, because in Lopesino et al. (2015b) it was mathematically proven that when DLDs are applied in forward time, the stable manifolds are revealed at points where the function is non-diﬀerentiable, and this implies that the gradient becomes discontinuous or unbounded. Following this approach, we calculate in Fig. 1B) the points where the gradient attains very large values, and this procedure gives us, not only the Julia set corresponding to the dendrite, but also the equipotential lines and external rays of the complex mapping.
	
	García Garrido, Víctor. (2020). Unveiling the Fractal Structure of Julia Sets with Lagrangian Descriptors. 
	https://www.researchgate.net/publication/338832557_Unveiling_the_Fractal_Structure_of_Julia_Sets_with_Lagrangian_Descriptors


•• Mathematical modeling and generation methods of treelike structures including Diffusion Limited Aggregation, L-systems as well as heuristics dedicated to certain issues. In a number of cases, a treelike structure generalization method is based on a recurrent algorithm. Structures generated according to this approach usually show fractal features.

	Dendry, a procedural function that generates dendritic patterns and is locally computable. The function is controlled by parameters such as the level of branching, the degree of local smoothing, random seeding and local disturbance parameters, and the range of the branching angles. It is also controlled by a global control function that defines the overall shape and can be used, for example, to initialize local minima. The algorithm returns the distance to a tree structure which is implicitly constructed on the fly, while requiring a small memory footprint. The evaluation can be performed in parallel for multiple points and scales linearly with the number of cores. We demonstrate an application of our model to the generation of terrain heighfields with consistent river networks. A quad core implementation of our algorithm takes about ten seconds for a 512 × 512 resolution grid on the CPU.

	Dendry: A Procedural Model for Dendritic Patterns
	Mathieu Gaillard, Bedrich Benes, Eric Guérin, Eric Galin, Damien Rohmer, and Marie-Paule Cani. 2019. Dendry: a procedural model for dendritic patterns. In Proceedings of the ACM SIGGRAPH Symposium on Interactive 3D Graphics and Games (I3D '19). Association for Computing Machinery, New York, NY, USA, Article 16, 1–9. 
	https://doi.org/10.1145/3306131.3317020; 	https://dl.acm.org/doi/pdf/10.1145/3306131.3317020

Yes, that is correct. L-systems are another popular method for generating tree-like structures and other natural patterns, and they can be used to create fractals as well. L-systems are a type of formal grammar that uses simple rules to produce complex patterns. They were originally developed to model the growth of plants and algae, but they have since been used to create a wide variety of natural and artificial shapes.

One advantage of L-systems is that they can produce highly detailed and realistic-looking patterns, with a level of complexity that can be adjusted by changing the rules and parameters of the system. Another advantage is that they can be used to create 3D models as well as 2D images, which makes them well-suited for creating landscapes and other natural environments.

There are many different software tools and libraries available for generating L-systems and other fractals, so you may want to explore some of these options to see which one best fits your needs. Some popular options include Fractint, Mandelbulber, and XaoS.


•• The terrain generator has the following requirements:

1
	compatible with the sample based architecture with minimal use of arrays (I'd prefer not to slow it down with a massive table).
2
	exploits fractal algorithms to produce dendritic features at appropriate scales for mountains, hills and broader plains.
3
	a hybrid algorithm that combines a fractal terrain generator with additional layers of detail, such as erosion and vegetation would be ideal. however, an erosion process would be difficult to implement well in Filter Forge. If the dendritic structure is generated, a minor amount of erosion could be considered.
	
	erosion
		a function for the basic erosion process.
		takes height, normal and or flow maps as inputs. the height will be eroded. the normal map can define surface details like bumps or roughness, while the flow map can be used to control the direction of movement or interpret the flow of the terrain. 
4
	the generator ought to be 3d, so that it can map properly to an equitorial projection. it would be worth-while at this stage to get more info on the Hammer projection, which can provide more accurate results for spherical surfaces.
5
	some hybrid of fractals and noise will likely be blended in octaves of fractal noise. I have to work out how the two types would be blended together in the same process or function.
6
	there is also a method of using signed distance fields or input gradients to seed terrain features. I don't know if that should be addressed in the generator functions or the blending function. either way, I'd like to implement one or both if I can. I had the idea that vector input from a normal or flow map might play a role in that. such inputs might support a modified diffusion limited aggregation by defining seed and boundry conditions at high and low values, respectively. that is merely an option to examine; "random walk" processes are non-deterministic, making repeatable results impossible.
7
	it's also a good idea for me to get an overview of L-systems that includes how they could be implemented to generate terrain. I don't know much about them. for the same reason, I need an overview like that for Dendry, too.

So, let's go over those points. It may be necessary to deal with each point one-at-a-time. I'll refresh your memory with each post, and only ask for a response to a specific point (by number) if your reply gets cut off.

•• let's look at number 1:

Sure, let's take a look at requirement number 1:

"Compatible with the sample-based architecture with minimal use of arrays (I'd prefer not to slow it down with a massive table)."

It sounds like you're looking for a solution that is efficient and doesn't use a lot of memory. One option to consider is to use a procedural generation technique, where you generate the terrain on the fly rather than storing it in memory.

Another approach would be to use a compact data structure that can represent the terrain efficiently. For example, you could use a quadtree to store terrain data at different levels of detail, or you could use a run-length encoding scheme to compress the terrain data.

It's also important to consider how the terrain will be rendered. If you're using a sample-based architecture, you'll likely be rendering the terrain using some form of texture mapping. In that case, you may want to consider using a tile-based approach, where you generate textures on-the-fly for each tile of terrain as it is rendered. This can help reduce memory usage and improve performance.

Let me know if you have any questions about this requirement.

•• In Filter Forge, I only need to worry about the current image tile.

I see. In that case, you can limit the use of arrays to a minimum to avoid slowing down the filter. One possible approach is to process the image tile row by row, which allows you to keep only one row of pixels in memory at a time. You can use loops to iterate through each pixel in the row and apply the necessary transformations and filters.

Alternatively, you can use functions that operate on individual pixels, rather than arrays or tables. This approach may be slower, but it reduces the memory requirements of the filter.

Another thing to keep in mind is that some filter operations, such as convolution or blurring, may require larger arrays. In those cases, you may need to balance the memory requirements with the performance impact on the filter.

Overall, it's a good idea to optimize your code as much as possible and avoid unnecessary use of arrays or tables. This can help improve the performance and speed of your filter.

•• what is convolution, in this context?

In the context of image processing, convolution is a mathematical operation that applies a kernel (a small matrix of numbers) to each pixel of an image, and replaces the pixel value with a weighted sum of its neighbors, based on the values in the kernel.

The kernel is usually a small square or rectangular matrix, and the operation of applying the kernel to each pixel is called a convolution. Convolution can be used for a variety of image processing tasks, such as smoothing, sharpening, edge detection, and more.

In Filter Forge, convolution can be performed using the Convolution component, which allows you to create custom kernels and apply them to an image. The resulting output is a new image that has been convolved using the kernel you defined.

•• Points 2-4 are closely related, so we can look at them together. If necessary, I'll come back to any that need it.

Sure, let's look at points 2-4 together.

Point 2 states that the terrain generator should use fractal algorithms to produce dendritic features at appropriate scales for mountains, hills, and broader plains. Fractal algorithms can create natural-looking patterns at multiple scales by iteratively applying a self-similar transformation to a simple pattern. Dendritic patterns, such as those found in mountain ranges and river systems, can be generated by fractal algorithms.

Point 4 states that the generator should be 3D so that it can map properly to an equatorial projection. The Hammer projection is mentioned as a potential projection to use, as it can provide more accurate results for spherical surfaces. The Hammer projection is a type of cylindrical equal-area projection that minimizes distortion in areas away from the equator.

To tie these points together, fractal algorithms can be used to create terrain at multiple scales, including the dendritic patterns seen in mountain ranges and rivers. This fractal terrain can then be mapped to a 3D equatorial projection using a projection like the Hammer projection for more accurate results.

•• let's do a function breakdown to get an idea how we can implement the ideas in points 2-4.

Sure, let's break down the functions that could be used to implement the ideas in points 2-4:

Fractal terrain generator: This function would generate the basic terrain using fractal algorithms. There are different types of fractals that can be used, such as Perlin noise, Simplex noise, or Fractal Brownian Motion. These can be used to generate different types of terrain features, such as mountains, valleys, and plains.

Erosion simulation: This function would simulate the effects of erosion on the generated terrain. Erosion can create features like rivers, canyons, and gullies. However, implementing erosion in Filter Forge could be challenging, so a simpler approach may be to generate a basic dendritic structure through fractal algorithms, and then add some minor erosion effects to make it more realistic.

Vegetation generator: This function would generate vegetation on the terrain, such as forests, grasslands, and deserts. This could be done using fractal algorithms or using a separate system, like L-systems.

Ocean generator: This function would generate oceans and other bodies of water on the terrain. This could be done using a separate algorithm, like the one you mentioned in point 3.

Map projection: This function would map the generated 3D terrain onto a 2D equatorial projection, such as the Hammer projection. This would ensure that the terrain looks accurate and realistic when viewed on a 2D map.

Overall, these functions can be combined in different ways to create a hybrid algorithm that generates realistic and varied Earth-like terrain.

•• In point 5, I consider the blending function. A breakdown of that function would need to address the compositing of noise layers (Perlin, et al) and fractal layers (dendritic structure). It will also feature scale or width, height, frequency, amplitude, octaves, lacunarity, gain, and seed variables and controls.

A blending function that combines noise layers and fractal layers would involve combining the output of different generator functions with various parameters such as scale or width, height, frequency, amplitude, octaves, lacunarity, gain, and seed. One possible approach could be to use a weighted sum of multiple noise and fractal functions at different scales and amplitudes, where the weights are controlled by the octaves and gain parameters. Another approach could be to use a fractal terrain generator as a base layer, and then add noise layers on top of it using a multiplicative or additive blending operation.

The specific implementation of the blending function will depend on the specific noise and fractal functions being used, as well as the desired output. For example, to create a realistic mountain range, one might use a fractal noise function to generate the base shape of the mountains, and then add additional layers of Perlin noise to add detail such as peaks and ridges. Alternatively, one might use a procedural method such as Worley noise to generate the shape of the mountains, and then use fractal functions to add detail at different scales.

•• In point 6, I noted that there is also a method of using signed distance fields or input gradients to seed terrain features. I don't know if that should be addressed in the generator functions or the blending function. either way, I'd like to implement one or both if I can. I had the idea that vector input from a normal or flow map might play a role in that. 

Signed distance fields (SDFs) and input gradients can be used to add additional detail to the terrain generator. SDFs can be used to define boundaries or shapes, and gradients can be used to control the flow of the terrain or add directional features like ridges or valleys.

In terms of implementation, you could create separate generator functions that use SDFs or gradients to create specific features like ridges, valleys, or other shapes. These functions could then be combined with the main terrain generator using the blending function mentioned in point 5. Alternatively, you could incorporate the SDFs or gradients directly into the blending function to control the distribution of noise and fractal layers.

Using vector input from a normal or flow map could also be useful in creating terrain features. Normal maps can be used to define surface details like bumps or roughness, while flow maps can be used to control the direction of movement or flow of the terrain. Like SDFs and gradients, these maps can be incorporated into the generator or blending functions to add additional detail to the terrain.

•• 7, the final point, may require more than one response, but we can start with an overview of L-systems that includes how they could be implemented to generate terrain. I don't know much about them. for the same reason, I need an overview like that for Dendry, too.
L-systems, also known as Lindenmayer systems, are a type of formal grammar used to model the growth of plants and other natural phenomena. They consist of a set of symbols and a set of rules for generating new symbols based on the existing ones. The rules are applied iteratively to produce a sequence of symbols, which can then be interpreted as a graphical or spatial object.

In the context of terrain generation, L-systems can be used to generate branching structures such as trees or rivers. The symbols can represent the types of terrain features, such as water, rock, or vegetation, and the rules can specify how these features should be distributed and connected. For example, a simple L-system for generating a river might have symbols for water, rock, and sand, and rules for branching and curving.

Dendry, also known as Dendritic Growth, is a simulation algorithm used to model the growth of fractal structures such as snowflakes, lightning, and dendritic drainage patterns. It works by simulating the diffusion and deposition of material in a two-dimensional or three-dimensional space, using simple rules to govern the growth of the structure.

In the context of terrain generation, Dendry can be used to generate dendritic structures such as mountain ranges or river networks. The simulation can be seeded with initial values for terrain elevation or moisture, and the deposition rules can be adapted to create the desired terrain features. For example, a simple Dendry simulation for generating a mountain range might have rules for lifting and folding the terrain based on the flow of moisture or wind.

•• So, Dendritic Growth would be a good base, with Lindenmayer systems controlling the addition of other fractal or noise components. Its rules could include specific instructions for supporting functions, coordinating generation and compositing overall. Input maps may need specific functions governing how each type is handled and passed on to more central functions.

Yes, that could be a good approach. Dendritic Growth provides a good starting point for generating natural-looking terrain features such as mountain ranges, valleys, and river systems. Lindenmayer systems can be used to add more complex fractal detail to the terrain and to control the overall structure of the landscape.

In terms of incorporating input maps, you could have specific functions that analyze the input maps and use them to influence the generation of the terrain. For example, you could use a normal map to add detail to the terrain by controlling the slope and orientation of the generated features. A flow map could be used to add rivers and other water features to the terrain. These input maps could be passed through various functions that modify and combine them with other fractal and noise components to produce the final output.

•• Okay, I have to do some more research on Dendritic Growth and L-systems. Thanks for helping organize my thoughts. 

You're welcome! I'm glad I could help. Don't hesitate to ask if you have any more questions or need further assistance in the future. Good luck with your project!