function prepare()
	-- v.001
	scale = get_slider_input(NOISE_SCALE) *50
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
end;

function get_sample(x, y)
	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) * scale
	local ny = math.sin(x) * math.sin(y) * scale
	local nz = math.cos(y) * scale
	local v = get_perlin_noise(nx,ny,nz,500)
	return v,v,v,1
end;