-- maurer rose https://en.wikipedia.org/wiki/Maurer_rose
-- 

n = 2	-- slider
d = 29	-- slider

for i = 0, 361 do
	local k = i * d -- angel
	local r = sin(n * k)	-- expand by scale; * 150
	x = r * cos(k)
	y = r * sin(k)

for j = 0, 361 do
	local k = j -- angel
	local r = sin(n * k)	-- expand by scale; * 150
	x = r * cos(k)
	y = r * sin(k)	
	
	-- check scale; variable?