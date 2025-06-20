function prepare()
	-- from collected curve formulas
	-- y = math.tan(x) 
		-- with infinite range shown and the domain from 0-360 degrees (0 to 2 pi radians)
	eps = 0.000001
	half_pi = math.pi / 2
end;

function get_sample(x, y, t)
	local vs = get_sample_grayscale(x, y, SOURCE)
	local cs = get_sample_grayscale(x, y, START)
	local ce = get_sample_grayscale(x, y, END)
	local mn = get_sample_grayscale(x, y, MINIMUM)
	local mx = get_sample_grayscale(x, y, MAXIMUM)
	local reverse = false
	t = t * 2 - 1

	-- curve generation
	local v = vs * math.tan(t) / half_pi
	local vn = get_sample_curve(x, y, v, CURVE)

	if cs > ce then
		temp = cs
		cs = ce
		ce = temp
		reverse = true
	end
	local amp = 1 / (math.abs(ce - cs) + eps)
	v = (v - cs) * amp
	mn = mn / 2 + 0.5
	v = v * (-1*mn + mx) + mn
	if reverse == true then v = 1 - v end

	return v
end;


function prepare()
	-- from collected curve formulas
	-- y = math.asin(x) 
		-- with a range of -pi to pi and a domain of -1 to 1.
	eps = 0.000001
	half_pi = math.pi / 2
end;

function get_sample(x, y, t)
	local vs = get_sample_grayscale(x, y, SOURCE)
	local cs = get_sample_grayscale(x, y, START)
	local ce = get_sample_grayscale(x, y, END)
	local mn = get_sample_grayscale(x, y, MINIMUM)
	local mx = get_sample_grayscale(x, y, MAXIMUM)
	local reverse = false
	t = t * 2 - 1

	-- curve generation
	local v = vs * math.asin(t) / half_pi
	local vn = get_sample_curve(x, y, v, CURVE)

	if cs > ce then
		temp = cs
		cs = ce
		ce = temp
		reverse = true
	end
	local amp = 1 / (math.abs(ce - cs) + eps)
	v = (v - cs) * amp
	mn = mn / 2 + 0.5
	v = v * (-1*mn + mx) + mn
	if reverse == true then v = 1 - v end

	return v
end;


function prepare()
	-- from collected curve formulas
	-- y = sin(x)
	eps = 0.000001
	-- pi, half_pi = math.pi, math.pi / 2
end;

function get_sample(x, y, t)
	local vs = get_sample_grayscale(x, y, SIN)
	local cs = get_sample_grayscale(x, y, START)
	local ce = get_sample_grayscale(x, y, END)
	local mn = get_sample_grayscale(x, y, MINIMUM)
	local mx = get_sample_grayscale(x, y, MAXIMUM)

	local reverse = false

	-- curve generation
	local v = vs * math.sin(t) 
	local v = get_sample_curve(x, y, v, CURVE)

	if cs > ce then
		temp = cs
		cs = ce
		ce = temp
		reverse = true
	end
	local amp = 1 / (math.abs(ce - cs) + eps)
	-- mn = mn / 2 + 0.5
	-- mx = mx * 2 - 1
	v = (v - cs) * amp
	v = v * (-1 * mn + mx) + mn
	if reverse == true then v = 1 - v end

	return v
end;


-- the bias function takes in a number between 0 and 1 as input (i like to think of this as the percent) and also takes a number between 0 and 1 as the “tuning parameter” which defines how the function will bend your curve.

function get_bias(t,bias)
	return (t / ((((1.0/bias) - 2.0)*(1.0 - t))+1.0))
end;


-- The gain function is like bias in that it takes in both a 0 to 1 input (I think of this as the percent as well) and also takes a number between 0 and 1 as the “tuning parameter”.

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


-- contrast curve script
-- this could	technically be a curve ops script, accepting another curve and providing contrast adjustment to it

function prepare()
	eps = 0.000001
end;

function get_sample(x, y, t)
	-- neutral input values: con, br, thr = 0.5, 0.5, 0.5
	local con = get_sample_grayscale(x, y, CONTRAST)
	local br = get_sample_grayscale(x, y, BRIGHTNESS)
	local thr = get_sample_grayscale(x, y, THRESHOLD)

	-- initial values
	local cs, ce, mn, mx = thr - 0.5, thr + 0.5, 0, 1 
	
	-- mn, mx change in response to changes in either br or con
		mn = mn + br	
		mx = mx - (1 - br)
	if con < 0.5 and con >= 0 then
		-- at con <= 0.5, cs, ce =	0, 1;	mn, mx shift to 0, 1. 
		mn = mn - con 
		mx = mx + con
	elseif con >= 0.5 and con <= 1 then
		-- at con > 0.5, cs, ce shift to 0.5, 0.5;	mn, mx = 0, 1. 
		mn = mn - con 
		mx = mx + con
		-- changes in cs, ce are relative to changes in con 
		cs, ce = cs + (con - 0.5), ce - (con - 0.5)
	end

	local amp = 1 / (math.abs(ce - cs) + eps)
	t = (t - cs) * amp

	local v = get_sample_curve(x, y, t, CURVE)
	v = v * (-1 * mn + mx) + mn

	 return v
end;