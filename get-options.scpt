#!/usr/bin/env osascript

script CLI
	property options: script
		property length:     0
		property list:       {}
		property longNames:  {}
		property shortNames: {}
	end
	
	-- Define a new option
	on option from props
		local option
		set option to {¬
			names:       {}, ¬
			description: "", ¬
			parameter:   "", ¬
			type:        Boolean ¬
		} & props & {value: missing value}
		copy a reference to the option to the end of the list of my options
		repeat with i from 1 to length of option's names
			set name to item i of names
			validate(name)
			if name starts with "--" then
				copy name to the end of the longNames of options
			else if name starts with "-" then
				copy name to the end of the shortNames of options
			end if
		end repeat
		set length to length + 1
	end
	
	-- Retrieve an option record by its -short or --long-name
	on find(name)
		repeat with i from 1 to length of list
			if names of item i of list contains name then
				return item i of list
			end if
		end repeat
		return null
	end
	
	-- Validate the name of an option being defined 
	on validate(name)
		if name does not start with "-" ¬
		or name starts with "--=" ¬
		or name equals "--" ¬
		or name equals "-" ¬
			then error "invalid option name: " & name
		if name is contained by longNames ¬
		or name is contained by shortNames ¬
			then error "option '" & name & "' is already defined"
	end
	
	-- Parse command-line arguments
	on parse(argv)
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
					set arg to (characters 1 through (eql - 1)      of arg) as Text
					if longOptions doesn't contain arg then
						error "unrecognised option: " & arg
					else if parameter of find(arg) is "" then
						error "option '" & arg & "' doesn't accept an argument"
					end if
					set arg to {"--" & arg, val}
				end if
				copy arg to the end of opts
			
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
end

tell Options
	add ({names: {"-a", "--auto"},   description: "Get/set auto-switch preference instead of light/dark theme"})
	add ({names: {"-q", "--quiet"},  description: "Don't produce output, just quit with an error code if false"})
	add ({names: {"-t", "--toggle"}, description: "Toggle relevant property"})
end tell
