#!/usr/bin/env osascript

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
