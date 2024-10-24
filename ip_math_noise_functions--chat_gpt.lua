function get_noise(x,y,z)
	local noise = 0
	if noise_type == 1 then
		noise = math.perlin_noise(x,y,z)
	elseif noise_type == 2 then
		noise = math.simplex_noise(x,y,z)
	elseif noise_type == 3 then
		noise = math.cellular_noise(x,y,z)
	elseif noise_type == 4 then
		noise = math.fractal_noise(x,y,z)
	end
	return noise
end

-- show function code for math noise functions using lua 5.1

--Perlin Noise
function math.perlin_noise(x, y, z)
	local X = math.floor(x) & 255
	local Y = math.floor(y) & 255
	local Z = math.floor(z) & 255
	x = x - math.floor(x)
	y = y - math.floor(y)
	z = z - math.floor(z)
	local u = fade(x)
	local v = fade(y)
	local w = fade(z)
	local A = perm[X  ]+Y
	local AA = perm[A]+Z
	local AB = perm[A+1]+Z
	local B = perm[X+1]+Y
	local BA = perm[B]+Z
	local BB = perm[B+1]+Z
 
	return lerp(w, lerp(v, lerp(u, grad(perm[AA  ], x  , y  , z   ),
								grad(perm[BA  ], x-1, y  , z   )),
						lerp(u, grad(perm[AB  ], x  , y-1, z   ),
								grad(perm[BB  ], x-1, y-1, z   ))),
				lerp(v, lerp(u, grad(perm[AA+1], x  , y  , z-1 ),
								grad(perm[BA+1], x-1, y  , z-1 )),
						lerp(u, grad(perm[AB+1], x  , y-1, z-1 ),
								grad(perm[BB+1], x-1, y-1, z-1 ))))
end

--Simplex Noise
function math.simplex_noise(x, y, z)
	local F3 = 1/3
	local s = (x+y+z)*F3
	local i = math.floor(x+s)
	local j = math.floor(y+s)
	local k = math.floor(z+s)
	local G3 = 1/6
	local t = (i+j+k)*G3
	local X0 = i-t
	local Y0 = j-t
	local Z0 = k-t
	local x0 = x-X0
	local y0 = y-Y0
	local z0 = z-Z0
	local i1, j1, k1
	local i2, j2, k2
	if x0 >= y0 then
		if y0 >= z0 then
			i1, j1, k1, i2, j2, k2 = 1,0,0,1,1,0
		elseif x0 >= z0 then 
			i1, j1, k1, i2, j2, k2 = 1,0,0,1,0,1
		else 
			i1, j1, k1, i2, j2, k2 = 0,0,1,1,0,1
		end
	else
		if y0 < z0 then
			i1, j1, k1, i2, j2, k2 = 0,0,1,0,1,1
		elseif x0 < z0 then
			i1, j1, k1, i2, j2, k2 = 0,1,0,0,1,1
		else
			i1, j1, k1, i2, j2, k2 = 0,1,0,1,1,0
		end
	end
	local x1 = x0 - i1 + G3
	local y1 = y0 - j1 + G3
	local z1 = z0 - k1 + G3
	local x2 = x0 - i2 + 2*G3
	local y2 = y0 - j2 + 2*G3
	local z2 = z0 - k2 + 2*G3
	local x3 = x0 - 1 + 3*G3
	local y3 = y0 - 1 + 3*G3
	local z3 = z0 - 1 + 3*G3
	local n0, n1, n2, n3
	n0 = grad(perm[ii+perm[jj+perm[kk]]], x0, y0, z0)
	n1 = grad(perm[ii+i1+perm[jj+j1+perm[kk+k1]]], x1, y1, z1)
	n2 = grad(perm[ii+i2+perm[jj+j2+perm[kk+k2]]], x2, y2, z2)
	n3 = grad(perm[ii+1+perm[jj+1+perm[kk+1]]], x3, y3, z3)
	local t0 = 0.6 - x0*x0 - y0*y0 - z0*z0
	if t0 < 0 then
		n0 = 0
	end
	local t1 = 0.6 - x1*x1 - y1*y1 - z1*z1
	if t1 < 0 then
		n1 = 0
	end
	local t2 = 0.6 - x2*x2 - y2*y2 - z2*z2
	if t2 < 0 then
		n2 = 0
	end
	local t3 = 0.6 - x3*x3 - y3*y3 - z3*z3
	if t3<0 then
		n3 = 0
	end
	local tt = t0*t0
	tt = tt * tt
	local noise = 8 * tt * tt * n0
	tt = t1*t1
	tt = tt * tt
	noise = noise + 8 * tt * tt * n1
	tt = t2*t2
	tt = tt * tt
	noise = noise + 8 * tt * tt * n2
	tt = t3*t3
	tt = tt * tt
	noise = noise + 8 * tt * tt * n3
	return 32*noise
end

--Cellular Noise
function math.cellular_noise(x, y, z)
	local x2 = x/cell_size
	local y2 = y/cell_size
	local z2 = z/cell_size
	local i = math.floor(x2)
	local j = math.floor(y2)
	local k = math.floor(z2)
	local dist = 999999
	local xi, yj, zk
	for zk = k-1, k+1 do
		for yj = j-1, j+1 do
			for xi = i-1, i+1 do
				local vec = {xi, yj, zk}
				local vec2 = {xi-x2, yj-y2, zk-z2}
				local new_dist = vec2[1]*vec2[1] + vec2[2]*vec2[2] + vec2[3]*vec2[3]
				if new_dist < dist then
					dist = new_dist
					ix = xi
					iy = yj
					iz = zk
				end
			end
		end
	end
	return math.noise(ix, iy, iz)
end

--Fractal Noise
function math.fractal_noise(x, y, z)
	local noise = 0
	local amplitude = 1
	local frequency = 0.5
	for i=1, octaves do
		noise = noise + get_noise(x*frequency, y*frequency, z*frequency)*amplitude
		amplitude = amplitude * persistence
		frequency = frequency * 2
	end
	return noise
end


