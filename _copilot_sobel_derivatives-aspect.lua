-- Sobel Derivatives + Aspect Output
-- David Roberson / A.V. Morgan

function prepare()
	height_scale = get_slider_input(SCALE) * 0.20
	gamma = get_slider_input(GAMMA)
	aspect_mode = get_checkbox_input(ASPECT_MODE)	-- false = derivatives, true = aspect RGB

	offset = 1 / math.min(OUTPUT_WIDTH, OUTPUT_HEIGHT)
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

			local weight = (kx == 0 and ky == 0) and 2 or 1

			local h = get_sample_grayscale(
				x + kx * offset,
				y + ky * offset,
				HEIGHT
			)

			-- gamma-adjust height before Sobel
			h = math.pow(h, gamma) * height_scale

			gx = gx + kernel_x[ky+2][kx+2] * h * weight
			gy = gy + kernel_y[ky+2][kx+2] * h * weight
		end
	end

	-- normalized Z component
	local nz = 1 / math.sqrt(1 + gx*gx + gy*gy)

	-- aspect angle (0–1)
	local theta = math.atan2(gy, gx)	-- radians, -pi to +pi
	local aspect = (theta + math.pi) / (2 * math.pi)

	-- OUTPUT MODES --------------------------------------

	if aspect_mode then
		-- Aspect as RGB visualization
		return aspect, aspect, aspect, 1.0
	else
		-- Derivatives + aspect in alpha
		return gx, gy, nz, aspect
	end
end
