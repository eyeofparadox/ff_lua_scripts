	--[[
	A lua script for filter forge that can identify the lightest, darkest and average values of an image (using the api `local r, g, b, a = get_sample_map(x, y, INPUT)`)This Lua script for Filter Forge that identifies the lightest, darkest, and average values of an image using the get_sample_map API:
	]]
	ˆ
function prepare()
    -- inputs and precalculation
    width, height = OUTPUT_WIDTH, OUTPUT_HEIGHT
    minR, minG, minB = 1, 1, 1
    maxR, maxG, maxB = 0, 0, 0
    sumR, sumG, sumB = 0, 0, 0
    numSamples = 0
end

function get_sample(x, y)
    local r, g, b, a = get_sample_map(x, y, INPUT)
    
    -- Update min and max values
    minR = math.min(minR, r)
    minG = math.min(minG, g)
    minB = math.min(minB, b)
    maxR = math.max(maxR, r)
    maxG = math.max(maxG, g)
    maxB = math.max(maxB, b)
    
    -- Update sum of values
    sumR = sumR + r
    sumG = sumG + g
    sumB = sumB + b
    
    numSamples = numSamples + 1
    
    return r, g, b, a
end

function finalize()
    -- Calculate average values
    local avgR = sumR / numSamples
    local avgG = sumG / numSamples
    local avgB = sumB / numSamples
    
    -- Output the results
    output("Min RGB: " .. minR .. ", " .. minG .. ", " .. minB)
    output("Max RGB: " .. maxR .. ", " .. maxG .. ", " .. maxB)
    output("Average RGB: " .. avgR .. ", " .. avgG .. ", " .. avgB)
end
	--[[
	This script initializes variables in the prepare function, processes each pixel in the get_sample function, and calculates the min, max, and average values in the finalize function.

	You can customize this script further by replacing the INPUT parameter with the actual input image you want to analyze. Simply replace "Min RGB: ..." and "Max RGB: ..." with the desired output format.

	Remember to replace OUTPUT_WIDTH and OUTPUT_HEIGHT with the appropriate values for your output image size.

	Let me know if you have any questions or need further assistance!
	]]