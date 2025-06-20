-- perlin-octaves-sphere
	local log, sqrt, min, max, floor, rad, pi, pi_div = math.log, math.sqrt, math.min, math.max, math.floor, math.rad, math.pi, 1 / math.pi
	local sin, cos, tan, asin, acos, atan2 = math.sin, math.cos, math.tan, math.asin, math.acos, math.atan2
-- https://tinyurl.com/2r3h3rar
	--[[
	--]]


function prepare()
--	constants
	amp_c = 1.731628995
	resolution = math.min(OUTPUT_WIDTH, OUTPUT_HEIGHT)
	rough_c = 0.000000001
	min_c = 0.000000001
	min_p = 0.00166666666666666666666666666667 --1 / resolution -- 

--	input values
	radius = 1 / math.max(get_slider_input(RADIUS), min_c)
	persp = math.max(0, min_c) -- get_slider_input(PERSP) * .25 * pi
	cp, sp = cos_sin(persp)
	sp_div = 1 / math.max(sp, min_c)
	rotation_1 = 1 - rad(get_angle_input(ROTATION_1)) -- y axis
	tilt_1 = rad(get_angle_input(TILT_1)) -- x axis
	roll_1 = rad(get_angle_input(ROLL_1)) -- z axis
	cy_1, sy_1, cx_1, sx_1, cz_1, sz_1 = get_cos_sin(rotation_1, tilt_1, roll_1)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seamless_region(aspect, aspect)
	set_perlin_noise_seamless(true) --|false
	details = 1 -- math.max(get_slider_input(DETAILS), 0.000011)
	details = details + (details * 25)
	noise_size = 1 -- get_slider_input(SCALE)
end;


function get_sample(x, y)
	local z = 0
	local xx,yy, zz = add_vector_gradients(x, y, 1, resolution)
	for x = 0, 1 do
		for y = 0, 1 do
			for i = min_p, resolution do
				z = 1 -- zz[i] --
			end;
		end;
	end;
	z = math.max(z, min_p)
	roughness = math.max(0.575, rough_c) -- math.max(get_sample_grayscale(x, y, ROUGHNESS), 0.000011)
	roughness = roughness + (roughness * 0.5)
	--[[
	local alpha, r = 1, 1 - math.sqrt(x * x + y * y)
	if r < 0 then alpha = 0 end;
	local th = math.atan2(y, x) * 0.159155 + 0.5
	]]
	local px_1, py_1, pz_1, pv = get_sphere(x, y)
	-- local px_1, py_1, pz_1, pv = get_sphere_xyz(x, y, z, 1)
	px_1, py_1, pz_1 = px_1 * 0.5 + 0.5, py_1 * 0.5 + 0.5, pz_1 * 0.5 + 0.5
	if pv == 0 then alpha = 0 end;
	-- local p= get_sample_curve(px_1, py_1, r, PROFILE)
	-- local v = get_perlin_octaves(px, py, 1, 1)
	local v = get_perlin_octaves(px_1, py_1, pz_1, 1)
	return px_1, py_1, pz_1, pv
	-- return v, v, v, pv
end;


function add_vector_gradients(x, y, num_dimensions, resolution)
	local gradients = {{1, 0}, {0, 1}} -- x and y gradients
	for i = 1, num_dimensions do
		table.insert(gradients, {1 / resolution, -1 / resolution})
	end
	return unpack(gradients)
