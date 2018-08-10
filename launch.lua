-- Launch window

local launch = {
   visible = false,
   _viewport = { width = 0, height = 0 },
   _rowHovered = -1,
   _lineHeight = 42,
   _boxSize = { x = 0.6, y = 0.5 },
   _history = {},
   _historyLength = 0,
}

function launch:setVisible(newVisible)
   if self.visible ~= newVisible then
      self.visible = newVisible
      if self.visible then
         history:load()
         local historyItems, historyLength = history:get()
         self._history = {}
         for k, item in pairs(historyItems) do
            self._history[k] = { value = item }
         end
         self._historyLength = historyLength
         self._history[0] = '' -- sentinel for clipboard
         local width, height = love.window.getMode()
         self._viewport.width = width
         self._viewport.height = height
         self._rowHovered = -1
      end
   end
end

function launch:update()
   if self.visible then
      self._history[0] = { title = 'Clipboard is empty' }
      local clipboard = love.system.getClipboardText()
      if clipboard and clipboard:len() > 0 then
         clipboard = clipboard:gsub('\n', ' ')
         clipboard = clipboard:gsub("%s+", "")
         if clipboard:len() > 0 then
            self._history[0] = { value = clipboard, title = clipboard, subtitle = 'Clipboard' }
         end
      end
   end
end

function launch:mousepressed(x, y, button)
   if self.visible then
      local rowIndexClicked = box.getItemIndex({ x = x, y = y }, self._viewport, self._boxSize, self._historyLength, self._lineHeight)
      local urlClicked
      if rowIndexClicked >= 0 then
         urlClicked = self._history[rowIndexClicked].value
      end
      if urlClicked and urlClicked:len() then
         history:push(urlClicked)
         app.load(urlClicked)
      end
   end
end

function launch:mousemoved(x, y, button)
   local rowIndexHovered = box.getItemIndex({ x = x, y = y }, self._viewport, self._boxSize, self._historyLength, self._lineHeight)
   if rowIndexHovered == 0 and self._history[0].value == nil then
      self._rowHovered = -1 -- empty clipboard
   else
      self._rowHovered = rowIndexHovered
   end
end

function launch:draw()
   if self.visible then
      box.draw(self._viewport, self._boxSize, 'ghost-player', self._history, self._rowHovered, self._lineHeight)
      
      love.graphics.setFont(font:smallFont())
      love.graphics.setColor(1, 1, 1, 1)
      local version = 'v0.0.1'
      local strWidth = font:smallFont():getWidth(version)
      love.graphics.print(version, self._viewport.width - strWidth - 24, self._viewport.height - 40)
   end
end

return launch
