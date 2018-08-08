-- Error management

local errors = {}

function portal.onError(err, descendant)
    app.close()
    errors.lastError = "portal to '" .. descendant.path .. "' was closed due to error:\n" .. err
    print('error: ' .. errors.lastError)
    network.flush()
end

function errors.clear()
    errors.lastError = nil
end

function errors.update()
    if errors.lastError ~= nil then
        tui.setNextWindowPos(
            0.5 * love.graphics.getWidth(), 0.5 * love.graphics.getHeight(),
            'FirstUseEver',
            0.5, 0.5)
        tui.setNextWindowSize(480, 120, 'FirstUseEver')
        tui.inWindow('error', true, function(open)
            if not open then
                errors.clear()
                return
            end

            if tui.button('reload') then
                app.reload()
            end
            tui.sameLine()
            if love.system.getClipboardText() ~= errors.lastError then
                if tui.button('copy message') then
                    love.system.setClipboardText(errors.lastError)
                end
            else
                tui.alignTextToFramePadding()
                tui.text('message copied!')
            end

            tui.inChild('error message', function()
                tui.textWrapped(errors.lastError)
            end)
        end)
    end
end

return errors
