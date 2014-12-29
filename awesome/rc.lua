-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local xdg_menu = require("archmenu")
require("awful.autofocus")
require("menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}attempt to index local 'color a nil value'

function run_or_raise(cmd, properties)
    local clients = client.get()
    local focused = awful.client.next(0)
    local findex = 0
    local matched_clients = {}
    local n = 0
    for i, c in pairs(clients) do
        --make an array of matched clients
        if match(properties, c) then
            n = n + 1
            matched_clients[n] = c
            if c == focused then
                findex = n
            end
        end
    end
    if n > 0 then
        local c = matched_clients[1]
        -- if the focused window matched switch focus to next in list
        if 0 < findex and findex < n then
            c = matched_clients[findex+1]
        end
        local ctags = c:tags()
        if #ctags == 0 then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
        else
            -- Otherwise, pop to first tag client is visible on
            awful.tag.viewonly(ctags[1])
        end
        -- And then focus the client
        client.focus = c
        c:raise()
        return
    end
    awful.util.spawn(cmd)
end

-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
    for k, v in pairs(table1) do
        if table2[k] ~= v and not table2[k]:find(v) then
            return false
        end
    end
    return true
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("~/.config/awesome/newblue/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "sakura -c 89 -r 22"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}
naughty.config.padding = 25
naughty.config.spacing = 10
-- }}}
naughty.config.defaults = {
  timeout = 5,
  text = "",
  screen = 1,
  ontop = true,
  font = "Noto Sans 12",
  margin = "5",
  border_width = "1",
  position = "top_right",
  opacity = 0.9,
}
-- {{{ Tags
tags = {
  names  = {  "0000", "0001", "0010", "0011", "0100", "0101" },
  layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1]
}}
 
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- {{{ Menu
-- Create a laucher widget and a main menu
local mysuspendmenu = {
   {"Suspend", "systemctl suspend"},
}

local mysysmenu = awful.menu({ items = {  { "Applications", xdgmenu },
                                    { "open terminal", "sakura -c 89 -r 22" },
                                    { "Suspend", mysuspendmenu, beautiful.awesome_icon },
                                    { "Lock", "/usr/bin/bash -c 'i3lock -e -t -i ~/lock.png'" },
                                    { "Exit", "oblogout" },
                                  }
                        })


local myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}
local myshortcutmenu = {
   { "Chromium", "chromium" },
   { "Twitter", "proxychains corebird" },
   { "Clementine", "clementine"},
   { "Chars", "gucharmap"},
   { "Steam", "steam" },
   { "Email", "claws-mail"},
   { "XP", "/usr/lib/virtualbox/VirtualBox --comment \"XP\" --startvm \"0b2a46ca-c48e-4706-bf7b-cef2c43ff445\"" },
   { "Virtualbox", "virtualbox"},
   { "Deadbeef", "deadbeef" },
   { "qBittorrent", "qbittorrent -style GTK+" },
}
local mymainmenu = awful.menu({ items = { { "File", "pcmanfm" },
                                    { "Firefox", "/usr/bin/firefox" },
                                    { "Terminal", "sakura -c 89 -r 22" },
                                    { "Shortcuts", myshortcutmenu, beautiful.awesome_icon },
                                    { "AllApps", xdgmenu, beautiful.awesome_icon },
                                    { "Awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Suspend", mysuspendmenu, beautiful.awesome_icon },
                                    { "Next", "pkill sleep"},
                                    { "Lock", "/usr/bin/bash -c 'i3lock -e -t -i ~/lock.png'"},
                                    { "Exit", "oblogout" },
                                  }
                        })

--local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
--                                     menu = mysysmenu })

-- Menubar configuration
menubar.utils.terminal = sakura -- Set the ter<p></p>minal for applications that require it
-- }}}

