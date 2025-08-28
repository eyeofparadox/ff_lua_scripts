function prepare()
    -- v.002.8.1

    -- Get numeric inputs
    frequency = get_intslider_input(FREQUENCY) * 100
    amplitude = math.max(get_slider_input(AMPLITUDE) * 5, 0.01)
    details = math.max(get_intslider_input(DETAILS) * 0.25, 1)
    aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
    seed = get_intslider_input(SEED)

    -- Get checkbox input
    if (get_checkbox_input(HDR)) then
        hdr = true
    else
        hdr = false
    end
end

function get_sample(x, y)
    -- Get map inputs for blend
    local fr, fg, fb, fa = get_sample_map(x, y, FOREGROUND)
    local br, bg, bb, ba = get_sample_map(x, y, BACKGROUND)

    -- Get map inputs for noise
    local roughness = math.max(3.75 - get_sample_grayscale(x, y, ROUGHNESS) * 4.375, 0.01)
    local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
    local sx, sy, sz, sa = get_sample_map(x, y, SCALE)
    local ox, oy, oz, oa = get_sample_map(x, y, OFFSET)
    local dx, dy, dz, da = get_sample_map(x, y, DISTORTION)

    -- Set or adjust internal variables
    local v, s, amp, factor = 0, frequency, amplitude, (259 * (contrast + 1)) / (1 * (259 - contrast))
    sx, sy, sz, sa = sx * 1.25, sy * 1.25, sz * 1.25, sa * 1.25

    -- Adjust seeds for each channel
    local seed_d1 = seed + 100
    local seed_d2 = seed + 200
    local seed_d3 = seed + 300

    -- Trigonometric remapping for east-west and north-south seamlessness
    local longitude = x * aspect * math.pi
    local latitude = (y - 0.5) * math.pi
    local nx = math.cos(latitude) * math.cos(longitude) * (sx * sa) + (ox * oa)
    local ny = math.cos(latitude) * math.sin(longitude) * (sy * sa) + (oy * oa)
    local nz = math.sin(latitude) * (sz * sa) + (oz * oa)

    -- Local octave generation - if rgb noise required, move to function
    for oct = 1, details do
        -- Seed each distortion then restore base seed
        set_perlin_noise_seed(seed_d1)
        local d1 = get_perlin_noise(nx, ny, nz, s) * (dx * da)
        set_perlin_noise_seed(seed_d2)
        local d2 = get_perlin_noise(nx, ny, nz, s) * (dy * da)
        set_perlin_noise_seed(seed_d3)
        local d3 = get_perlin_noise(nx, ny, nz, s) * (dz * da)
        set_perlin_noise_seed(seed)

        -- Generate octaves 
        if oct == 1 then
            v = get_perlin_noise(nx + d1, ny + d2, nz + d3, s)
        else
            v = (v + get_perlin_noise(nx + d1 / oct, ny + d2 / oct, nz + d3 / oct, s) * amp) / (1 + amp)
        end

        -- Update octave parameters for next iteration
        nz = nz * 2
        s = s / 2
        amp = amp / roughness
    end

    -- Apply contrast and profile adjustments to opacity value `v`
    v = truncate(factor * (v - 0.5) + 0.5)
    v = get_sample_curve(x, y, v, PROFILE)

    -- Blend `FOREGROUND` and `BACKGROUND`
    r, g, b, a = blend_normal(br, bg, bb, ba, fr, fg, fb, fa, v, hdr)

    -- Output to canvas
    return r, g, b, a
end

function truncate(value)
	-- This function ensures that `v` stays normalized within [0, 1]
	if value <= 0 then value = 0 end
	if value >= 1 then value = 1 end
	return value
end;

function map(value, start1, stop1, start2, stop2)
	-- Used to remap range (not currently neccessary, but retained for future use)
    if stop1 - start1 == 0 then
        return start2
    else
        return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
    end
end