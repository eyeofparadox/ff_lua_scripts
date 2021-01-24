function disttype()
	-- no dist declaration, function will return nil
	if dtype == 1 then
		-- Euclidean 
		local dist = math.sqrt((sx - dx)^2 + (sy - dy)^2 + (sz - dz)^2)	
	elseif dtype == 2 then
		-- Chebyshev
		local dist = math.max(math.abs(sx - dx), math.abs(sy - dy), math.abs(sz - dz))	
	elseif dtype == 3 then
		-- Manhattan
		local dist = (math.abs(sx - dx) + math.abs(sy - dy) + math.abs(sz - dz)) / 1.5	
	else
		-- Minkowski 
		local pe = 1/p
		local dist = (math.abs(sx - dx)^p + math.abs(sy - dy)^p + math.abs(sz - dz)^p)^pe
	end	
	return dist
end;