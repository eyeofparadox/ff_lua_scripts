A Worley noise implementation in Lua for a Filter Forge map script. I'm still new at tables so I wanted to see if I am going about it right. I'm not interested in a radical departure, particularly given your ignorance of lua in Filter Forge. I want feedback on the code submitted in overview form so you have enough room to reply without being cut off.:

name = "map"
worley {	-- • main module
	pro {	--• process array
		in {	--• interpolation, an array of functions to calculate interpolated distance
			}
		},
		d {	--• distance, an array of functions for distance calculation
		}
	},
	pts {	--• points array
						--<!> each point has a unique id, pts[i], coordinates are only recorded once, referenced by pts[i] in pts.k[1, 4]
		x {	--• sample coordinate x, default
		},
		y {	--• sample coordinate y, default
		},
		z {	--• sample coordinate z, optional if y
		},
		w {	--• sample coordinate w, optional if z
		},
		k {	--• k-nearest-neighbors, 1 thru 4
				--• sub array of distances, interpolated distances
				dist,
				in_dist
			}
		}
	}
}

-- • procedure
	function prepare()
	-- • called once, before the rendering begins.
	-- • used for non-mapped inputs and precalculation.
		set_noise_seed(get_intslider_input(SEED) + 1) -- range 1 to 30000 + 1
		octaves = get_intslider_input(OCTAVES) -- range 1 to 10
		m = get_intslider_input(METRIC) -- range 1 to 5
		f = get_intslider_input(FORMULA) -- range 1 to 4
		-- • `f` > 4 will index complex noises derived from combinations of `m` and`f` with more than one distance calculation
		amp = 1
	end
	
	get_sample()
		z = dimension_grad(x, y, 1, resolution)
		local rhi, ghi, bhi, ahi = get_sample_map(x, y, HIGH)
		local rlo, glo, blo, alo = get_sample_map(x, y, LOW)
		roughness = get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
		contrast = get_sample_grayscale(x, y, CONTRAST)
		local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
		sx, sy, sz = math.max(0.0001, sx), math.max(0.0001, sy), math.max(0.0001, sz)
		sx, sy, sz = x * sx * sa * 5, y * sy * sa * 5, z * sz * sa * 5
		local noise = worley.fractal(sx, sy, sz)
	end

	worley.fractal
		for o = 1, octaves do
			if o == 1 then octave = worley.noise(x, y, z) else
				octave = (octave + worley.noise(x, y, z) * amp) / (1 + amp)
				-- • other input attributes can be added before publication
			end
		end
		sx, sy, sz = sx / 2, sy / 2, sz / 2
		amp = amp / roughness
	end

	worley.noise
		local octave = worley.points(x, y, z)
		-- • local distance = worley.distances(x, y, z, m, f)
		-- • local interpolation = worley.interpolations(x, y, z)
	end

	worley.points
		local cx, cy, cz = math.floor(x), math.floor(y), math.floor(z)
		-- local ox, oy, oz
		-- original code
		-- for ox = -1, 1 do
			-- for oy = -1, 1 do
				-- for oz = -1, 1 do
					-- local dx = cx + ox + get_noise(cx + ox, cy + oy, cz + oz)
					-- local dy = cy + oy + get_noise(cx + ox, cy + oy, cz + oz)
					-- local dz = cz + oz + get_noise(cx + ox, cy + oy, cz + oz)
				-- end
			-- end
		-- end
		-- • using worley.pts[x][y][z][k]
		local dx, dy, dz
		for dx = -1, 1 do
			for dy = -1, 1 do
				for dz = -1, 1 do
					for k = 1, 4 do
						-- • passing cx, cy, cz to worley.distances
						local x_, y_, z_, d_ = worley.distances(x, y, z, cx, cy, cz, dx,dy,dz, k)
						worley.pts[dx][dy][dz][k] = {x=x_, y=y_, z=z_, d=d_}
					end
				end
			end
		end
	end
			--[[
				If worley.pts is already a table that you've defined and x, y, and z are the dimensions of the table, then you should be able to index it using the loop variables dx, dy, and dz without creating a new array.

				For example, if worley.pts is defined as worley.pts = {}, and you later assign it to worley.pts[x] = {}, worley.pts[x][y] = {}, and worley.pts[x][y][z] = {}, then indexing it using worley.pts[dx][dy][dz][k] should work as expected as long as dx, dy, and dz are valid indices within the dimensions of worley.pts (i.e., within the range of 1 to x, 1 to y, and 1 to z, respectively).

				So in your case, as long as you've already defined worley.pts as a table with the appropriate dimensions, you should be able to update its values using the syntax worley.pts[dx][dy][dz][k] = d.

				As long as you use the same looping structure to access and modify the values in the worley.pts table, you should be able to manipulate the values within the table. Just make sure that the table is properly initialized before accessing its values, and that you are not creating a new table accidentally when indexing the values.

The dot notation is used to access an object's property by name, not to index into a table using a value. To call a function stored in a table using dot notation, you can use parentheses after the property name. For example, if worley.pts.x is a function stored in a table, you would need to call it using the dot notation with parentheses like this:

	worley.pts.x()
			]]

	worley.pro.d = { -- • array of distance calculations for use in distances function
		-- 1 is euclidean
		{ dist = function(x, y, z, dx, dy, dz) 
		return math.sqrt((x - dx)^2 + (y - dy)^2 + (z - dz)^2) end },
		-- 2 is manhattan
		{ dist = function(x, y, z, dx, dy, dz) 
		return math.abs(x - dx) + math.abs(y - dy) + math.abs(z - dz)) end },
		-- 3 is chebyshev
		{ dist = function(x, y, z, dx, dy, dz) 
		return math.max(math.abs(x - dx), math.abs(y - dy), math.abs(z - dz)) end },
		-- 4 is minkowski
		{ dist = function(x, y, z, dx, dy, dz) 
		return (math.abs(x - dx)^p + math.abs(y - dy)^p + math.abs(z - dz)^p)^(1/d) end },
		-- 5 is quadratic
		{ dist = function(x, y, z, dx, dy, dz) 
		return ((x - dx)^2 + (y - dy)^2 + (z - dz)^2) / (1 + (x - dx)^2 + (y - dy)^2 + (z - dz)^2) end }
	}	-- • `dist` is distance; `x`, `y`,`z` are seed coordinates; `dx`, `dy`,`dz` are distant point coordinates; `p` is power

	worley.distances(x, y, z, cx, cy, cz, dx,dy,dz, k)
		local min = math.huge
		local cx, cy, cz = cx, cy, cz
		-- • inject randomness into dx, dy, dz
		local dx = cx + dx + get_noise(cx + dx, cy + dy, cz + dz)
		local dy = cy + dy + get_noise(cx + dx, cy + dy, cz + dz)
		local dz = cz + dz + get_noise(cx + dx, cy + dy, cz + dz)
		-- • calculate distance between x, y, z and dx, dy, dz using m metric and k nearest neighbor
		d = worley.pro.d[m].dist(x, y, z, dx, dy, dz) -- • is this how to call calculation from array?
		return dx,dy,dz, d -- • will this populate calling fields?
	end

	worley.pro.in = { -- array of interpolations for use in interpolation function
		-- 1 is linear interpolation
		{ in_dist = function(d1, d2) 
		return (1 - t) * d1 + t * d2 end },
		-- 2 is cosine interpolation
		{ in_dist = function(d1, d2) 
		return (1 - cos(t * pi)) / 2 * d1 + (1 - cos((1 - t) * pi)) / 2 * d2 end },
		-- 3 is cubic interpolation
		{ in_dist = function(d1, d2) 
		return (2 * t^3 - 3 * t^2 + 1) * d1 + (3 * t^2 - 2 * t^3) * d2 end },
		-- 4 is smoothstep interpolation
		{ in_dist = function(d1, d2) 
		return (3 - 2 * t) * t^2 * d1 + t^2 * (t - 1) * d2 end },
		-- 5 is perlin interpolation
		{ in_dist = function(d1, d2) 
		return pxyz * (((1 - (d1 / d2)) * v1) + ((d1 / d2) * v2)) + (1 - pxyz) * v1 end }
	}	-- • call with worley.pro.in[f].in_dist(d1, d2)

