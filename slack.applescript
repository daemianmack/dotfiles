tell the application "Slack"
     -- If we don't activate the application window, then the sub-window can't activate.
     activate
     set theWindow to the first item of (get the windows whose name contains "Slack call |")
     if the index of theWindow is not 1 then
        set the index of theWindow to 2
     end if
end tell
