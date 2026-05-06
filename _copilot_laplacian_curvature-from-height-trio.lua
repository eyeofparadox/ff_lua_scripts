-- Height-based Curvature / Convexity / Cavity
-- (canonical version)

-- Modes:
-- 1 = Curvature (signed)
-- 2 = Convexity (positive)
-- 3 = Cavity	 (negative)

function prepare()
	mode = get_intslider_input(MODE)
	strength = get_slider_input(STRENGTH)
	offset = 1 / math.min(OUTPUT_WIDTH, OUTPUT_HEIGHT)
end

function H(x,y)
	return get_sample_grayscale(x,y,HEIGHT)
end

function get_sample(x, y)

	local h  = H(x,y)
	local hl = H(x-offset, y)
	local hr = H(x+offset, y)
	local hu = H(x, y-offset)
	local hd = H(x, y+offset)

	-- second derivatives
	local hxx = hr - 2*h + hl
	local hyy = hd - 2*h + hu

	-- signed curvature
	local k = (hxx + hyy) * strength

	local v

	if mode == 1 then
		-- CURVATURE (0.5 + 0.5*k)
		v = 0.5 + 0.5 * k

	elseif mode == 2 then
		-- CONVEXITY (max(k,0) + 0.5)
		v = math.max(k, 0) + 0.5

	else
		-- CAVITY (min(k,0) + 0.5)
		v = math.min(k, 0) + 0.5
	end

	-- clamp
	-- v = math.max(0, math.min(1, v))

	return v, v, v, 1
end