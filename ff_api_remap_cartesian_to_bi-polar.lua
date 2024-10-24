-- cartesian to bi-polar v.0.1
-- converted radians to rotations for more proportional remapping
function prepare()
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	mode = get_checkbox_input(MODE) and true or false
	mapmode = get_checkbox_input(MAPMODE) and true or false
end;
-- 
function get_sample(x, y)
	local nz = 1 - x
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y)
	local ny = math.sin(x) * math.sin(y)
	local nnx, nny
	if mapmode then 
		-- poles to equator
		nnx = (rad2rot(math.atan(math.cos(y), nx)) + 0.5) * 2 - 1
		nny = 1 - rad2rot(math.acos(ny)) * 2
	else
		-- poles to poles
		nnx = (math.atan(math.cos(y), nx) / math.pi)
		nny = (1 - rad2rot(math.acos(ny)) * 2) * 2 - 1
	end
	r = nnx
	g = nny
	b = 0.8235294118
	if mode then 
		return r, g, b, 1
	else
		r, g, b, a = get_sample_map(nnx, nny, SOURCE)
		return r, g, b, a
	end
end;

function rad2rot(x) return x * 0.159155 end

-- tails -- nx -- nzrad2rot() * 2 -- * 0.5 + 0.5 -- * nz * 0.5 + 0.5 -- 0.5 + 0.5 -- ny -- / math.pi) 
-- tails -- * 0.5 + 0.5 -- nx = nx * 0.5 + 0.5 -- ny = ny * 0.5 + 0.5