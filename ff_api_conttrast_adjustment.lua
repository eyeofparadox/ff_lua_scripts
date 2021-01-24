function prepare()
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end; 

function get_sample(x,y)
	contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local r, g, b, a = get_sample_map(x, y, COLOR)
	local nr = truncate(factor * (r - 0.5) + 0.5)
	local ng = truncate(factor * (g - 0.5) + 0.5)
	local nb = truncate(factor * (b - 0.5) + 0.5)
	return nr, ng, nb, a
end;

-- function prepare()
	-- slider contrast control
	-- contrast = (get_slider_input(CONTRAST) * 2) - 1
	-- factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
-- end;

-- function truncate(value)
	-- if value <= 0 then value = 0 end
	-- if value >= 1 then value = 1 end
	-- return value
-- end; 

-- function get_sample(x,y)
	-- local r, g, b, a = get_sample_map(x, y, COLOR)
	-- local nr = truncate(factor * (r - 0.5) + 0.5)
	-- local ng = truncate(factor * (g - 0.5) + 0.5)
	-- local nb = truncate(factor * (b - 0.5) + 0.5)
	-- return nr, ng, nb, a
-- end;

-- function prepare()
	-- no truncate
-- end;

-- function get_sample(x,y)
	-- contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	-- factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	-- local r, g, b, a = get_sample_map(x, y, COLOR)
	-- local nr = factor * (r - 0.5) + 0.5
	-- local ng = factor * (g - 0.5) + 0.5
	-- local nb = factor * (b - 0.5) + 0.5
	-- return nr, ng, nb, a
-- end;