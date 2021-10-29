--[[
    Auto Slice sprite based on transparency
    Author: NgnDang
--]]

local sprite = app.activeSprite
local selection = sprite.selection

local function getActiveCel(layer, frame)
    -- Loop through cels
    for i,cel in ipairs(layer.cels) do
  
      -- Find the cel in the given frame
      if cel.frame == frame then
        return cel
      end
    end
end

local ogLayer = app.activeLayer
local ogFrame = app.activeFrame
local ogCel = getActiveCel(ogLayer, ogFrame)
local cel = getActiveCel(ogLayer, ogFrame)


local auto_dialog = Dialog("Auto Slicer (Experimental)")
auto_dialog
    :separator{ text = "Auto Slice (Experimental)"}
    :entry{ id = "name", label = "Name", text = "Slice"}
	:color{ id = "color", label = "Color", color = Color{ r = 0, g = 0, b = 250, a = 150 }}
    :button{ text = "Slice", focus = true, onclick = function() 
        if #sprite.cels > 0 then
            app.alert("This script will clear all current slices")
            clearSlices() 
            lineScanSlice()  
        else
            app.alert("Sprite is blank")
        end
    end}
    :separator{}
    :button{ text = "Close", onclick = function() auto_dialog:close() return end}
	:show { wait = false }

app.refresh()
 
function lineScanSlice()
    app.transaction( function()  
        local celW = cel.bounds.width
        local celH = cel.bounds.height

        for Y = 0, celH - 1, 1 do --Rows
            local slice
            local line_length = 0

            for X = 0, celW - 1, 1 do --Cols
                local trueX =  X + cel.bounds.x
                local trueY = Y + cel.bounds.y
                
                local right = cel.image:getPixel(X + 1, Y); local left = cel.image:getPixel(X-1, Y)
                
                local p = cel.image:getPixel(X, Y)

                if pixelHasColor(p) then
                    if not pixelHasColor(left) or X == 0 then --Create a new line slice
                        slice = createSlice(trueX, trueY, 1, 1) 
                        line_length = 0
                    else   --Increment current line slice length (width)
                        line_length = line_length + 1
                    end
                    if slice ~= nil and (not pixelHasColor(right) or X == celW - 1) then  --Expand slice at the end of the line
                        slice.bounds = ExpandRight(slice.bounds, line_length)
                        slice = nil
                    end
                end
            end
            
        end
        mergeSlices(sprite)
    end)
end

function mergeSlices(_sprite) 
    for i, sli1 in ipairs(_sprite.slices) do --Go through all slices pair by pair
        for j, sli2 in ipairs(_sprite.slices) do
            x1 = sli1.bounds.x; y1 = sli1.bounds.y; w1 = sli1.bounds.width; h1 = sli1.bounds.height; 
            x2 = sli2.bounds.x; y2 = sli2.bounds.y; w2 = sli2.bounds.width; h2 = sli2.bounds.height

            -- Check for intersecting or touching (including diagonally touches) slices
            if sli1.bounds ~= sli2.bounds and sli1.bounds:intersects(sli2.bounds) 
            or (math.abs((x1+(w1/2))-(x2+(w2/2))) <= math.abs((w1+w2)/2)
            and math.abs((y1+(h1/2))-(y2+(h2/2))) <= math.abs((h1+h2)/2))
            then 
                sli1.bounds = sli1.bounds:union(sli2.bounds) --Merge touching slices
            end
        end
    end
    cleanDupSlices(app.activeSprite)
end

local function sliceInTable(table, element) --Return true if table contains a slice with same bounds rect
    for i, value in pairs(table) do
      if value.bounds == element.bounds then
        return true
      end
    end
    return false
end
local function nameInTable(table, name) --Return true if table contains a slice with same name
    for i, value in ipairs(table) do
      if value.name == name then
        return true
      end
    end
    return false
end


local keep = {}
function cleanDupSlices(_sprite)
    -- Add one slice of similar ones to a keep array
    for i, sli1 in ipairs(_sprite.slices) do
        local ins = 0
        for j, sli2 in ipairs(_sprite.slices) do
            if not sli1.bounds:intersects(sli2.bounds) then 
                if not sliceInTable(keep, sli2) then
                    keep[#keep + 1] = sli2
                end
            end
        end
    end
    --Delete every slices not in the keep array
    while #app.activeSprite.slices > #keep and #app.activeSprite.slices > 1 do
        for k, slice in ipairs(app.activeSprite.slices) do  
            if not nameInTable(keep, slice.name) then
                app.activeSprite:deleteSlice(slice)
            end
        end
    end
    --Rename slices
    local no = 0
    for k, slice in ipairs(app.activeSprite.slices) do 
        no = no + 1
        slice.name = auto_dialog.data.name .. "_" .. no 
    end
end


function pixelHasColor(pixel) --Check if pixel has alpha ~= 0
    local rgbaAlpha = app.pixelColor.rgbaA(pixel)
    local grayAlpha = app.pixelColor.grayaA(pixel)
  
    return rgbaAlpha ~= 0 or grayAlpha ~= 0
end

local id = 0

function createSlice(x, y, w, h)
    slice = sprite:newSlice(x, y, w, h)
    slice.color = auto_dialog.data.color
    id = id + 1
	slice.name = id
    app.refresh()
    return slice
end 

function clearSlices()
	while #sprite.slices > 0 do 
		for i, slice in ipairs(sprite.slices) do
			sprite:deleteSlice(slice)
		end
	end
end


function ExpandRight(rect, amount)
    return Rectangle(rect.x, rect.y, rect.width + amount, rect.height)
end
local function ExpandLeft(rect, amount)
    return Rectangle(rect.x - amount, rect.y, rect.width + amount, rect.height)
end
local function ExpandUp(rect, amount)
    return Rectangle(rect.x, rect.y - amount, rect.width, rect.height + amount)
end
local function ExpandDown(rect, amount)
    return Rectangle(rect.x, rect.y, rect.width, rect.height + amount)
end