font = {
   _fonts = nil
}

function font:bigFont()
   return self:_getFont('big')
end

function font:smallFont()
   return self:_getFont('small')
end

function font:tinyFont()
   return self:_getFont('tiny')
end

function font:_getFont(key)
   if self._fonts == nil then
      self:load()
   end
   return self._fonts[key]
end

function font:load()
   self._fonts = {}
   self._fonts['big'] = love.graphics.newFont('x14y24pxHeadUpDaisy.ttf', 36)
   self._fonts['small'] = love.graphics.newFont('x14y24pxHeadUpDaisy.ttf', 14)
   self._fonts['tiny'] = love.graphics.newFont('x14y24pxHeadUpDaisy.ttf', 8)
end

return font
