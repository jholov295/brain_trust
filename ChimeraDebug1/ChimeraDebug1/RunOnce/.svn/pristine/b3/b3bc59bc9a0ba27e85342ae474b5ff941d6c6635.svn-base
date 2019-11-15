--Utils for ChimeraTester [Refactoring sandbox]

if not _UTILITIES then
	_UTILITIES = true

	--[==[ TABLE UTILITY FUNCTIONS --]==]

	--[=[ TABLE COPY --]=]

	--[[ Deep table copy
	-- Makes new instances of all its objects,
	-- including tables (and tables in those tables)
	-- Set the "meta" parameter to change metatable copy options:
	--		"Anonymous" - Use a reference to the original metatable
	--		"Duplicate" - Create a new metatable identical to the old one
	-- 		nil 		- Use the default table creator metatable (nil)
	--		[Other]		- Error
	--]]
	function tcopy(object, meta)
		local lookup_table = {}

		local function _copy(object)
			if type(object) ~= "table" then
				return object
			elseif lookup_table[object] then
				return lookup_table[object]
			end

			local new_table = {}
			lookup_table[object] = new_table

			for index, value in pairs(object) do
				new_table[_copy(index)] = _copy(value)
			end

			if meta == "Anonymous" then
				return setmetatable(new_table, getmetatable(object))
			elseif meta == "Duplicate" then
				return setmetatable(new_table, _copy(getmetatable(object)))
			elseif meta == nil then
				--WARNING: This will not work for metatables whose metatable is non-nil
				return setmetatable(new_table, nil)
			else
				error("Invalid meta option.")
			end
		end

		return _copy(object)
	end

	--[=[ TABLE PRINT --]=]

	-- Alphabetizer
	-- Returns true if arguments are in the alphabetical order.
	-- Numbers come before strings.
	-- Case does not matter (ex. SourceId < STmin)
	function alphabetical (a, b)
		if type(a) == "number" or type (b) == "number" then
			return a < b
		else
			return a:upper() < b:upper()
		end
	end
	-- Ordered iterator
	-- Returns the elements of a table ordered by their keys.
	-- Order is determined by f, a function which returns true if its
	-- two arguments are in the correct order.  If f is nil, the < operator
	-- is used.
	function pairsByKeys (t, f)
		--Build alphabetized table a from table t
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)

		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then
				return nil
			else
				return a[i], t[a[i]]
			end
		end

		return iter
	end

	--[[ Recursive table printer
	-- Writes tables in lua table constructor syntax
    --]]
	function tprint (t, indent, done, name)

		if type(t) ~= "table" then
			error("Invalid argument: t parameter (String:"..tostring(t)..": is not a table.")
		end
		done = done or {}
		indent = indent or 0

		if name then
			io.write(string.rep ("\t", indent))
			io.write(name .. " = {\n" )
			indent = indent + 1
			name = nil
			nameCloser = true;
		end


		for key, value in pairsByKeys (t, alphabetical) do
			io.write(string.rep ("\t", indent))
			if type (value) == "table" and not done [value] then
				done [value] = true
				io.write (tostring (key)," = {\n");
				tprint (value, indent + 1, done)
				io.write(string.rep ("\t", indent + 1), "},\n")
			else
				if type (key) == "number" then
					if type(value) == "string" then
						io.write ("[", tostring (key), "]"," = \"", value, "\",\n");
					else
						io.write ("[", tostring (key), "]"," = ", value, ",\n");
					end
				else --key is a string (OK, so it could be a userdata...right?)
					if type(value) == "string" then
						io.write (tostring (key)," = \"", value, "\",\n");
					else
						io.write (tostring (key)," = ", value, ",\n");
					end
				end
			end
		end
		if nameCloser then
			io.write(string.rep ("\t", indent - 1))
			io.write( "},\n" )
		end
	end

	--Prints a simple array.
	function printArray(array)
		for i,v in ipairs(array) do
			print("[" .. i .. "]",v)
		end
	end

	--[==[ INPUT AND OUTPUT FUNCTIONS --]==]

    indent = 0

	function comment(msg, prefix)
		--No prefix if 0
		--Repeat ' ' prefix times if number
		--Or, write if string
		--Default newline prefix.
		if prefix ~= 0 and type(prefix) == "number" then
			io.write(string.rep(" ", prefix))
		elseif type(prefix) == "string" then
			io.write(prefix)
		elseif not prefix then
			io.write("\n")
		end

		io.write(string.rep (" ", indent))
		io.write(msg)

	end

	function inc(increment)
		increment = increment or 1
		indent = indent + increment
	end
	function dec(decrement)
		decrement = decrement or 1
		indent = indent - decrement
		if indent < 0 then
			indent = 0
		end
	end


	--[[ Prompt --]]
	if TEAMCITY then
		prompt = error("Prompt should not be needed when triggered by TeamCity.\nHow did you get here?", 2)
	elseif _LEXECUTOR then
		prompt = lExecutor.Prompt
	else
		prompt = function (message)	print(message);	return io.stdin:read("*line")	end
	end

	if not TEAMCITY then
		--[[ Check for a yes or no answer.
			Returns true if "Yes", "yes", 'Y', or 'y' is entered, and
			returns false if "No", "no",  'N', or 'n' is entered.
			Otherwise, it prompts the user for another answer.
		--]]
		function yes(answer)

			if (	 string.find(answer, "Yes") ~= nil
				  or string.find(answer, "yes") ~= nil
							or answer == 'Y'
							or answer == 'y') then
				return true
			elseif  (string.find(answer, "No") ~= nil
				  or string.find(answer, "no") ~= nil
							or answer == 'N'
							or answer == 'n')  then
				return false
			end

			--Recursively call until a valid answer is given.
			return prompt("Invalid answer:", answer, ". Enter yes or no:");
		end
	else
		yes = error("'Yes' function should not be needed when triggered by TeamCity.\nHow did you get here?", 2)
	end
	--[[ Captures and returns the output of a system call.
		Also redirects stderr to stdout, by adding 2>&1 to the
		command call. This will break on commands which already redirect.
		If 'raw' is true, the output will be parsed into one
		string, removing line breaks, tabs, or prompts. Otherwise, the raw
		data is returned.
	--]]
	function os.capture(cmd, raw)

		local f = assert(io.popen(cmd .. " 2>&1", 'r'))

		local s = assert(f:read('*a'))

		f:close()

		if raw then
			return s
		end

		s = string.gsub(s, '^%s+', '')
		s = string.gsub(s, '%s+$', '')
		s = string.gsub(s, '[\n\r]+', ' ')

		return s
	end

	--[[ Executes a command without popping open a command window (From Lexecutor).
		If in command line mode, it just executes it.
		This function does not return the result of running the command
		as os.capture does above. Choose carefully.
	--]]
	function exec(cmd)
		if (_LEXECUTOR) then
			process = wx.wxProcess()
			process:Redirect()
			wx.wxExecute(cmd, wx.wxEXEC_SYNC, process)
		else
			os.execute(cmd)
		end
	end


	--[==[ MISCELLANEOUS FUNCTIONS --]==]

	--[[ Sleep for a while.
		Uses the os.clock function, which theoretically provides millisecond
		resolution (but is limited by the system tick rate to 15ms on Windows.)
		Note that this is the CPU time allocated to the program and not actual
		clock time - Therefore, this sleep will be at least as long as desired,
		but could be longer if the system is under heavy load.
        Use fractional seconds if more precise timing is required.
        (ex. sleep(0.030) = 30ms)
	--]]
	function sleep (seconds)
		local start   = os.clock()
		local current = 0

		repeat
			current = os.clock()
		until ((current - start) >= seconds)
	end
end
