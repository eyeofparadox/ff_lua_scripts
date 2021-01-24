function prepare()
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local opacity = get_sample_grayscale(x, y, OPACITY)

	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
	return r, g, b, a
end;