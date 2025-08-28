function prepare()
	-- function add_offset(x, y) controls
	xo = 1 - get_slider_input(X_OFFSET)
	yo = 1 - get_slider_input(Y_OFFSET)
end;

function add_offset(x, y)
	-- find out the offset required
	local t = x
	-- x remains the same. y gets shifted according to C
	x = x + xo
	if x > 1 then x = x -1 end
	if x < 0 then x = x + 1 end
	y = y + yo
	if y > 1 then y = y -1 end
	if y < 0 then y = y + 1 end
	local r, g, b, a = get_sample_map(x, y, SOURCE_MAP)
	return r, g, b, a
end;
