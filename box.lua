box = {}

font = require 'font'

function box.getItemIndex(mousePosition, viewport, proportionsInViewport, numItems, lineHeight)
   local centerX, centerY = viewport.width * 0.5, viewport.height * 0.5
   local boxWidth, boxHeight = viewport.width * proportionsInViewport.x, viewport.height * proportionsInViewport.y

   x = mousePosition.x - centerX
   y = mousePosition.y - centerY

   if x > -boxWidth * 0.5 and y > -boxHeight * 0.5 and x < boxWidth * 0.5 and y < boxHeight * 0.5 then
      local textX, textY = (-boxWidth * 0.5) + 24, (-boxHeight * 0.5) + 72
      local rowIndex = math.floor((y - textY) / lineHeight)
      if rowIndex <= numItems then
         return rowIndex
      end
   end
   return -1
end

function box.draw(viewport, proportionsInViewport, title, items, itemIndexToHighlight, lineHeight)
      local centerX, centerY = viewport.width * 0.5, viewport.height * 0.5
      local boxWidth, boxHeight = viewport.width * proportionsInViewport.x, viewport.height * proportionsInViewport.y
      love.graphics.push()
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.translate(centerX, centerY)
      love.graphics.rectangle('fill', -boxWidth * 0.5, -boxHeight * 0.5, boxWidth, boxHeight)

      love.graphics.setColor(0, 0, 0, 1)
      if title then
         love.graphics.setFont(font:bigFont())
         love.graphics.print(title, (-boxWidth * 0.5) + 24, (-boxHeight * 0.5) + 32 - (font:bigFont():getHeight() * 0.5))
      end

      love.graphics.setFont(font:smallFont())
      local fontHalfHeight = font:smallFont():getHeight() * 0.5
      local textX, textY = (-boxWidth * 0.5) + 24, (-boxHeight * 0.5) + 72
      for k, v in pairs(items) do
         if k == itemIndexToHighlight then
            love.graphics.push('all')
            love.graphics.setColor(0.9, 0.9, 0.9, 1)
            love.graphics.rectangle('fill', -boxWidth * 0.5, textY, boxWidth, lineHeight)
            love.graphics.pop()
         end
         love.graphics.print(v, textX, textY + (lineHeight * 0.5) - fontHalfHeight)
         textY = textY + lineHeight
      end
      
      love.graphics.pop()
end

return box
