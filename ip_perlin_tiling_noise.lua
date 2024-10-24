-- Create 256 shuffled numbers
local perm = {}
for i = 1, 256 do
   table.insert(perm, math.random(#perm + 1), i)
end

-- Repeat the list
for i = 1, 256 do
   perm[i+256] = perm[i]
end

-- Generate 256 directions
local dirs = {}
for a = 0, 255 do
   table.insert(dirs, { math.cos(a * 2.0 * math.pi / 256),
                        math.sin(a * 2.0 * math.pi / 256) })
end

local function noise(x, y, per)
   local function surflet(grid_x, grid_y)
      local dist_x, dist_y = math.abs(x - grid_x), math.abs(y - grid_y)
      local poly_x = 1 - 6 * dist_x ^ 5 + 15 * dist_x ^ 4 - 10 * dist_x ^ 3
      local poly_y = 1 - 6 * dist_y ^ 5 + 15 * dist_y ^ 4 - 10 * dist_y ^ 3
      local hashed = perm[(perm[(math.floor(grid_x) % per) + 1] + math.floor(grid_y) % per) + 1]
      local grad = (x - grid_x)  * dirs[hashed][1] + (y - grid_y) * dirs[hashed][2]
      return poly_x * poly_y * grad
   end
   local int_x, int_y = math.floor(x), math.floor(y)
   return surflet(int_x+0, int_y+0) + surflet(int_x+1, int_y+0) +
          surflet(int_x+0, int_y+1) + surflet(int_x+1, int_y+1)
end

local function fBm(x, y, per, octs)
   local val = 0
   for o = 0, octs - 1 do
      val = val + (0.5 ^ o * noise(x * 2 ^ o, y * 2 ^ o, per * 2 ^ o))
   end
   return val
end

local size, freq, octs = 128, 1/32.0, 5

-- Generate 128x128 data points
local data = {}
for y = 1, size do
   local line = {}
   for x = 1, size do
      table.insert(line, math.floor((fBm(x*freq, y*freq, math.floor(size*freq), octs) + 1) * 128))
   end
   table.insert(data, line)
end

-- To demonstrate, let's generate a PGM file,
-- which is easy to convert to PNG.
local out = { "P2", "128 128", "255" }
for y = 1, size do
   local line = {}
   for x = 1, size do
      table.insert(line, tostring(data[y][x]))
   end
   table.insert(out, table.concat(line, " "))
end
local pgm_data = table.concat(out, "\n") .. "\n"

-- And now let's convert it to PNG using ImageMagick.

-- We'll try to do it natively, loading https://github.com/leafo/magick
-- To use it, install it with `luarocks install magick`
-- and run this script with `luajit`.
local ok, magick = pcall(require, "magick")
if ok then
   local im = magick.load_image_from_blob(pgm_data)
   im:set_format("pgm")
   im:write("noise.png")
else
   -- If we don't have the library, let's just call ImageMagick from the command-line.
   local fd = io.open("noise.pgm", "w")
   fd:write(pgm_data)
   fd:close()
   os.execute("convert noise.pgm noise.png")
end