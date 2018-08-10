-- Modules

errors = require 'errors'
app = require 'app'
launch = require 'launch'
dev = require 'dev'

-- Top-level Love callbacks

local main = {}

function main.update(dt)
    app.forwardEvent('update', dt)

    launch:setVisible(not app.isOpen())

    launch:update()
    errors.update()
    dev.update()
end

function main.draw()
   if launch.visible then
      launch:draw()
   else
      app.forwardEvent('draw')
   end

    app.drawLoadedIndicator()
end

function main.mousepressed(x, y, button, ...)
   if launch.visible then
      launch:mousepressed(x, y, button)
   else
      app.forwardEvent('mousepressed', x, y, button, ...)
   end
end

function main.mousemoved(x, y, button, ...)
   if launch.visible then
      launch:mousemoved(x, y, button)
   else
      app.forwardEvent('mousemoved', x, y, button, ...)
   end
end

function main.keypressed(key, ...)
    local cmdDown = love.keyboard.isDown('lgui') or love.keyboard.isDown('rgui')

    -- F10 or cmd + w: close app
    if key == 'escape' then
        app.togglePaused()
        return
    end
    
    -- F5 or cmd + r: reload
    if key == 'f5' or (cmdDown and key == 'r') then
        network.async(function()
            app.reload()

            -- GC and print memory usage
            collectgarbage()
            print(math.floor(collectgarbage('count')) .. 'KB', 'mem usage')
        end)
        return
    end

    -- F4 or cmd + d: toggle development window
    if key == 'f4' or (cmdDown and key == 'd') then
        dev.setVisible(not dev.isVisible())
        return
    end

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
            app.forwardEvent(k, ...)
        end
    end
end
