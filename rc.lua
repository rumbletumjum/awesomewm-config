-- Requires {{{
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
require("awful.remote")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local vicious = require("vicious")
local mylayouts = require("layouts")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- package.loaded["popup_tasklist"] = nil
local popup_tasklist = require("popup_tasklist").new()
-- require("popup_tasklist")
-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors
   })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true

      naughty.notify({
         preset = naughty.config.presets.critical,
         title = "Oops, an error happened!",
         text = tostring(err)
      })
      in_error = false
   end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
float_term = "alacritty --class floatterm"
file_browser = "nautilus"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   awful.layout.suit.tile,
   awful.layout.suit.max,
   awful.layout.suit.fair,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.tile.left,
   awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome  = { "Awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "Terminal", float_term }
local menu_nautilus = { "Nautilus", file_browser }


if has_fdo then
   mymainmenu = freedesktop.menu.build({
      before = { menu_terminal, menu_nautilus },
      after =  { menu_awesome }
   })
else
   mymainmenu = awful.menu {
      items = {
         { "terminal", float_term },
         { "nautilus", file_browser },
         { "awesome", myawesomemenu, beautiful.awesome_icon },
      }
   }
end

mylauncher = awful.widget.launcher({
   image = beautiful.awesome_icon,
   menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Taglist/Tasklist Buttons {{{
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
      if client.focus then
         client.focus:move_to_tag(t)
      end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
      if client.focus then
         client.focus:toggle_tag(t)
      end
   end),
   awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
   awful.button({ }, 1, function (c)
      if c == client.focus then
         c.minimized = true
      else
         c:emit_signal(
            "request::activate",
            "tasklist",
            {raise = true}
         )
      end
   end),
   awful.button({ }, 2, function (c) c:kill() end),
   awful.button({ }, 3, function()
      awful.menu.client_list({ theme = { width = 250 } })
   end),
   awful.button({ }, 4, function ()
      awful.client.focus.byidx(1)
   end),
   awful.button({ }, 5, function ()
      awful.client.focus.byidx(-1)
   end))
-- }}}

-- Tags {{{
awful.screen.connect_for_each_screen(function(s)
   local l = awful.layout.suit

   awful.tag.add('1', {
      layout = mylayouts.cols,
      master_fill_policy = 'master_width_factor',
      master_width_factor = 0.55,
      gap_single_client = false,
      gap = 5,
      screen = s,
      selected = true,
   })

   awful.tag.add('2', {
      layout = l.tile,
      master_width_factor = 0.60,
      gap_single_client = false,
      gap = 5,
      screen = s,
   })

   awful.tag.add('3', {
      layout = l.max,
      gap_single_client = true,
      gap = 5,
      screen = s,
   })

   awful.tag.add('4', {
      layout = l.floating,
      screen = s,
   })

   awful.tag.add('5', {
      layout = l.tile,
      screen = s,
   })

   awful.tag.add('6', {
      screen = s,
   })
   -- }}}

   -- Wibar Widgets {{{
   -- Create a textclock widget
   local mytextclock = wibox.widget {
      widget = wibox.widget.textclock(),
      format = '%T',
      refresh = 1,
   }

   -- Create a promptbox for each screen
   s.mypromptbox = awful.widget.prompt()

   -- Create an imagebox widget which will contain an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   s.mylayoutbox = awful.widget.layoutbox(s)
   s.mylayoutbox:buttons(gears.table.join(
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc(-1) end),
      awful.button({ }, 4, function () awful.layout.inc( 1) end),
      awful.button({ }, 5, function () awful.layout.inc(-1) end)))

   s.mem_widget = wibox.widget.textbox()
   vicious.cache(vicious.widgets.mem)
   vicious.register(s.mem_widget, vicious.widgets.mem, "$1%", 5)

   s.bat_widget = wibox.widget.textbox()
   vicious.cache(vicious.widgets.bat)
   vicious.register(s.bat_widget, vicious.widgets.bat, "$2%", 61, "BAT0")

   s.batwidget = wibox.widget {
      widget = wibox.widget.progressbar,
      max_value = 1,
      border_width = 0.5, border_color = "#ffffff",
      background_color = "#2b3339",
      color = {
         type = "linear",
         from = { 0, 0 },
         to = { 0, 22 },
         -- stops = { { 0, "#FF5656" }, { 1, "#AECF96" } }
         stops = { { 0, "#aecf96" }, { 1, "#5656ff" } }
      }
   }

   s.batbox = wibox.widget {
         layout = wibox.container.rotate,
         direction = 'east', color = beautiful.fg_widget,
         -- forced_height = 10, forced_width = 6,
         forced_width = 6, forced_height = 10,
         s.batwidget,
   }
   vicious.register(s.batwidget, vicious.widgets.bat, "$2", 61, "BAT0")


   -- }}}

   -- {{{ Taglist
   s.mytaglist = awful.widget.taglist {
      screen   = s,
      filter   = awful.widget.taglist.filter.all,
      buttons  = taglist_buttons,
      layout = {
         layout = wibox.layout.fixed.horizontal,
         spacing = 6,
      },
      widget_template = {
         id = 'background_role',
         border_strategy = 'inner',
         widget = wibox.container.background,
         {
            widget = wibox.layout.fixed.horizontal,
            fill_space = true,
            {
               widget = wibox.container.place,
               {
                  id = 'text_margin_role',
                  widget = wibox.container.margin,
                  left = 8,
                  right = 8,
                  {
                     id = 'text_role',
                     widget = wibox.widget.textbox,
                  },
               }
            }
         }
      }
   }
   -- }}}

   -- Tasklist {{{
   s.mytasklist = awful.widget.tasklist {
      screen  = s,
      filter  = awful.widget.tasklist.filter.currenttags,
      buttons = tasklist_buttons,
      style = {
         shape = gears.shape.rounded_rect,
         shape_border_width = 1,
      },
      widget_template = {
         forced_width = 300,
         id = 'background_role',
         border_strategy = 'inner',
         widget = wibox.container.background,
         {
            widget = wibox.container.margin,
            left = 10, right = 10,
            {
               widget = wibox.layout.fixed.horizontal,
               fill_space = true,
               spacing = 8,
               {
                  id = 'icon_margin_role',
                  widget = wibox.container.margin,
                  left = 4,
                  {
                     widget = wibox.container.place,
                     {
                        widget = wibox.container.constraint,
                        height = 12,
                        {
                           id = 'icon_role',
                           widget = wibox.widget.imagebox,
                        },
                     },
                  },
               },
               {
                  id = 'text_margin_role',
                  widget = wibox.container.margin,
                  -- left = 8,
                  right = 4,
                  {
                     widget = wibox.container.place,
                     halign = "left",
                     {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                     },
                  },
               }
            }
         }
      }
   }
   -- }}}

   -- Wibox {{{

   local fancy_taglist = require("fancy_taglist")
   s.fancytaglist = fancy_taglist.new { screen = s, taglist_buttons = taglist_buttons }

   s.mywibar = awful.wibar { position = 'top', screen = s, height = 32, bg = "#2b333900" }

   s.mywibar:setup {
      layout = wibox.container.margin,
      top = 5, bottom = 5, left = 5,
      {
         layout = wibox.layout.align.horizontal,
         expand = "inside",
         { -- left
            layout = wibox.layout.fixed.horizontal,
            s.fancytaglist,
            s.mypromptbox,
         },
         { -- middle
            layout = wibox.container.margin,
            left = 10, right = 10,
            {
               layout = wibox.layout.fixed.horizontal,
               s.mytasklist,
            },
         },
         { -- right
            layout = wibox.layout.fixed.horizontal,
            spacing = 20,
            spacing_widget = {
               widget = wibox.container.place,
               valign = "center", halign = "center",
               {
                  widget = wibox.widget.separator,
                  forced_height = 20
               }
            },
            s.mem_widget,
            s.bat_widget,
            {
               widget = wibox.container.place,
               valign = "center", halign = "center",
               {
                  layout = wibox.container.constraint,
                  width = 100, height = 5,
                  s.batwidget,
               },
            },
            -- wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
         },
      },
   }
end)
-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings {
   awful.button({ }, 1, function () mymainmenu:toggle() end),
   awful.button({ }, 3, function () awful.menu.client_list {
      theme = { width = 250 },
   }
   end),
   awful.button({ }, 4, awful.tag.viewnext),
   awful.button({ }, 5, awful.tag.viewprev)
}
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
   awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
      {description="show help", group="awesome"}),
   awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
      {description = "view previous", group = "tag"}),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
      {description = "view next", group = "tag"}),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
      {description = "go back", group = "tag"}),

   awful.key({ modkey,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
   ),
   awful.key({ modkey,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
      end,
      {description = "focus previous by index", group = "client"}
   ),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
      {description = "swap with next client by index", group = "client"}),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
      {description = "swap with previous client by index", group = "client"}),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
      {description = "focus the next screen", group = "screen"}),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
      {description = "focus the previous screen", group = "screen"}),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
      {description = "jump to urgent client", group = "client"}),
   awful.key({ modkey,           }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end,
      {description = "go back", group = "client"}),

   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
      {description = "open a terminal", group = "launcher"}),
   awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(float_term) end,
      {description = "launch a floating terminal", group = "launcher"}),
   awful.key({ modkey,           }, "b",
      function()
         local wb = awful.screen.focused().mywibar
         wb.visible = not wb.visible
      end,
      {description = "launch file browser", group = "launcher"}),

   awful.key({ modkey, "Control" }, "r", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit,
      {description = "quit awesome", group = "awesome"}),

   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
      {description = "increase master width factor", group = "layout"}),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
      {description = "decrease master width factor", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
      {description = "increase the number of master clients", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
      {description = "decrease the number of master clients", group = "layout"}),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
      {description = "increase the number of columns", group = "layout"}),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
      {description = "decrease the number of columns", group = "layout"}),
   awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
      {description = "select next", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
      {description = "select previous", group = "layout"}),

   awful.key({ modkey, "Control" }, "n",
      function ()
         awful.menu.client_list({
            theme = {
               width = 500,
               height = 22,
            },
            coords = {
               x = awful.screen.focused().workarea.width * 0.5 - 250,
               y = awful.screen.focused().workarea.height * 0.125,
            }
         })
      end,
      { description = "restore minimized", group = "client" }),

   -- Prompt
   awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
      {description = "run prompt", group = "launcher"}),

   awful.key({ modkey }, "x",
      function ()
         awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
         }
      end,
      {description = "lua execute prompt", group = "awesome"}),
   -- Menubar
   awful.key({ modkey }, "p", function() menubar.show() end,
      {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
   awful.key({ modkey,           }, "f",
      function (c)
         c.fullscreen = not c.fullscreen
         c:raise()
      end,
      {description = "toggle fullscreen", group = "client"}),
   awful.key({ modkey,           }, "w",      function (c) c:kill()                         end,
      {description = "close", group = "client"}),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
      {description = "toggle floating", group = "client"}),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),
   awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
      {description = "move to screen", group = "client"}),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
      {description = "toggle keep on top", group = "client"}),
   awful.key({ modkey,           }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end ,
      {description = "minimize", group = "client"}),
   awful.key({ modkey,           }, "m",
      function (c)
         c.maximized = not c.maximized
         c:raise()
      end ,
      {description = "(un)maximize", group = "client"}),
   awful.key({ modkey, "Control" }, "m",
      function (c)
         c.maximized_vertical = not c.maximized_vertical
         c:raise()
      end ,
      {description = "(un)maximize vertically", group = "client"}),
   awful.key({ modkey, "Shift"   }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c:raise()
      end ,
      {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   globalkeys = gears.table.join(globalkeys,
      -- View tag only.
      awful.key({ modkey }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               tag:view_only()
            end
         end,
         {description = "view tag #"..i, group = "tag"}),
      -- Toggle tag display.
      awful.key({ modkey, "Control" }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               awful.tag.viewtoggle(tag)
            end
         end,
         {description = "toggle tag #" .. i, group = "tag"}),
      -- Move client to tag.
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:move_to_tag(tag)
               end
            end
         end,
         {description = "move focused client to tag #"..i, group = "tag"}),
      -- Toggle tag on focused client.
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:toggle_tag(tag)
               end
            end
         end,
         {description = "toggle focused client on tag #" .. i, group = "tag"})
   )
