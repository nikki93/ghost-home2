-- Launch window

box = require 'box'
history = require 'history'

local launch = {
   visible = false,
   _viewport = { width = 0, height = 0 },
   _rowHovered = -1,
   _lineHeight = 28,
   _boxSize = { x = 0.6, y = 0.5 },
   _history = {},
   _historyLength = 0,
}

function launch:setVisible(newVisible)
   if self.visible ~= newVisible then
      self.visible = newVisible
      if self.visible then
         history:load()
         self._history, self._historyLength = history:get()
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
        --[[
        tui.setNextWindowPos(40, 40, 'FirstUseEver')
        tui.setNextWindowSize(480, 320, 'FirstUseEver')
        tui.inWindow('welcome to ghost!', function()
            for name, url in pairs(urls) do
                if tui.button(name) then
                    app.load(url)
                end
            end
            tui.text('fps: ' .. tostring(love.timer.getFPS()))
        end)
        --]]
    end
end

function launch:mousepressed(x, y, button)
   local rowIndexClicked = box.getItemIndex({ x = x, y = y }, self._viewport, self._boxSize, self._historyLength, self._lineHeight)
   local urlClicked
   if rowIndexClicked >= 0 then
      if rowIndexClicked == 0 then
         local clipboard = love.system.getClipboardText()
         urlClicked = clipboard
      else
         urlClicked = self._history[rowIndexClicked]
      end
   end
   if urlClicked then
      history:push(urlClicked)
      app.load(urlClicked)
   end
end

function launch:mousemoved(x, y, button)
   local rowIndexHovered = box.getItemIndex({ x = x, y = y }, self._viewport, self._boxSize, self._historyLength, self._lineHeight)
   self._rowHovered = rowIndexHovered
end

function launch:draw()
   if self.visible then
      local clipboard = love.system.getClipboardText()

      self._history[0] = 'Clipboard: ' .. clipboard
      box.draw(self._viewport, self._boxSize, 'ghost-player', self._history, self._rowHovered, self._lineHeight)
   end
end

return launch
