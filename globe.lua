-- Color globe, light and add atmosphere
function prepare()
	radius = get_slider_input(RADIUS)
	sea_level = get_slider_input(SEA_LEVEL)
	sea_power = get_intslider_input(SEA_POWER)

	--light direction flipped
	toRad = 180/math.pi
	lax = get_angle_input(LIGHTING_X)
	lay = get_angle_input(LIGHTING_Y)
	lightx = 0
	lighty = 0
	lightz = 1
		--rotate for y
	local angle = math.rad(get_angle_input(LIGHTING_Y))
	local cosa = math.cos(angle)
	local sina = math.sin(angle)
	local tx = -sina * lightz -- + (cosa * lightx) 
   local tz = cosa * lightz -- + (sina * lightx)
		--rotate for x
	lightx = tx
	lighty = 0
	lightz = tz
	angle = math.rad(get_angle_input(LIGHTING_X))
	cosa = math.cos(angle)
	sina = math.sin(angle)
	tx = cosa * lightx
   local ty = sina * lightx
	lightx = tx
	lighty = ty
	
	light_sharpness = get_slider_input(LIGHTING_SHARPNESS)*8
	light_sharpness = 1 + (light_sharpness*light_sharpness)

	--atmosphere
	ainner_size = get_slider_input(ATMOS_INNER)
	ainner = 1.0-ainner_size
	aouter_size = get_slider_input(ATMOS_OUTER)
	aouter = 1.0 + aouter_size
	anoise_level = get_slider_input(ATMOS_NOISE_LEVEL)
	anoise_level = math.sqrt(anoise_level)
end;


function get_sample(x, y)
	-- Image generation
	local px = (x*2.0) - 1.0
	local py = (y*2.0) - 1.0
	px = px/radius
	py = py/radius
	local len = math.sqrt((px*px)+(py*py))
	local pz = 0
	if len >= 1.0 then
		px = px/len
		py = py/len
	else 
		pz = math.sqrt(1.0 - ((px*px)+(py*py)))
	end

	local r = 0
	local g = 0
	local b = 0
	local a = 0

	if len <= 1.0 then
		local v = get_sample_curve(x, y, get_sample_grayscale(x, y, NOISE), LAND_CURVE)

		if v >= sea_level then
			v = (v-sea_level)/(1.0-sea_level)
			r, g, b, a = get_sample_map(v, 0, LAND_COLOR)			
		else
			v = v/sea_level
			r, g, b, a = get_sample_map(math.pow(v,sea_power), 0, SEA_COLOR)
			v = 0
		end

		a = 1
	end
	

	--lighting approximation - smoothed to avoid poor looking gradient
	local l = (lightx * px) + (lighty * py) + (lightz * pz)
	l = -get_sample_curve(0, 0, -l, LIGHT_CURVE)
	l = 1.0 + (light_sharpness*l)
	if l > 1 then l = 1 end
	if l < 0 then l = 0 end
	
	--atmosphere, outer
	local ar,ag,ab,aa = get_sample_map(0, 0, ATMOS_COLOR)
	local offset = 1.0
	if len > 1.0 then 
		l = math.sqrt(l)
		if len < aouter then			
			local size = aouter_size
			if anoise_level > 0.01 then
				local ang = math.atan2(px,py)
				if ang < 0 then ang = ang + (math.pi*2) end
				ang = ang/(math.pi*2)
				local v = get_sample_grayscale(ang, 0, ATMOS_NOISE)
				if ang > 0.95 then--wrap noise smoothly
					local a1 = (1.0-ang)*20
					local v2 = get_sample_grayscale(0.001, 0, ATMOS_NOISE)
					v = (v*a1)+(v2*(1.0-a1))
				end
				size = v*aouter_size*l--atmos length scale down for lighting edge
				size = (aouter_size*(1.0-anoise_level))+(anoise_level*size)
			end
			offset = (len-1.0)/size			
			if offset > 1.0 then offset = 1.0 end
		end
		return ar,ag,ab,aa*(1.0-offset)*l
	--inner
	else
		len = 1.0-math.sqrt(1.0 - ((px*px)+(py*py)))
		if len > ainner then		
			len = (len-ainner)/ainner_size
			offset = 1.0-(len*len)
		end
	end
	aa = aa*(1.0-offset)
	aa = aa*l
	local maa = 1.0-aa

	local cloudr, cloudg, cloudb, clouda = get_sample_map(x, y, CLOUD_MAP)
	
	if clouda > 0.0001 then
		local clouda2 = 1.0-clouda
		r = (r*clouda2)+(cloudr*clouda)
		g = (g*clouda2)+(cloudg*clouda)
		b = (b*clouda2)+(cloudb*clouda)
	end

	return (l*r*maa)+(ar*aa), (l*g*maa)+(ag*aa), (l*b*maa)+(ab*aa), a
end;