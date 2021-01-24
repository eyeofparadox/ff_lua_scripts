function prepare()
	-- v.005
	oct_max = get_intslider_input(OCTAVES)
	MIN_SCALE = 0.01
	scale = math.max(MIN_SCALE, get_slider_input(SCALE) / 2) * 5
	set_noise_seed(get_intslider_input(NOISE_SEED))
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local vosx = get_sample_grayscale(x, y, OFFSET_X)
	local vosy = get_sample_grayscale(x, y, OFFSET_Y)
	local vosz = get_sample_grayscale(x, y, OFFSET_Z)
	local amp = 1
	local s = scale
	local detail = 3.75 - get_sample_grayscale(x, y, DETAIL) * 2 + 0.01
	local distortion = get_sample_grayscale(x, y, DISTORTION) * 2
	local x = x * aspect * math.pi
	local y = y * math.pi
	local z = get_sample_grayscale(x, y, Z_COORDINATE)
	local nx = math.cos(x) * math.sin(y) + vosx
	local ny = math.sin(x) * math.sin(y) + vosy 
	local nz = math.cos(y) * z + vosz
	for oct = 1, oct_max do
		local d1 = get_worley_noise(nx+1,ny,nz,s) * distortion
		local d2 = get_worley_noise(nx+2,ny,nz,s) * distortion
		local d3 = get_worley_noise(nx+3,ny,nz,s) * distortion
		if oct == 1 then v = get_worley_noise(nx+d1,ny+d2,nz+d3,s) else
			v = (v + get_worley_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,s) * amp ) / (1 + amp)
		end
		nz = nz * 2
		s = s / 2
		amp = amp / detail
	end
	v = get_sample_curve(x,y,v,PROFILE)
	local opacity = v 
	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
	return r, g, b, a
end;

function get_worley_noise(x,y,z,s)
	local sx, sy, sz = x / s , y / s, z / s
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)

	local offset_x, offset_y, offset_z
	local min_dist = 100
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)
				min_dist = math.min(dist, min_dist)
			end
		end
	end
	min_dist = 1.0 - min_dist
	return min_dist
end;