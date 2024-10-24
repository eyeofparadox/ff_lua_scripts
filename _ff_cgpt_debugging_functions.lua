script = "_ff_cgpt_debugging_functions.lua"
--[[
	a repository for debugging functions created to test lua map scripts in filter forge: 
]]--

C:\Users\david\AppData\Local\Temp\Filter Forge x64.log


-- name = "test"

function test(...)
	-- take named arguments
	local args = {...}
	local n = #args
	-- use default values in the `options` table for `min`, `max`, and `kind` if they are not provided
	local options = {min=1, max=256, kind="indexed value"}
	-- if `min`, `max`, or `kind` are used as arguments, default values will be overwritten
	local values = {}
	local errors = {}
	-- store both the variable `name` and corresponding`value` in the `values` table
	for i = 1, n, 2 do
		local name = args[i]
		local value = args[i+1]
		-- check `name`
		if type(name) ~= "string" then
			error("Variable name must be a string")
		end
		values[name] = value
	end
	
	for name, value in pairs(values) do
		local result = nil
		-- test and store the `result`
		if value == nil then
			result = "nil"
			errors[name] = true
		elseif value < options.min or value > options.max then
			result = "oob"
			errors[name] = true
		else
			result = "true"
		end
		values[name] = {value=value, result=result}
	end
	-- count errors
	local num_errors = 0
	for name, error in pairs(errors) do
		if error then
			num_errors = num_errors + 1
		end
	end
	
	-- error reporting includes the names, values, and results of all variables tested. 
	if num_errors > 0 then
	local report = ""
	for name, data in pairs(values) do
	report = report .. name .. "=" .. data.value .. "," .. data.result .. "; "
	end
	report = report .. "kind=" .. options.kind
	error("<!> " .. num_errors .. ": " .. report)
	end
	
	return num_errors, options.min, options.max, options.kind
