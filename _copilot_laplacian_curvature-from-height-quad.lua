-- Height-based Curvature / Convexity / Cavity / Packed RGB
-- (canonical version)

-- Modes:
-- 1 = Curvature (signed)
-- 2 = Convexity (positive)
-- 3 = Cavity	(negative)
-- 4 = Packed RGB (R=curve, G=convex, B=cavity)

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

	-- canonical decomposition
	local curve  = 0.5 + 0.5 * k
	local convex = 0.5 + math.max(k, 0)
	local cavity = 0.5 + math.min(k, 0)

	-- clamp for safety
	curve  = math.max(0, math.min(1, curve))
	convex = math.max(0, math.min(1, convex))
	cavity = math.max(0, math.min(1, cavity))

	if mode == 1 then
		return curve, curve, curve, 1

	elseif mode == 2 then
		return convex, convex, convex, 1

	elseif mode == 3 then
		return cavity, cavity, cavity, 1

	else
		-- Packed RGB
		return curve, convex, cavity, 1
	end
end