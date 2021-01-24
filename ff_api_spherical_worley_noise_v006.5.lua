function prepare()
	-- v.006.5
	-- added distance mapping - Euclidean, Manhattan, Chebyshev, Minkowski
	-- prepare global noise constants
	oct_max = get_intslider_input(OCTAVES)
	set_noise_seed(get_intslider_input(NOISE_SEED))
	-- adjust for spherical mapping - constant
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	dtype = get_intslider_input(DISTANCE_TYPE)
	p = get_intslider_input(P)
	--- set hdr state
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	-- get map inputs
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	-- get offset map inputs or values
	local vosx = get_sample_grayscale(x, y, OFFSET_X)
	local vosy = get_sample_grayscale(x, y, OFFSET_Y)
	local vosz = get_sample_grayscale(x, y, OFFSET_Z)
	-- initialize noise amplitude
	local amp = 1
	-- get scale map or value and prevent s = 0
	local s = get_sample_grayscale(x, y, SCALE)/2 * 5
	if s == 0 then
		s = 0.001
	end
	-- get detail and distortion map inputs or values
	local detail = 3.75 - get_sample_grayscale(x, y, DETAIL) * 2 + 0.01
	local distortion = get_sample_grayscale(x, y, DISTORTION) * 2
	-- remap to sphere, get value for z 
	-- map input not viable, but value input necessary
	local x = x * aspect * math.pi
	local y = y * math.pi
	local z = get_sample_grayscale(x, y, Z_COORDINATE)
	local nx = math.cos(x) * math.sin(y) + vosx
	local ny = math.sin(x) * math.sin(y) + vosy 
	local nz = math.cos(y) * z + vosz
	
	-- get and distort each octave of spheremapped noise 
	for oct = 1, oct_max do
		local d1 = get_worley_noise(nx+1,ny,nz,s) * distortion
		local d2 = get_worley_noise(nx+2,ny,nz,s) * distortion
		local d3 = get_worley_noise(nx+3,ny,nz,s) * distortion
		-- modify 1st octave fully
		-- then modify each octave's frequency and amplitude proportionately
		if oct == 1 then v = get_worley_noise(nx+d1,ny+d2,nz+d3,s) else
			v = (v + get_worley_noise(nx+d1/oct,ny+d2/oct,nz+d3/oct,s) * amp ) / (1 + amp)
		end
		nz = nz * 2
		-- decrease scale for next octave
		s = s / 2
		-- decrease amplitude for next octave
		amp = amp / detail
	end
	--- get profile curve - internal tonemapping
	v = get_sample_curve(x,y,v,PROFILE)
	-- set opacity to noise values
	local opacity = v 
	-- blend foreground with background
	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
	return r, g, b, a
end;

function get_worley_noise(x,y,z,s)
	-- adjust x,y,z for scale
	local sx, sy, sz = x / s , y / s, z / s
	-- partition x,y,z into "integer" cells
	local cell_x, cell_y, cell_z = math.floor(sx), math.floor(sy), math.floor(sz)
	-- create offset variables for x,y,z
	local offset_x, offset_y, offset_z
	-- set benchmark minimum distance
	local min_dist = 10000
	-- nested loop through x,y,z coordinate space via incremental offsets each  
	for offset_x=-1,1 do
		for offset_y=-1,1 do
			for offset_z=-1,1 do
				-- seeding points with random values for each offset of x,y,z?
				local dx = cell_x + offset_x + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dy = cell_y + offset_y + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				local dz = cell_z + offset_z + get_noise(cell_x + offset_x, cell_y + offset_y, cell_z + offset_z)
				-- option: create array of distances to seed points here?
				-- option: get distance of random point from current point?
				-- option: assign distances to array of distances for nth point distances?
				local dist = distcalc(sx,sy,sz,dx,dy,dz) 
				-- compare distance to benchmark minimum distance for lesser value
				min_dist = math.min(dist, min_dist)
			end
		end
	end
	-- what does this adjustment accomplish?
	min_dist = 1.0 - min_dist
	-- return value of current point
	return min_dist
end;

function distcalc(sx,sy,sz,dx,dy,dz)
	local dist = 0 -- returns nil value without this variable declaration
	if dtype == 1 then
		-- Euclidean 
		dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)	
	elseif dtype == 2 then
		-- Chebyshev
		dist = math.max(math.abs(sx - dx), math.abs(sy - dy), math.abs(sz - dz))	
	elseif dtype == 3 then
		-- Manhattan
		dist = (math.abs(sx - dx) + math.abs(sy - dy) + math.abs(sz - dz)) / 1.5	
	else
		-- Minkowski 
		local pe = 1/p
		dist = (math.abs(sx - dx)^p + math.abs(sy - dy)^p + math.abs(sz - dz)^p)^pe
	end	
	-- dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)	-- test
	return dist -- tests indicate this returns a nil value for all values of dtype
end;