name = "pseudo code"
-- • declare global array
worley = {}
worley.pro = { m, f }

function prepare() • required
	-- • called once, before the rendering begins.
	-- • used for non-mapped inputs and precalculation.
	-- • select a distance metric and formula
	worley.pro.m = get_intslider_input(METRIC) • 1 of 5
	worley.pro.f = get_intslider_input(FORMULA) • 1 of (4 + (...)) --<!> `...` refers to additional complex noises tbd
	-- •<!> full list uncompiled: `f` > 4 indexes complex noises derived from combinations of `m` and`f` with more than one distance calculation
	-- • initialize other global variables
	scale = get_slider_input(SCALE)
	dimensions = 2
	-- •<!> full list of inputs uncompiled: includes octaves, frequency, lacunarity, amplitude, persistence, period, etc.
		--[[
			octaves: a key factor in the detail of a noise fractal, each octave has, by default, double the frequency of the previous octave.
			frequency: the number of periodic cycles per unit length of a coherent-noise, impacting feature scale and repetition.
			lacunarity: a multiplier that determines how quickly the frequency increases for each successive octave in a noise function 
			amplitude: the maximum absolute value that a specific coherent-noise function can output (influences lacunarity).
			persistence: aka gain, a multiplier that determines how quickly the amplitudes diminish for each successive octave in a noise function 
			period: the number of waves generated, increasing the period within the same spatial distance increases the spatial frequency of the wave.
			note: a multi-fractal calls in extra noise to shape the values of these variables.
		]]
