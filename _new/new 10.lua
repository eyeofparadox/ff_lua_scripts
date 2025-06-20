function prepare()
    --Constants
    amplitude_correction_factor = 1.731628995
    roughness_threshold = 0.000000001
    remainder_threshold = 0.000000001
   aspect = OUTPUT_HEIGHT / OUTPUT_WIDTH * 2
    hdr = true -- get_checkbox_input(HDR) tbd
    
    -- Input values
    roughness = get_slider_input(ROUGHNESS)
    roughness = map(roughness, 0, 100, 0, 105)
    details = get_intslider_input(DETAILS)
    noise_size = get_intslider_input(SCALE) * 3
    noise_size = mapToExpScale(noise_size, 1, 900, 6)
    seed = get_intslider_input(NOISE_VARIATION)
    blend_factor = get_slider_input(BLEND_FACTOR) -- Adjust this value to control blending
end

function get_sample(x, y)
    local contrast = (get_sample_grayscale(x, y, CONTRAST) * 2) - 1
    local w = get_sample_grayscale(x, y, TIME)
    local factor = (259 * (contrast + 1)) / (1 * (259 - contrast))

    -- Trigonometric remapping for east-west and north-south seamlessness
    local longitude = x * aspect * math.pi
    local latitude = (y - 0.5) * math.pi
    local nx = math.cos(latitude) * math.cos(longitude)
    local ny = math.cos(latitude) * math.sin(longitude)
    local nz = math.sin(latitude)

    -- Calculate 3D-like noise by interpolating 2D noise values with different seeds
    local v = blend_noise(nx, ny, nz, w)
    local r = blend_noise(nx, ny, nz, w)
    local g = blend_noise(nx, ny, nz, w)
    local b = blend_noise(nx, ny, nz, w)
    local a = 1 -- return solid noise

    -- Normalize and apply any necessary adjustments
    r = truncate(r * 0.5 + 0.5)
    g = truncate(g * 0.5 + 0.5)
    b = truncate(b * 0.5 + 0.5)

    return r, g, b, a
end

function get_perlin_octaves(x,y,z,offset) -- updated function, only inputs remain in prepare()
    set_perlin_noise_seed(seed+offset)

    octaves_count = math.floor(details)
    local remainder = details - octaves_count
    if (remainder > remainder_threshold) then
        octaves_count = octaves_count + 1
    end

     -- artifacts removed from roughness
    roughness = roughness_threshold + roughness * (1.0 - roughness_threshold)

    octaves = {}
    -- removeded unnecessary noise_size adjustments
    local cell_size = noise_size
    local scale = roughness
    local octave_index
    for octave_index = 1, octaves_count do
        if (scale < roughness_threshold) then
            octaves_count = octave_index - 1
            break
        end
        octaves[octave_index] = {cell_size, scale}
        cell_size = cell_size * 0.5
        scale = scale * roughness
    end

    if (remainder >= 0.001) then
        octaves[octaves_count][2] = octaves[octaves_count][2] * remainder
    end

    norm_factor = 0
    for octave_index = 1, octaves_count do
        norm_factor = norm_factor + octaves[octave_index][2] ^ 2
    end
    norm_factor = 1 / math.sqrt(norm_factor)

    local v = 0
    local octave_index
    for octave_index = 1, octaves_count do
        local size = octaves[octave_index][1]
        local opacity = octaves[octave_index][2]
        if z == nil then
            z = octave_index
        else
            z = z + octave_index
        end
        v = v + opacity * (2 * get_perlin_noise(x, y, z, size) - 1)
    end
    v = (v * norm_factor + amplitude_correction_factor) *
        (0.5 / amplitude_correction_factor)
    return v
end

function truncate(value)
    if value <= 0 then value = 0 end
    if value >= 1 then value = 1 end
    return value
end

-- Map functions
function map(value, start1, stop1, start2, stop2)
    -- Avoid division by zero
    if stop1 - start1 == 0 then
        return start2
    else
        return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
    end
end

function mapToLogScale(value, min, max)
    -- Ensure the value is within the slider range
    if value < min then value = min end
    if value > max then value = max end

    -- Normalize the value to range [0, 1]
    local normalized = (value - min) / (max - min)

    -- Apply logarithmic scaling
    local logScale = math.log(normalized + 1) / math.log(12)  -- Base-2 logarithm

    -- Map back to desired scale (if needed)
    local mappedValue = min + logScale * (max - min)

    return mappedValue
end

function mapToExpScale(value, min, max, exponent)
    -- Ensure the value is within the slider range
    if value < min then value = min end
    if value > max then value = max end

    -- Normalize the value to range [0, 1]
    local normalized = (value - min) / (max - min)

    -- Apply exponential scaling with a custom exponent
    local expScale = (normalized ^ exponent)

    -- Map back to desired scale (if needed)
    local mappedValue = min + expScale * (max - min)

    return mappedValue
end

function perlin_noise(x, y, seed_offset)
    set_perlin_noise_seed(seed+seed_offset)
    return get_perlin_octaves(x, y, 0, 500)
end

function blend_noise(x, y, z, w)
    -- Different seed offsets for xy and zw noise functions
    local noise_xy = perlin_noise(x, y, 0)
    local noise_zw = perlin_noise(z, w, 500)

    -- Linear interpolation between noise values
    local blended_noise = noise_xy * (1 - blend_factor) + noise_zw * blend_factor
    return blended_noise
end
