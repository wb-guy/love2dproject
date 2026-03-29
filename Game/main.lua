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
-- inital vars
mouse = {}
-- window class
Windows = {}
WindowsRender = {}
Windows.__index = Windows

function Windows.create(coords, transform, flags) 
    local self = setmetatable({}, Windows)
    self.x = coords[1] or 5
    self.y = coords[2] or 5
    self.width = transform[1] or 25
    self.height = transform[2] or 25
    self.held = false
    self.resize = false
    self.movable = flags["movable"] or false
    self.resizable = flags["resizable"] or false
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

function Windows.IsHeld(window)
    if mouse.x > window.x and mouse.x < window.x + window.width and mouse.y > window.y and mouse.y < window.y + window.height then
        if mouse.x > window.x and mouse.x < window.x + 10 and mouse.y > window.y and mouse.y < window.y + 10 then
            love.mouse.setCursor(mouse.cursor.hand)
            if mouse.down == true then
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
            if mouse.down == true then
                if window.resize == false then
                window.resize = true
                window.heldx = mouse.x
                window.heldy = mouse.y
                window.iw = window.width
                window.ih = window.height
                print("a")
                end
            end
        end
    end
end

function Windows.Holding(window)
    if window.held == true and window.movable == true then
        love.mouse.setCursor(mouse.cursor.sizeall)
        window.x = window.ix - (window.heldx - mouse.x)
        window.y = window.iy - (window.heldy - mouse.y)
        if mouse.down == false then window.held = false end
    end
end

function Windows.Resizing(window)
    if window.resize == true and window.resizable == true then
        love.mouse.setCursor(mouse.cursor.sizeall)
        window.width = clamp(window.iw - (window.heldx - mouse.x), 100, 1/0)
        window.height = clamp(window.ih - (window.heldy - mouse.y), 50, 1/0)
        if mouse.down == false then window.resize = false end
    end
end

defaultwindow = Windows.create({100,100}, {200,150}, {movable = true, resizable = true})
--------------------------------------------------------------------------------------------------
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    defaultfont = love.graphics.newFont("med.ttf", 15)
    love.graphics.setFont(defaultfont)

    love.graphics.setBackgroundColor(14/100, 15/255, 33/255)

    mouse.cursor = {}

    mouse.cursor.arrow = love.mouse.getSystemCursor("arrow")
    mouse.cursor.hand = love.mouse.getSystemCursor("hand")
    mouse.cursor.sizeall = love.mouse.getSystemCursor("sizeall")
end


function love.update(dt)
    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.down = love.mouse.isDown(1)
    love.mouse.setCursor(mouse.cursor.arrow) 

    for _, wrench in ipairs(WindowsRender) do
    Windows.IsHeld(wrench)
    Windows.Holding(wrench)
    Windows.Resizing(wrench)
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.print("Mouse Coordinates: "..mouse.x..", "..mouse.y.." | ".. tostring(mouse.down) )
    
    for _, wrench in ipairs(WindowsRender) do
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", wrench.x, wrench.y, wrench.width, wrench.height)
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.rectangle("fill", wrench.x, wrench.y, 10, 10)
        love.graphics.rectangle("fill", wrench.x + wrench.width - 10, wrench.y + wrench.height - 10, 10, 10)
    end
end
