-- ```
	-- local SimplexNoise = {} -- Simplex noise in 2D, 3D and 4D
local noiseScale = 50
local noiseOctaves = 4
local noiseLacunarity = 2.0
local noisePersistence = 0.5


	local grad3 = {
		{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0},
		{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1},
		{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}
	}

	local grad4 = {
		{0,1,1,1},{0,1,1,-1},{0,1,-1,1},{0,1,-1,-1},
		{0,-1,1,1},{0,-1,1,-1},{0,-1,-1,1},{0,-1,-1,-1},
		{1,0,1,1},{1,0,1,-1},{1,0,-1,1},{1,0,-1,-1},
		{-1,0,1,1},{-1,0,1,-1},{-1,0,-1,1},{-1,0,-1,-1},
		{1,1,0,1},{1,1,0,-1},{1,-1,0,1},{1,-1,0,-1},
		{-1,1,0,1},{-1,1,0,-1},{-1,-1,0,1},{-1,-1,0,-1},
		{1,1,1,0},{1,1,-1,0},{1,-1,1,0},{1,-1,-1,0},
		{-1,1,1,0},{-1,1,-1,0},{-1,-1,1,0},{-1,-1,-1,0}
	}

	local p = {
		151,160,137,91,90,15,
		131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
		190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
		88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,
		77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
		102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,
		135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,
		5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
		223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,
		129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,
		251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,
		49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,
		138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
	}

	perm = {}
	permMod12 = {}
	for i=1,256 do
		p[i] = math.random(0,255)
	end
	for i=1,512 do
		perm[i] = p[(i-1)%256+1]
		permMod12[i] = perm[i]%12+1
	end

	F2 = 0.5*(math.sqrt(3.0)-1.0)
	G2 = (3.0-math.sqrt(3.0))/6.0
	F3 = 1.0/3.0
	G3 = 1.0/6.0
	F4 = (math.sqrt(5.0)-1.0)/4.0
	G4 = (5.0-math.sqrt(5.0))/20.0
	
function prepare()
end;

function fastfloor(x)
	local xi = math.floor(x)
	return (x < xi) and (xi-1) or xi
end

function dot(g, x, y)
	return (g.x*x) + (g.y*y)
end

function dot(g, x, y, z)
	return (g.x*x) + (g.y*y) + (g.z*z)
end

function dot(g, x, y, z, w)
	return (g.x*x) + (g.y*y) + (g.z*z) + (g.w*w)
end

function get_2d_noise(xin, yin) 
	local n0, n1, n2
	
	local s = (xin+yin)*F2
	local i = fastfloor(xin+s)
	local j = fastfloor(yin+s)
	local t = (i+j)*G2
	local x0 = i-t
	local y0 = j-t
	local x0 = xin-x0
	local y0 = yin-y0
	
	local i1, j1
	if x0>y0 then 
		i1 = 1
		j1 = 0
	else
		i1 = 0 
		j1 = 1
	end
	
	local x1 = x0 - i1 + G2
	local y1 = y0 - j1 + G2
	local x2 = x0 - 1.0 + 2.0 * G2
	local y2 = y0 - 1.0 + 2.0 * G2
	
	local ii = i & 255
	local jj = j & 255
	local gi0 = permMod12[ii+perm[jj]] -- debug "error : attempt to perform arithmetic on a nil value (field '?')" implies improper handling of i, j, k, l
	local gi1 = permMod12[ii+i1+perm[jj+j1]]
	local gi2 = permMod12[ii+1+perm[jj+1]]
	
	local t0 = 0.5 - x0*x0-y0*y0
	if t0<0 then
		n0 = 0.0
	else
		t0 = t0 * t0
		n0 = t0 * t0 * dot(grad3[gi0], x0, y0)
	end
	local t1 = 0.5 - x1*x1-y1*y1
	if t1<0 then
		n1 = 0.0
	else
		t1 = t1 * t1
		n1 = t1 * t1 * dot(grad3[gi1], x1, y1)
	end
	local t2 = 0.5 - x2*x2-y2*y2
	if t2<0 then
		n2 = 0.0
	else
		t2 = t2 * t2
		n2 = t2 * t2 * dot(grad3[gi2], x2, y2)
	end
	
	return 70.0 * (n0 + n1 + n2)
end

function get_3d_noise(xin, yin, zin)
	local n0, n1, n2, n3
	local s = (xin+yin+zin)*f3
	local i = math.floor(xin+s)
	local j = math.floor(yin+s)
	local k = math.floor(zin+s)
	local t = (i+j+k)*G3
	local x0 = i-t
	local y0 = j-t
	local z0 = k-t
	local x0 = xin-x0
	local y0 = yin-y0
	local z0 = zin-z0
	local i1, j1, k1
	local i2, j2, k2
	if x0>=y0 then
		if y0>=z0 then
			i1=1; j1=0; k1=0; i2=1; j2=1; k2=0
		elseif x0>=z0 then
			i1=1; j1=0; k1=0; i2=1; j2=0; k2=1
		else
			i1=0; j1=0; k1=1; i2=1; j2=0; k2=1
		end
	else -- x0<y0
		if y0<z0 then
			i1=0; j1=0; k1=1; i2=0; j2=1; k2=1
		elseif x0<z0 then
			i1=0; j1=1; k1=0; i2=0; j2=1; k2=1 
		else
			i1=0; j1=1; k1=0; i2=1; j2=1; k2=0
		end
	end
	local x1 = x0 - i1 + g3
	local y1 = y0 - j1 + g3
	local z1 = z0 - k1 + g3
	local x2 = x0 - i2 + 2.0*g3
	local y2 = y0 - j2 + 2.0*g3
	local z2 = z0 - k2 + 2.0*g3
	local x3 = x0 - 1.0 + 3.0*g3
	local y3 = y0 - 1.0 + 3.0*g3
	local z3 = z0 - 1.0 + 3.0*g3
	local ii = bit.band(i, 255)
	local jj = bit.band(j, 255)
	local kk = bit.band(k, 255)
	local gi0 = permMod12[ii+perm[jj+perm[kk+1]]]
	local gi1 = permMod12[ii+i1+perm[jj+j1+perm[kk+k1+1]]]
	local gi2 = permMod12[ii+i2+perm[jj+j2+perm[kk+k2+1]]]
	local gi3 = permMod12[ii+1+perm[jj+1+perm[kk+1+1]]]
	local t0 = 0.6 - x0*x0 - y0*y0 - z0*z0
	if t0<0 then n0 = 0.0 else
		t0 = t0 * t0
		n0 = t0 * t0 * dot(grad3[gi0], x0, y0, z0)
	end
	local t1 = 0.6 - x1*x1 - y1*y1 - z1*z1
	if t1<0 then n1 = 0.0 else
		t1 = t1 * t1
		n1 = t1 * t1 * dot(grad3[gi1], x1, y1, z1)
	end
	local t2 = 0.6 - x2*x2 - y2*y2 - z2*z2
	if t2<0 then n2 = 0.0 else
		t2 = t2 * t2
		n2 = t2 * t2 * dot(grad3[gi2], x2, y2, z2)
	end
	local t3 = 0.6 - x3*x3 - y3*y3 - z3*z3
	if t3<0 then n3 = 0.0 else
		t3 = t3 * t3
		n3 = t3 * t3 * dot(grad3[gi3], x3, y3, z3)
	end
	return 32.0*(n0 + n1 + n2 + n3)
end

function get_4d_noise(x, y, z, w)
	local n0, n1, n2, n3, n4
	local s = (x + y + z + w) * F4
	local i = math.floor(x + s)
	local j = math.floor(y + s)
	local k = math.floor(z + s)
	local l = math.floor(w + s)
	local t = (i + j + k + l) * G4
	local x0 = x - x0
	local y0 = y - y0
	local z0 = z - z0
	local w0 = w - w0
	local rankx = 0
	local ranky = 0
	local rankz = 0
	local rankw = 0
	if x0 > y0 then
		rankx = rankx + 1
	else
		ranky = ranky + 1
	end
	if x0 > z0 then
		rankx = rankx + 1
	else
		rankz = rankz + 1
	end
	if x0 > w0 then
		rankx = rankx + 1
	else
		rankw = rankw + 1
	end
	if y0 > z0 then
		ranky = ranky + 1
	else
		rankz = rankz + 1
	end
	if y0 > w0 then
		ranky = ranky + 1
	else
		rankw = rankw + 1
	end
	if z0 > w0 then
		rankz = rankz + 1
	else
		rankw = rankw + 1
	end
	local i1, j1, k1, l1
	local i2, j2, k2, l2
	local i3, j3, k3, l3
	i1 = (rankx >= 3) and 1 or 0
	j1 = (ranky >= 3) and 1 or 0
	k1 = (rankz >= 3) and 1 or 0
	l1 = (rankw >= 3) and 1 or 0
	i2 = (rankx >= 2) and 1 or 0
	j2 = (ranky >= 2) and 1 or 0
	k2 = (rankz >= 2) and 1 or 0
	l2 = (rankw >= 2) and 1 or 0
	i3 = (rankx >= 1) and 1 or 0
	j3 = (ranky >= 1) and 1 or 0
	k3 = (rankz >= 1) and 1 or 0
	l3 = (rankw >= 1) and 1 or 0
	local x1 = x0 - i1 + G4
	local y1 = y0 - j1 + G4
	local z1 = z0 - k1 + G4
	local w1 = w0 - l1 + G4
	local x2 = x0 - i2 + 2.0*G4
	local y2 = y0 - j2 + 2.0*G4
	local z2 = z0 - k2 + 2.0*G4
	local w2 = w0 - l2 + 2.0*G4
	local x3 = x0 - i3 + 3.0*G4
	local y3 = y0 - j3 + 3.0*G4
	local z3 = z0 - k3 + 3.0*G4
	local w3 = w0 - l3 + 3.0*G4
	local x4 = x0 - 1.0 + 4.0*G4
	local y4 = y0 - 1.0 + 4.0*G4
	local z4 = z0 - 1.0 + 4.0*G4
	local w4 = w0 - 1.0 + 4.0*G4
	local ii = bit.band(i, 255)
	local jj = bit.band(j, 255)
	local kk = bit.band(k, 255)
	local ll = bit.band(l, 255)
	local gi0 = bit.band(perm[ii+perm[jj+perm[kk+perm[ll]]]], 31)
	local gi1 = bit.band(perm[ii+i1+perm[jj+j1+perm[kk+k1+perm[ll+l1]]]], 31)
	local gi2 = bit.band(perm[ii+i2+perm[jj+j2+perm[kk+k2+perm[ll+l2]]]], 31)
	local gi3 = bit.band(perm[ii+i3+perm[jj+j3+perm[kk+k3+perm[ll+l3]]]], 31)
	local gi4 = bit.band(perm[ii+1+perm[jj+1+perm[kk+1+perm[ll+1]]]], 31)
local t0 = 0.6 - x0*x0 - y0*y0 - z0*z0 - w0*w0
if t0 < 0 then
	n0 = 0.0
else
	t0 = t0 * t0
	n0 = t0 * t0 * (x0 * grad4[gi0].x + y0 * grad4[gi0].y + z0 * grad4[gi0].z + w0 * grad4[gi0].w)
end

local t1 = 0.6 - x1*x1 - y1*y1 - z1*z1 - w1*w1
if t1 < 0 then
	n1 = 0.0
else
	t1 = t1 * t1
	n1 = t1 * t1 * (x1 * grad4[gi1].x + y1 * grad4[gi1].y + z1 * grad4[gi1].z + w1 * grad4[gi1].w)
end

local t2 = 0.6 - x2*x2 - y2*y2 - z2*z2 - w2*w2
if t2 < 0 then
	n2 = 0.0
else
	t2 = t2 * t2
	n2 = t2 * t2 * (x2 * grad4[gi2].x + y2 * grad4[gi2].y + z2 * grad4[gi2].z + w2 * grad4[gi2].w)
end

local t3 = 0.6 - x3*x3 - y3*y3 - z3*z3 - w3*w3
if t3 < 0 then
	n3 = 0.0
else
	t3 = t3 * t3
	n3 = t3 * t3 * (x3 * grad4[gi3].x + y3 * grad4[gi3].y + z3 * grad4[gi3].z + w3 * grad4[gi3].w)
end

local t4 = 0.6 - x4*x4 - y4*y4 - z4*z4 - w4*w4
if t4 < 0 then
	n4 = 0.0
else
	t4 = t4 * t4
	n4 = t4 * t4 * (x4 * grad4[gi4].x + y4 * grad4[gi4].y + z4 * grad4[gi4].z + w4 * grad4[gi4].w)
end

return 27.0 * (n0 + n1 + n2 + n3 + n4)
end

local Grad = {
	x = 0, y = 0, z = 0, w = 0
}

function Grad:new(x, y, z)
	local obj = {
		x = x, y = y, z = z
	}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function Grad:new(x, y, z, w)
	local obj = {
		x = x, y = y, z = z, w = w
	}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function get_sample(x, y)
	local noise2D = get_2d_noise(x / noiseScale, y / noiseScale, noiseOctaves, noiseLacunarity, noisePersistence)
	local noise3D = get_3d_noise(x / noiseScale, y / noiseScale, 0, noiseOctaves, noiseLacunarity, noisePersistence)
	local noise4D = get_4d_noise(x / noiseScale, y / noiseScale, 0, 0, noiseOctaves, noiseLacunarity, noisePersistence)

	local r = noise2D
	local g = noise3D
	local b = noise4D
	local a = 1

	return r, g, b, a
	-- return r, 0, 0, a
	-- return 0, g, 0, a
	-- return 0, 0, b, a
end
-- return SimplexNoise
-- ```