local cairo = require("lgi").cairo

local module = {}

module.desaturate_icon = function(icon)
   local ic = cairo.Surface(icon)
   local icp = cairo.Pattern.create_for_surface(ic)
   local sw,sh = ic:get_width(),ic:get_height()

   local default_height = 14

   -- Create matrix
   local ratio = (default_height-4) / ((sw > sh) and sw or sh)
   local matrix = cairo.Matrix()
   cairo.Matrix.init_scale(matrix,ratio,ratio)
   matrix:translate(default_height/2 - 6,-2)

   --Copy to surface
   local img5 = cairo.ImageSurface.create(cairo.Format.ARGB32, sw, sh)
   local cr5 = cairo.Context(img5)
   cr5:set_operator(cairo.Operator.CLEAR)
   cr5:paint()
   cr5:set_operator(cairo.Operator.SOURCE)
   -- cr5:set_matrix(matrix)
   cr5:set_source(icp)
   cr5:paint()

   --Generate the mask
   local img4 = cairo.ImageSurface.create(cairo.Format.A8, sw, sh)
   local cr4 = cairo.Context(img4)
   --         cr4:set_matrix(matrix)
   cr4:set_source(icp)
   cr4:paint()

   -- Apply desaturation
   cr5:set_source_rgba(0,0,0,1)
   cr5:set_operator(cairo.Operator.HSL_SATURATION)
   cr5:mask(cairo.Pattern.create_for_surface(img4))
   cr5:set_operator(cairo.Operator.HSL_COLOR)
   cr5:set_source_rgba(64/255,64/255,64/255,1)
   cr5:mask(cairo.Pattern.create_for_surface(img4))

   --Cache
   -- icon_cache[c.icon] = img5
   return img5
end

return module
