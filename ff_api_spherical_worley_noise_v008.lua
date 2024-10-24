function prepare()
	-- v.008.01
	-- added distance mapping - Euclidean, Manhattan, Chebyshev, Minkowski, Quadratic
	-- updated with more familiar controls and variables
	details = get_intslider_input(DETAILS)
	set_noise_seed(get_intslider_input(SEED))
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	dtype = get_intslider_input(DISTANCE_TYPE)
	p = get_intslider_input(P)
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local roughness = 3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local osx, osy,  osz, osa = get_sample_map(x, y, OFFSET)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION)
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	sx, sy, sz = sx * sa * 2.5, sy * sa * 2.5, sz * sa * 2.5
	if sx == 0 then sx = 0.001 end;
	if sy == 0 then sy = 0.001 end;
	if sz == 0 then sz = 0.001 end;
	local amp = 1

	local x = x * aspect * math.pi
	local y = y * math.pi
	local nx = math.cos(x) * math.sin(y) + (osx * osa)
	local ny = math.sin(x) * math.sin(y) + (osy * osa) 
	local nz = math.cos(y) + (osz * osa)
	
	for oct = 1, details do
		local d1 = get_worley_noise(nx+1,ny,nz,sx,sy,sz) * (dx * da)
		local d2 = get_worley_noise(nx+2,ny,nz,sx,sy,sz) * (dy * da)
		local d3 = get_worley_noise(nx+3,ny,nz,sx,sy,sz) * (dz * da)
		if oct == 1 then v = get_worley_noise(nx+d1,ny+d2,nz+d3,sx,sy,sz) else
			v = (v + get_worley_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,sx,sy,sz) * amp ) / (1 + amp)
		end
		nz = nz * 2
		sx, sy, sz = sx / 2, sy / 2, sz / 2
		amp = amp / roughness
	end
	v  = truncate(factor * (v - 0.5) + 0.5)
	v = get_sample_curve(x,y,v,PROFILE)
	local opacity = v 
	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
	return r, g, b, a
end;

function get_worley_noise(x,y,z,sx,sy,sz)
	local sx, sy, sz = x / sx , y / sy, z / sz
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local offset_x, offset_y, offset_z
	local min_dist = 10000
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dist = distcalc(sx,sy,sz,dx,dy,dz) 
				min_dist = math.min(dist, min_dist)
			end
		end
	end
	min_dist = 1.0 - min_dist
	return min_dist
end;

function distcalc(sx,sy,sz,dx,dy,dz)
	local dist = 0
	if dtype == 1 then
		-- Euclidean 
		dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)	
	elseif dtype == 2 then
		-- Chebyshev
		dist = math.max(math.abs(sx - dx), math.abs(sy - dy), math.abs(sz - dz))	
	elseif dtype == 3 then
		-- Manhattan
		dist = (math.abs(sx - dx) + math.abs(sy - dy) + math.abs(sz - dz)) / 1.5	
	elseif dtype == 4 then
		-- Minkowski 
		local pe = 1/p
		dist = (math.abs(sx - dx)^p + math.abs(sy - dy)^p + math.abs(sz - dz)^p)^pe
	else
		-- Quadratic
		dist = ((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2) / (1 + (sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)
	end	
	return dist
end;

function truncate(value)
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;