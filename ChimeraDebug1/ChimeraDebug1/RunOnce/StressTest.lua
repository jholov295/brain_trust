
-- Attempt to hide output with io.popen
-- Most output is hidden, but stderr still gets through
-- TODO: Redirect stderr
function capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- Sleep for a while.
-- This is a duplicate of the sleep(seconds) function in setup,
-- but that shouldn't be a problem because they are exact and
-- don't need to change.
function sleep (seconds)
	local start   = os.clock()
	print(start)
	local current = 0

	repeat
		current = os.clock()
	until ((current - start) >= seconds)
end

-- Print a header like:
-- 0    5    10   15  04/22/10 08:55:50  [0]
-- .......
-- 0    5    10   15  04/22/10 08:55:57  [1]
-- ..............
-- @param trials The number of trials to run; determines width (example 15-19)
-- @param time_print (bool) Print the timestamp if true
-- @param testNumber  The test we're on; ignored if nil
function printProgressHeader (trials, time_print, testNumber)
	io.write("")
	for i = 0, trials do
		if (i % 5 == 0) then
			if i < 10 then
				io.write (i .. "    ")
			elseif i < 100 then
				io.write (i .. "   ")
			else
				io.write(i .. "  ")
			end
		end
	end
	if time_print then io.write(os.date()); end
	if testNumber ~= nil then io.write("  [" .. testNumber .. "]"); end
	io.write("\n")
end

-- Performs trials tests.
-- @param showProgress (bool) Display (or not) the progress header and bar.
-- @param showResult (bool) Print a message summarizing the test result
-- @param testNumber  The test we're on; ignored if nil
function runTests(execStr, trials, showProgress, showResult, testNumber)
	failure = 0
	ttf = 0
	j = 0;
	--Progress header
	if showProgress then
		printProgressHeader(trials, true, testNumber)
	end

	--Loop
	repeat
		j = j + 1
		--Progress tracker
		if showProgress then io.write(".");		end
		local s = capture(execStr, false)
	until (string.find(s, "Error") or (j > trials))
	--End progress tracker
	if showProgress then io.write("\n"); end

	--Output/computation
	if testNumber ~= nil and showResult then
		io.write("Test " .. testNumber .. " ")
	end
	if j > trials then
		if showResult then	print("was OK for   " .. trials .. " trials.");end
	else
		if showResult then	print("failed after " .. j .. " trials.");		end
		failure = 1
		ttf = ttf + j
	end

	return failure, ttf
end
--
--
--
--
--
--
-- [[ MAIN ]]

-- Number of times to test the number of failures.
TESTS = 10
-- Maximum number of successes per test.
TRIALS = 10
-- Count of failures (Not incremented if a test performs TRIALS trials sucessfully)
failures = 0
-- Sum of trials before failure.
tbf_sum = 0
for i = 1, TRIALS do
	failure, ttf = runTests("Chronos.bat ChimeraTester.lua", TRIALS, true, false, i)
	failures = failures + failure
	tbf_sum = tbf_sum + ttf
end

mean_tbf = tbf_sum / failures
print(	"Ran " .. TESTS .. " tests.\nGot " .. failures .. " failures.\nMean TBF was " .. mean_tbf .. ".\n" )
