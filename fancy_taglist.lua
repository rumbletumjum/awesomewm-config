-- awesomewm fancy_taglist: a taglist that contains a tasklist for each tag.

-- Usage:
-- 1. Save as "fancy_taglist.lua" in ~/.config/awesome
-- 2. Add a fancy_taglist for every screen:
--		awful.screen.connect_for_each_screen(function(s)
--			...
--			local fancy_taglist = require("fancy_taglist")
--			s.mytaglist = fancy_taglist.new({ screen = s })
--			...
--		end)
-- 3. Add s.mytaglist to your wibar.

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local desaturate = require("utils").desaturate_icon

local module = {}

local generate_filter = function(i)
	return function(c, scr)
		local t = scr.tags[i]
		local ctags = c:tags()
		for _, v in ipairs(ctags) do
			if v == t then
				return true
			end
		end
		return false
	end
end

local update_function = function(self, c, _, _)
   local icon = desaturate(c.icon)
   self:get_children_by_id("_icon_role")[1].image = icon
end


local fancytasklist = function(cfg, tag_index)
	return awful.widget.tasklist{
		screen = cfg.screen or awful.screen.focused(),
		filter = generate_filter(tag_index),
		buttons = cfg.tasklist_buttons,
      layout = {
         layout = wibox.layout.fixed.horizontal,
         spacing = 4,
      },
		widget_template = {
         {
            widget = wibox.container.margin,
            -- right = 4,
            {
               widget = wibox.container.place,
               {
                  widget = wibox.container.constraint,
                  height = 24,
                  {
                     id = "clienticon",
                     widget = awful.widget.clienticon,
                  },
               },
            },
         },
			layout = wibox.layout.stack,
         -- create_callback = update_function,
         -- update_callback = update_function,
			create_callback = function(self, c, _, _)
				self:get_children_by_id("clienticon")[1].client = c
				awful.tooltip{
					objects = { self },
					timer_function = function()
						return c.name
					end
				}
			end
		}
	}
end

function module.new(config)
	local cfg = config or {}

	local s = cfg.screen or awful.screen.focused()
	local taglist_buttons = cfg.taglist_buttons

	return awful.widget.taglist{
		screen = s,
		filter = awful.widget.taglist.filter.noempty,
      layout = {
         layout = wibox.layout.fixed.horizontal,
         spacing = 0,
      },
      style = {
         shape = gears.shape.rounded_rect,
         shape_border_width = 1,
         shape_border_color = "#2b333900",
      },
      widget_template = {
         {
            {
               {
               -- tag
               layout = wibox.layout.fixed.horizontal,
               spacing = 8,
               {
                  widget = wibox.container.place,
                  {
                  layout = wibox.container.margin,
                  -- right = 4,
                  -- left = 10, right = 4,
                  {
                     id = "text_role",
                     widget = wibox.widget.textbox,
                     align = "center"
                  },
                     },
               },
               -- tasklist
               {
                  id = "tasklist_placeholder",
                  layout = wibox.layout.fixed.horizontal
               },
            },
            widget = wibox.container.margin,
            left = 10, right = 10
            },
            id = "background_role",
            widget = wibox.container.background,
         },
         layout = wibox.layout.fixed.horizontal,
         create_callback = function(self, t, index, _)
            self:get_children_by_id("tasklist_placeholder")[1]:add(fancytasklist(cfg, index))
            local icon = gears.color.recolor_image(t.icon, "#2b3339")
         end
      },
		buttons = taglist_buttons
	}
end

return module
