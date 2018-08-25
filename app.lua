-- App management

local app = {
   _isPaused = false,
   _viewport = { width = 0, height = 0 },
   _boxSize = { x = 0.6, y = 0.3 },
   _lineHeight = 28,
   _numOptions = 1,
   _rowHovered = -1,
   _options = {},
}

local lastUrl -- Last URL that was requested to be loaded
local lastLoadTime -- `love.timer.getTime()` when last load occured
local childPortal -- The portal to the app

local copas = require 'copas'

function app.load(url)
    lastUrl = url
    app._isPaused = false
    network.async(function()
        errors.clear()
        childPortal = portal:newChild(url, {
            extraGlobals = {
                print = print,
            },
        })
        if childPortal then
            lastLoadTime = love.timer.getTime()
            print("loaded '" .. url .. "'")
            history:push(url)
        end
    end)
end

function app.reload()
    if lastUrl then
        network.flush()
        app.load(lastUrl)
    end
end

function app.softReload()
    if lastUrl and childPortal then
        -- Iterate over modules loaded in `childPortal` asynchronously
        local urls = {} -- Map of `url` to `'waiting'`, `'reload'` or `'done'`
        local mainCoroutine = coroutine.running()
        for url in pairs(childPortal.globals.package.loaded) do
            -- Make sure it's located under the portal's base URL
            if url:sub(1, #childPortal.basePath) == childPortal.basePath then
                urls[url] = 'waiting'
                network.async(function()
                    -- Find the previously cached and newly requested 'Last-Modified' HTTP HEAD values
                    local before, after
                    do
                        local _, _, headers = network.fetch(url, 'HEAD')
                        before = headers['last-modified']
                    end
                    network.fetchEntries.HEAD[url] = nil -- Flush from HTTP HEAD cache
                    do
                        local _, _, headers = network.fetch(url, 'HEAD')
                        after = headers['last-modified']
                    end

                    -- If they are different, we need to reload!
                    if before ~= after then
                        urls[url] = 'reload'
                        childPortal.globals.package.loaded[url] = nil -- Flush from module cache
                        network.fetchEntries.GET[url] = nil -- Flush from HTTP GET cache
                    else
                        urls[url] = 'done'
                    end
                    copas.wakeup(mainCoroutine)
                end)
            end
        end

        -- Wait until none of the `urls` are in `'waiting'` state
        while true do
            local anyWaiting = false
            for _, state in pairs(urls) do
                if state == 'waiting' then
                    anyWaiting = true
                    break
                end
            end
            if anyWaiting then
                copas.sleep(-1)
            else
                break
            end
        end

        -- Reload the modules using the child portal's `require`
        for url, state in pairs(urls) do
            if state == 'reload' then
                childPortal.globals.require(url:sub(#childPortal.basePath + 1):gsub('^/*', ''))
            end
        end
    end
end

function app.close()
    childPortal = nil
end

function app.togglePaused()
   app._isPaused = not app._isPaused
   if app._isPaused then
      local width, height = love.window.getMode()
      app._viewport.width = width
      app._viewport.height = height
      app._rowHovered = -1
      app._options[0] = { value = 'Resume' }
      app._options[1] = { value = 'Back to ghost-player index' }
   end
end

function app.forwardEvent(eventName, ...)
   if app._isPaused then
      -- paused: capture needed events for pause menu
      -- and don't forward anything to childPortal
      if (eventName == 'update' or eventName == 'draw' or eventName == 'mousemoved' or eventName == 'mousepressed')
      then
         app[eventName](...)
      end
   else
      -- not paused, forward everything to childPortal
      if childPortal and childPortal[eventName] then
         childPortal[eventName](childPortal, ...)
      end
   end
end

function app.draw()
   if app._isPaused then
      -- draw underlying portal
      if childPortal and childPortal.draw then
         childPortal:draw()
      end
      -- overlay
      love.graphics.setColor(1, 1, 1, 0.3)
      love.graphics.rectangle('fill', 0, 0, app._viewport.width, app._viewport.height)

      box.draw(app._viewport, app._boxSize, 'ghost-player', app._options, app._rowHovered, app._lineHeight)
   end
end

function app.update(dt)
end

function app.mousepressed(x, y, button)
   if button == 1 then
      local rowIndexClicked = box.getItemIndex({ x = x, y = y }, app._viewport, app._boxSize, app._numOptions, app._lineHeight)
      if rowIndexClicked == 0 then
         app.togglePaused()
      elseif rowIndexClicked == 1 then
         app.close()
      end
   end
end

function app.mousemoved(x, y)
   local rowIndexHovered = box.getItemIndex({ x = x, y = y }, app._viewport, app._boxSize, app._numOptions, app._lineHeight)
   app._rowHovered = rowIndexHovered
end

function app.drawLoadedIndicator()
    if childPortal and love.timer.getTime() - lastLoadTime < 2 then
        love.graphics.push('all')
        love.graphics.setColor(0.8, 0.5, 0.1)
        local fontH = love.graphics.getFont():getHeight()
        local yStep = 1.2 * fontH
        love.graphics.print("loaded '" .. lastUrl .. "'",
            yStep - fontH + 4,
            love.graphics.getHeight() - yStep)
        love.graphics.pop('all')
    end
end

function app.isOpen()
    return childPortal ~= nil
end

return app
