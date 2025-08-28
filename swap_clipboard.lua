C:\Users\david\AppData\Local\Temp\Filter Forge x64.log
-- 
	--[[
		...
	]]--

Converting between languages. You can get Codex to convert from one language to another by following a simple format where you list the language of the code you want to convert in a comment, followed by the code and then a comment with the language you want it translated into.

# Convert this from Python to R
# Python version

[ Python code ]

# End

# R version


# Convert this from Java to Lua
# Java version version 1.4.2_19

[
]

# End

# Lua version 5.1

Self Scaling, Terrain Erosion Lab, Height Slope - Erosion?, Cell Rotation, Landmass Concept, Object Lab, Planet Lab.Warp, Texture Mapping Lab, Object Lab

# Convert this from C# to Lua
# Lua version 5.1

[
]

# End

# Lua version 5.1


This is a lua script for a Filter Forge Map Script component. 


function prepare()
	-- This function is called once,
	-- before the rendering begins.
	-- Use it for querying non-mapped
	-- inputs and precalculation.
end;

function get_sample(x, y)
	-- Image generation code goes here.
	local r = x
	local g = y
	local b = (x + y) / 2
	local a = 1
	return r, g, b, a
end;


an example of how you could integrate the Simplex Noise code from simplex noise.lua into the get_sample function:

-- Import SimplexNoise module
local SimplexNoise = {}

-- Insert SimplexNoise code here (from line 1 to 424)

-- Define global variables
local noiseScale = 50
local noiseOctaves = 4
local noiseLacunarity = 2.0
local noisePersistence = 0.5

function prepare()
	-- This function is called once,
	-- before the rendering begins.
	-- Use it for querying non-mapped
	-- inputs and precalculation.

	local grad3 = {
		{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0},
		{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1},
		{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}
	}

	local grad4 = {
		{0,1,1,1}, {0,1,1,-1}, {0,1,-1,1}, {0,1,-1,-1},
		{0,-1,1,1}, {0,-1,1,-1}, {0,-1,-1,1}, {0,-1,-1,-1},
		{1,0,1,1}, {1,0,1,-1}, {1,0,-1,1}, {1,0,-1,-1},
		{-1,0,1,1}, {-1,0,1,-1}, {-1,0,-1,1}, {-1,0,-1,-1},
		{1,1,0,1}, {1,1,0,-1}, {1,-1,0,1}, {1,-1,0,-1},
		{-1,1,0,1}, {-1,1,0,-1}, {-1,-1,0,1}, {-1,-1,0,-1},
		{1,1,1,0}, {1,1,-1,0}, {1,-1,1,0}, {1,-1,-1,0},
		{-1,1,1,0}, {-1,1,-1,0}, {-1,-1,1,0}, {-1,-1,-1,0}
	}

	local p = {}
	for i=1,256 do
		p[i] = math.random(0,255)
	end
	for i=1,512 do
		perm[i] = p[(i-1)%256+1]
		permMod12[i] = perm[i]%12+1
	end

	local F2 = 0.5*(math.sqrt(3.0)-1.0)
	local G2 = (3.0-math.sqrt(3.0))/6.0
	local F3 = 1.0/3.0
	local G3 = 1.0/6.0
	local F4 = (math.sqrt(5.0)-1.0)/4.0
	local G4 = (5.0-math.sqrt(5.0))/20.0

end;

function get_sample(x, y)
  -- Generate noise values
  local noise2D = SimplexNoise.get_2d_noise(x / noiseScale, y / noiseScale, noiseOctaves, noiseLacunarity, noisePersistence)
  local noise3D = SimplexNoise.get_3d_noise(x / noiseScale, y / noiseScale, 0, noiseOctaves, noiseLacunarity, noisePersistence)
  local noise4D = SimplexNoise.get_4d_noise(x / noiseScale, y / noiseScale, 0, 0, noiseOctaves, noiseLacunarity, noisePersistence)

  -- Image generation code goes here.
  local r = noise2D
  local g = noise3D
  local b = noise4D
  local a = 1

  return r, g, b, a
end
--[[
In this example, we first load the simplex noise.lua module using require, and create a new SimplexNoise object. Then, inside the get_sample function, we use the get_2d_noise function of the noise2d object to generate a noise value at the given x and y coordinates. We then map this noise value to color values for the red, green, and blue channels, and return the resulting color values.
]]--

an example implementation of a tileable and periodic Simplex noise function in Lua:




By the way, is there a way to format the code in my posts like yours?
Yes, there is a way to format code in your posts. You can use Markdown syntax to achieve this.

