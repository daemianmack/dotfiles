local program = hs.fs.currentDir() .. "/portfolio/evaluate-portfolio.clj"
local program_args = {"--config", hs.fs.currentDir() .. "/portfolio/portfolio-config.edn"}

local ticker_url = "https://robinhood.com/stocks/"

local menubar = hs.menubar.new()
local symb = {name = "Monaco", size = 9}
local font = {name = "Monaco", size = 8}
local bold_symb = {name = "MonacoB2 Bold", size = 7}
local bold_font = {name = "MonacoB2 Bold", size = 9}

local menu_font = {name = "Monaco", size = 11}

local bad_color = hs.drawing.color.x11.red
local good_color = hs.drawing.color.x11.green

local REFRESH_PORTFOLIO_TIMER = 60 * 1 -- minutes

local left_pad = function(str, width)
  return string.rep(" ", width-(string.len(str)))
end

local format_menu_item = function(quote)
   local symbol   = string.format("%s%s",  left_pad(quote["symbol"], 8), quote["symbol"])
   local price    = string.format("%s$%s", left_pad(quote["regularMarketPrice"], 8), quote["regularMarketPrice"])
   local holding  = string.format("%s%s",  left_pad(quote["holding"], 5), quote["holding"])
   local gains = 0
   if 0 > quote["gains"] then
     gains = string.format("%s-$%s", left_pad(quote["gains"], 6), math.abs(quote["gains"]))
   else
     gains = string.format("%s$%s", left_pad(quote["gains"], 6), math.abs(quote["gains"]))
    end

   local icon = " "
   if quote["icon"] ~= nil then
     icon = icon .. quote["icon"]
   end

   local previous = quote["previousClose"]
   local color    = good_color

   if quote["regularMarketPrice"] < previous then
      color = bad_color
   end

   return hs.styledtext.new(symbol .. " " .. price .. " ⋆ " .. holding .. " ≈ " .. gains .. icon, { font=menu_font, color = color })
end

local format_url = function(quote)
   local url = ticker_url .. quote["symbol"]
   return function() hs.urlevent.openURL(url) end
end

local format_ticker_gains = function(quote)
   local dollar_display=quote["gains"]
   if quote["holding"] == 0 then
      dollar_display = "⌜" .. math.modf(quote["regularMarketPrice"]) .. "⌟"
   end

   local symbol_color = good_color
   if quote["holding"] ~= 0 then
      if 0 > dollar_display then
         symbol_color = bad_color
      end
   end

   local val = hs.styledtext.new(quote["label"] .. " ", {color = symbol_color, font = symb})
      .. hs.styledtext.new(dollar_display, {color=hs.drawing.color.x11.cornflowerblue, font = font})
   return val
end

local format_type_gains = function(quote)
   local symbol_color = good_color
   if quote["total"] < 1 then
      symbol_color = bad_color
   end

   local dollar_display=quote["total"]

   local val = hs.styledtext.new(quote["type"] .. " ", {color = symbol_color, font = bold_symb})
      .. hs.styledtext.new(dollar_display, {color=hs.drawing.color.x11.fuchsia, font = bold_font})
   return val
end

local render_portfolio = function(exitCode, stdOut, stdErr)
    local portfolio = hs.json.decode(stdOut)
    local color = good_color
    if 0 > portfolio["total_gains"] then
       color = bad_color
    end

    local title = hs.styledtext.new("", {font=font})

    local quotes_by_type = portfolio["by_type"]
    if #quotes_by_type > 0 then
       for i = 1, #quotes_by_type, 1 do
          title = title .. format_type_gains(quotes_by_type[i])
          if quotes_by_type[i+1] then
             title = title .. " "
          end
       end
       title = title .. hs.styledtext.new(" ‣ ", {font = font, color=hs.drawing.color.x11.navy})
    end

    local quotes_by_symbol = portfolio["by_symbol"]
    if #quotes_by_symbol > 1 then
       title = title .. hs.styledtext.new(portfolio["total_gains"], {font = font, color = color})
    end

    menubar:setTitle(title)
    menubar:setTooltip(os.date("%x %X"))

    if #quotes_by_symbol > 0 then
        local submenu = { }
        for i = 1, #quotes_by_symbol, 1 do
           local quote = quotes_by_symbol[i]
           table.insert(submenu, { title   = format_menu_item(quote),
                                   fn      = format_url(quote),
                                   tooltip = "Cost basis: " .. quote["cost_basis"]})
        end
        menubar:setMenu(submenu)
    end
    print("Portfolio updated.")
end

local function market_is_open(date_obj)
   -- This is a little bit wrong in that it will run
   -- more than it should for half an hour, but
   return date_obj.wday > 1 and date_obj.wday < 7
      and date_obj.hour > 8 and date_obj.hour < 16
end

local function refresh_portfolio()
    print("Portfolio updating...")
    portfolio_task = hs.task.new(program, render_portfolio, program_args)
    portfolio_task:start()
end

portfolio_task_timer = hs.timer.new(REFRESH_PORTFOLIO_TIMER, refresh_portfolio, true):start()

refresh_portfolio()