end;

function get_sample(x, y) • render function;  required
	-- • main function returning image output.
	-- • used for mapped inputs and mage generation.
	-- •<!> create z and w if required: x, y, (z), (w) = dimension_grad(x, y, plus, resolution)
	-- •<!> apply scale multiplier before generating noise
	-- • call worley constructor function
	return r, g, b, a
end;

function dimension_grad(x, y, plus, resolution)
	dimensions = 2 + plus
	local gradients = {{1, 0}, {0, 1}} -- x and y gradients
	for i = 1, plus do
		table.insert(gradients, {1 / resolution, -1 / resolution})
	end
	return unpack(gradients)
end;
	--[[
	call with: x, y, (z), (w) = dimension_grad(x, y, 2, 600). This returns the individual elements of the gradients table as separate values, which can be assigned to the variables x, y, z, and w in the calling statement using multiple assignment.
	]]

function worley.noise() • controller function
	-- • call worley.points to get seed points and four closest neighbors sorted by distances
	-- • call worley.octaves
	return worley_noise • the final value at the sample point
end;

function worley.points() • support function
	-- construction loop; use to iterate thru worley.pts conditionally
	-- • construct worley.pts { x, y, ... } from given coordinates
	if x then -- create and initialize .x
		for x = -1, 1 do worley.pts.x = { x }
			if y then -- create and initialize .y
				for y = -1, 1 do worley.pts.y = { y }
					if z then -- create and initialize .z
						for z = -1, 1 do worley.pts.z = { z }
							if w then -- create and initialize .w
								for w = -1, 1 do worley.pts.w = { w }
									-- • construct worley.pts.k { 1, 2, 3, 4 }
									for k = 1, 4 do worley.pts.k = { k } -- create and initialize .k
										-- • establish cells and seed points in worley.pts[x][y][z][w]
										-- • call get_noise function at current sample coordinates
										-- something else with k.i
									end
								end
							else -- not w
								• construct worley.pts.k { 1, 2, 3, 4 }
								for k = 1, 4 do worley.pts.k = { k } -- create and initialize .k
									-- • establish cells and seed points in worley.pts[x][y][z]
									-- • call get_noise function at current sample coordinates
									-- something else with k.i
								end
							end;
						end
					else -- not z
						-- • construct worley.pts.k { 1, 2, 3, 4 }
						for k = 1, 4 do worley.pts.k = { k } -- create and initialize .k
							-- • establish cells and seed points in worley.pts[x][y]
							-- • call get_noise function at current sample coordinates
							-- something else with k.i
						end
					end;
				end
			end
		end
	end
	• find the first four neighboring points to the seed points
	-- action loop; use to iterate thru worley.pts
	for x = -1, 1 do -- something .x specific
		for y = -1, 1 do -- something .y specific
			if z then -- has extra dimension
				for z = -1, 1 do -- something .z specific
					if w then -- has extra dimension
						for w = -1, 1 do -- something .w specific
							for k = 1, 4 do
									-- • call worley.distance to calculate distances in worley.pts[x][y][z][w]
									-- something with k.i
							end
						end
					else -- not w
						for k = 1, 4 do
								-- • call worley.distance to calculate distances in worley.pts[x][y][z]
								-- something with k.i
						end
					end;
				end
			else -- not z
				for k = 1, 4 do
						-- • call worley.distance to calculate distances in worley.pts[x][y]
						-- something with k.i
				end
			end;
		end
	end
	-- • sort the distances to determine the order of the first four neighboring points
	return done -- • true or false
end;

function distance() -- • support function
	-- • get current seed point and distant point
	-- • set temp variables for array calculation -- if not `z` if not `w` pass `0` instead of `nil` coordinates
	-- • if find then perform the straight distance calculation for current points when requested
	-- • else perform the `m`:`f` distance calculation for current points when requested
	return distance
end;

