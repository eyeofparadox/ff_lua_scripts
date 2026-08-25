-- 3d rgb perlin spectral
function prepare()
	-- v.002.7.a
	details = get_intslider_input(DETAILS)
	aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
	set_perlin_noise_seed(get_intslider_input(SEED))
	if (get_checkbox_input(HDR)) then
		hdr = true
	else
		hdr = false
	end
end;

function get_sample(x, y)
	local r, g, b, a = get_sample_map(x, y, BACKGROUND)
	local r2, g2, b2, a2 = get_sample_map(x, y, FOREGROUND)
	roughness = 3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 2 + 0.01
	local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
	local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))
	local v = 0
	local osx, osy,  osz, osa = get_sample_map(x, y, OFFSET)
	local dx, dy, dz, da = get_sample_map(x, y, DISTORTION) -- * 2
	local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
	local s = 500
	amp = 1
	local x = x * aspect * math.pi
	local y = y * math.pi
	local z = (x + y) / 2 + math.pi
	local nx = math.cos(x) * math.sin(y) * (sx * sa) + (osx * osa)
	local ny = math.sin(x) * math.sin(y) * (sy * sa) + (osy * osa)
	local nz = math.cos(y) * (sz * sa) + (osz * osa)
	local r, g, b = get_perlin_spectral_full(x,y,z,dx,dy,dz,da,s)
	local a = 1
	
	r  = truncate(factor * (r - 0.5) + 0.5)
	g  = truncate(factor * (g - 0.5) + 0.5)
	b  = truncate(factor * (b - 0.5) + 0.5)
	v  = truncate(factor * (v - 0.5) + 0.5)
	v = get_sample_curve(x,y,v,PROFILE)
	local opacity = v
--	r, g, b, a = blend_normal(r, g, b, a, r2, g2, b2, a2, opacity, hdr)
--	return dx, dy, dz, da
	return r, g, b, a
end;

-- full-spectrum octave perlin
function hsv_to_rgb(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r, g, b
end


function get_perlin_spectral_full(x,y,z,dx,dy,dz,da,s)
    local R, G, B = 0, 0, 0
    local amp = 1

    for oct = 1, details do
        -- octave → hue (0..1)
        local h = (oct - 1) / (details - 1)

        -- full-spectrum hue → RGB
        local wr, wg, wb = hsv_to_rgb(h, 1.0, 1.0)

        -- distortion
        local d1 = get_perlin_noise(x+1,y,z,s) * (dx * da)
        local d2 = get_perlin_noise(x+2,y,z,s) * (dy * da)
        local d3 = get_perlin_noise(x+3,y,z,s) * (dz * da)

        local v = get_perlin_noise(x + d1, y + d2, z + d3, s)

        -- accumulate weighted by octave hue
        R = R + v * wr * amp
        G = G + v * wg * amp
        B = B + v * wb * amp

        -- next octave
        z = z * 2
        s = s / 2
        amp = amp / roughness
    end

    return R, G, B
end
