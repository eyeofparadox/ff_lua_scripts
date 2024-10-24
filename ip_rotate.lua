-- rotate script
function prepare()
   ox,oy = get_slider_input(ORIGIN_X),get_slider_input(ORIGIN_Y)
   d = math.rad(get_angle_input(ROTATION))
   s,c = math.sin(d), math.cos(d)
end;

function get_sample(x, y)
   local nx = c * (x-ox) - s * (y-oy) + ox
   local ny = s * (x-ox) + c * (y-oy) + oy
   local r,g,b,a = get_sample_map(nx, ny, SOURCE)
   return r,g,b,a
end;