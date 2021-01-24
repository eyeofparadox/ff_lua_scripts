	index = x + y * width
	for x = 0, 1 do	
		for y = 0, 1 do
		
		end	
	end	
			
	pixels[index] = get_noise(x,y,z)

	for i = 0, points.length do
		points[i] = (random(x), random(y))
	end