function interpolation() • support function
	-- • get dimensions and distances from seed point to neighboring points -- from array
	-- action loop; use to iterate thru worley.pts
	for x = -1, 1 do -- something .x specific
		for y = -1, 1 do -- something .y specific
			if z then -- has extra dimension
				for z = -1, 1 do -- something .z specific
					if w then -- has extra dimension
						for w = -1, 1 do -- something .w specific
							for k = 1, 4 do
								-- something with k.i
								-- • set temp variables for array calculation -- if not `z` if not `w` pass `0` instead of `nil` coordinates
								-- • use distances to calculate the blending weight for interpolation
								-- condensed blend weight calculation
								t = (d1^p + d2^p + d3^p + d4^p) / dimensions
								-- • use the selected worley.pro.in calculation to blend the distance to the neighboring point
							end
						end
					end
				end
			end
		end
	end
	return interpolated_distance
end;

function worley.octaves() -- • support function --<!> something is very wrong here
	-- • get dimension and distance from current seed point to current neighboring point -- from array
	-- • set temp variables for array calculation -- if not `z` if not `w` pass `0` instead of `nil` coordinates
	-- • generate octaves
	return fractal_noise
end;

worley.pts = {}
worley.pts[x][y][z][w] -- coordinates of sample seed points
worley.pts[x][y][z][w][k[1][2][3][4]] -- indexes of four closest points, used to get coordinates, worley.pts[x][y][z][w], to use in calculation of distances
worley.pts[x][y][z][w][k[n[dist]]] -- distances of k.i points, saved to use in calculation of distance interpolations
worley.pts[x][y][z][w][k[n[in_dist]]] -- interpolations of k.i points

worley.pro.d = { -- array of distance calculations for use in distance function
	-- 1 is euclidean
	d = math.sqrt((sx - px)^2 + (sy - py)^2 + (sz - pz)^2 + (sw - pw)^2),
	-- 2 is manhattan
	d = math.abs(sx - px) + math.abs(sy - py) + math.abs(sz - pz) + math.abs(sw - pw),
	-- 3 is chebyshev
	d = math.max(math.abs(sx - px), math.abs(sy - py), math.abs(sz - pz), math.abs(sw - pw)),
	-- 4 is minkowski
	d = (math.abs(sx - px)^p + math.abs(sy - py)^p + math.abs(sz - pz)^p + math.abs(sw - pw)^p)^(1/p),
	-- 5 is quadratic
	d = ((sx - px)^2 + (sy - py)^2 + (sz - pz)^2 + (sw - pw)^2) / (1 + (sx - px)^2 + (sy - py)^2 + (sz - pz)^2 + (sw - pw)^2)
}	-- `d` is distance; `s...` is seed + coordinate `...x`, `...y`,`...z`, `...w`; `p...` is distant point + coordinate `...x`, `...y`,`...z`, `...w`

worley.pro.in = { -- array of interpolations for use in interpolation function
	-- linear interpolation
	in = (1 - t) * d1 + t * d2,
	-- cosine interpolation
	in = (1 - cos(t * pi)) / 2 * d1 + (1 - cos((1 - t) * pi)) / 2 * d2,
	-- cubic interpolation
	in = (2 * t^3 - 3 * t^2 + 1) * d1 + (3 * t^2 - 2 * t^3) * d2,
	-- smoothstep interpolation
	in = (3 - 2 * t) * t^2 * d1 + t^2 * (t - 1) * d2,
	-- perlin interpolation
	in = pxyz * (((1 - (d1 / d2)) * v1) + ((d1 / d2) * v2)) + (1 - pxyz) * v1
}

-- action loop; use to iterate thru worley.pts
for x = -1, 1 do -- something .x specific
	for y = -1, 1 do -- something .y specific
		if z then -- has extra dimension
			for z = -1, 1 do -- something .z specific
				if w then -- has extra dimension
					for w = -1, 1 do -- something .w specific
						for k = 1, 4 do
							-- something with k.i
						end
					end
				end
			end
		end
	end
end

-- construction loop; use to iterate thru worley.pts conditionally
if x then -- create and initialize .x
	for x = -1, 1 do worley.pts.x = { x }
		if y then -- create and initialize .y
			for y = -1, 1 do worley.pts.y = { y }
				if z then -- create and initialize .z
					for z = -1, 1 do worley.pts.z = { z }
						if w then -- create and initialize .w
							for w = -1, 1 do worley.pts.w = { w }
								for k = 1, 4 do worley.pts.k = { k } -- create and initialize .k
								-- something else with k.i
								end
							end
						end
					end
				end
			end
		end
	end
end

function name(...) calculation return result end

for this = from, to do something end

if this then that end


