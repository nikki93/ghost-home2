-- Launch window

box = require 'box'

local launch = {
   visible = false,
   _viewport = { width = 0, height = 0 },
   _rowHovered = -1,
   _lineHeight = 24,
   _numUrls = 7,
   _boxSize = { x = 0.6, y = 0.5 },
   _urls = {
      'http://0.0.0.0:8000/main.lua',
      'https://raw.githubusercontent.com/jimmylee/lua-examples/master/basic-5/main.lua',
      'https://raw.githubusercontent.com/EvanBacon/love-game/master/main.lua',
      'https://raw.githubusercontent.com/ccheever/tetris-ghost/master/main.lua',
      'https://raw.githubusercontent.com/nikki93/ghost-home/ee1950fbfb2266f17719b7cf50f36ffe3bcb7f40/main.lua',
      'https://raw.githubusercontent.com/schazers/ghost-playground/master/main.lua',
      'https://raw.githubusercontent.com/terribleben/circloid/release/main.lua',
   }
}

function launch:setVisible(newVisible)
   if self.visible ~= newVisible then
      self.visible = newVisible
      if self.visible then
         self._urls[0] = '' -- sentinel for clipboard
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
   local rowIndexClicked = box.getItemIndex({ x = x, y = y }, self._viewport, self._boxSize, self._numUrls, self._lineHeight)
   local urlClicked
   if rowIndexClicked >= 0 then
      if rowIndexClicked == 0 then
         local clipboard = love.system.getClipboardText()
         urlClicked = clipboard
      else
         urlClicked = self._urls[rowIndexClicked]
      end
   end
   if urlClicked then
      app.load(urlClicked)
   end
end

function launch:mousemoved(x, y, button)
   local rowIndexHovered = box.getItemIndex({ x = x, y = y }, self._viewport, self._boxSize, self._numUrls, self._lineHeight)
   self._rowHovered = rowIndexHovered
end

function launch:draw()
   if self.visible then
      local clipboard = love.system.getClipboardText()

      self._urls[0] = 'Clipboard: ' .. clipboard
      box.draw(self._viewport, self._boxSize, 'ghost-player', self._urls, self._rowHovered, self._lineHeight)
   end
end

return launch
