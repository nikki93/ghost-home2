-- Modules

errors = require 'errors'
app = require 'app'
launch = require 'launch'
dev = require 'dev'


-- Top-level Love callbacks

local main = {}

function main.update(dt)
    app.forwardEvent('update', dt)

    launch.update()
    errors.update()
    dev.update()
end

function main.draw()
    app.forwardEvent('draw')

    app.drawLoadedIndicator()
end

function main.keypressed(key, ...)
    -- F5 or cmd + r: reload
    if key == 'f5' or (love.keyboard.isDown('lgui') and key == 'r') then
        network.async(function()
            app.reload()

            -- GC and print memory usage
            collectgarbage()
            print(math.floor(collectgarbage('count')) .. 'KB', 'mem usage')
        end)
        return
    end

    -- F4 or cmd + d: toggle development window
    if key == 'f4' or (love.keyboard.isDown('lgui') and key == 'd') then
        dev.toggle()
        return
    end

    tui.love.keypressed(key, ...)

    app.forwardEvent('keypressed', key, ...)
end

for k in pairs({
    load = true,
    update = true,
    draw = true,
    keypressed = true,
    keyreleased = true,
    mousefocus = true,
    mousemoved = true,
    mousepressed = true,
    mousereleased = true,
    resize = true,
    textedited = true,
    textinput = true,
    touchmoved = true,
    touchpressed = true,
    touchreleased = true,
    wheelmoved = true,
    gamepadaxis = true,
    gamepadpressed = true,
    gamepadreleased = true,
    joystickadded = true,
    joystickaxis = true,
    joystickhat = true,
    joystickpressed = true,
    joystickreleased = true,
    joystickremoved = true,
}) do
    love[k] = function(...)
        if main[k] then
            main[k](...)
        else -- Default behavior if we didn't define it in `main`
            if tui.love[k] then
                tui.love[k](...)
            end

            app.forwardEvent(k, ...)
        end
    end
end
