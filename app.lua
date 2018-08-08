-- App management

local app = {}

function app.load(url)
    app.lastUrl = url
    network.async(function()
        app.portal = portal:newChild(url)
        app.loadTime = love.timer.getTime()
        print("loaded '" .. url .. "'")
        errors.clear()
    end)
end

function app.reload()
    if app.lastUrl then
        network.flush()
        app.load(app.lastUrl)
    end
end

function app.close()
    app.portal = nil
end

function app.forwardEvent(eventName, ...)
    if app.portal and app.portal[eventName] then
        app.portal[eventName](app.portal, ...)
    end
end

function app.drawLoadedIndicator()
    if app.portal and love.timer.getTime() - app.loadTime < 2 then
        love.graphics.push('all')
        love.graphics.setColor(0.8, 0.5, 0.1)
        local fontH = love.graphics.getFont():getHeight()
        local yStep = 1.2 * fontH
        love.graphics.print("loaded '" .. app.lastUrl .. "'",
            yStep - fontH + 4,
            love.graphics.getHeight() - yStep)
        love.graphics.pop('all')
    end
end

return app