end
	-- resolution = math.min(OUTPUT_WIDTH, OUTPUT_HEIGHT)
	-- x, y, z, w = add_vector_gradients(x, y, 2, resolution)
	-- x, y, z = add_vector_gradients(x, y, 1, resolution)
	--<!> returns tables; add loop to access sample coordinates


	--[[
		experiment with positioning and referencing of arrays and functions to see if there is a way to use this implementation.
function perlin:noise(x, y, z)
	y = y or 0
	z = z or 0

	-- calculate the "unit cube" that the point asked will be located in
	local xi = bit32.band(floor(x), 255)
	local yi = bit32.band(floor(y), 255)
	local zi = bit32.band(floor(z), 255)
	-- local xi = bit32.band(floor(x), 255)
	-- local yi = bit32.band(floor(y), 255)
	-- local zi = bit32.band(floor(z), 255)

	-- calculate the location (from 0 to 1) in that cube
	x = x - floor(x)
	y = y - floor(y)
	z = z - floor(z)

	-- fade the location to smooth the result
	local u = perlin.fade(x)
	local v = perlin.fade(y)
	local w = perlin.fade(z)

	-- hash all 8 unit cube coordinates surrounding input coordinate
	local p = perlin.p
	local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
	A = p[xi ] + yi
	AA = p[A ] + zi
	AB = p[A + 1 ] + zi
	AAA = p[ AA ]
	ABA = p[ AB ]
	AAB = p[ AA + 1 ]
	ABB = p[ AB + 1 ]

	B = p[xi + 1] + yi
	BA = p[B ] + zi
	BB = p[B + 1 ] + zi
	BAA = p[ BA ]
	BBA = p[ BB ]
	BAB = p[ BA + 1 ]
	BBB = p[ BB + 1 ]

	-- take the weighted average between all 8 unit cube coordinates
	return 
	perlin.lerp(w, 
		perlin.lerp(v, 
			perlin.lerp(u, 
				perlin.grad(AAA, x, y, z), 
				perlin.grad(BAA, x - 1, y, z)
			), 
			perlin.lerp(u, 
				perlin.grad(ABA, x, y - 1, z), 
				perlin.grad(BBA, x - 1, y - 1, z)
			)
		), 
		perlin.lerp(v, 
			perlin.lerp(u, 
				perlin.grad(AAB, x, y, z - 1), perlin.grad(BAB, x - 1, y, z - 1)
			), 
			perlin.lerp(u, 
				perlin.grad(ABB, x, y - 1, z - 1), perlin.grad(BBB, x - 1, y - 1, z - 1)
			)
		)
	)
end;
	-- return range: [ - 1, 1]


function perlin:grad(hash, x, y, z)
	return perlin.dot_product[bit32.band(hash, 0xF)](x, y, z)
end;
	-- gradient function finds dot product between pseudorandom gradient vector
	-- and the vector from input coordinate to a unit cube vertex.


function perlin.fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end;
	-- fade function is used to smooth final output


function perlin.lerp(t, a, b)
	return a + t * (b - a)
end;
	-- end perlin
	--]]



function get_perlin_octaves(x, y, z, channel)
	local v, x, y, z, channel = 0, x, y, z, channel
	octaves_n = math.floor(details)
	local remainder = details - octaves_n
	if (remainder > min_c) then
		octaves_n = octaves_n + 1
	end;
	octaves = {}
	local cell_size = (0.00001 + (noise_size * 0.99999))
	cell_size = cell_size + (cell_size * 1000)
	local scale = roughness
	local octave_index
	for octave_index = 1, octaves_n do
		if (scale < rough_c) then
			octaves_n = octave_index - 1
			break
		end;
		octaves[octave_index] = {cell_size, scale}
		cell_size = cell_size * 0.5
		scale = scale * roughness
	end;
	
	if (remainder >= 0.001) then
		octaves[octaves_n][2] = octaves[octaves_n][2] * remainder
	end;

	norm = 0
	for octave_index = 1, octaves_n do
		norm = norm + octaves[octave_index][2] ^ 2
	end;
	norm = 1 / math.sqrt(norm)

	local octave_index 
	for octave_index = 1, octaves_n do
		local size = octaves[octave_index][1]
		local opacity = octaves[octave_index][2]
		v = v + opacity * (2 * perlin.noise(x, y, z, size) - 1)
	end;
	v = (v * norm + amp_c) * (0.5 / amp_c)
	return v
end;