--config wibox
--[[
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_batt)
timeicon = wibox.widget.imagebox()
timeicon:set_image(beautiful.widget_clock)
sysicon = wibox.widget.imagebox()
sysicon:set_image(beautiful.widget_sysload)
weathericon = wibox.widget.imagebox()
weathericon:set_image(beautiful.widget_temp)
netupicon = wibox.widget.imagebox()
netupicon:set_image(beautiful.widget_netup)
netdownicon = wibox.widget.imagebox()
netdownicon:set_image(beautiful.widget_netdown)
]]
--
--
splitl = wibox.widget.textbox()
splitl:set_markup("<span color=\"#FFD200\">" .. "  " .. "</span>")
splitr = wibox.widget.textbox()
splitr:set_markup("<span color=\"#FFD200\">" .. "  " .. "</span>")
--Volume widget
volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume, "<span color=\"#ADFF00\" font=\"Noto Sans Bold 8\">🔊 $1%</span>", 3, "Master")
volwidget:buttons(
    awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn("amixer -q sset Master toggle")   end),
        awful.button({ }, 3, function () awful.util.spawn( terminal .. " -e alsamixer")   end),
        awful.button({ }, 4, function () awful.util.spawn("amixer -q sset Master 2%+,2%+") end),
        awful.button({ }, 5, function () awful.util.spawn("amixer -q sset Master 2%-,2%-") end)
    )
)
---
--[[
deadbeef = wibox.widget.textbox()
deadbeef:set_align("right")
function deadbeef_s(widget)
     local status = io.popen('deadbeef --nowplaying "%a - %t"'):read("*all")
     --deadbeef:set_markup("<span color=\"" .. color .. "\">" .. status .. "</span>")
     deadbeef:set_text(status)
end
deadbeef_s(deadbeef)
mytimer_deadbeef = timer({ timeout = 3 })
mytimer_deadbeef:connect_signal("timeout", function () deadbeef_s(deadbeef) end)
mytimer_deadbeef:start()
]]

--Network widget
function get_net()
    local fd = io.popen("~/.config/awesome/myscript.sh netinfo")
    local str = fd:read("*all")
    fd:close()
    return str 
end
netinfo = wibox.widget.textbox()
vicious.register(netinfo, vicious.widgets.net, "<span color=\"#00FFF2\" font=\"Noto Sans Bold 8\">⬇ ${wifi0 down_kb}/${wifi0 up_kb} ⬆</span>", 1)
netinfo_t = awful.tooltip({ objects = { netinfo },})
netinfo_t:set_text(get_net())
-- Sysinfo widget
function get_sysinfo()
    local fd = io.popen("~/.config/awesome/myscript.sh sysinfo")
    local str = fd:read("*all")
    fd:close()
    return str 
end
sysload = wibox.widget.textbox()
vicious.register(sysload, vicious.widgets.uptime, "<span color=\"#F92672\" font=\"Noto Sans Bold 8\">$4 $5 $6</span>", 5)
sysload_t = awful.tooltip({ objects = { sysload },})
sysload_t:set_text(get_sysinfo())
-- Textclock widget
function get_time()
    local fd = io.popen("~/.config/awesome/myscript.sh time")
    local str = fd:read("*all")
    fd:close()
    return str 
