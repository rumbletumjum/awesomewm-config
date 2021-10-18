local ipairs = ipairs
local math = math

local cols = {}

local function do_cols(p)
   local wa = p.workarea
   local cls = p.clients

   local fact = 1 / #cls

   for k, c in ipairs(cls) do
      k = k - 1
      local g = {}

      g.height = wa.height
      g.y = wa.y

      g.width = math.ceil(wa.width * fact)
      g.x = wa.x + k * g.width

      p.geometries[c] = g
   end
end

cols.name = "cols"
function cols.arrange(p)
   return do_cols(p)
end

return cols