end
	--[[
	to call the `test` function using named arguments:
	• `sum_errors, min, max, kind = test(ix=128, iy=192, iz=64, iw=210, min=1, max=256, kind="permutation")`
	overwrite example: user calls `test("ix"=128, "iy"=192, "iz"=64, "iw"=210, min=10, kind="permutation")`
	• options.min` will be set to `10`, `options.max` will remain `256`, and `options.kind` will be set to `"permutation"`.
	]]--

-- name = "test_args"

function test_args(p, ...)
	local args = {...}
	local n = #args
	local p_range = #p
	local arg_errors = {}
	
	for i = 1, n do
		local v = args[i]
		if v == nil then
			arg_errors[#arg_errors + 1] = "V|" .. i .. " is nil."
		elseif type(v) ~= "table" and type(v) == "number" then
			if (v%1 == 0) and (v < 1 or v > p_range) then
				arg_errors[#arg_errors + 1] = "V|" .. i .. " = " .. v .. " OOB: [1," .. p_range .. "]."
			end;
		end;
	end;
	
	if #arg_errors > 0 then
		local all_args = ""
		for i, v in ipairs(args) do
			all_args = all_args .. tostring(v) .. ", "
		end
		all_args = all_args:sub(1, -3)
		error("<!> " .. table.concat(arg_errors, " ") .. "All arguments: " .. all_args)
	end;
	
	return unpack(args, 1, n)
end;
	--[[
	`test_args` keeps track of any errors in a table, and then if there are any errors, it concatenates all of the arguments together and includes them in the error message.
	]]--

-- name = "test_vars"

function test_vars(...)
	local vars = {...}
	local var_errors = {}
	local n = # vars
	local errors = false
	
	for i = 1, n do
		local v = vars[i]
		if v == nil then
			var_errors[#var_errors + 1] = "V|" .. i .. " nil."
			errors = true
		elseif type(v) ~= "number" then
			var_errors[#var_errors + 1] = "V|" .. i .. " nan."
			errors = true
		elseif v % 1 ~= 0 then
			var_errors[#var_errors + 1] = "V|" .. i .. " int."
		elseif v ~= math.floor(v) then
			var_errors[#var_errors + 1] = "V|" .. i .. " float."
		end
	end
	
	if errors then
		local all_vars = ""
		for i, v in ipairs(vars) do
			all_vars = all_vars .. tostring(v) .. ", "
		end
		all_vars = all_vars:sub(1, -3)
		error("<!> " .. table.concat(var_errors, " ") .. "All variables: " .. all_vars)
	end
	
	return vars, n
end
	--[[
	`test_vars` tests for nil values and sets the appropriate error message and sets errors to true. it also tests for numbers and checks if they are integers or floats, and sets the appropriate error message if needed. finally, if there are any errors, it concatenates all of the variables together and includes them in the error message.
	]]--

-- name == "try_catch" <!> currently freezes ff, probably due to `map`. can try to buffer current sample values only.

-- global variables
local map = {}

	-- in `prepare`: initialize global `map` array
	-- local xa = 600 -- OUTPUT_WIDTH
	-- local ya = 600 -- OUTPUT_HEIGHT
	local xa = OUTPUT_WIDTH
	local ya = OUTPUT_HEIGHT
	-- xa = math.floor(xa) already int
	-- ya = math.floor(ya) already int
	for ym = 1, ya do
		map[ym] = {}
		for xm = 1, xa do
			map[ym][xm] = {0, 0, 0, 0}
		end
	end

	-- in `get_sample`: if `noise4d == 77777` then retrieve channels from `map`
	if noise4d == 77777 then 
		r, g, b, a = map[y][x][1], map[y][x][2], map[y][x][3], map[y][x][4]
	end

	-- in `noise4d`: include 
	catch_n = try_catch(x, y, p, inx, iny, inz, inw)
	if catch_n then return -77777 end

-- `try_catch` function
function try_catch(x, y, p, inx, iny, inz, inw)
	local length = # p
	local catch = false
	local ra, ga, ba, aa
	
	-- revision test each arg for `nil` or out-of-bounds
	-- set fail values or normalize arg values 
	if not p[inx] then
		ra = 0
		catch = true
	elseif (p[inx] < 1 or p[inx] > length) then
		ra = 1
		catch = true
	elseif p[inx] then
		ra = p[inx] / 255
	end
	if not p[iny] then
		ga = 0
		catch = true
	elseif (p[iny] < 1 or p[iny] > length) then
		ga = 1
		catch = true
	elseif p[iny] then
		ga = p[iny] / 255
	end
	if not p[inz] then
		ba = 0
		catch = true
	elseif (p[inz] < 1 or p[inz] > length) then
		ba = 1
		catch = true
	elseif p[inz] then
		ba = p[inz] / 255
	end
	if not p[inw] then
		catch = true
		ra = 1
	elseif (p[inw] < 1 or p[inw] > length) then
		ra = 1
		catch = true
	elseif p[inw] then
		aa = p[inw] / 255
	end
	-- store values for `r`, `g`, `b`, `a` channels of the current sample of get_sample function in `map`
	map[y][x] = {ra, ga, ba, aa}
	
	-- check for errors
	if catch then
		return catch
	end
end
	--[[
	a debugging function for a lua map script in filter forge: its pupose is to evaluate indices used in `noise4d` for `nil` or out-of-bounds conditions. a `map` array will be used to generate feedback as `r`, `g`, `b`, `a` channels that can be used to render the current sample in the main `get_sample` function. A conditional inserted after `try_catch` monitors the boolean `catch_n` and interrupts the host function if it becomes `true` during the current render pass, returning `77777` from `noise4d`. a conditional in `get_sample` will determine if `noise4d == 77777` then retrieve the `r`, `g`, `b`, `a` values from `map` so that `get_sample` can return them.
	]]--
	--[[
	call this function from `noise4d` function with the appropriate arguments. the `map` global variable will be updated with each call to `try_catch`. `map` will store values for the `r`, `g`, `b`, `a` channels of the current sample based on the test results. if an error is detected, the `catch` variable will be set to true, and returned to `noise4d`. the statement after `try_catch` should monitor `catch_n`; if `true` a special value of `77777` will be returned by `noise4d`, bypassing any remaining function code.
	]]--

