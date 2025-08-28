-- !_circle_diamond_packing.lua
function prepare()
	-- inputs
		-- mindist = 1, 100
		-- maxrad = 1, 100
		-- minrad = 1, 100
		-- circles = 1, 2500
		-- calculate_taxi = bool
		-- render_taxi = bool
		-- random_size = bool
	mindist = (get_intslider_input(MIN_DISTANCE)-.01) * .001
	maxrad = get_intslider_input(MAX_RADIUS)/500
	minrad = get_intslider_input(MIN_RADIUS)/500
	circles = get_intslider_input(NUMBER_OF_CIRCLES) * 10
	calculate_taxi = get_checkbox_input(CALCULATE_TAXI)
	render_taxi = get_checkbox_input(RENDER_TAXI)
	random_size = get_checkbox_input(RANDOM_SIZE)
	mindist = (get_intslider_input(MIN_DISTANCE)-.01) * .001

	-- set some basic values
	grid_divisions = 10
	print("grid_divisions b: "..tostring(1 / grid_divisions))
	print("maxrad		 b: "..maxrad)
	--while ((1 / grid_divisions) < maxrad) do
		grid_divisions = math.floor(1 / maxrad) - 1 --grid_divisions - 1
		print("grid_divisions a: "..tostring(grid_divisions))
	--end
	minradD2 = minrad * .5
	if (minrad>maxrad) then
		minrad = maxrad
	end
	math.randomseed(VARIATION)
	rnd = math.random()
	INITIALISE = true
	-- Create grids - x, y, radii, counts
	grid_x, grid_y, grid_r, grid_c = {}, {}, {}, {}
	for i = 1, grid_divisions do
		grid_x[i], grid_y[i], grid_r[i], grid_c[i] = {}, {}, {}, {}
		for j = 1, grid_divisions do
			grid_x[i][j], grid_y[i][j], grid_r[i][j], grid_c[i][j] = {}, {}, {}, 0
		end
	end
	 -- set distance functions
	 calc_distance = euclidian_distance
	 render_distance = euclidian_distance
	 if (calculate_taxi) then calc_distance = taxicab_distance end
	 if (render_taxi) then render_distance = taxicab_distance end
	 -- set size function
	 radmod_function = get_greyscale
	 if (random_size) then radmod_function = get_random end
end;

function get_sample(x, y)
	-- only on first run:
	if (INITIALISE) then 
		get_circles()
		INITIALISE = false
	end 	
	-- for every pixel:
	local aa_zone = 0
	local r, g, b, a = 0, 0, 0, 1
	local xg, yg, d, _xg, _yg
	xg = get_grid_ref(x)
	yg = get_grid_ref(y)	
	for _xg = xg - 1, xg + 1 do
		for _yg = yg - 1, yg + 1 do
			if _xg > 0 and _xg <= grid_divisions and _yg > 0 and _yg <= grid_divisions then
				for i = 1, grid_c[_xg][_yg] do
					d = render_distance(x, y, grid_x[_xg][_yg][i], grid_y[_xg][_yg][i]) 
					if d < grid_r[_xg][_yg][i] - mindist then
						r, g, b, a = get_sample_map(grid_x[_xg][_yg][i], grid_y[_xg][_yg][i], SOURCE)
						aa_zone = aa_zone + 1
					end 
				end
			end
		end
	end
	return r, g, b, a, aa_zone
end;

function get_grid_ref(coord)
	return math.floor((coord) * grid_divisions) + 1
end;

function euclidian_distance(x1, y1, x2, y2)
	return math.sqrt( (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) )
end;

function taxicab_distance(x1, y1, x2, y2)
	return math.abs(x1 - x2) + math.abs(y1 - y2)
end;

function get_greyscale(x, y)
	return get_sample_grayscale(x, y, PARTICLE_SIZE) * .5
end;

function get_random(x, y)
	return rndm(rnd)
end;

 -- function random number
 function rndm(rnd)
	  rnd = math.mod(rnd * 123.6834067574+.7559584731,1)
	  return rnd
 end

 -- function get circles
 function get_circles()
	  -- fill grid tables 
	  for i=0, circles, 1 do
			local circleadded = 0
			local trycount = 0
			local loopcount = 0
			local x, y, xg, yg, d, dmax, _tc
			local new_index
			while (circleadded == 0) do
				 x = rndm(rnd)
				 y = rndm(x)
				 rnd = rndm(y)
				 xg = get_grid_ref(x)
				 yg = get_grid_ref(y)
				 radmod = radmod_function(x, y)
				 -- determine radius
				 if (i>0) then
					  dmax = minradD2+(maxrad)*radmod
					  for _xg = xg - 1, xg + 1 do
							for _yg = yg - 1, yg + 1 do
								 if _xg > 0 and _xg <= grid_divisions and _yg > 0 and _yg <= grid_divisions then
									  _tc = grid_c[_xg][_yg] 
									  for k = 1, _tc do
											d = calc_distance(x, y, grid_x[_xg][_yg][k], grid_y[_xg][_yg][k]) - grid_r[_xg][_yg][k]
											if (d < dmax) then
												 dmax = d
											end -- if d<dmax
									  end
								 end
							end
					  end
					  if dmax > minradD2 then
							circleadded = 1
							new_index = grid_c[xg][yg] + 1
							grid_c[xg][yg] = new_index
							grid_x[xg][yg][new_index] = x
							grid_y[xg][yg][new_index] = y
							grid_r[xg][yg][new_index] = dmax
					  end -- if dmax
				 else 
					  new_index = grid_c[xg][yg] + 1
					  grid_c[xg][yg] = new_index
					  grid_x[xg][yg][new_index] = x
					  grid_y[xg][yg][new_index] = y
					  grid_r[xg][yg][new_index] = minradD2+(maxrad)*radmod
					  circleadded = 1
				 end -- if (i>0)
				 loopcount = loopcount + 1
				 if (loopcount > 1000) then
					  circleadded = 1
				 end -- if
			end -- while
	  end -- for i
end -- function get circles