end

client.connect_signal("request::default_mousebindings", function()
   awful.mouse.append_client_mousebindings({
      awful.button({ }, 1, function (c)
         c:activate { context = "mouse_click" }
      end),
      awful.button({ modkey }, 1, function (c)
         c:activate { context = "mouse_click", action = "mouse_move"  }
      end),
      awful.button({ modkey }, 3, function (c)
         c:activate { context = "mouse_click", action = "mouse_resize"}
      end),
   })
end)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
-- All clients will match this rule.
ruled.client.connect_signal("request::rules", function()
   ruled.client.append_rule {
      id = "global",
      rule = { },
      properties = {
         focus = awful.client.focus.filter,
         raise = true,
         screen = awful.screen.preferred,
         keys = clientkeys,
         placement = awful.placement.no_overlap+awful.placement.no_offscreen,
      }
   }

   ruled.client.append_rule {
      id = 'floating',
      rule_any = {
         class = {
            '1Password',
            'Baobab',
            'Gnome-control-center',
            'Gnome-tweaks',
            'Gpick',
            'Org.gnome.Nautilus',
            'Sxiv',
         },
      },
      properties = {
         floating  = true,
         placement = awful.placement.centered
      }
   }

   ruled.client.append_rule {
      id = 'float_term',
      rule = { instance = 'floatterm' },
      properties = {
         floating  = true,
         height    = awful.screen.focused().workarea.height * 0.5,
         width    = awful.screen.focused().workarea.width * 0.25,
         -- placement = awful.placement.centered,
         ontop     = true,
         x = 960,
         y = 180,
      }
   }

   ruled.client.append_rule {
      rule_any = {
         class = {
            'Brave-browser',
            'qutebrowser',
            'Vivaldi-stable',
         },
      },
      properties = {
         screen = 1,
         tag    = '2',
      },
   }

   ruled.client.append_rule {
      rule_any = {
         class = {
            'Emacs',
         },
      },
      properties = {
         screen = 1,
         tag    = '3',
      },
   }

   ruled.client.append_rule {
      rule = {
         class = "Spacefm",
         type = "dialog",
      },
      properties = {
         floating = true,
         placement = awful.placement.centered,
      }
   }
end)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
   -- Set the windows at the slave,
   -- i.e. put it at the end of others instead of setting it master.
   -- if not awesome.startup then awful.client.setslave(c) end

   local t = awful.screen.focused().selected_tag
   if not awesome.startup then
      -- and t.name ~= "two" then
      awful.client.setslave(c)
   end
   if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
   end
