-- source: https://thecodingtrain.com/challenges/136-polar-noise-loops
-- Daniel Shiffman's 'Polar Perlin Noise Loop' (p5.js)
-- Adapted to Filter Forge Lua Script by David Bryan Roberson (Copilot Collaboration)

-- Complete Updated Script
	-- Slider Input: NOISE_MAX, Min: 0, Max: 10, Default: 3, Caption: "Noise Max"
	-- Slider Input: PHASE, Min: 0, Max: 6.28318, Default: 0, Caption: "Phase"
	-- Slider Input: ZOFF, Min: 0, Max: 10, Default: 0, Caption: "Z Offset"
	-- Slider Input: RADIUS_MIN, Min: 0.0, Max: 0.0, Default: 0, Caption: "Min Radius"
	-- Slider Input: RADIUS_MAX, Min: 0.0, Max: 0.5, Default: 0.5, Caption: "Max Radius"
	-- Slider Input: FREQUENCY, Min: 1, Max: 10, Default: 1, Caption: "Noise Frequency"
	-- IntSlider Input: SEED, Min: 1, Max: 1000, Default: 1, Caption: "Seed"

function prepare()
    -- Import parameters
    noiseMax = get_slider_input(NOISE_MAX)
    phase = get_slider_input(PHASE)
    zoff = get_slider_input(ZOFF)
    radius_min = get_slider_input(RADIUS_MIN)
    radius_max = get_slider_input(RADIUS_MAX)
    frequency = get_slider_input(FREQUENCY)
    seed = get_intslider_input(SEED)

    -- Set the seed for noise functions
    set_noise_seed(seed)
    set_perlin_noise_seed(seed)

    -- Constants
    TWO_PI = math.pi * 2
    cos = math.cos
    sin = math.sin

    -- Center coordinates
    centerX, centerY = 0.5, 0.5
end

function get_sample(x, y)
    -- Convert (x, y) to polar coordinates relative to the center
    local dx = x - centerX
    local dy = y - centerY
    local angle = math.atan2(dy, dx) -- Range: -PI to PI
    if angle < 0 then
        angle = angle + TWO_PI -- Normalize angle to 0 to 2*PI
    end
    local dist = math.sqrt(dx * dx + dy * dy)

    -- Calculate noise offsets
    local a = angle + phase
    local xoff = map(cos(a), -1, 1, 0, noiseMax)
    local yoff = map(sin(a), -1, 1, 0, noiseMax)

    -- Compute the perlin noise value
    local noise_value = get_perlin_noise(xoff * frequency, yoff * frequency, zoff * frequency)

    -- Normalize noise_value to [0, 1] (since get_perlin_noise returns values in [-1, 1])
    noise_value = noise_value * 0.5 + 0.5

    -- Map the noise value to a radius
    local r = map(noise_value, 0, 1, radius_min, radius_max)

    -- Determine if the current pixel is inside the shape
    if dist <= r then
        -- Inside the shape
        return 1, 1, 1, 1 -- White color
    else
        -- Outside the shape
        return 0, 0, 0, 1 -- Black color
    end
end

-- Map function
function map(value, start1, stop1, start2, stop2)
    -- Avoid division by zero
    if stop1 - start1 == 0 then
        return start2
    else
        return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
    end
end

-- The next step is transforming this into a generic function that can be called by a 2D or 3D noise_octaves function that can take in arbitrary base coordinates (x, y, z; y, z, x; z, x, y) along with the global parameters. It would not hurt to incorporate additionay enhancements.