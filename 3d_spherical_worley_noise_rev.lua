function prepare()
	-- v.008.0 - 3d spherical worley noise - filter forge - lua 5.3
	-- fixed some issues with scale and seed, but a small seam artifact appears at randm at particular settings.
	-- added distance mapping - Euclidean, Manhattan, Chebyshev, Minkowski.
	-- updated with more familiar controls and variables.
	seed = get_intslider_input(SEED)
	details = get_intslider_input(DETAILS)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	metric = get_intslider_input(METRIC)
	p = get_intslider_input(P)
	hdr = get_checkbox_input(HDR) and true or false
end;

function get_sample(x, y)
	-- map inputs and remapping adjustments
	local dx, dy, dz, da, sx, sy, sz, sa = 0, 0, 0, 0, 0, 0, 0, 0
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	local roughness = 3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	-- adjust scale coordinates
	sx, sy, sz = sx * sa * 10, sy * sa * 10, sz * sa * 10
	if sx == 0 then sx = 0.001 end;
	if sy == 0 then sy = 0.001 end;
	if sz == 0 then sz = 0.001 end;
	local osx, osy, osz, osa = get_sample_map(x, y, OFFSET)
	-- adjust offset coordinates
	osx, osy, osz = osx * osa, osy * osa, osz * osa
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION)
	-- adjust distortion coordinates
	dx, dy, dz = dx * da, dy * da, dz * da

	nx, ny, nz = get_sphereical_coordinates(x, y)
	-- apply offset adjustments to spherical coordinates
	nx, ny, nz = nx + osx, ny + osy, nz + osz
	
	octaves = get_worley_octaves(x, y, z, sx, sy, sz, dx, dy, dz, seed, roughness)
	
	octaves = factor * (octaves - 0.5) + 0.5
	octaves = get_sample_curve(x, y, octaves, PROFILE)
	local opacity = octaves
	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
	return r, g, b, a
end;


function get_sphereical_coordinates(x, y)
	local x = x * aspect * math.pi
	local y = y * math.pi
	nx = math.cos(x) * math.sin(y)
	ny = math.sin(x) * math.sin(y)
	nz = math.cos(y)
	return nx, ny, nz
end;


function get_worley_octaves(x, y, z, sx, sy, sz, dx, dy, dz, seed, roughness)
	local amp = 1
	for o = 1, details do
		local d1 = get_worley_noise(nx+1, ny, nz, sx, sy, sz, seed + 11) * dx
		local d2 = get_worley_noise(nx+2, ny, nz, sx, sy, sz, seed + 22) * dy
		local d3 = get_worley_noise(nx+3, ny, nz, sx, sy, sz, seed + 33) * dz
		if o == 1 then octave = get_worley_noise(nx+d1, ny+d2, nz+d3, sx, sy, sz, seed + o) else
			octave = (octave + get_worley_noise(nx+d1/o, ny+d2/o, nz+d3/o, sx, sy, sz, seed + o) * amp ) / (1 + amp)
		end
		nz = nz * 2
		sx, sy, sz = sx / 2, sy / 2, sz / 2
		amp = amp / roughness
	end
	return octave
end;


function get_worley_noise(x, y, z, sx, sy, sz, seed)
	-- seed = 0
	set_noise_seed(seed)
	z = z * 0.5
	local sx, sy, sz = x / sx , y / sy, z / sz
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	local os_x, os_y, os_z
	local distance = math.huge
	for os_x=-1, 1 do
		for os_y=-1, 1 do
			for os_z=-1, 1 do
				local dx = cell_x + os_x + get_noise(cell_x + os_x, cell_y + os_y, cell_z + os_z)
				local dy = cell_y + os_y + get_noise(cell_x + os_x, cell_y + os_y, cell_z + os_z)
				local dz = cell_z + os_z + get_noise(cell_x + os_x, cell_y + os_y, cell_z + os_z)
				local dist = get_distance(sx, sy, sz, dx, dy, dz)
				distance = math.min(dist, distance)
			end
		end
	end
	distance = 1.0 - distance
	return distance
end;


function get_distance(sx, sy, sz, dx, dy, dz)
	local distance = 0
	if metric == 1 then
		-- Euclidean
		distance = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)	
	elseif metric == 2 then
		-- Manhattan
		distance = (math.abs(sx - dx) + math.abs(sy - dy) + math.abs(sz - dz)) / 1.5
	elseif metric == 3 then
		-- Chebyshev
		distance = math.max(math.abs(sx - dx), math.abs(sy - dy), math.abs(sz - dz))	
	elseif metric == 4 then
		-- Minkowski
		local pe = 1/p
		distance = (math.abs(sx - dx)^p + math.abs(sy - dy)^p + math.abs(sz - dz)^p)^pe
	else
		-- Quadratic
		distance = ((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2) / (1 + (sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2) / 0.5
	end	
	return distance
end;


