-- polar to cartesian - good for noise, may not blend patterns or images as well
function prepare()
	-- inputs and precalculation.
	pi, cos, sin = math.pi, math.cos, math.sin
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	mode = get_checkbox_input(MODE)
end;
-- (x * 0.5 + 0.5)
function get_sample(x, y)
	-- image generation code.
	local xe = x * aspect * pi
	local yn = y * 0.5 * pi
	local ys = (y + 1) * 0.5 * pi
	local nxn = cos(xe) * sin(yn)
	local nyn = sin(xe) * sin(yn)
	local zn = cos(yn)
	local nxs = cos(xe) * sin(ys)
	local nys = sin(xe) * sin(ys)
	local zs = cos(ys)
	local r, g, b, a = blend_normal(nxn, nyn, zn, 1, nxs, nys, zs, 1, y, true)
	if mode == 1 then
		xe = xe * 1.75 - 0.875
		local nr, ng, nb, na = get_sample_map(nxn, nyn - 0.33333, SOURCE)
		local sr, sg, sb, sa = get_sample_map(1 - nxs, nys + 0.33333, SOURCE)
		local er, eg, eb, ea = get_sample_map(x, y, EQUATOR)
		m = (((nr + ng + nb) / 3) * 2 - 1) * .0375
		y = set_gain(y, 0.33333 + m)
		ye = sin(y * pi) ^ 4
		r, g, b, a = blend_normal(nr, ng, nb, na, sr, sg, sb, sa, y, true)
		r, g, b, a = blend_normal(r, g, b, a, er, eg, eb, ea, ye, true)
	else
		local r, g, b, a = get_sample_gradient(r, g, b)
	end
	return r, g, b, a
end;

function get_sample_gradient(x, y, z)
	local nr, ng, nb, na = x, y, z, 1
	return nr, ng, nb, na
end;

function set_bias(t,bias)
	return (t / ((((1.0/bias) - 2.0)*(1.0 - t))+1.0))
end;

function set_gain(t,gain)
-- set_gain makes use of the get_bias function; gain is just bias and reflected bias.
	if(t < 0.5) then
		return set_bias(t * 2.0,gain)/2.0
	else
		return set_bias(t * 2.0 - 1.0,1.0 - gain)/2.0 + 0.5
	end
end;