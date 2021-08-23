#!/usr/bin/env osascript

on run argv
	set argv to expandOptions of argv given shortOptions: {"a"}, longOptions: {"auto"}
	return argv
end

-- Expand bundled switches and --long-options with values affixed by ‘=’
to expandOptions of argv given shortOptions:shortOptions, longOptions:longOptions
	set opts to {}
	
	repeat while the length of argv > 0
		set arg to the first item of argv

		-- Argument isn't an option
		if arg does not start with "-" then exit
		
		set argv to the rest of argv
		
		-- Terminate option-processing
		if arg equals "--" then exit
		
		-- Expand GNU-style long-option assignment: “--foo=XYZ” ⇒ “--foo XYZ”
		if arg starts with "--" then
			set eql to offset of "=" in arg
			if eql > 0 then
				set val to (characters (eql + 1) through length of arg) as Text
				set arg to (characters 3 through (eql - 1)      of arg) as Text
				if longOptions doesn't contain arg then
					error "option '" & arg & "' doesn't accept an argument"
				end if
				copy {"--" & arg, val} to the end of opts
			else
				copy arg to the end of opts
			end if
		
		-- Expand bundled switches: “-qta…” ⇒ “-q -t -a…”
		else
			repeat with i from 2 to length of arg
				set switch to character i of arg
				copy ("-" & switch) to the end of opts
				
				-- Treat remainder of argument as an option's parameter
				if arg's length - i > 0 and shortOptions contains switch then
					set arg to (characters (i + 1) through length of arg) as Text
					copy arg to the end of opts
					exit
				end if
			end repeat
		end if
	end repeat
	
	return opts & argv
end
