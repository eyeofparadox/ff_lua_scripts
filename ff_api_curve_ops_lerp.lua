function prepare()
	factor = get_slider_input(FACTOR)
end;

function get_sample(x, y, t)
	local c1 = get_sample_curve(x, y, t, C1)
	local c2 = get_sample_curve(x, y, t, C2)
	v = (1 - factor) * c1 + factor * c2
	return v
end;