function get_sphere_xyz(x, y, z, i)
	local x, y, z, tx, ty, tz, alpha, rho, i = x, y, z, 0, 0, 0, 1, 1, i
	x, y = (x * 2.0) - 1.0, (y * 2.0) - 1.0
	x, y = x * radius, y * radius
	rho = sqrt((x * x)+(y * y))
	if rho > 1.0 then alpha = 0 end
	z = -sqrt(math.max(1.0 - ((x * x)+(y * y)), min_c)) + z
	if not i or i == 1 then
		cy, sy, cx, sx, cz, sz = cy_1, sy_1, cx_1, sx_1, cz_1, sz_1
	elseif i == 2 then
		cy, sy, cx, sx, cz, sz = cy_2, sy_2, cx_2, sx_2, cz_2, sz_2
	else
		cy, sy, cx, sx, cz, sz = cy_3, sy_3, cx_3, sx_3, cz_3, sz_3
	end	
	tx, ty = (cz * x) - (sz * y), (sz * x) + (cz * y)
 	x, y = tx, ty-- roll
	tz, ty = (cx * z) - (sx * y), (sx * z) + (cx * y)
 	z, y = tz, ty -- tilt
	tx, tz= (cy * x) - (sy * z), (sy * x) + (cy * z)
 	x, z = tx, tz -- rotation
 	return x, y, z, alpha, rho
end;
	-- px, py, pz, alpha, rho = get_sphere_xyz(x, y, rho)


function cos_sin(angle)
	local cos_angle, sin_angle = cos(angle), sin(angle)
	return cos_angle, sin_angle
end;


function get_cos_sin(rotation, tilt, roll)
	local rotation, tilt, roll = rotation, tilt, roll
	local cy, sy = cos_sin(rotation) -- y-axis = yaw
	local cx, sx = cos_sin(tilt) -- x-axis = pitch
	local cz, sz = cos_sin(roll) -- z-axis = roll
	return cy, sy, cx, sx, cz, sz
end;
	-- Rotation, Tilt, Roll

function get_sphere(x, y)
	x, y = x * 2 - 1, y * 2 - 1
	x, y = x * radius, y * radius
	local alpha, rho = 1, sqrt(x * x + y * y)
	if rho > 1.0 then alpha = 0 end;
	local th = atan2(y, x)
	if persp > 0 then
		local ph = min(1, rho) * persp
		local sph, cph = sin(ph), cos(ph)
		rho = sph * (cph * sp_div - sqrt((cph * cph - cp * cp) * sp_div * sp_div))
	else
		rho = min(1, rho)
	end;
	x, y = rho * cos(th), rho * sin(th)
		local tx, ty = (cz_1 * x) - (sz_1 * y), (sz_1 * x) + (cz_1 * y)
		x, y = tx, ty
		x, y, z = rotate_xyz(x, y, rotation_1)
	return x, y, z, alpha
end;


function rotate_xyz(x, y, rotation) -- tha, phi
	local x, y, z = min(max(x, - 1), 1), - min(max(y, - 1), 1), 0
	local phi, tha = asin(y), 0
	local cph = cos(phi)
	x = min(max(x, - cph), cph)
	if cph~=0 then tha = asin(x / cph) end;
	phi = .5 * pi - phi
	x, y, z = cos(tha) * sin(phi), sin(tha) * sin(phi), cos(phi)
	x, z = x * cx_1 - z * sx_1, x * sx_1 + z * cx_1 -- tilt
	tha, phi = atan2(y, x) + rotation_1, acos(z) -- rotation
	tha, phi = (tha * pi_div + 1) * .5, phi * pi_div
	tha = xratio(tha) -- aspect auto-conversion
	x, y = tha, phi
	return x, y, z -- relative x, y
end;


function xratio(x)
	if OUTPUT_WIDTH / OUTPUT_HEIGHT == 2 then
		x = x * 2 - 1 else x = x
	end;
	return x
end;
