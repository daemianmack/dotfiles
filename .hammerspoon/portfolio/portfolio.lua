local program = hs.fs.currentDir() .. "/portfolio/evaluate-portfolio.clj"
local program_args = {"--config", hs.fs.currentDir() .. "/portfolio/portfolio-config.edn"}

local ticker_url = "https://robinhood.com/stocks/"

local menubar = hs.menubar.new()
local symb = {name = "Monaco", size = 7}
local font = {name = "Monaco", size = 8}
local bold_symb = {name = "MonacoB2 Bold", size = 7}
local bold_font = {name = "MonacoB2 Bold", size = 9}

local bad_color = hs.drawing.color.x11.red
local good_color = hs.drawing.color.x11.green

local REFRESH_PORTFOLIO_TIMER = 60 * 1 -- minutes

local left_pad = function(str, width)
  return string.rep(" ", width-(string.len(str)))
end

local format_menu_item = function(quote)
   local label   = quote["label"]
   local value    = string.format("%s$%s", left_pad(quote["value"], 5), quote["value"])
   local holding  = string.format("%s%s",  left_pad(quote["holding"], 3), quote["holding"])
   local price    = string.format("%s$%s", left_pad(quote["regularMarketPrice"], 8), quote["regularMarketPrice"])
   local previous = quote["previousClose"]
   local color    = good_color

   if quote["regularMarketPrice"] < previous then
      color = bad_color
   end

   return hs.styledtext.new(label .. " " .. value .. " · " .. price .. " * " .. holding, { font=font, color = color })
end

local format_url = function(quote)
   local url = ticker_url .. quote["symbol"]
   return function() hs.urlevent.openURL(url) end
end

local format_ticker_value = function(quote)
   local dollar_display=quote["value"]
   if quote["holding"] == 0 then
      dollar_display = "⌜" .. math.modf(quote["regularMarketPrice"]) .. "⌟"
   end

   local symbol_color = good_color
   if 0 > dollar_display then
      symbol_color = bad_color
   end

   local val = hs.styledtext.new(quote["label"] .. " ", {color = symbol_color, font = symb})
      .. hs.styledtext.new(dollar_display, {color=hs.drawing.color.x11.cornflowerblue, font = font})
   return val
end

local format_type_value = function(quote)
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
    if 0 > portfolio["total_value"] then
       color = bad_color
    end

    local title = hs.styledtext.new("", {font=font})

    local quotes_by_symbol = portfolio["by_symbol"]
    if #quotes_by_symbol > 0 then
       for i = 1, #quotes_by_symbol, 1 do
          title = title .. format_ticker_value(quotes_by_symbol[i])
          if #quotes_by_symbol > 1 then
             if quotes_by_symbol[i+1] then
                title = title .. hs.styledtext.new(" ", {font = font, color=hs.drawing.color.x11.navy})
             end
          end
       end
    end

    local quotes_by_type = portfolio["by_type"]
    title = title .. hs.styledtext.new(" ‣ ", {font = font, color=hs.drawing.color.x11.navy})

    if #quotes_by_type > 0 then
       for i = 1, #quotes_by_type, 1 do
          title = title .. format_type_value(quotes_by_type[i])
          if quotes_by_type[i+1] then
             title = title .. " "
          end
       end
       title = title .. hs.styledtext.new(" ‣ ", {font = font, color=hs.drawing.color.x11.navy})
    end

    if #quotes_by_symbol > 1 then
       menubar:setTitle(title .. hs.styledtext.new(portfolio["total_value"], {font = font, color = color}))
    else
       menubar:setTitle(title)
    end

    menubar:setTooltip(os.date("%x %X"))

    if #quotes_by_symbol > 0 then
        local submenu = { }
        for i = 1, #quotes_by_symbol, 1 do
           table.insert(submenu, { title = format_menu_item(quotes_by_symbol[i]),
                                   fn    = format_url(quotes_by_symbol[i])})
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
