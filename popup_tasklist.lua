local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local module = {}

local mytasklist = function(cfg, tag_index)
   local s = cfg.screen or awful.screen.focused()
   return awful.widget.tasklist {
      -- awful.widget.tasklist {
      visible = false,
      screen   = s,
      filter   = awful.widget.tasklist.filter.allscreen,
      buttons  = tasklist_buttons,
      layout   = {
         spacing = 5,
         -- forced_num_rows = 1,
         layout = wibox.layout.fixed.horizontal
      },
      widget_template = {
         {
            {
               id     = "clienticon",
               widget = awful.widget.clienticon,
            },
            margins = 0,
            widget  = wibox.container.margin,
         },
         id              = "background_role",
         forced_width    = 16,
         forced_height   = 16,
         widget          = wibox.container.background,
         create_callback = function(self, c, index, objects) --luacheck: no unused
            self:get_children_by_id("clienticon")[1].client = c
         end,
      }
   }
end

function module.new(config) 
   local cfg = config or {}
   
   local s  = cfg.screen or awful.screen.focused()
   local tasklist_buttons = cfg.tasklist_buttons

   local mypopup = wibox {
      -- widget = mytasklist(cfg),
      border_color = "#0000ff",
      border_width = 2,
      ontop        = true,
      placement    = awful.placement.centered,
      shape        = gears.shape.rounded_rect,
      visible = false,
      height = 100,
      width = 200,
   }

   mypopup:setup {
      widget = awful.widget.taglist {
         screen = s,
         filter = awful.widget.taglist.filter.all,
         -- widget_template = {
         --    widget = wibox.container.background,
         --    id = "background_role",
         --    {
         --       widget = wibox.widget.textbox,
         --       forced_height = 20,
         --       id = "text_role",
         --    },
         --    create_callback = function(self, c, index, objects)
         --       self.get_children_by_id("index_role")[1].markup = c.index
         --    end
         -- }
      }
      -- valign = center,
      -- mytasklist(cfg),
   }

   local widget = {
      popup = mypopup
   }

   awful.placement.centered(mypopup)

   return widget
end

return module
