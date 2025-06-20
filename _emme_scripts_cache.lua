-- emme_curve_control_v001
function prepare()
	c_start = get_slider_input(START)
	c_end = get_slider_input(END)
	c_min = get_slider_input(MIN)
	c_max = get_slider_input(MAX)
	eps = 0.000001
	temp = 0
	if c_start > c_end then
		temp = c_start
		c_start = c_end
		c_end = temp
	end
end;

function get_sample(x, y, t)
	local amp = 1 / (math.abs(c_end - c_start) + eps)
	t = (t - c_start) * amp
	local c = get_sample_curve(x, y, t, CURVE)
	c = c * (-1*c_min + c_max) + c_min
	return c
end;


--emme_curve_lerp_v001
function prepare()
	factor = get_slider_input(FACTOR)
end;

function get_sample(x, y, t)
	local c1 = get_sample_curve(x, y, t, C1)
	local c2 = get_sample_curve(x, y, t, C2)
	v = (1 - factor) * c1 + factor * c2
	return v
end;


