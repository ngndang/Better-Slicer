--[[----------------------------------------------

	 _       _   _           
	| |_ ___| |_| |_ ___ ___ 
	| . | -_|  _|  _| -_|  _|
	|___|___|_| |_| |___|_| 
   _____ _      _____ _____ /  ______ _____  
  / ____| |    |_   _/ ___ / ||  ____|  __ \ 
 | (___ | |      | || |   /   | |__  | |__) |
  \___ \| |      | || |  /    |  __| |  _  / 
  ____) | |____ _| || | / ___ | |____| | \ \ 
 |_____/|______|_____\ / ____||______|_|  \_\
                      /
  	
	BETTER SLICER 1.0 for Aseprite

	-------------Author-------------------------
    by NgnDang (Ngn Hai Dang)
    Twitter: http://twitter.com/ngndangg
	
	-------------About---------------------------
	A handy script for slicing Aseprite sprites
	Main features:
	+ Creating Slices Automatically (Currently under further development)
	+ Creating a Grid of slices by Grid size
	+ Creating a Grid of slices by Columns and Rows count

	This interface is similar to that of Unity's Sprite Editor
	I hope you enjoy using this script as much as I do. It is really useful for working with big spritesheets
	and just big projects overall.

	If you would want to see more features please consider supporting me through Ko-fi
	https://ko-fi.com/ngndang (Itch takes too many % lol)

--]]

------------------------Preparation-----------------------------------
local mode_auto = "Automatic (Experimental)"
local mode_bySize = "Grid by Cell Size"
local mode_byCount = "Grid by Cell Count"

sprite = app.activeSprite
selection = sprite.selection

if not sprite then app.alert("Error: You must be working on a Sprite to use this Script.") return end

if app.activeImage:isEmpty() then app.alert("Error: Sprite is blank") return end


-------------------------Dialog------------------------------
local main_dialog = Dialog("Slice Sprite")
main_dialog
	:combobox{  
		id = "type",
		label = "Type",
		option = mode_bySize,
		options = {mode_auto, mode_bySize, mode_byCount },
		onchange = function() updateDialog() end
	}

	:entry{ id = "name", label = "Name", text = "Slice"}
	:color{ id = "color", label = "Color", color = Color{ r = 0, g = 0, b = 250, a = 150 }}
	:check{ id = "clear", text = "Clear slices on canvas", selected = true }

	:separator{ id = "size_header", text = "Slice Size"}
	:number{ id = "cell_W", label = "W:", text = "8", decimals = integer }
	:number{ id = "cell_H", label = "H:", text = "8", decimals = integer }

	:number{ id = "no_Col", label = "Col:", text="1", decimals = integer }
	:number{ id = "no_Row", label = "Row:", text="1", decimals = integer }

	:separator{ id = "padding_header", label="Padding", text="Padding" }
	:number{ id = "padding_X", label = "X:", text = "0" }
	:number{ id = "padding_Y", label="Y:", text = "0" }

	:separator{ id = "offset_header", label="Offset", text="Offset" }
	:number{ id = "offset_X", label = "X:", text="0" }
	:number{ id = "offset_Y", label = "Y:", text="0" }

	:separator{}
	:button{ id = "slice", text = "Slice", focus = true, onclick = function() 
		doSlice() 
	end }
	:separator{}
	:button{ text = "Close", onclick= function() 
		main_dialog:close()
		return
	end }


local function showPaddingNOffsetField(_dlg, bool)
	_dlg
		:modify{ id = "padding_X", visible = bool, enabled = bool}
		:modify{ id = "padding_Y", visible = bool, enabled = bool}
		:modify{ id = "offset_X", visible = bool, enabled = bool}
		:modify{ id = "offset_Y", visible = bool, enabled = bool}
end
local function showCellSizeField(_dlg, bool)
	_dlg
		:modify{ id = "cell_W", visible = bool, enabled = bool}
		:modify{ id = "cell_H", visible = bool, enabled = bool}
end
local function showCellCountField(_dlg, bool)
	_dlg
		:modify{ id = "no_Col", visible = bool, enabled = bool}
		:modify{ id = "no_Row", visible = bool, enabled = bool}
