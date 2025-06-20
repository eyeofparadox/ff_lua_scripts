function prepare()
	-- called once, before the rendering begins.
	-- used for non-mapped inputs and precalculation.
end;

function get_sample(x, y)
	-- main function returning image output.
	-- used for mapped inputs and mage generation.
    local r, g, b, a = 0, 0, 0, 1			-- initialize when not input
	local , g, b = x, y, (x + y) / 2		-- default gradient output
	return r, g, b, a
end;
