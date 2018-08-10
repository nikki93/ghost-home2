font = {
   _fonts = nil
}

function font:bigFont()
   if self._fonts == nil then
      self:load()
   end
   return self._fonts['big']
end

function font:smallFont()
   if self._fonts == nil then
      self:load()
   end
   return self._fonts['small']
end

function font:load()
   self._fonts = {}
   self._fonts['big'] = love.graphics.newFont('x14y24pxHeadUpDaisy.ttf', 36)
   self._fonts['small'] = love.graphics.newFont('x14y24pxHeadUpDaisy.ttf', 14)
end

return font
