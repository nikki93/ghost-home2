-- Launch window

local launch = {}

local visible = true

function launch.setVisible(newVisible)
    visible = newVisible
end

function launch.update()
    if visible then
        local clipboard = love.system.getClipboardText()
        local urls = {
            ["localhost"] = 'http://0.0.0.0:8000/main.lua',
            ["clipboard (" .. clipboard .. ")"] = clipboard,
            ["@wwwjim's"] = 'https://raw.githubusercontent.com/jimmylee/lua-examples/master/basic-5/main.lua',
            ["evan's"] = 'https://raw.githubusercontent.com/EvanBacon/love-game/master/main.lua',
            ["ccheever's"] = 'https://raw.githubusercontent.com/ccheever/tetris-ghost/master/main.lua',
            ["nikki's"] = 'https://raw.githubusercontent.com/nikki93/ghost-home/ee1950fbfb2266f17719b7cf50f36ffe3bcb7f40/main.lua',
            ["jason's"] = 'https://raw.githubusercontent.com/schazers/ghost-playground/master/main.lua',
            ["CIRCLOID"] = 'https://raw.githubusercontent.com/terribleben/circloid/release/main.lua',
        }

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
    end
end

return launch