end)

function double_click_event_handler(double_click_event)
   if double_click_timer then
      double_click_timer:stop()
      double_click_timer = nil
      return true
   end

   double_click_timer = gears.timer.start_new(0.20, function()
      double_click_timer = nil
      return false
   end)
end
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
   -- buttons for the titlebar
   local buttons = gears.table.join(
      awful.button({ }, 1, function()
         if double_click_event_handler() then
            c.maximized = not c.maximized
         else
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
         end
      end),
      awful.button({ }, 3, function()
         c:emit_signal("request::activate", "titlebar", {raise = true})
         awful.mouse.client.resize(c)
      end)
   )

   awful.titlebar(c) : setup {
      { -- Left
         awful.titlebar.widget.iconwidget(c),
         buttons = buttons,
         layout  = wibox.layout.fixed.horizontal
      },
      { -- Middle
         { -- Title
            font = beautiful.font_title,
            align  = "center",
            widget = awful.titlebar.widget.titlewidget(c)
         },
         buttons = buttons,
         layout  = wibox.layout.flex.horizontal
      },
      { -- Right
         -- awful.titlebar.widget.floatingbutton (c),
         -- awful.titlebar.widget.stickybutton   (c),
         -- awful.titlebar.widget.ontopbutton    (c),
         awful.titlebar.widget.minimizebutton(c),
         awful.titlebar.widget.maximizedbutton(c),
         awful.titlebar.widget.closebutton    (c),
         layout = wibox.layout.fixed.horizontal()
      },
      layout = wibox.layout.align.horizontal
   }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
   -- c:emit_signal("request::activate", "mouse_enter", {raise = false})
   -- c:emit_signal("request::activate", "mouse_enter", {raise = false})
   c:activate { context = "mouse_enter", { raise = false } }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

screen.connect_signal("arrange", function(s)
   -- local s = c.screen
   local max = s.selected_tag.layout.name == "max"
   local only_one = #s.tiled_clients == 1
   for _, c in pairs(s.clients) do
      c.border_width = (max or only_one) and not c.floating and 0 or beautiful.border_width
   end
end)
-- }}}

-- vim: ts=3:sw=3:sts=3:et:fdm=marker
