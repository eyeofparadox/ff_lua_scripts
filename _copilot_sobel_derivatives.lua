-- Sobel filtering for derivatives
function prepare()
	height_scale = get_slider_input(SCALE) * 0.20
	offset = 1 / math.min(OUTPUT_HEIGHT, OUTPUT_WIDTH)
end

function get_sample(x, y)

	local kernel_x = {
		{-1, 0, 1},
		{-2, 0, 2},
		{-1, 0, 1}
	}

	local kernel_y = {
		{-1, -2, -1},
		{ 0,	0,	0},
		{ 1,	2,	1}
	}

	local gx = 0
	local gy = 0

	for ky = -1, 1 do
		for kx = -1, 1 do

			local weight = (ky == 0 and kx == 0) and 2 or 1

			local h = get_sample_grayscale(x + kx * offset, y + ky * offset, HEIGHT)

			h = h * height_scale

			gx = gx + kernel_x[ky+2][kx+2] * h * weight
			gy = gy + kernel_y[ky+2][kx+2] * h * weight
		end
	end

	-- compute nz from normalization constraint
	local nz = 1 / math.sqrt(1 + gx*gx + gy*gy)

	-- return derivatives directly
	-- gx = dh/dx
	-- gy = dh/dy
	-- nz = normal z-component
	return gx, gy, nz, 1.0
end