end
mytextclock = awful.widget.textclock("<span font=\"Noto Sans Bold 8\" color=\"#00FF16\">%b-%d/%a %I:%M:%S %p</span>", 1)
mytextclock_t = awful.tooltip({ objects = {mytextclock},})
mytextclock_t:set_text(get_time())
mytextclock:buttons(
    awful.util.table.join(
        awful.button({ }, 3, function () awful.util.spawn("zenity --calendar")   end)
    )
)
-- Battery widget
--{{{ battery indicator, using smapi
local battery_state = {
    Unknown     = '<span color="yellow">? ',
    Full        = '<span color="#ffffff">↯',
    Charging    = '<span color="#00FF16">+ ',
    Discharging = '<span color="#1e90ff">– ',
}
function update_batwidget()
    local bat_dir = '/sys/class/power_supply/BAT0/'
    local f = io.open(bat_dir .. 'status')
    if not f then
        batterywidget:set_markup('<span color="red">ERR</span>')
        return
    end
    local state = f:read('*l')
    f:close()
    local state_text = battery_state[state] or battery_state.unknown
    f = io.open(bat_dir .. 'capacity')
    if not f then
        batterywidget:set_markup('<span color="red">ERR</span>')
        return
    end
    local percent = tonumber(f:read('*l'))
    f:close()
    if  percent <= 30 and percent > 10 and state == 'Discharging' then
        naughty.notify({ title = "Battery Warning", 
            text = "Battery low! " .. percent .."%" .. " left!", 
            fg = "#ffffff",
            bg = "#C91C1C",
            timeout = 15,
            position = "bottom_right"
        })
    elseif percent <= 10 and state == 'Discharging' then
        awful.util.spawn("systemctl suspend")
        percent = '<span color="red">' .. percent .. '</span>'
    end
    batterywidget:set_markup(state_text .. percent .. '%</span>' .. '<span color="#FFD200">' .. ' | ' .. '</span>')
end
batterywidget = wibox.widget.textbox('↯??%')
update_batwidget()
mytimer_bat = timer({ timeout = 30 })
mytimer_bat:connect_signal("timeout", update_batwidget)
mytimer_bat:start()
batterywidget:buttons(
    awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn_with_shell("find ~/.wallpaper -print0 | shuf -n1 -z | xargs -0 feh --bg-fill") end)
    )
)
-- Weather widget
function get_weather()
    local fd = io.popen("~/.config/awesome/myscript.sh tooltip_temp")
    local str = fd:read("*all")
    fd:close()
    return str 
end
tempwidget = wibox.widget.textbox()
tempwidget:set_align("right")
function get_weather_statusbar(widget)
     local status = io.popen("~/.config/awesome/myscript.sh display_temp_only"):read("*all")
     local color = "#FFC100"
     tempwidget:set_markup("<span font=\"Noto Sans Bold 8\" color=\"" .. color .. "\">" .. status .. "</span>")
end
get_weather_statusbar(tempwidget)
weather_t = awful.tooltip({ objects = { tempwidget },})
weather_t:set_text(get_weather())
-- {{{ MPD Readout
-- Icon
--mpdicon = widget({type = "imagebox" })
--mpdicon.image = image(beautiful.widget_mpd)
-- Display

mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd,
  function (widget, args)
    if args["{state}"] == "Stop" then 
      return " - "
    else 
      return ' ' .. args["{Artist}"]..' - '.. args["{Title}"] .. ' '
    end
  end, 10)
mpdwidget:buttons(
    awful.util.table.join(
        awful.button({ }, 3, function () awful.util.spawn("sakura -c 95 -r 33 -e ncmpcpp")   end)
    )
)
-- }}}
--[[
-- Initialize widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, 
                    {1, "#AECF96" }}})
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
]]

--update scripts
mytimer = timer({ timeout = 120 })
mytimer:connect_signal("timeout", function () 
--awful.util.spawn_with_shell("find ~/.wallpaper -print0 | shuf -n1 -z | xargs -0 feh --bg-fill") 
weather_t:set_text(get_weather())
mytextclock_t:set_text(get_time())
netinfo_t:set_text(get_net())
sysload_t:set_text(get_sysinfo())
get_weather_statusbar(tempwidget)
end)
mytimer:start()

mytimer_w = timer({ timeout = 919 })
mytimer_w:connect_signal("timeout", function () awful.util.spawn_with_shell("~/.config/awesome/myscript.sh update") end)
mytimer_w:start()

--mpdwidget = wibox.widget.background(mpdwidget, "#B89B4F")
--[[
netinfo = wibox.widget.background(netinfo, "#C0EE57")
sysload = wibox.widget.background(sysload, "#11FB0E")
volwidget = wibox.widget.background(volwidget, "#1B98C4")
mytextclock = wibox.widget.background(mytextclock, "#281833")
batterywidget = wibox.widget.background(batterywidget, "#D42F69")
]]
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
--mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 2, function (c)
                                              c.maximized_horizontal = not c.maximized_horizontal
                                              c.maximized_vertical   = not c.maximized_vertical
                                          end),
                     awful.button({ }, 3, function () mymainmenu:toggle() end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 8, function (c)
                                              c.ontop = not c.ontop
                                          end),
                     awful.button({ }, 9, function (c)
                                              c:kill()
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    --mylayoutbox[s] = awful.widget.layoutbox(s)
    --mylayoutbox[s]:buttons(awful.util.table.join(
    --                       awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    --                       awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    --                       awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end),
    --                       awful.button({ }, 5, function () awful.layout.inc(layouts, 1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", 
      screen = s, 
      height = 20 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(splitl)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(splitr)
    right_layout:add(mpdwidget)
    --right_layout:add(netdownicon)
    --right_layout:add(deadbeef)
    right_layout:add(splitr)
    --right_layout:add(cpuwidget)
    right_layout:add(netinfo)
    right_layout:add(splitr)
    --right_layout:add(netupicon)
    right_layout:add(tempwidget)
    right_layout:add(splitr)
    --right_layout:add(sysicon)    
    right_layout:add(sysload)
    right_layout:add(splitr)
    --right_layout:add(volicon)
    right_layout:add(volwidget)
    right_layout:add(splitr)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(splitr)
    --right_layout:add(timeicon)
    right_layout:add(mytextclock)
    right_layout:add(splitr)
    --right_layout:add(baticon)
    right_layout:add(batterywidget)
    --right_layout:add(splitr)
    --right_layout:add(mylayoutbox[s])
    --right_layout:add(searchicon)
    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)
    mywibox[s]:set_widget(layout)
end
-- }}}
--config wibox

