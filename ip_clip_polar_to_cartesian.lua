-- polar to cartesian v001 - good for noise, may not blend patterns or images as well
function prepare()
	-- inputs and precalculation.
	pi, cos, sin = math.pi, math.cos, math.sin
	gain = get_slider_input(GAIN) * 0.33 + 0.44
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	mode = get_checkbox_input(MODE)
end;

function get_sample(x, y)
	-- image generation code.
	local r, g, b, a = 0, 0, 0, 0 
	local nm, sm = set_gain(1 - y, 0.1), set_gain(y, 0.1)
	local er, eg, eb, ea = get_sample_map(x, y, EQUATOR)
	local em = ((er + eg + eb) / 3) * (gain)
	local e = set_gain(y, em)
	local eq = sin(e * pi) ^ 4
	local xe = x * aspect * pi
	local yn = y * 0.5 * pi
	local ys = (y + 1) * 0.5 * pi
	local nxn = cos(xe) * sin(yn)
	local nyn = sin(xe) * sin(yn)
	local zn = cos(yn)
	local nxs = cos(xe) * sin(ys)
	local nys = sin(xe) * sin(ys)
	local zs = cos(ys)
	if mode == 1 then
		xe = xe * 1.75 - 0.875
		local nr, ng, nb, na = get_sample_map(nxn, nyn - 0.33333, SOURCE)
		local sr, sg, sb, sa = get_sample_map(1 - nxs, nys + 0.33333, SOURCE)
		nr, ng, nb, na = blend_multiply(nr, ng, nb, na, 0, 0, 0, 1, sm, true)
		sr, sg, sb, sa = blend_multiply(sr, sg, sb, sa, 0, 0, 0, 1, nm, true)
		r, g, b, a = blend_lighten(nr, ng, nb, na, sr, sg, sb, sa, 1, true)
		r, g, b, a = blend_normal(r, g, b, a, er, eg, eb, ea, eq, true)
	else
--		r, g, b, a = blend_normal(nxn, nyn, zn, 1, nxs, nys, zs, 1, eg, true)
--		r, g, b, a = get_sample_gradient(r, g, b)
		r, g, b, a = get_sample_gradient(nm, sm, eq)
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

function rad2rot(x) return x * 0.159155 end -- or / 6.2832


-- cartesian to polar v000 - unlike gradient remapping, does not pinch at pole
function prepare()
	-- inputs and precalculation.
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	mode = true
end;

function get_sample(x, y)
	-- image generation.
	local radius, theta = cartesian_to_polar(x, y)
	if mode then
		r, g, b, a = get_sample_map(theta, radius, SOURCE)
	else
		r, g, b, a = theta, radius, 1 - radius ^ math.pi, 1
	end
	return r, g, b, a
end;

function cartesian_to_polar(x, y)
	-- translate (x, y) from corner (0,0) to center (0.5, 0.5)
	local cx = (x - 0.5) * aspect
	local cy = (y - 0.5) * aspect
	-- calculate radius
	local radius = math.sqrt(cx * cx + cy * cy)
	-- calculate angle in radians and normalize to [0, 1]
	local theta = math.atan2(cy, cx) / (2 * math.pi)
	if theta < 0 then
		theta = theta + 1
	end
	return radius, 1 - theta
end;

-- cartesian to polar v001 - unlike gradient remapping, does not pinch at pole
function prepare()
	-- inputs and precalculation.
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	mode = get_checkbox_input(MODE)
end;

function get_sample(x, y)
	-- image generation.
	local r, g, b, a = 0, 0, 0, 1
	local radius, theta = cartesian_to_polar(x, y)
	if mode then
		r, g, b, a = get_sample_map(theta, radius, SOURCE)
	else
		r, g, b, a = theta, radius, 1 - radius ^ math.pi, 1
	end
	return r, g, b, a
end;

function cartesian_to_polar(x, y)
	-- translate (x, y) from corner (0,0) to center (0.5, 0.5)
	local cx = (x - 0.5) * aspect
	local cy = (y - 0.5) * aspect
	-- calculate radius
	local radius = math.sqrt(cx * cx + cy * cy)
	-- calculate angle in radians and normalize to [0, 1]
	local theta = math.atan2(cy, cx) / (2 * math.pi)
	if theta < 0 then
		theta = theta + 1
	end
	return radius, 1 - theta
end;