end
local function showAllLabel(_dlg, bool)
	_dlg
		:modify{ id = "size_header", visible = bool, enabled = bool}
		:modify{ id = "padding_header", visible = bool, enabled = bool}
		:modify{ id = "offset_header", visible = bool, enabled = bool}
		:modify{ id = "clear", selected = true, enabled = bool}
end


function updateDialog() --Hide/Unhide elements based on mode
	showAllLabel(main_dialog, false)
	showCellSizeField(main_dialog, false)
	showCellCountField(main_dialog, false)
	showPaddingNOffsetField(main_dialog, false)
	if main_dialog.data.type == mode_auto then
		showAllLabel(main_dialog, false)
		showCellCountField(main_dialog, false)
		showCellSizeField(main_dialog, false)
		showPaddingNOffsetField(main_dialog, false)
	end
	if main_dialog.data.type == mode_bySize then
		main_dialog
			:modify{ id = "size_header", text = "Slice Size"}
		showAllLabel(main_dialog, true)
		showCellSizeField(main_dialog, true)
		showPaddingNOffsetField(main_dialog, true)
	end
	if main_dialog.data.type == mode_byCount then
		main_dialog
			:modify{ id = "size_header", text = "Slice Count"}
		showAllLabel(main_dialog, true)
		showCellCountField(main_dialog, true)
		showPaddingNOffsetField(main_dialog, true)
	end
	
end
updateDialog()

------------------------by Size, by Number mode Functions------------------------------

function doSlice() --Start
	if main_dialog.data.type == mode_bySize then
		sliceBySize()
	end
	if main_dialog.data.type == mode_byCount then
		sliceByCount()
	end
	if main_dialog.data.type == mode_auto then
		local alert_dialog = Dialog("Alert")
		alert_dialog
			:label{text = "Experimental Script!"}:newrow{}
			:label{text = "This script will clear all current slices"}:newrow{}
			:label{text = "Do you want to continue (._.) ?"}:newrow{}
			:button{ text = "Yes", focus = true, onclick= function() 
				alert_dialog:close()
				doAutoSlice()
			end }
			:button{ text = "Cancel", onclick= function() 
				alert_dialog:close()
				return
			end }
			:show{wait = true}
	end
	app.refresh()
end

local bounds_W
local bounds_H

function GetBounds()
	selection = sprite.selection
	if selection.isEmpty then return app.alert("Please select an area to create slices") end
	bounds_W = selection.bounds.width
	bounds_H = selection.bounds.height
end

function sliceBySize()
	if main_dialog.data.clear then clearSlice() end
	data = main_dialog.data

	GetBounds()

	cell_W = data.cell_W
	cell_H = data.cell_H
	no_Col = bounds_W // cell_W
	no_Row = bounds_H // cell_H

	createSliceGrid(data, selection, cell_W, cell_H, no_Col, no_Row)
end

function sliceByCount()
	if main_dialog.data.clear then clearSlice() end
	data = main_dialog.data

	GetBounds()

	cell_W = math.floor( bounds_W / data.no_Col )
	cell_H = math.floor( bounds_H / data.no_Row )

	createSliceGrid(data, selection, cell_W, cell_H, data.no_Col, data.no_Row)
end

--Create a Grid of slices based on the cells' size and the number of Collumns, Rows
function createSliceGrid(data, selection, cellW, cellH, noCol, noRow)
	i = 0
	for col = 0, noCol - 1 do
		for row = 0, noRow - 1 do

			X = col * cellW + col * data.padding_X + data.offset_X + selection.origin.x
			Y = row * cellH + row * data.padding_Y + data.offset_Y + selection.origin.y
		
			slice = sprite:newSlice(Rectangle(X, Y, cellW, cellH))
		
			slice.color =  data.color
			slice.name = data.name .. "_" .. i

			i = i + 1
		end
	end
end

------------------------Auto mode Variables------------------------------

ogLayer = app.activeLayer
ogFrame = app.activeFrame
function getActiveCel(layer, frame)
    -- Loop through cels
    for i,cel in ipairs(layer.cels) do
  
      -- Find the cel in the given frame
      if cel.frame == frame then
        return cel
      end
    end
