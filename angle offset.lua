-- angle offset
function prepare()
   -- prepare
   dis = get_slider_input(DISTANCE)
   dir = math.rad(get_angle_input(DIRECTION))
end;

function get_sample(x, y)
   nx = math.sin(dir)
   ny = math.cos(dir)
   -- get source
   x = x + nx * dis
   y = y + ny * dis
   local r, g, b, a = get_sample_map(x,y,SOURCE)
   return v,v,v,1
end;