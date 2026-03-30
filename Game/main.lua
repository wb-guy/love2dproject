-- function made for easy

function clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    else
        return x
    end
end

function averagecolor(colors)
    if #colors == 3 then
        if (colors[1] + colors[2] + colors[3])/3 >= 0.5 then
            --print("black")
        return true 
        else
            --print("white")
        return false 
        end
    else print("you forgot 3") return true end
end
-- inital vars

mouse = {}

------------------- window class -------------------------

Windows = {}
WindowsRender = {}
Windows.__index = Windows
ActiveWindow = nil
ActiveWindowpos = 0
IDPointer = 0
function Windows.create(coords, transform, flags) 
    local self = setmetatable({}, Windows)
    self.x = coords[1] or actualwin.width/2
    self.y = coords[2] or actualwin.height/2
    self.width = transform[1] or 200
    self.height = transform[2] or 100
    self.held = false
    self.resize = false
    self.doingstuff = false
    self.movable = flags["movable"] or true
    self.resizable = flags["resizable"] or true
    self.removable = flags["removable"] or true
    self.title = flags["title"] or "title"
    self.type = flags["type"] or "none"
    self.id = IDPointer + 1 
    self.colorbg = flags["colorbg"] or {1, 1, 1}
    IDPointer = IDPointer + 1 
    table.insert(WindowsRender, self)
    return self
end

------------------------- loading stuffz 

-- kill window (idk why it uses the window itself not the position but its for convience)
function Windows.delete(dead)
    for i, window in ipairs(WindowsRender) do
        if window == dead then
        table.remove(WindowsRender, i)
        break
        end
    end
end

-- check if cursor is on active window + on doing something 
function Windows.CursorOnActiveBusiness(window)
    if window == ActiveWindow then
        if mouse.x > window.x and mouse.x < window.x + window.width and 
        mouse.y > window.y and mouse.y < window.y + window.height then
        else
            if window.doingstuff == false then
                print("bye")
                ActiveWindow = nil
                ActiveWindowpos = 0
            end
        end
    end
end

-- table for touching windows

tabletouching = {}

function Windows.TouchingFunction(window, pos)
    if mouse.x > window.x and mouse.x < window.x + window.width and mouse.y > window.y and mouse.y < window.y + window.height then
        window.touching = true
        table.insert(tabletouching, pos)
        touchingwindows = true
    else window.touching = false end
end

---------------------------- biggest part: window touching system

function Windows.IsHeld(window, pos)
    if window.touching == true then
        if mouse.clicked and ActiveWindow == nil then
            --it grabs the front to be a active window
            table.sort(tabletouching, function(a, b) return a > b end)
            ActiveWindow = WindowsRender[tabletouching[1]]
            ActiveWindowpos = tabletouching[1]
        end

        if mouse.x > window.x and mouse.x < window.x + 10 and mouse.y > window.y and mouse.y < window.y + 10 then
            if ActiveWindow == window then love.mouse.setCursor(mouse.cursor.hand) end
            if mouse.clicked == true and window == ActiveWindow then
                if window.held == false then
                window.doingstuff = true
                window.held = true
                window.heldx = mouse.x
                window.heldy = mouse.y
                window.ix = window.x
                window.iy = window.y
                print("g")
                end
            end
        elseif mouse.x > window.x + window.width - 10 and mouse.x < window.x + window.width and mouse.y > window.y + window.height - 10 and mouse.y < window.y + window.height then
            if ActiveWindow == window then love.mouse.setCursor(mouse.cursor.hand) end
            if mouse.clicked == true and window == ActiveWindow then
                if window.resize == false then
                window.doingstuff = true
                window.resize = true
                window.heldx = mouse.x
                window.heldy = mouse.y
                window.iw = window.width
                window.ih = window.height
                print("a")
                end
            end
        elseif mouse.x > window.x + window.width - 10 and mouse.x < window.x + window.width and mouse.y > window.y - 10 and mouse.y < window.y + 10 then
            if ActiveWindow == window then love.mouse.setCursor(mouse.cursor.hand) end
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

------------------------------------------- purpose stuffz 

function Windows.Holding(window)
    if window.held == true and window.movable == true then
        touchingwindows = true
        love.mouse.setCursor(mouse.cursor.sizeall)
        window.x = clamp(window.ix - (window.heldx - mouse.x), 10, actualwin.width - window.width - 10)
        window.y = clamp(window.iy - (window.heldy - mouse.y), 10, actualwin.height - window.height - 10)
        if mouse.down == false then 
            window.held = false 
            window.doingstuff = false end
    end
