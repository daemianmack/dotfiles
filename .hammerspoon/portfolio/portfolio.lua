local program = hs.fs.currentDir() .. "/portfolio/evaluate-portfolio.clj"
local program_args = {"--config", hs.fs.currentDir() .. "/portfolio/portfolio-config.edn"}

local ticker_url = "https://robinhood.com/stocks/"

local menubar = hs.menubar.new()
local font = "Monaco"

local bad_color = hs.drawing.color.x11.red
local good_color = hs.drawing.color.x11.green

local REFRESH_PORTFOLIO_TIMER = 60 * 5 -- minutes

local left_pad = function(str, width)
  return string.rep(" ", width-(string.len(str)))
end

local format_menu_item = function(quote)
   local symbol   = quote["symbol"]
   local value    = string.format("%s$%s", left_pad(quote["value"], 5), quote["value"])
   local holding  = string.format("%s%s",  left_pad(quote["holding"], 3), quote["holding"])
   local price    = string.format("%s$%s", left_pad(quote["regularMarketPrice"], 7), quote["regularMarketPrice"])
   local previous = quote["previousClose"]
   local color    = good_color

   if quote["regularMarketPrice"] < previous then
      color = bad_color
   end
   
   return hs.styledtext.new(symbol .. " " .. value .. " · " .. price .. " * " .. holding, { font=font, color = color })
end

local format_url = function(quote)
   local url = ticker_url .. quote["symbol"]
   return function() hs.urlevent.openURL(url) end
end

local render_portfolio = function(exitCode, stdOut, stdErr)
    local portfolio = hs.json.decode(stdOut)
    local color = good_color
    if portfolio["total_value"] < 0 then
       color = bad_color
    end

    menubar:setTitle(hs.styledtext.new(portfolio["total_value"], {font = font, color = color})) 
    menubar:setTooltip(os.date("%x %X"))
    
    local quotes_by_symbol = portfolio["by_symbol"]
    if #quotes_by_symbol > 1 then
        local submenu = { }
        for i = 1, #quotes_by_symbol, 1 do
           table.insert(submenu, { title = format_menu_item(quotes_by_symbol[i]),
                                   fn    = format_url(quotes_by_symbol[i])})
        end
        menubar:setMenu(submenu)
    end
end

local function market_is_open(date_obj)
   -- This is a little bit wrong in that it will run
   -- more than it should for half an hour, but
   return date_obj.wday > 0 and date_obj.wday < 7
      and date_obj.hour > 8 and date_obj.hour < 16
end

local function refresh_portfolio()
   local now = os.date("*t")
   -- If market is closed, don't bother updating unless we've reloaded
   -- Hammerspoon config, in which case get outdated values just for display.
   if market_is_open(now) or not portfolio_task  then
      print("Portfolio updating...")
      portfolio_task = hs.task.new(program, render_portfolio, program_args)
   else
      print("Skipping portfolio update.")
   end
end

portfolio_task_timer = hs.timer.new(REFRESH_PORTFOLIO_TIMER, refresh_portfolio, true):start()

refresh_portfolio()
