-- <?> 3.15.2023»01:57

what is special about these four colors as a group?: #FF4040, #00BFBF, #8000FF, #80FF00

These four colors are sometimes referred to as "Web Safe Colors." The term "Web Safe" refers to a set of 216 colors that were standardized by early web browsers to ensure consistent color rendering across different devices and platforms. These four colors are not part of the original 216 Web Safe Colors, but they are sometimes included in lists of Web Safe Colors because they are close approximations of the original colors. They are often used in web design and other digital applications because they are generally considered to be safe choices that will display consistently on a wide range of devices.

•• I found them being used to create a hue-based gradient in Lua for Filter Forge.

Yes, that's correct! These four colors were likely chosen because they represent a range of hues that can be used to create a smooth gradient effect.

In Filter Forge, Lua scripts can be used to create custom filters, and one common use for these scripts is to generate gradient effects. The four colors you listed could be used as endpoints for a hue-based gradient that transitions smoothly from red (#FF4040) to cyan (#00BFBF), to purple (#8000FF), and finally to lime green (#80FF00).

By using these specific colors in a gradient, you can create a visually pleasing effect that transitions smoothly through a range of hues.

•• Can other colors with the same relationship be used in their place?

Yes, other colors can be used with the same relationship to create a hue-based gradient. The four colors you mentioned, #FF4040, #00BFBF, #8000FF, and #80FF00, are evenly spaced around the color wheel, each being 90 degrees apart from the adjacent color.

Any set of colors that are equally spaced around the color wheel by 90 degrees can be used to create a similar hue-based gradient. For example, #FF0000 (red), #FFFF00 (yellow), #00FF00 (green), and #00FFFF (cyan) are also 90 degrees apart and can be used to create a similar gradient.

•• That's good to know.

You're welcome! If you have any more questions, feel free to ask.

•• Since you ask, are #FF0000 (red), #FFFF00 (yellow), #00FF00 (green), and #00FFFF (cyan) present strongly enough in a normals or flow map to derive a hue-gradient from? I was wondering if that was part of how they could serve to remap an image via x, y lookup.

Colors present in a normal or flow map are typically used to represent the direction or orientation of surface normals or flow vectors, rather than to create a hue-based gradient. While it may be possible to use these colors to create a hue gradient, it may not be the most effective method since the colors may not be present in the map in sufficient quantities to create a smooth gradient.

In general, hue-based gradients are created by selecting colors that are evenly spaced around the color wheel. The four colors you mentioned earlier (#FF4040, #00BFBF, #8000FF, #80FF00) are evenly spaced around the color wheel, which makes them ideal for creating a smooth hue gradient.

•• I'll take a closer look at the filter where I found the hue-gradient, and see what I can figure out. I've just been looking for a way to remap textures so they really follow the flow of shapes in the source image.

Remapping textures to follow the flow of shapes in the source image can be done using a technique called texture mapping. One common approach is to create a UV map, which is a 2D coordinate system that maps each point on the surface of the 3D model to a corresponding point on the 2D texture map. This allows you to accurately apply the texture to the model and align it with the surface features.

To create a UV map, you can use a tool like Blender or Maya. You can also use third-party plugins like Unfold3D or RizomUV. Once you have a UV map, you can use it to remap the texture coordinates of the image to follow the flow of shapes in the source image.

Regarding the colors #FF0000 (red), #FFFF00 (yellow), #00FF00 (green), and #00FFFF (cyan), they could be used to create a hue-based gradient, but it depends on the specific use case and the type of texture being used. It may be helpful to experiment with different color combinations and see how they affect the final result.

•• I'm just working in 2D; I don't know if UV mapping can be applied there. The idea is to get the texture to bend with the curves during remapping. I've managed to implement a little z-axis rotational remapping in x, y lookups. But I'm after a contour-fitting technique.

Ah, I see. In that case, you may want to look into techniques such as texture splatting or texture mapping, which can help with aligning textures to the contours of 2D surfaces. These techniques involve breaking up a texture into smaller regions and mapping them to specific parts of the surface based on certain criteria (such as proximity to a certain point or angle of the surface). This can help create a more natural-looking texture that aligns with the contours of the surface.

Another technique you could try is using a displacement map, which is a texture that stores height information for a surface. By applying this texture to the surface, you can create the appearance of bumps and ridges, which can help align the texture with the contours of the surface.

There are also various software tools and libraries available that can help with texture remapping and alignment, such as Unity's texture mapping tools, Unreal Engine's texture mapping tools, and the OpenCV library for computer vision.

•• Mmm. I know it's within the capabilities of lookups, The challenge lies in creating the x, y gradients. I had hopes for flow maps, since they can be derived from a source image (a height, more or less, like a normal).

Yes, flow maps can definitely be helpful in achieving the effect you're after. By using a flow map, you can control the direction and speed of movement of a texture across a surface. This can help you create the contour-fitting technique you're looking for.

To use a flow map in your texture remapping process, you would first need to create or obtain a flow map that corresponds to your source image. This flow map would have to be generated from a heightmap or normal map that captures the contours of the surface you're working with.

Once you have the flow map, you can use it to calculate the UV coordinates for each pixel in your texture. This is done by adding the flow map's RGB values to the UV coordinates, essentially shifting each pixel in the direction and speed specified by the flow map.

The resulting texture should then appear to bend and contour to the surface in a more natural way. You may need to experiment with different flow maps and scaling factors to achieve the desired effect.

•• I have written a few map scripts for Filter Forge for creating normals and flow maps and used the r and g channels in lookups, offsets and rotations using the built-in components. I do not have a function for translating a normal or flow map to UV coordinates and using them to remap an image or texture. 

Got it. One way to approach remapping an image using a normal or flow map is to use a technique called texture splatting.That involves blending multiple textures together based on the values of a set of maps, such as a normal map or a flow map. Each map controls the amount of a particular texture that is blended in at each point in the image.

To apply this technique, you could start by creating a set of textures that you want to blend together. Then, create a set of maps that will control how those textures are blended together. For example, you could use a normal map to control the amount of a rough texture that is blended in at each point on a surface, or a flow map to control the amount of a water texture that is blended in based on the direction of the flow.

Next, you would need to create a shader that implements the texture splatting technique. The shader would take the set of textures and maps as inputs, and use them to blend the textures together. The specific implementation of the shader would depend on the details of your use case, such as the specific maps and textures you are working with, as well as the rendering engine you are using.

In terms of using UV coordinates to remap an image, one approach is to use a technique called texture coordinate transformation. This involves transforming the UV coordinates of each point in the image based on some transformation function, such as a rotation or a distortion. You could use a normal or flow map as input to the transformation function, to create a mapping that is based on the surface normal or flow direction at each point.

Again, the specific implementation of the texture coordinate transformation would depend on your use case and the rendering engine you are using. But in general, you would create a shader that takes the original image and the normal or flow map as inputs, and uses them to transform the UV coordinates of each point in the image. The transformed coordinates would then be used to sample the original image to create the remapped output image.

•• Could you write a Filter Forge map script in Lua that has a UV mapping function that will calculate the UV coordinates for each pixel in a flow map, source image and output texture by adding the flow map's RGB values to the UV coordinates?

Sure! Here's a sample Filter Forge map script in Lua that remaps the input image using a flow map. The script calculates the UV coordinates for each pixel in the input image by adding the flow map's RGB values to the UV coordinates.

function init()
	sourceMap = {
		ImagePath = "input.png",
		DataType = "Color",
		IsFilter = true
	}

	flowMap = {
		ImagePath = "flow_map.png",
		DataType = "Color",
		IsFilter = true
	}

	output = {
		ImagePath = "output.png",
		DataType = "Color",
		IsFilter = false
	}
end

function main()
	for x, y, color in output:Pixels() do
		-- calculate the UV coordinates by adding the flow map's RGB values to the pixel coordinates
		uvX = x + (flowMap:GetPixel(x, y).r * 2.0 - 1.0)
		uvY = y + (flowMap:GetPixel(x, y).g * 2.0 - 1.0)

		-- remap the input image using the calculated UV coordinates
		color = sourceMap:GetPixel(uvX, uvY)

		output:SetPixel(x, y, color)
	end
end

Note that this is a basic implementation and may need to be adjusted based on your specific needs. Also, make sure to replace the input.png and flow_map.png with the actual file names of your input image and flow map.

Options to explore:

Flood Fill, Substance 3D Designer - Flood fill, also called seed fill, is a flooding algorithm that determines and alters the area connected to a given node in a multi-dimensional array with some matching attribute. It is used in the "bucket" fill tool of paint programs to fill connected, similarly-colored areas with a different color, and in games such as Go and Minesweeper for determining which pieces are cleared. A variant called boundary fill uses the same algorithms but is defined as the area connected to a given node that does not have a particular attribute. https://en.wikipedia.org/wiki/Flood_fill

The traditional flood-fill algorithm takes three parameters: a start node, a target color, and a replacement color. The algorithm looks for all nodes in the array that are connected to the start node by a path of the target color and changes them to the replacement color. For a boundary-fill, in place of the target color, a border color would be supplied.

In order to generalize the algorithm in the common way, the following descriptions will instead have two routines available. [3] One called Inside which returns true for unfilled points that, by their color, would be inside the filled area, and one called Set which fills a pixel/node. Any node that has Set called on it must then no longer be Inside.

Depending on whether we consider nodes touching at the corners connected or not, we have two variations: eight-way and four-way respectively.

Flood Fill to Position: Generates a per-tile position map from a Flood Fill base. The color of each tile represents its X- and Y-coordinate center, stored in the Red and Green channels. This map is intended as a base for further calculations, rather than a ready-to-use map. Flood Fill to Gradient: Transforms a Flood Fill base into (randomly oriented) gradients. Very useful for creating a Heightmap where tiles are randomly tilted and sloped. The hybrid in mind generates a vector gradient fill with contextual angle and slope adjustment sensitive to flow direction (source "cell" curvature) and able to interpret the corresponding rotation, or torque of the cell. 

	Inputs
		Flood Fill: Color Input
		Base Flood fill data.
		Angle Input: Grayscale Input; Optional map to determine per-cell angle with an external map.
		Slope Input: Grayscale Input; Optional map to determine per-cell gradient slope-strength.

•• Another thing I've wanted to do is implement (replicate the function of) the Flood Fill node in Substance Designer in a Filter Forge map script.
Implementing the Flood Fill node in a Filter Forge map script can be quite challenging as it requires a recursive algorithm to fill all connected pixels of a certain color with a new color. However, it is possible to achieve a similar effect using a combination of built-in components and custom code.