--config keybindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext)
))
-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ "Mod1",           }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ "Mod1", "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    -- Standard program
    awful.key({  "Mod1", "Shift"  }, "q",    function () run_or_raise("sakura -c 95 -r 33 -e ncmpcpp",   { name = "ncmpcpp" })        end ),
    awful.key({  "Mod1", "Shift"  }, "w",     function () run_or_raise("qps",   { class = "Qps" })        end ),
    awful.key({  "Mod1", "Shift"  }, "l",     function () run_or_raise("sakura",   { name = "WeeChat" })        end ),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey,           }, "#82",    function () awful.util.spawn("amixer -q sset Master 2%-", false) end),
    awful.key({ modkey,           }, "#86",    function () awful.util.spawn("amixer -q sset Master 2%+", false) end),
    awful.key({ "Mod1",           }, "r",    function () awful.util.spawn_with_shell("bash -c '~/.config/awesome/myscript.sh dmenu_start'", true)      end),
    awful.key({ modkey, "Shift"   }, "q", function() awful.util.spawn_with_shell("zenity --question&&echo 'awesome.quit()' | awesome-client", false) end),
    awful.key({ modkey,           }, "g",     function () awful.util.spawn("subl3")              end),
    awful.key({                   }, "Print", function () awful.util.spawn_with_shell('import -window root -quality 100 /tmp/$(date "+%Y-%m-%d_%H:%M:%S").png', false) end),
    --awful.key({ modkey,           }, "`", false, function () awful.util.spawn_with_shell('scrot -s /tmp/`date "+%Y-%m-%d_%H:%M:%S"`.png', false) end),
    awful.key({ modkey,           }, "`", false, function () awful.util.spawn_with_shell('import -quality 100 /tmp/`date "+%Y-%m-%d_%H:%M:%S"`.png', false) end),
    awful.key({         "Control" }, "m", false, function () awful.util.spawn("bash -c '~/.config/awesome/myscript.sh nowplaying'", false)  end),
    awful.key({ "Mod1"          , }, "`", false, function () awful.util.spawn("bash -c '~/.config/awesome/myscript.sh input_m'",false)      end),
    awful.key({ modkey,           }, "#87",   function () awful.util.spawn("xbacklight -dec 10", false)         end),
    awful.key({ modkey,           }, "#89",   function () awful.util.spawn("xbacklight -inc 10", false)         end),
    awful.key({ modkey,           }, "#88",   function () awful.util.spawn("xbacklight -set 50", false)         end),
    awful.key({ "Control", modkey }, "l",     function () awful.util.spawn("bash -c 'i3lock -e -t -i ~/lock.png'") end),
    --awful.key({ "Control", "Mod1" }, "h",     function () awful.util.spawn_with_shell("xfce4-popup-clipman")    end),
    awful.key({  "Mod1", "Shift"  }, "e",     function () awful.util.spawn("gnome-character-map")   end),
    awful.key({ modkey,           }, "t",     function () awful.util.spawn("sakura -c 89 -r 22")    end),
    awful.key({ modkey,           }, "e",     function () awful.util.spawn("pcmanfm")               end),
    awful.key({ modkey,           }, "q",     function () awful.util.spawn("xkill", false)          end),
    awful.key({  "Mod1", "Shift"  }, ".",     function () awful.util.spawn_with_shell("mpc next")   end),
    awful.key({  "Mod1", "Shift"  }, ",",     function () awful.util.spawn_with_shell("mpc prev")   end),
    awful.key({  "Mod1", "Shift"  }, "/",     function () awful.util.spawn_with_shell("mpc volume +5")   end),
    awful.key({  "Mod1", "Shift"  }, "m",     function () awful.util.spawn_with_shell("mpc volume -5")   end),
    awful.key({  "Mod1", "Shift"  }, ";",     function () awful.util.spawn_with_shell("mpc pause")   end),
    awful.key({  "Mod1", "Shift"  }, "'",     function () awful.util.spawn_with_shell("mpc play")   end),
    awful.key({  "Mod1", "Shift"  }, "d",     function () awful.util.spawn("xfce4-appfinder")       end),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    awful.key({ modkey, },            "r",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({ "Mod1" }, "F3",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "u", awful.titlebar.toggle),
    awful.key({ modkey,           }, "c",       function (c) c:kill()                           end),
    awful.key({ modkey, "Control" }, "space",   awful.client.floating.toggle                        ),
    awful.key({ modkey, "Control" }, "Return",  function (c) c:swap(awful.client.getmaster())   end),
    awful.key({ modkey,           }, "o",       awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "a",       function (c) c.ontop = not c.ontop              end),
    awful.key({ modkey,           }, "y",       awful.titlebar.toggle                                   ),
    awful.key({ modkey,           }, "z",       function (c) c.minimized = true                 end),
    awful.key({ modkey,           }, "f",      
        function (c) 
            c.fullscreen = not c.fullscreen
            c.ontop = c.ontop 
        end),
    awful.key({ modkey,           }, "x",
        function (c)
            if c.maximized_horizontal == true then
                if c.maximized_vertical == false then
                    c.maximized_vertical   = not c.maximized_vertical
                    c.border_width = "0"
                else
                    c.maximized_horizontal = not c.maximized_horizontal
                    c.maximized_vertical   = not c.maximized_vertical
                    c.border_width = beautiful.border_width
                end        
            else
                if c.maximized_vertical == true then
                    c.maximized_horizontal = not c.maximized_horizontal
                    c.border_width = "0"
                else
                    c.maximized_horizontal = not c.maximized_horizontal
                    c.maximized_vertical   = not c.maximized_vertical
                    c.border_width = "0"
                end           
            end
        end),
    awful.key({ modkey,           }, "s",
        function (c)
            c.sticky = not c.sticky
        end),
    awful.key({ modkey,           }, "d",
        function (c)
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey,           }, "b",
        function (c)
            c.maximized_horizontal   = not c.maximized_horizontal
        end),
    awful.key({ "Control", modkey   }, "Left",
        function ()
            awful.client.moveresize(-10, 0, 0, 0)
        end),
    awful.key({ "Control", modkey   }, "Right",
        function ()
            awful.client.moveresize(10, 0, 0, 0)
        end),
    awful.key({ "Control", modkey   }, "Up",
        function ()
            awful.client.moveresize(0, -10, 0, 0)
        end),
    awful.key({ "Control", modkey   }, "Down",
        function ()
            awful.client.moveresize(0, 10, 0, 0)
        end),
    awful.key({  "Mod1",                       }, "h",
        function ()
            awful.tag.incmwfact(-0.05)
        end),
    awful.key({  "Mod1",                       }, "j",
        function ()
            awful.client.incwfact(-0.05)
        end),
    awful.key({  "Mod1",                       }, "k",
        function ()
            awful.client.incwfact(0.05)
        end),
    awful.key({  "Mod1",                       }, "l",
        function ()
            awful.tag.incmwfact( 0.05)
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ "Mod1" }, 1, awful.mouse.client.move),
    awful.button({ "Mod1" }, 3, awful.mouse.client.resize))
