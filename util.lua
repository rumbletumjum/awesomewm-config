local cairo = require("lgi").cairo
local gears_color = require("gears.color")

local util = {}

--- Generate selected taglist square.
-- @tparam number size Size.
-- @tparam color fg Background color.
-- @return Image with the square.
function util.taglist_squares_sel(size, fg)
    local bound = size + 5
    local img = cairo.ImageSurface(cairo.Format.ARGB32, bound, bound)
    local cr = cairo.Context(img)
    cr:set_source(gears_color(fg))
    cr:rectangle(2, 2, 5, 5)
    cr:fill()
    return img
end

--- Generate unselected taglist square.
-- @tparam number size Size.
-- @tparam color fg Background color.
-- @return Image with the square.
function util.taglist_squares_unsel(size, fg, bg)
    local bound = size + 5
    local img = cairo.ImageSurface(cairo.Format.ARGB32, bound, bound)
    local cr = cairo.Context(img)
    cr:set_source(gears_color(fg))
    cr:rectangle(2, 2, 5, 5)
    cr:fill()
    cr:set_source(gears_color(bg))
    cr:rectangle(3, 3, 3, 3)
    cr:fill()
    return img
end

return util
