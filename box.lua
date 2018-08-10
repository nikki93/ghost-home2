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

function box.drawItem(item, bounds, isHighlighted)
   local fontHalfHeight = font:smallFont():getHeight() * 0.5
   if isHighlighted then
      love.graphics.push('all')
      love.graphics.setColor(0.9, 0.9, 0.9, 1)
      love.graphics.rectangle('fill', bounds.x, bounds.y, bounds.width, bounds.height)
      love.graphics.pop()
   end
   local valueY = bounds.y + (bounds.height * 0.5) - fontHalfHeight
   if item.subtitle then
      love.graphics.setFont(font:tinyFont())
      love.graphics.print(item.subtitle, bounds.x + 24, bounds.y + bounds.height - 14)
      valueY = valueY - 6
   end
   if item.value or item.title then
      local label
      if item.title then label = item.title else label = item.value end
      love.graphics.setFont(font:smallFont())
      love.graphics.print(label, bounds.x + 24, valueY)
   end
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
         love.graphics.print(title, (-boxWidth * 0.5) + 24, (-boxHeight * 0.5) + 40 - (font:bigFont():getHeight() * 0.5))
      end

      local x, y = (-boxWidth * 0.5), (-boxHeight * 0.5) + 80
      for k, item in pairs(items) do
         box.drawItem(
            item,
            { x = x, y = y, width = boxWidth, height = lineHeight },
            k == itemIndexToHighlight
         )
         y = y + lineHeight
      end
      
      love.graphics.pop()
end

return box
