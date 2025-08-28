

-- !_sobel_normals.lua
	-- sobel filtering for surface normals
function prepare()
	-- get inputs and set up
	-- height_scale = get_slider_input(SCALE)
	-- most textures are 1:1. if another aspect ratio is used, the shorter axis will be [0, 1] and the other will exceed 1.
	-- to preserve pixel aspect ratio, use the min axis.
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

function get_sample(x, y)
	-- get height and surface gradient
	-- local height = get_sample_grayscale(x, y, HEIGHT)
	height_scale = get_sample_grayscale(x, y, SCALE)
	-- 
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

	-- flip R and or G channels
	if flip_r then r = 1 - r end
	if flip_g then g = 1 - g end
	
	return r, g, b, alpha
end