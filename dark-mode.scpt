#!/usr/bin/env osascript

use script "CLI"

property name:    "DarkMode"
property id:      "com.alhadis.dark-mode"
property version: "1.0.0"
property parent:  CLI

on run argv
	set argv to parse argv given options: {}
end

-- Return TRUE if appearance auto-switching is enabled
to getAuto()
	try
		set auto to (do shell script "defaults read -g AppleInterfaceStyleSwitchesAutomatically 2>/dev/null")
		return makeBoolean(auto)
	end try
	return false
end

on run argv
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
