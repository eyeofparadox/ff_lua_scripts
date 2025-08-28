--[[
	```
]]--
--[[
    A speed-improved simplex noise algorithm for 2D, 3D and 4D in Lua.

    Based on example code by Stefan Gustavson (stegu@itn.liu.se).
    Optimisations by Peter Eastman (peastman@drizzle.stanford.edu).
	Lua conversion by David Bryan Roberson (https://github.com/eyeofparadox) in 2023
    Better rank ordering method for 4D by Stefan Gustavson in 2012.

    This could be speeded up even further, but it's useful as it is.

    Version 2012-03-09

    This code was placed in the public domain by its original author,
    Stefan Gustavson. You may use it as you see fit, but attribution is appreciated.
--]]
--[[
	This code is an implementation of Simplex noise in 2D, 3D and 4D in Lua, based on example code by Stefan Gustavson with optimizations by Peter Eastman. Simplex noise is a type of gradient noise that is used for generating natural-looking textures, terrain, and other procedural content.

	The code defines two arrays of gradient vectors (grad3 and grad4) and a permutation table p that is used to shuffle the gradients. It also defines two skewing and unskewing factors (F2 and G2) used in the calculation of the noise.

	The SimplexNoise table contains three functions for generating 2D, 3D, and 4D noise. Each function takes in the coordinates of a point in the respective dimension and returns a noise value between -1 and 1.

	The noise generation functions work by first skewing the coordinates to a new set of coordinates in a higher-dimensional space, then dividing the coordinates into cells and determining the gradient vectors at each vertex of the cells. The noise value at the input coordinates is then calculated as the sum of the dot products of the gradients and the distance vectors between the input point and the cell vertices, passed through a falloff function.

	The code uses bitwise operations and modular arithmetic to efficiently calculate the cell indices and gradient indices.]]--
--[[
	The line local SimplexNoise = {} in simplex noise.lua creates a table named SimplexNoise, which will be used to store all the functions and variables related to the simplex noise algorithm implemented in the Lua script. The table serves as a namespace for the code and helps prevent naming collisions with other parts of the program.
]]--
local SimplexNoise = {} -- Simplex noise in 2D, 3D and 4D

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

local perm = {}
local permMod12 = {}

for i=1, #p do
	-- # is the lua length operator which works on strings or on table arrays.
  perm[i] = p[i-1]
  permMod12[i] = (perm[i] % 12)
end

-- Skewing and unskewing factors for 2, 3, and 4 dimensions
local F2 = 0.5*(math.sqrt(3.0)-1.0)
local G2 = (3.0-math.sqrt(3.0))/6.0
local F3 = 1.0/3.0
local G3 = 1.0/6.0
local F4 = (math.sqrt(5.0)-1.0)/4.0
local G4 = (5.0-math.sqrt(5.0))/20.0

-- This method is a *lot* faster than using (int)Math.floor(x)
	--[[
	The fastfloor() function appears to be a helper function that returns the largest integer value less than or equal to the input value. This is a common function used in noise generation algorithms to calculate the integer grid coordinates of the surrounding points in the noise space.
	]]--
local function fastfloor(x)
  local xi = math.floor(x)
  return (x < xi) and (xi-1) or xi
end

	--[[
	The dot() functions appear to be variations of a function that calculates the dot product between a gradient vector and a position vector in the noise space. This is another common operation in noise generation algorithms, used to calculate the contribution of each gradient vector to the final noise value at a given point.
	]]--
local function dot(g, x, y)
  return (g.x*x) + (g.y*y)
end

local function dot(g, x, y, z)
  return (g.x*x) + (g.y*y) + (g.z*z)
end

local function dot(g, x, y, z, w)
  return (g.x*x) + (g.y*y) + (g.z*z) + (g.w*w)
end

	--[[
	The get_2d_noise(), get_3d_noise(), and get_4d_noise() functions appear to be the main noise generation functions, which take in the coordinates of a point in 2D, 3D, or 4D noise space and return a noise value at that point. These functions likely call the dot() function to calculate the contributions of each gradient vector at the surrounding points in the noise space and then combine those contributions using a suitable interpolation function.
	]]--

-- 2D simplex noise
function get_2d_noise(xin, yin) 
  local n0, n1, n2 -- Noise contributions from the three corners
  
  -- Skew the input space to determine which simplex cell we're in
  local s = (xin+yin)*F2 -- Hairy factor for 2D
  local i = fastfloor(xin+s)
  local j = fastfloor(yin+s)
  local t = (i+j)*G2
  local X0 = i-t -- Unskew the cell origin back to (x,y) space
  local Y0 = j-t
  local x0 = xin-X0 -- The x,y distances from the cell origin
  local y0 = yin-Y0
  
  -- For the 2D case, the simplex shape is an equilateral triangle.
  -- Determine which simplex we are in.
  local i1, j1 -- Offsets for second (middle) corner of simplex in (i,j) coords
  if x0>y0 then 
    i1 = 1
    j1 = 0
  else -- lower triangle, XY order: (0,0)->(1,0)->(1,1)
    i1 = 0 
    j1 = 1
  end -- upper triangle, YX order: (0,0)->(0,1)->(1,1)
  
  -- A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
  -- a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
  -- c = (3-sqrt(3))/6
  local x1 = x0 - i1 + G2 -- Offsets for middle corner in (x,y) unskewed coords
  local y1 = y0 - j1 + G2
  local x2 = x0 - 1.0 + 2.0 * G2 -- Offsets for last corner in (x,y) unskewed coords
  local y2 = y0 - 1.0 + 2.0 * G2
  
  -- Work out the hashed gradient indices of the three simplex corners
  local ii = i & 255
  local jj = j & 255
  local gi0 = permMod12[ii+perm[jj]]
  local gi1 = permMod12[ii+i1+perm[jj+j1]]
  local gi2 = permMod12[ii+1+perm[jj+1]]
  
  -- Calculate the contribution from the three corners
  local t0 = 0.5 - x0*x0-y0*y0
  if t0<0 then
    n0 = 0.0
  else
    t0 = t0 * t0
    n0 = t0 * t0 * dot(grad3[gi0], x0, y0) -- (x,y) of grad3 used for 2D gradient
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
  
  -- Add contributions from each corner to get the final noise value.
  -- The result is scaled to return values in the interval [-1,1].
  return 70.0 * (n0 + n1 + n2)
end

-- 3D simplex noise
function get_3d_noise(xin, yin, zin)
  local n0, n1, n2, n3 -- Noise contributions from the four corners
  -- Skew the input space to determine which simplex cell we're in
  local s = (xin+yin+zin)*F3 -- Very nice and simple skew factor for 3D
  local i = math.floor(xin+s)
  local j = math.floor(yin+s)
  local k = math.floor(zin+s)
  local t = (i+j+k)*G3
  local X0 = i-t -- Unskew the cell origin back to (x,y,z) space
  local Y0 = j-t
  local Z0 = k-t
  local x0 = xin-X0 -- The x,y,z distances from the cell origin
  local y0 = yin-Y0
  local z0 = zin-Z0
  -- For the 3D case, the simplex shape is a slightly irregular tetrahedron.
  -- Determine which simplex we are in.
  local i1, j1, k1 -- Offsets for second corner of simplex in (i,j,k) coords
  local i2, j2, k2 -- Offsets for third corner of simplex in (i,j,k) coords
  if x0>=y0 then
    if y0>=z0 then
      i1=1; j1=0; k1=0; i2=1; j2=1; k2=0 -- X Y Z order
    elseif x0>=z0 then
      i1=1; j1=0; k1=0; i2=1; j2=0; k2=1 -- X Z Y order
    else
      i1=0; j1=0; k1=1; i2=1; j2=0; k2=1 -- Z X Y order
    end
  else -- x0<y0
    if y0<z0 then
      i1=0; j1=0; k1=1; i2=0; j2=1; k2=1 -- Z Y X order
    elseif x0<z0 then
      i1=0; j1=1; k1=0; i2=0; j2=1; k2=1 -- Y Z X order
    else
      i1=0; j1=1; k1=0; i2=1; j2=1; k2=0 -- Y X Z order
    end
  end
  -- A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
  -- a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
  -- a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
  -- c = 1/6.
  local x1 = x0 - i1 + G3 -- Offsets for second corner in (x,y,z) coords
  local y1 = y0 - j1 + G3
  local z1 = z0 - k1 + G3
  local x2 = x0 - i2 + 2.0*G3 -- Offsets for third corner in (x,y,z) coords
  local y2 = y0 - j2 + 2.0*G3
  local z2 = z0 - k2 + 2.0*G3
  local x3 = x0 - 1.0 + 3.0*G3 -- Offsets for last corner in (x,y,z) coords
  local y3 = y0 - 1.0 + 3.0*G3
  local z3 = z0 - 1.0 + 3.0*G3
  -- Work out the hashed gradient indices of the four simplex corners
  local ii = bit.band(i, 255)
  local jj = bit.band(j, 255)
  local kk = bit.band(k, 255)
  local gi0 = permMod12[ii+perm[jj+perm[kk+1]]]
  local gi1 = permMod12[ii+i1+perm[jj+j1+perm[kk+k1+1]]]
  local gi2 = permMod12[ii+i2+perm[jj+j2+perm[kk+k2+1]]]
  local gi3 = permMod12[ii+1+perm[jj+1+perm[kk+1+1]]]
  -- Calculate the contribution from the four corners
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
  -- Add contributions from each corner to get the final noise value.
  -- The result is scaled to stay just inside [-1,1]
  return 32.0*(n0 + n1 + n2 + n3)
end

-- 4D simplex noise, better simplex rank ordering method 2012-03-09
function get_4d_noise(x, y, z, w)
  local n0, n1, n2, n3, n4 -- Noise contributions from the five corners
  -- Skew the (x,y,z,w) space to determine which cell of 24 simplices we're in
  local s = (x + y + z + w) * F4 -- Factor for 4D skewing
  local i = math.floor(x + s)
  local j = math.floor(y + s)
  local k = math.floor(z + s)
  local l = math.floor(w + s)
  local t = (i + j + k + l) * G4 -- Factor for 4D unskewing
  local X0 = i - t -- Unskew the cell origin back to (x,y,z,w) space
  local Y0 = j - t
  local Z0 = k - t
  local W0 = l - t
  local x0 = x - X0 -- The x,y,z,w distances from the cell origin
  local y0 = y - Y0
  local z0 = z - Z0
  local w0 = w - W0
  -- For the 4D case, the simplex is a 4D shape I won't even try to describe.
  -- To find out which of the 24 possible simplices we're in, we need to
  -- determine the magnitude ordering of x0, y0, z0 and w0.
  -- Six pair-wise comparisons are performed between each possible pair
  -- of the four coordinates, and the results are used to rank the numbers.
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
  local i1, j1, k1, l1 -- The integer offsets for the second simplex corner
  local i2, j2, k2, l2 -- The integer offsets for the third simplex corner
  local i3, j3, k3, l3 -- The integer offsets for the fourth simplex corner
  -- [rankx, ranky, rankz, rankw] is a 4-vector with the numbers 0, 1, 2 and 3
  -- in some order. We use a thresholding to set the coordinates in turn.
  -- Rank 3 denotes the largest coordinate.
  i1 = (rankx >= 3) and 1 or 0
  j1 = (ranky >= 3) and 1 or 0
  k1 = (rankz >= 3) and 1 or 0
  l1 = (rankw >= 3) and 1 or 0
  -- Rank 2 denotes the second largest coordinate.
  i2 = (rankx >= 2) and 1 or 0
  j2 = (ranky >= 2) and 1 or 0
  k2 = (rankz >= 2) and 1 or 0
  l2 = (rankw >= 2) and 1 or 0
  -- Rank 1 denotes the second smallest coordinate.
  i3 = (rankx >= 1) and 1 or 0
  j3 = (ranky >= 1) and 1 or 0
  k3 = (rankz >= 1) and 1 or 0
  l3 = (rankw >= 1) and 1 or 0
  -- The fifth corner has all coordinate offsets = 1, so no need to compute that.
  local x1 = x0 - i1 + G4 -- Offsets for second corner in (x,y,z,w) coords
  local y1 = y0 - j1 + G4
  local z1 = z0 - k1 + G4
  local w1 = w0 - l1 + G4
  local x2 = x0 - i2 + 2.0*G4 -- Offsets for third corner in (x,y,z,w) coords
  local y2 = y0 - j2 + 2.0*G4
  local z2 = z0 - k2 + 2.0*G4
  local w2 = w0 - l2 + 2.0*G4
  local x3 = x0 - i3 + 3.0*G4 -- Offsets for fourth corner in (x,y,z,w) coords
  local y3 = y0 - j3 + 3.0*G4
  local z3 = z0 - k3 + 3.0*G4
  local w3 = w0 - l3 + 3.0*G4
  local x4 = x0 - 1.0 + 4.0*G4 -- Offsets for last corner in (x,y,z,w) coords
  local y4 = y0 - 1.0 + 4.0*G4
  local z4 = z0 - 1.0 + 4.0*G4
  local w4 = w0 - 1.0 + 4.0*G4
  -- Work out the hashed gradient indices of the five simplex corners
  local ii = bit.band(i, 255)
  local jj = bit.band(j, 255)
  local kk = bit.band(k, 255)
  local ll = bit.band(l, 255)
  local gi0 = bit.band(perm[ii+perm[jj+perm[kk+perm[ll]]]], 31)
  local gi1 = bit.band(perm[ii+i1+perm[jj+j1+perm[kk+k1+perm[ll+l1]]]], 31)
  local gi2 = bit.band(perm[ii+i2+perm[jj+j2+perm[kk+k2+perm[ll+l2]]]], 31)
  local gi3 = bit.band(perm[ii+i3+perm[jj+j3+perm[kk+k3+perm[ll+l3]]]], 31)
  local gi4 = bit.band(perm[ii+1+perm[jj+1+perm[kk+1+perm[ll+1]]]], 31)
-- Calculate the contribution from the five corners
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

-- Sum up and scale the result to cover the range [-1,1]
return 27.0 * (n0 + n1 + n2 + n3 + n4)
end

-- Inner class to speed up gradient computations
-- (In Lua, array access is a lot faster than member access)
local Grad = {
  x = 0, y = 0, z = 0, w = 0
}

	--[[
	The Grad:new() functions appear to define a gradient vector class that is used in the noise generation algorithm. The new() function creates a new gradient vector with the specified x, y, z, and/or w components. The gradient vectors are used to calculate the dot product with the position vectors in the noise space.
	]]--
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

--[[
	The line `return SimplexNoise` at the end of the script returns the SimplexNoise table as the result of the script when it is executed. This allows the functions and variables defined in the script to be accessed from other parts of the program that require the use of simplex noise.
]]--
return SimplexNoise
--[[
	```
]]--