-- App management

local app = {}

local lastUrl -- Last URL that was requested to be loaded
local lastLoadTime -- `love.timer.getTime()` when last load occured
local childPortal -- The portal to the app

function app.load(url)
    lastUrl = url
    network.async(function()
        childPortal = portal:newChild(url)
        lastLoadTime = love.timer.getTime()
        print("loaded '" .. url .. "'")
        errors.clear()
    end)
end

function app.reload()
    if lastUrl then
        network.flush()
        app.load(lastUrl)
    end
end

function app.close()
    childPortal = nil
end

function app.forwardEvent(eventName, ...)
    if childPortal and childPortal[eventName] then
        childPortal[eventName](childPortal, ...)
    end
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
