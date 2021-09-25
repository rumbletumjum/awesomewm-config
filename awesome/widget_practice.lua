local buttons_example = wibox {
    visible = true,
    bg = '#2E3440',
    ontop = true,
    x = 50,
    y = 150,
    height = 200,
    width = 700,
    -- shape = function(cr, width, height)
    --     gears.shape.rounded_bar(cr, width, height)
    -- end
}

local button = wibox.widget {
    {
    {
        {
            {
                text = "I'm a widget!",
                widget = wibox.widget.textbox
            },
            top = 4, bottom = 4, left = 8, right = 8,
            widget = wibox.container.margin
        },
        bg = '#2e3440',
        shape_border_width = 1, shape_border_color = '#4c566a',
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 5)
        end,
        widget = wibox.container.background
    },
    widget = wibox.container.place
    },

    shape_border_width = 1, shape_border_color = 'red',
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 5)
    end,
    widget = wibox.container.background
}

buttons_example:setup {
    layout = wibox.layout.fixed.vertical,
    {
        layout = wibox.container.constraint,
        strategy = min,
        height = 100,
        forced_height = 100,
        button
    },
}

-- buttons_example:setup

awful.placement.top(buttons_example, { margins = {top = 40}, parent = awful.screen.focused()})