To format a code block in your post, you can start and end the block with three backticks (`). For example:


--[[]]--


generate seamless 3d multi-octave worley noise function using lua version 5.1
create functions:

calculate distance mapping
using int distance_type (1 is Euclidean, 2 is Manhattan, 3 is Chebyshev, 4 is Minkowski, 5 is Quadratic),
using int distance_formula (1	is first closest seed point, 2 issecond closest seed point, 3 is third closest seed point, 4 is fourth closest seed point)
return noise = result of distance mapping


--[[
	generate spherical projection function with x, y, z rotation controls returns x, y using lua version 5.1
]]--

function sphericalProjection(xRot, yRot, zRot)
  local x = math.sin(yRot) * math.cos(xRot)
  local y = math.sin(xRot)
  
  x = x * math.cos(zRot) - y * math.sin(zRot)
  y = x * math.sin(zRot) + y * math.cos(zRot)

  return x, y
end


--[[
	generate polar_to_cartesian coordinates function returns x, y, z using lua version 5.1
]]--

-- polar to cartesian coordinate conversion function
function polar_to_cartesian(r, theta, phi)
	local x = r * math.sin(theta) * math.cos(phi)
	local y = r * math.sin(theta) * math.sin(phi)
	local z = r * math.cos(theta)
	return x, y, z
end

--[[
	generate cartesian_to_polar coordinates function returns theta, phi using lua version 5.1
]]--

-- cartesian to polar coordinate conversion function
function cartesian_to_polar(x, y, z)
	local r = math.sqrt(x^2 + y^2 + z^2)
	local theta = math.acos(z/r)
	local phi = math.atan2(y, x)
	return theta, phi
end


--[[
	generate equatorial mapping coordinates function using lua version 5.1
	function takes in hour, minute, second, ra and dec and returns the equatorial mapping coordinates
	calculates the Julian date using the given hour, minute and second
	calculates the galactic coordinates (l, b) by converting the equatorial coordinates (ra, dec) using equatorial_to_galactic function
	converts the galactic coordinates back to equatorial coordinates (x, y) using galactic_to_equatorial function
	galactic_to_equatorial function also uses the precession_j2000_to_date function to account for the precession of the Earth's axis
]]--

function equatorial_mapping_coordinates(hour, minute, second, ra, dec)
  local jd = get_julian_date(hour, minute, second)
  local l, b = equatorial_to_galactic(ra, dec)
  local x, y = galactic_to_equatorial(l, b, jd)
  return x, y
end

function get_julian_date(hour, minute, second)
  return (367 * year - trunc((7 * (year + trunc((month + 9) / 12))) / 4) +
    trunc((275 * month) / 9) + day + 1721013.5 +
    (hour + (minute / 60) + (second / 3600)) / 24
end

function equatorial_to_galactic(ra, dec)
  local l = math.deg(math.atan2(
    math.sin(math.rad(ra - 6.5)),
    math.cos(math.rad(ra - 6.5)) * math.sin(math.rad(dec)) -
    math.tan(math
      .rad(27.4)) * math.cos(math.rad(dec))
  ))
  local b = math.deg(math.asin(
    math.sin(math.rad(dec)) * math.sin(math.rad(27.4)) +
    math.cos(math.rad(dec)) * math.cos(math.rad(27.4)) *
    math.cos(math.rad(ra - 6.5))
  ))
  return l, b
end

function galactic_to_equatorial(l, b, jd)
  local ra = math.deg(math.atan2(
    math.sin(math.rad(l)) * math.cos(math.rad(27.4)) -
    math.tan(math.rad(b)) * math.sin(math.rad(27.4)),
    math.cos(math.rad(l))
  )) + 6.5
  local dec = math.deg(math.asin(
    math.sin(math.rad(b)) * math.sin(math.rad(27.4)) +
    math.cos(math.rad(b)) * math.cos(math.rad(27.4)) *
    math.sin(math.rad(l))
  ))
  -- Precession (J2000 -> date)
  local x, y = precession_j2000_to_date(ra, dec, jd)
  return x, y
end

function precession_j2000_to_date(ra, dec, jd)
  local T = (jd - 2451545.0) / 36525.0
  local zeta = (2306.2181 + (1.39656 - 0.000139 * T) * T) * T / 3600
  local z = (2306.2181 + (1.39656 - 0.000139 * T) * T) * T / 3600
  local theta = (2004.3109 - (0.85330 + 0.000217 * T) * T) * T / 3600
  local A = math.rad(ra - (zeta * math.cos(math.rad(dec)) +
    z * math.sin(math.rad(dec))))
  local B = math.rad(dec - (zeta * math.sin(math.rad(dec)) -
    z * math.cos(math.rad(dec))))
  local x = math.deg(math.atan2(
    math.sin(A) * math.cos(math.rad(theta)) +
    math.tan(B) * math.sin(math.rad(theta)),
    math.cos(A)
  ))
  local y = math.deg(math.asin(
    math.sin(B) * math.cos(math.rad(theta)) -
    math.cos(B) * math.sin(math.rad(theta)) *
    math.sin(A)
  ))
  return x, y
end

