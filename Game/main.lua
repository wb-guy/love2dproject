-- function made
function clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    else
        return x
    end
end
function copyTable(t)
    local new = {}
    for k,v in pairs(t) do
        new[k] = v
    end
    return new
end
-- inital vars
mouse = {}
-- window class
Windows = {}
WindowsRender = {}
Windows.__index = Windows
ActiveWindow = nil
ActiveWindowpos = 0
IDPointer = 0
function Windows.create(coords, transform, flags) 
    local self = setmetatable({}, Windows)
    self.x = coords[1] or 5
    self.y = coords[2] or 5
    self.width = transform[1] or 25
    self.height = transform[2] or 25
    self.held = false
    self.resize = false
    self.movable = flags["movable"] or true
    self.resizable = flags["resizable"] or true
    self.removable = flags["removable"] or true
    self.title = flags["title"] or "title"
    self.type = flags["type"] or "none"
    self.id = IDPointer + 1 
    IDPointer = IDPointer + 1 
    table.insert(WindowsRender, self)
    return self
end

function Windows.delete(dead)
    for i, window in ipairs(WindowsRender) do
        if window == dead then
        table.remove(WindowsRender, i)
        break
        end
    end
end

function Windows.IsHolding(window)
    if window == ActiveWindow then
        if mouse.x > window.x and mouse.x < window.x + window.width and mouse.y > window.y and mouse.y < window.y + window.height then
        else
            print("bye")
            ActiveWindow = nil
            ActiveWindowpos = 0
        end
    end
end

function Windows.active()

end

windowstouched = {}

function Windows.TouchingFunction(window, pos)
    if mouse.x > window.x and mouse.x < window.x + window.width and mouse.y > window.y and mouse.y < window.y + window.height then
        window.touching = true
        table.insert(windowstouched, pos)
        touchingwindows = true
        print(table.concat(windowstouched, ", "))
    else window.touching = false end
end

function Windows.IsHeld(window, pos)
    if mouse.x > window.x and mouse.x < window.x + window.width and mouse.y > window.y and mouse.y < window.y + window.height then
        if mouse.clicked and ActiveWindow == nil then
            print("wtf")
            max = windowstouched[1]
            for i = 2, #windowstouched do
                if windowstouched[i] > max then
                    max = windowstouched[i]
                end
            end
            print("a: " .. max)
            -- im going insane
            ActiveWindow = WindowsRender[max]
            ActiveWindowpos = pos
        end

        if mouse.x > window.x and mouse.x < window.x + 10 and mouse.y > window.y and mouse.y < window.y + 10 then
            love.mouse.setCursor(mouse.cursor.hand)
            if mouse.clicked == true and window == ActiveWindow then
                if window.held == false then
                window.held = true
                window.heldx = mouse.x
                window.heldy = mouse.y
                window.ix = window.x
                window.iy = window.y
                print("g")
                end
            end
        elseif mouse.x > window.x + window.width - 10 and mouse.x < window.x + window.width and mouse.y > window.y + window.height - 10 and mouse.y < window.y + window.height then
            love.mouse.setCursor(mouse.cursor.hand)
            if mouse.clicked == true and window == ActiveWindow then
                if window.resize == false then
                window.resize = true
                window.heldx = mouse.x
                window.heldy = mouse.y
                window.iw = window.width
                window.ih = window.height
                print("a")
                end
            end
        elseif mouse.x > window.x + window.width - 10 and mouse.x < window.x + window.width and mouse.y > window.y - 10 and mouse.y < window.y + 10 then
            love.mouse.setCursor(mouse.cursor.hand)
            if mouse.clicked == true and window == ActiveWindow then
                if window.removable == true then
                ActiveWindowpos = 0
                ActiveWindow = nil
                Windows.delete(window)
                print("oof")
                end
            end
        end
    end
end

function Windows.Holding(window)
    if window.held == true and window.movable == true then
        touchingwindows = true
        love.mouse.setCursor(mouse.cursor.sizeall)
        window.x = window.ix - (window.heldx - mouse.x)
        window.y = window.iy - (window.heldy - mouse.y)
        if mouse.down == false then window.held = false end
    end
