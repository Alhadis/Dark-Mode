#!/usr/bin/env osascript

tell application "System Events"
	tell appearance preferences
		set isDark to dark mode
		log isDark
	end tell
end tell
