-- Dev window

local dev = {}

dev.visible = false
dev.consoleMessages = {}
dev.scrollToBottom = true

function dev.setVisible(newVisible)
    dev.visible = newVisible
end

function dev.isVisible()
    return dev.visible
end

function dev.update()
    if not dev.visible then
        return
    end

    tui.setNextWindowPos(40, love.graphics.getHeight() - 240 - 40, 'FirstUseEver')
    tui.setNextWindowSize(480, 240, 'FirstUseEver')
    tui.inWindow('development', true, function(open)
        if not open then
            dev.setVisible(false)
            return
        end

        if app.isOpen() then
            if tui.button('close portal') then
                app.close()
            end
            tui.sameLine()
        end
        if tui.button('reload portal') then
            app.reload()
        end
        tui.sameLine()
        if tui.button('clear console') then
            dev.consoleMessages = {}
        end

        tui.inChild('console', function()
            for _, message in ipairs(dev.consoleMessages) do
                tui.textWrapped(message)
            end
            if dev.scrollToBottom then
                tui.setScrollHere()
                dev.scrollToBottom = false
            end
        end)
    end)
end

function dev.print(...)
    local message = select(1, ...)
    for i = 2, select('#', ...) do
        message = message .. '    ' .. select(i, ...)
    end
    table.insert(dev.consoleMessages, message)
    dev.scrollToBottom = true
end

local oldPrint = print
function print(...) -- Replace global `print`, but stil call original
    oldPrint(...)
    dev.print(...)
end

return dev