end

function Windows.Resizing(window)
    if window.resize == true and window.resizable == true then
        touchingwindows = true
        love.mouse.setCursor(mouse.cursor.sizeall)
        window.width = clamp(window.iw - (window.heldx - mouse.x), 200, 500)
        window.height = clamp(window.ih - (window.heldy - mouse.y), 100, 250)
        if mouse.down == false then
            window.resize = false 
            window.doingstuff = false end
    end
end

-- add default windows 

Windows.create({100,100}, {200,150}, {movable = true, resizable = true, type = "its gay", title = "gay window", colorbg = {0, 0, 0.4} })

--------------------------------------------------------------------------------------------------
function love.load()
    love.window.setVSync(0)
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

actualwin = {}
function love.update(dt)

    fps = love.timer.getFPS()
    actualwin.width, actualwin.height = love.graphics.getDimensions( )
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

    tabletouching = {}

    for iz, wrench in ipairs(WindowsRender) do
    Windows.TouchingFunction(wrench, iz)
    end

    for iz, wrench in ipairs(WindowsRender) do
    Windows.IsHeld(wrench, iz)
    Windows.Holding(wrench)
    Windows.Resizing(wrench)
    Windows.CursorOnActiveBusiness(wrench)
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

    love.graphics.setColor(1,1,1,1/10)

    love.graphics.circle( "fill", actualwin.width/2, actualwin.height/2, (math.sin(love.timer.getTime())*10) + 100 )
    love.graphics.circle( "fill", actualwin.width/2-50, actualwin.height/2-50, (math.sin(love.timer.getTime())*10) + 50 )
    
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(defaultfont)
    
    if ActiveWindow ~= nil then
        temp1 = tostring(ActiveWindow.doingstuff)
    else 
        temp1 = nil
    end

    love.graphics.print("x:"..mouse.x..", y:"..mouse.y.." | down:".. tostring(mouse.down) .. " | ".. tostring(mouse.howlong) .. 
    "\n | touchingwindows:" .. tostring(touchingwindows) .. " | isactive:" .. tostring(temp1) ..
    "\n FPS: " .. fps )
    
    for _, wrench in ipairs(WindowsRender) do
        love.graphics.setColor(wrench.colorbg[1]/3,wrench.colorbg[2]/3,wrench.colorbg[3]/3)
        love.graphics.rectangle("fill", wrench.x-2, wrench.y-2, wrench.width+4, wrench.height+4)
        
        if ActiveWindow == wrench then 
            love.graphics.setColor(wrench.colorbg[1]/1.1, wrench.colorbg[2]/1.1, wrench.colorbg[3]/1.1)
        elseif touchingwindows then
            love.graphics.setColor(wrench.colorbg[1]/1.3, wrench.colorbg[2]/1.3, wrench.colorbg[3]/1.3)
        else
            love.graphics.setColor(wrench.colorbg[1],wrench.colorbg[2],wrench.colorbg[3])
        end
        love.graphics.rectangle("fill", wrench.x, wrench.y, wrench.width, wrench.height)
        
        love.graphics.setColor(wrench.colorbg[1]/2,wrench.colorbg[2]/2,wrench.colorbg[3]/2)
        love.graphics.rectangle("fill", wrench.x, wrench.y, wrench.width, 10)
        
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", wrench.x, wrench.y, 10, 10)
        
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle("fill", wrench.x + wrench.width - 10, wrench.y + wrench.height - 10, 10, 10)
        
        love.graphics.setColor(1,0,0.5)
        love.graphics.rectangle("fill", wrench.x + wrench.width - 10, wrench.y, 10, 10)
        
        love.graphics.setColor(1/1.5,0,0.5/1.5)
        love.graphics.polygon("fill", wrench.x+wrench.width-10,wrench.y, wrench.x+wrench.width-10,wrench.y+10, wrench.x+wrench.width,wrench.y)
        
        if wrench == ActiveWindow then 
            if not averagecolor(wrench.colorbg) then love.graphics.setColor(1,1,1) else love.graphics.setColor(0,0,0) end else love.graphics.setColor(wrench.colorbg[1]+0.4,wrench.colorbg[2]+0.4,wrench.colorbg[3]+0.4) end 
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
        Windows.create({mouse.x-100,mouse.y-50}, {}, {movable = true, resizable = true, title = "im.." .. #WindowsRender + 1 .. "!"})
    end
end