root.keys(globalkeys)
--config keybindings

--config signals
-- {{{ Signals
-- Signal function to execute when a new client appears.

client.connect_signal("manage", function (c, startup)
    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:add(awful.titlebar.widget.stickybutton(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)
        awful.titlebar(c):set_widget(layout)
    end
    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
    c.size_hints_honor = false
    -- Floating clients don't overlap, cover 
    -- the titlebar or get placed offscreen
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)
        awful.titlebar.hide(c)

        if c.type == "normal" then
            if not c.size_hints.user_position or not c.size_hints.program_position then
                awful.placement.no_overlap(c)
                awful.placement.under_mouse(c)
                awful.placement.no_offscreen(c)
                awful.titlebar.hide(c)
            end
        elseif c.type ~= "normal" then
            awful.placement.centered(c,p)
            awful.titlebar.hide(c)
        end
    else
        awful.titlebar.hide(c)
    end
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--config Signals

--autostart
-- {{{ Rules

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
       properties = { border_width = beautiful.border_width,
                      border_color = beautiful.border_normal,
                      focus = awful.client.focus.filter,
                      keys = clientkeys,
                      floating = true,
                      size_hints_honor = false,
                      buttons = clientbuttons },
       },
    { rule = { class = "Sakura" }, 
      properties = { floating = false } },
    { rule = { class = "Gvim" }, 
      properties = { size_hints_honor = false } },
    { rule = { class = "guake" }, 
      properties = { border_width = 0 } },
    { rule = { class = "Pidgin" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Steam" },
      properties = { floating = true, tag = tags[1][4] } },
    { rule = { class = "Hexchat" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "Liferea" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Cr3" },
      properties = { tag = tags[1][1] }, callback = function(c) awful.placement.centered(c,nil) end },
    { rule = { class = "Zim" },
      properties = { floating = true, tag = tags[1][3] } },
    { rule = { name = "WeeChat" },
      properties = { floating = true, tag = tags[1][5] }, maximized_vertical = true, maximized_horizontal = true },
    { rule = { class = "Claws-mail" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Clementine" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Zathura" }, 
      properties = { maximized_vertical = true, border_width = 0 } },
    { rule = { instance = "crx_nckgahadagoaajjgafhacjanaoiihapd" }, 
      properties = { floating = true }, callback = function(c) c:geometry( { width = 260 , height = 460 } ) end },
    { rule_any = { class = { "Tilda" } }, except = { name = "Tilda 0 Config" },
      properties = { maximized_vertical = true, maximized_horizontal = true } },
}

awful.util.spawn_with_shell("[ -z `pgrep compton` ]&&compton")
awful.util.spawn_with_shell("[ -z `pgrep zim` ]&&zim")
--naughty.notify({title="Welcome", text=""})
--awful.util.spawn_with_shell("[ -z `pgrep unagi` ]&&unagi")
--awful.util.spawn_with_shell("[ -z `pgrep guake` ]&&sleep 5s&&guake")
awful.util.spawn_with_shell("[ -z `pgrep tilda` ]&&sleep 3s&&tilda")
awful.util.spawn_with_shell("numlockx on")
awful.util.spawn_with_shell("xbacklight -set 40")
awful.util.spawn_with_shell("fcitx -r")
--awful.util.spawn_with_shell("[ `pgrep NetworkManager` ]&&[ -z `pgrep nm-applet` ]&&nm-applet")
--awful.util.spawn_with_shell("[ `pgrep connmand` ]&&[ -z `pgrep connman-ui-gtk` ]&&connman-ui-gtk")
--awful.util.spawn_with_shell("[ -z `pgrep xfce4-clipman` ]&&xfce4-clipman")
awful.util.spawn_with_shell("[ -z `pgrep parcellite` ]&&parcellite")
awful.util.spawn_with_shell("xautolock -time 5 -locker 'i3lock -e -t -i ~/lock.png'")
awful.util.spawn_with_shell("[ -z `pgrep polkit-` ]&&/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
--awful.util.spawn_with_shell("[ -z `pgrep dropbox` ]&&dropboxd")
awful.util.spawn_with_shell("[ -z `pgrep pnmixer` ]&&pnmixer")
--awful.util.spawn_with_shell("[ -z `pgrep claws-mail` ]&&claws-mail")
awful.util.spawn_with_shell("sh ~/.fehbg")
