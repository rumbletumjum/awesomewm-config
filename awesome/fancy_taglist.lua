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

local fancytasklist = function(cfg, tag_index)
	return awful.widget.tasklist{
		screen = cfg.screen or awful.screen.focused(),
		filter = generate_filter(tag_index),
		buttons = cfg.tasklist_buttons,
		widget_template = {
			{
				id = "clienticon",
				widget = awful.widget.clienticon
			},
			layout = wibox.layout.stack,
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
		filter = awful.widget.taglist.filter.all,
		style = {
			shape_border_width = 2, shape_border_color = '#90c8c2',
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, 5)
			end
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = 10,
		},
		widget_template = {
			{
				{
					{
						{ -- Tag
							id = "text_role",
							widget = wibox.widget.textbox,
							align = "center"
						},
						{ -- tasklist
							id = "tasklist_placeholder",
							layout = wibox.layout.fixed.horizontal
						},
						layout = wibox.layout.fixed.vertical
					},
					top = 4, bottom = 4, left = 8, right = 8,
					widget = wibox.container.margin,
				},
				id = "background_role",
				widget = wibox.container.background,
			},
			layout = wibox.layout.fixed.horizontal,
			create_callback = function(self, _, index, _)
				self:get_children_by_id("tasklist_placeholder")[1]:add(fancytasklist(cfg, index))
			end
		},
		buttons = taglist_buttons
	}
end

return module
