A Tech/Mech wall or greeble componant pattern maker. This expansion on the original Technical Panels generates a wider range of compatible designs. Provides a complete set of surface textures, with a variety of customizable designs. Try different base noise, formulas, curvature, complexity, alternate geometry, metal morph, texture scale, stretching, plus primary, secondary and tertiary color and PBR controls. The Offset controls allow for quick and easy changes to an entire color scheme, but they do wrap, which can be a little counter-intuitive at times. You may prefer to ignore them in favor of keeping control of the results. The lack of drop down menu titles make it simpler to handle metal albedo  values manually, so those are provided here. 

Metals PBR Values

Copper [fad0c0], Brass [d6b97b], Gold [ffe29b], Silver [fcfaf5], Platinum [d5d0c8], Chrome[c4c5c5], Nickel [d3cbbe], Iron  [c4c7c7], Titanium [c1bab1], Aluminum [f5f6f6], Cobalt [d3d2cf], Zinc [d5eaed], Mercury [e5e4e4], Palladium [ded9d3] 

https://digitalcolony3d.wordpress.com/2019/07/25/albedo-chart/



Re: Is there a known system of converting degrees to (x,y) coordinates?
« Reply #2 on: June 08, 2013, 08:51:05 PM »
http://en.wikipedia.org/wiki/Polar_coordinate_system

x = r * cos(a)
y = r * sin(a)

(r=1 in a unit circle)

to convert from degrees to radians do this:

cos(degrees*pi/180)*distance - this will convert degrees to change of x
sin(degrees*pi/180)*distance - this will convert degrees to change of y

in other words, let's say you wanted to move an object 17 pixels in a direction of 257 degrees

what you'd do is

x += cos(257*pi/180)*17;
y += sin(257*pi/180)*17;

if you're using game maker, this is equivalent to lengthdir_x() and lengthdir_y()

You may want to take the chance to learn how to work in radians instead of degrees. It's especially easy if you realize that π (pi) is wrong and start using τ (tau) instead:
http://tauday.com/

90° is a quarter of a circle ->  τ/4 radians.
180° is a half of a circle ->  τ/2 radians
270° is 3/4 of a circle -> τ*3/4 radians



Here's a classic and a tribute to my highschool math formula that was saved on a TI-83. Puzzle this one out...

function prepare()
value1 = get_slider_input(NUMBER)
end;

function get_sample(x, y)
w = (x+(value1)*3*math.sin(y*x))*0.2
u = (w+(value1)*3*math.sin(y*x))*0.2
return w, u, w, a
end;



function prepare()	v = get_slider_input(RANDOM_SEED)	function get_random(v, x, y)		n1 = math.mod((v*(5+x+y)+0.103469371759376473),1)/1		return n1	endend;function get_sample(x, y)	v = get_random (v, x, y)	local r = v	local g = v	local b = v	local a = 1	return r, g, b, aend;



