#!/usr/bin/env osascript

property name:    "DarkMode"
property id:      "com.alhadis.dark-mode"
property version: "1.0.0"

on run argv
	
	-- Parse command-line arguments:
	set auto   to false  --auto,   -a  Get/set auto-switch preference instead of light/dark theme
	set quiet  to false  --quiet,  -q  Don't produce output, just quit with an error code if false
	set toggle to false  --toggle, -t  Toggle relevant property
	set task   to "get"
	
	set argv to expandOptions from argv given ¬
		shortOptions: {monadic: "a",    niladic: "qt"}, ¬
		longOptions:  {monadic: "auto", niladic: "quiet toggle"}	
	repeat
		set argc to the length of argv
		if argc equals 0 then exit
		set arg to first item of argv
		if arg does not start with "-" then exit
		set argv to the rest of argv
		if arg equals "--" then exit
		if {"-a", "--auto"} contains arg then
			set auto to true
			if the length of argv > 0 then
				set arg to the first item of argv
				if arg does not start with "-" or arg isn't contained by ¬
				{"-a", "-q", "-t", "--auto", "--quiet", "--toggle"} then
					set argv to the rest of argv
					set auto to arg
				end if
			end if
		else if {"-q", "--quiet"} contains arg then
			set quiet to true
		else if {"-t", "--toggle"} contains arg then
			set toggle to true
		end if
	end repeat
	if length of argv > 0 then set task to "set"
	
	log argv
	return
	
	tell application "System Events"
		tell appearance preferences
			set isDark to dark mode
			if my getAuto() then
				log (isDark as String) & " (auto)"
			else
				log isDark
			end if
		end tell
	end tell
end

-- Expand bundled switches and --long-options with values affixed by ‘=’
to expandOptions from argv given shortOptions: shortOptions, longOptions: longOptions
	set shortMonadic to characters of monadic of shortOptions
	set shortNiladic to characters of niladic of shortOptions
	set longMonadic  to words      of monadic of longOptions
	set longNiladic  to words      of niladic of longOptions
	set longOptions  to longMonadic  & longNiladic
	set shortOptions to shortMonadic & shortNiladic
	set opts         to {}
	
	repeat while the length of argv > 0
		set arg to the first item of argv

		-- Argument isn't an option, or indicates the end of the options list
		if arg does not start with "-" or arg is "--" then exit
		
		set argv to the rest of argv
		
		-- Expand GNU-style long-option assignment: “--foo=XYZ” ⇒ “--foo XYZ”
		if arg starts with "--" then
			set eql to offset of "=" in arg
			if eql > 0 then
				set val to (characters (eql + 1) through length of arg) as Text
				set arg to (characters 1 through (eql - 1)      of arg) as Text
				if longOptions doesn't contain arg then
					error "unrecognised option: " & arg
				else if longMonadic doesn't contain arg then
					error "option '" & arg & "' doesn't accept an argument"
				end if
				set arg to {"--" & arg, val}
			end if
			copy arg to the end of opts
		
		-- Expand bundled switches: “-qta…” ⇒ “-q -t -a…”
		else
			repeat with i from 2 to length of arg
				set switch to character i of arg
				
				if shortOptions doesn't contain switch then
					error "unrecognised option: -" & switch
				end if
				
				copy ("-" & switch) to the end of opts
				
				-- Treat remainder of argument as an option's parameter
				if arg's length - i > 0 and shortMonadic contains switch then
					set arg to (characters (i + 1) through length of arg) as Text
					copy arg to the end of opts
					exit
				end if
			end repeat
		end if
	end repeat
	
	return opts & argv
end

-- Coerce a boolean-ish string into an actual boolean
to makeBoolean(value)
	if the class of the value isn't String then
		set value to (value as String)
	end if
	if ( ¬
		value starts with "T"   or ¬
		value starts with "Y"   or ¬
		value starts with "On"  or ¬
		value starts with "Enable" ¬
	) then
		return true
	else if ( ¬
		value starts with "F"    or ¬
		value starts with "N"    or ¬
		value starts with "Off"  or ¬
		value starts with "Disable" ¬
	) then
		return false
	else
		considering numeric strings
			try
				return (value as real) ≥ 1
			end try
		end considering
		return null
	end if
end

-- Return TRUE if appearance auto-switching is enabled
to getAuto()
	try
		set auto to (do shell script "defaults read -g AppleInterfaceStyleSwitchesAutomatically 2>/dev/null")
		return makeBoolean(auto)
	end try
	return false
end
