function prepare()
	-- This function is called once,
	-- before the rendering begins.
	-- Use it for querying non-mapped
	-- inputs and precalculation.
	heading = get_angle_input(HEADING)/360
	pitch = get_angle_input(PITCH)/360
	bank = get_angle_input(BANK)/360
end;

function get_sample(x, y)
	-- Image generation code goes here.
	local r,g,b,a = 0.1,0.1,0.1,1
	x = x - 0.5
	y = y * 0.5
	local xc, xs = math.cos(x), math.sin(x)
	local yc, ys = math.cos(y), math.sin(y)
	local hc, hs = math.cos(heading), math.sin(heading)
	local pc, ps = math.cos(pitch), math.sin(pitch)
	local bc, bs = math.cos(bank), math.sin(bank)
	local nx, ny = xc * ys, xs * ys
	local h1, h2 = (nx * hc) + (ny * hs), (nx * hs) - (ny * hc)
	local p1, p2 = (h1 * pc) - (yc * ps), (h1 * ps) + (yc * pc)
	local b1, b2 = (h2 * bc) + (p2 * bs), (h2 * bs) - (p2 * bc)
	local xlook = math.atan2(b1, p1) -- + 0.5
	local ylook = math.acos(b2) -- * 2 
	-- local r = heading
	-- local g = pitch
	-- local b = bank
	-- g = math.sqrt(g)
	-- return r, g, b, a
	return x, y, b, a
end;

	local xc, xs = math.cos(x)/6.283, math.sin(x)/6.283
	local yc, ys = math.cos(y)/6.283, math.sin(y)/6.283
	local hc, hs = math.cos(heading)/6.283, math.sin(heading)/6.283
	local pc, ps = math.cos(pitch)/6.283, math.sin(pitch)/6.283
	local bc, bs = math.cos(bank)/6.283, math.sin(bank)/6.283
