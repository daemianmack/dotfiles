my_key = {"shift", "cmd"}
qux_key = {"ctrl", "cmd"}

hs.window.animationDuration = 0


function moveRightHalf()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   f.x = max.x + (max.w / 2)
   f.y = max.y
   f.w = max.w / 2
   f.h = max.h
   win:setFrame(f)
end

function moveLeftHalf()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   f.x = 0
   f.y = max.y
   f.w = max.w / 2
   f.h = max.h
   win:setFrame(f)
end

function fullScreen()
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   f.x = 0
   f.y = max.y
   f.w = max.w
   f.h = max.h
   win:setFrame(f)
end


hs.hotkey.bind(qux_key, "1", moveRightHalf)
hs.hotkey.bind(qux_key, "2", moveLeftHalf)
hs.hotkey.bind(qux_key, "5", fullScreen)

-- IFF a process_name is already running, then give it focus.
function focus(program, process_name)
   -- Oddly, `hs.window.find` uses a different string handle for a
   -- running process than `hs.application.launchOrFocus` uses to find
   -- the binary.
   if hs.window.find(process_name) then
      hs.application.launchOrFocus(program)
   end
end

-- Launch or focus a program.
function open(program)
   hs.application.launchOrFocus(program)
end

function focus_on_key(key, program, process_name)
   hs.hotkey.bind(my_key, key, function()
                     focus(program, process_name)
                     print(hs.window.focusedWindow())
   end)
end

function open_on_key(key, program)
   hs.hotkey.bind(my_key, key, function()
                     open(program)
                     print(hs.window.focusedWindow())
   end)
end

-- Useful to temporarily comment out a binding but accommodate muscle
-- memory by not letting the accustomed hotkey do the thing I'm no
-- longer used to it doing... like locking the screen.
function dead_key(key, program)
   hs.hotkey.bind(my_key, key, function()
                  print(hs.window.focusedWindow())
   end)
end


function launch_local_applescript(scriptname)
   local pwd = io.popen("pwd"):read("*a")
   local pwd = string.gsub(pwd, "(\n)", "")
   local script_name = scriptname
   local script_path = string.format("%s/%s", pwd, script_name)
   hs.osascript.applescriptFromFile(script_path)
end


-- Here we specify the binary because otherwise Hammerspoon keys off
-- the title of the window, which in GUI Emacs will be the buffer
-- name, and thus always wrong, so HS will pop open multiple Emacses.
--focus_on_key("e", "/usr/local/opt/emacs-plus/Emacs.app/Contents/MacOS/Emacs")
open_on_key("c", "Google Chrome")
open_on_key("z", "Iterm")
open_on_key("m", "Messages")
open_on_key("f", "Firefox")
open_on_key("2", "Firefox")
open_on_key("r", "Keybase")
hs.hotkey.bind(my_key, "q", function() launch_local_applescript("slack.applescript") end)
hs.hotkey.bind(my_key, "w", function() launch_local_applescript("slack.applescript") end)
hs.hotkey.bind(my_key, "s", function() launch_local_applescript("skype.applescript") end)



hs.hotkey.bind(qux_key, "l", hs.reload)

hs.hotkey.bind(qux_key, "f", function() open("Finder") end)

hs.hotkey.bind(qux_key, "e", function() open("zoom.us") end)

local application = require "hs.application"
local timer = require "hs.timer"
local alert = require "hs.alert"
local popclick = require "hs.noises"
local eventtap = require "hs.eventtap"

muteNotice = hs.menubar.new()
function toggleMikeMute()
   -- TODO This should mute *ALL* input devices, not just default
   --      which can be set incorrectly to an unexpected input
   local isMuted = hs.audiodevice.defaultInputDevice():inputMuted()
   local newState = not isMuted
   hs.audiodevice.defaultInputDevice():setMuted(newState)

   if (tostring(newState) == "false") then
      muteNotice:setTitle("")
      alert.show("mike open!")
   else
      muteNotice:setTitle("MIKE MUTED")
      alert.show("mike muted")
   end
end

hs.hotkey.bind(my_key, "[", toggleMikeMute)

function toggleSpeakerMute()
   local isMuted = hs.audiodevice.defaultOutputDevice():outputMuted()
   local newState = not isMuted
   hs.audiodevice.defaultOutputDevice():setMuted(newState)
   alert.show("speaker mute -> " .. tostring(newState))
end

hs.hotkey.bind(my_key, "]", toggleSpeakerMute)

listener = nil
popclickListening = false
local scrollDownTimer = nil
function popclickHandler(evNum)
   -- alert.show(tostring(evNum))
   -- alert.show(application.frontmostApplication():name())
--   if evNum == 1 then
--     scrollDownTimer = timer.doEvery(0.02, function()
--       eventtap.scrollWheel({0,-10},{}, "pixel")
--       end)
--   elseif evNum == 2 then
--     if scrollDownTimer then
--       scrollDownTimer:stop()
--       scrollDownTimer = nil
--     end
   --   else
   if evNum == 3 then
if application.frontmostApplication():name() == "iTerm2" then
       -- Issue tmux control leader.
       eventtap.keyStroke({}, "`")
       eventtap.keyStroke({}, "[")
    else
      eventtap.scrollWheel({0,-500},{}, "pixel")
    end
  end
end

function popclickPlayPause()
  if not popclickListening then
    listener:start()
    alert.show("listening")
  else
    listener:stop()
    alert.show("stopped listening")
  end
  popclickListening = not popclickListening
end

local function wrap(fn)
  return function(...)
    if fn then
      local ok, err = xpcall(fn, debug.traceback, ...)
      if not ok then hs.showerror(err) end
    end
  end
end

function popclickInit()
  popclickListening = false
  -- local fn = wrap(popclickHandler)
  local fn = popclickHandler
  listener = popclick.new(fn)
end

function init()
  popclickInit()
  alert.show("Hammerspoon, at your service.")
end

hs.hotkey.bind(qux_key, "P", popclickPlayPause)
init()

--[[ debugging utils
   function printObj(obj, hierarchyLevel) 
   if (hierarchyLevel == nil) then
   hierarchyLevel = 0
   elseif (hierarchyLevel == 4) then
   return 0
   end

   local whitespace = ""
   for i=0,hierarchyLevel,1 do
   whitespace = whitespace .. "-"
   end
   io.write(whitespace)

   print(obj)
   if (type(obj) == "table") then
   for k,v in pairs(obj) do
   io.write(whitespace .. "-")
   if (type(v) == "table") then
   printObj(v, hierarchyLevel+1)
   else
   print(v)
   end           
   end
   else
   print(obj)
   end
   end

   function showme()
   local apps = hs.application.runningApplications()
   print(apps)
   for app in apps do
   printObj(app)
   end
   -- for k, v in pairs(apps) do
   --    print(k, v[1], v[2], v[3])
   -- end
   end
   
   hs.hotkey.bind(my_key, "o", showme)
]]


function print_focused_title()
   local it = hs.window.focusedWindow()
   local tit = it.title(it)
   print(tit)
   local nam = it:application():name()
   print(nam)
end

hs.hotkey.bind(my_key, "p", print_focused_title)