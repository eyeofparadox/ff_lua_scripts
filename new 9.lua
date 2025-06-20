function prepare()
	pi, cos, sin = math.pi, math.cos, math.sin
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	-- width = OUTPUT_WIDTH / OUTPUT_HEIGHT
	mode = get_intslider_input(MODE)
end;

function get_sample(x, y)
	local r2, g2, b2, a2 = get_sample_map(x, y, SOURCE)
	local inv, thr, r, g, b, a = y, 0, 0, 0, 0, 1
	local x = x * aspect * pi
	local y = y * pi
	local nx = cos(x) * sin(y)
	local ny = sin(x) * sin(y) 
	local nz = cos(y)
	if inv > 0.5 then
		thr = 1
		r = 1 - (nx * 0.5 + 0.5)
		g = 1 - (ny * 0.5 + 0.5)
	else
		thr = 0
		r = nx * 0.5 + 0.5
		g = ny * 0.5 + 0.5
	end
	local b, b0= sin(y), b2
	r, g, b, a = blend_normal(r, g, b, a, thr, g, b, a, 0.5, true)
	r1, g1, b1, a1 = get_sample_map(r, g, SOURCE)
	if (mode == 1) then
		r1, g1, b1, a1 = blend_normal(r1, r1, r1, a1, g1, g1, g1, a1, b1, true)
		r2, g2, b2, a2 = blend_normal(r2, r2, r2, a2, g2, g2, g2, a2, b2, true)
		r, g, b, a = blend_normal(r1, g1, b1, a1, b0, b0, b0, a2, b, true)
	elseif (mode == 2) then
		r1, g1, b1, a1 = blend_darken(r1, r1, r1, a1, g1, g1, g1, a1, b1, true)
		r2, g2, b2, a2 = blend_darken(r2, r2, r2, a2, g2, g2, g2, a2, b2, true)
		r, g, b, a = blend_normal(r1, g1, b1, a1, b0, b0, b0, a2, b, true)
	elseif (mode == 3) then
		r1, g1, b1, a1 = blend_lighten(r1, r1, r1, a1, g1, g1, g1, a1, b1, true)
		r2, g2, b2, a2 = blend_lighten(r2, r2, r2, a2, g2, g2, g2, a2, b2, true)
		r, g, b, a = blend_normal(r1, g1, b1, a1, b0, b0, b0, a2, b, true)
	elseif (mode == 4) then
		r1, g1, b1, a1 = blend_difference(r1, r1, r1, a1, g1, g1, g1, a1, b1, true)
		r2, g2, b2, a2 = blend_difference(r2, r2, r2, a2, g2, g2, g2, a2, b2, true)
		r, g, b, a = blend_normal(r1, g1, b1, a1, b0, b0, b0, a2, b, true)
	elseif (mode == 5) then
		r, g, b, a = blend_normal(r1, g1, b1, a1, r2, g2, b2, a2, b, true)
	else
		return r, g, b, a
	end
	return r, g, b, a
end;