end
cel = getActiveCel(ogLayer, ogFrame)

celW = cel.bounds.width
celH = cel.bounds.height
celX = cel.bounds.x
celY = cel.bounds.y

------------------------Auto mode Helper Functions------------------------------

function isNotTransparent(pixel) --Check if pixel has alpha ~= 0
    local rgbaAlpha = app.pixelColor.rgbaA(pixel)
    local grayAlpha = app.pixelColor.grayaA(pixel)
  
    return rgbaAlpha ~= 0 or grayAlpha ~= 0
end

function inAnySlice(x, y) --Check if pixel is inside any slices
    for i, sli in ipairs(sprite.slices) do
        if sli.bounds:contains(Rectangle(x, y, 1, 1)) or sli.bounds:intersects(Rectangle(x, y, 1, 1)) then 
            return true
        end
    end
    return false
end 

local id = 0
local function createSlice(x, y, w, h)
    local slice = sprite:newSlice(x, y, w, h)
    slice.color = main_dialog.data.color
    id = id + 1
	slice.name = main_dialog.data.name .. "_" .. id
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

--------------------------Flood Fill-------------------------------
local img = cel.image:clone()

local newColor = app.pixelColor.rgba(0, 0, 0, 255)

local Xmax = 0
local Xmin = 0
local Ymax = 0
local Ymin = 0

local function isColorEqual(a, b)
    local pc = app.pixelColor
    return pc.rgbaR(a) == pc.rgbaR(b) and
            pc.rgbaG(a) == pc.rgbaG(b) and
            pc.rgbaB(a) == pc.rgbaB(b) and
            pc.rgbaA(a) == pc.rgbaA(b)
end
local function isColorEqualAt(x, y, color)
    local p = img:getPixel(x, y)
    return isColorEqual(p, color)
end
local function isTransparentAt(_x, _y) 
    local p = img:getPixel(_x, _y)
    return not isNotTransparent(p)
end

function floodFill(x, y, targetColor) 
    if isTransparentAt(x, y) or isColorEqualAt(x, y, newColor) or x < 0 or x >= celW or y < 0 or y >= celH  then return end

	--Get the highest - lowest value of x, y when flood fill to determind the boudaries
    Xmax = math.max(Xmax, x)
    Xmin = math.min(Xmin, x)
    Ymax = math.max(Ymax, y)
    Ymin = math.min(Ymin, y)

    img:drawPixel(x, y, newColor)
	--8 ways DFS flood fill
    floodFill(x+1, y, targetColor)
    floodFill(x-1, y, targetColor)
    floodFill(x, y+1, targetColor)
    floodFill(x, y-1, targetColor)
    floodFill(x+1, y+1, targetColor)
    floodFill(x+1, y-1, targetColor)
    floodFill(x-1, y+1, targetColor)
    floodFill(x-1, y-1, targetColor)
end

function doAutoSlice()
	clearSlices() 
	img = cel.image:clone()
    app.transaction( function()  
        for Y = 0, celH - 1, 1 do --Rows
            local newSlice = nil

            for X = 0, celW - 1, 1 do --Cols
                local trueX =  X + celX
                local trueY = Y + celY
                
                local p = cel.image:getPixel(X, Y)

                if isNotTransparent(p) and not inAnySlice(trueX, trueY) then
                    if not isNotTransparent(left) or X == 0 then 		
                        newSlice = createSlice(trueX, trueY, 1, 1)		--Create a new slice
                        Xmax = 0; Xmin = X; Ymax = 0; Ymin = Y 			--Reset XY info
                        floodFill(X, Y, p) 								--To get XY info (boundaries info)
                        newSlice.bounds = Rectangle(Xmin + celX, Ymin + celY, Xmax - Xmin + 1, Ymax - Ymin + 1) --Apply XY info (boundaries info) to slice
                        --print("Xmax: " .. Xmax + celX .. ", Xmin: " .. Xmin + celX .. ", Ymax: " .. Ymax + celY .. ", Ymin: " .. Ymin + celY)
                    end
                end
            end
        end
    end)
end
---------------------------------------------------------

main_dialog:show{wait=false}