end

function Windows.Resizing(window)
    if window.resize == true and window.resizable == true then
        touchingwindows = true
        love.mouse.setCursor(mouse.cursor.sizeall)
        window.width = clamp(window.iw - (window.heldx - mouse.x), 200, 500)
        window.height = clamp(window.ih - (window.heldy - mouse.y), 100, 250)
        if mouse.down == false then window.resize = false end
    end
end

Windows.create({100,100}, {200,150}, {movable = true, resizable = true, type = "gen", title = "im window 1"})
Windows.create({123,242}, {200,150}, {movable = true, resizable = true})

--------------------------------------------------------------------------------------------------
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    defaultfont = love.graphics.newFont("med.ttf", 15)
    window = love.graphics.newFont("med.ttf", 9)

    love.graphics.setBackgroundColor(14/100, 15/255, 33/255)

    mouse.cursor = {}

    mouse.cursor.arrow = love.mouse.getSystemCursor("arrow")
    mouse.cursor.hand = love.mouse.getSystemCursor("hand")
    mouse.cursor.sizeall = love.mouse.getSystemCursor("sizeall")
end


function love.update(dt)
    touchingwindows = false
    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.down = love.mouse.isDown(1)
    if mouse.down == true then
        if mouse.pressed == true then
            mouse.howlong = love.timer.getTime() - mouse.pressedtime
        else
            mouse.pressed = true
            mouse.pressedtime = love.timer.getTime()
        end
    else
        if mouse.pressed == true then
            mouse.pressed = false
        end
    end
    love.mouse.setCursor(mouse.cursor.arrow) 

    windowstouched = {}
    for iz, wrench in ipairs(WindowsRender) do
    Windows.TouchingFunction(wrench, iz)
    Windows.IsHeld(wrench, iz)
    Windows.Holding(wrench)
    Windows.Resizing(wrench)
    Windows.IsHolding(wrench)
    end
    mouse.clicked = false
end

function love.mousepressed(x, y, button)
    if button == 1 then
        mouse.clicked = true
        print(tostring(mouse.clicked).."..clicked")
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(defaultfont)
    love.graphics.print("Mouse Coordinates: "..mouse.x..", "..mouse.y.." | ".. tostring(mouse.down) .. " | ".. tostring(mouse.howlong) .. " | clicked:" .. tostring(mouse.clicked) .. " | touchingwindows:" .. tostring(touchingwindows) )
    
    for _, wrench in ipairs(WindowsRender) do
        love.graphics.setColor(1/3,1/3,1/3)
        love.graphics.rectangle("fill", wrench.x-2, wrench.y-2, wrench.width+4, wrench.height+4)
        if ActiveWindow == wrench then 
            love.graphics.setColor(1/1.1,1/1.1,1/1.1)
        elseif touchingwindows then
            love.graphics.setColor(1/1.3,1/1.3,1/1.3)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.rectangle("fill", wrench.x, wrench.y, wrench.width, wrench.height)
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle("fill", wrench.x, wrench.y, wrench.width, 10)
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", wrench.x, wrench.y, 10, 10)
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle("fill", wrench.x + wrench.width - 10, wrench.y + wrench.height - 10, 10, 10)
        love.graphics.setColor(1,0,0.5)
        love.graphics.rectangle("fill", wrench.x + wrench.width - 10, wrench.y, 10, 10)
        love.graphics.setColor(1/1.5,0,0.5/1.5)
        love.graphics.polygon("fill", wrench.x+wrench.width-10,wrench.y, wrench.x+wrench.width-10,wrench.y+10, wrench.x+wrench.width,wrench.y)
        if wrench == ActiveWindow then love.graphics.setColor(1,1,1) else love.graphics.setColor(0,0,0) end 
        love.graphics.setFont(window)
        love.graphics.print(wrench.title, wrench.x + 15, wrench.y) 
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit( "restart" )
    elseif key == "f1" then
        love.event.quit( "bye" )
    elseif key == "space" then
        Windows.create({mouse.x-100,mouse.y-50}, {200,100}, {movable = true, resizable = true, title = "im" .. #WindowsRender + 1})
    end
end
