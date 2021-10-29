--[[
  	A handy Slicer similar to that of Unity's Sprite Editor
Author: NgnDang
--]]

local mode_auto = "Automatic"
local mode_bySize = "Grid by Cell Size"
local mode_byCount = "Grid by Cell Count"

local sprite = app.activeSprite

if not sprite then
  return app.alert("Error: You must be working on a Sprite to use this Script.")
end

local main_dialog = Dialog("Slice Sprite")
main_dialog
	:combobox{  
		id = "type",
		label = "Type",
		option = mode_bySize,
		options = { mode_bySize, mode_byCount },
		onchange = function() updateDialog() end
	}

	:entry{ id = "name", label = "Name", text = "Slice"}
	:color{ id = "color", label = "Color", color = Color{ r = 0, g = 0, b = 250, a = 150 }}
	:check{ id = "clear", text = "Clear slices on canvas", selected = true }

	:separator{ id = "header", text = "Slice Size" }

	:number{ id = "cell_W", label = "W:", text = "8", decimals = integer }
	:number{ id = "cell_H", label = "H:", text = "8", decimals = integer }

	:number{ id = "no_Col", label = "Col:", text="1", decimals = integer }
	:number{ id = "no_Row", label = "Row:", text="1", decimals = integer }

	:separator{ label="Padding", text="Padding" }
	:number{ id = "padding_X", label = "X:", text = "0", decimals = integer }
	:number{ id = "padding_Y", label="Y:", text = "0", decimals = integer }

	:separator{ label="Offset", text="Offset" }
	:number{ id = "offset_X", label = "X:", text="0", decimals = integer }
	:number{ id = "offset_Y", label = "Y:", text="0", decimals = integer }

	:button{ id = "slice", text = "&Slice", focus = true, onclick = function() doSlice() end }

	:separator{}
	:button{ text = "&Close", onclick= function() 
		main_dialog:close()
		return
	end }

--Hide/Unhide elements based on mode
function updateDialog()
	if main_dialog.data.type == mode_bySize then
		main_dialog:modify{ id = "header", text = "Slice Size"}
		main_dialog:modify{ id = "cell_W", visible = true, enabled = true}
		main_dialog:modify{ id = "cell_H", visible = true, enabled = true}
		main_dialog:modify{ id = "no_Col", visible = false, enabled = false}
		main_dialog:modify{ id = "no_Row", visible = false, enabled = false}
	end
	if main_dialog.data.type == mode_byCount then
		main_dialog:modify{ id = "header", text = "Slice Count"}
		main_dialog:modify{ id = "cell_W", visible = false, enabled = false}
		main_dialog:modify{ id = "cell_H", visible = false, enabled = false}
		main_dialog:modify{ id = "no_Col", visible = true, enabled = true}
		main_dialog:modify{ id = "no_Row", visible = true, enabled = true}
	end
end
updateDialog()

--Start creating slices and refreshes when done
function doSlice()
	if main_dialog.data.type == mode_bySize then
		sliceBySize()
	end
	if main_dialog.data.type == mode_byCount then
		sliceByCount()
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
	if main_dialog.data.clear then
		clearSlice()
	end

	data = main_dialog.data

	cell_W = data.cell_W
	cell_H = data.cell_H

	no_Col = bounds_W // cell_W
	no_Row = bounds_H // cell_H

	newSliceGrid(data, selection, cell_W, cell_H, no_Col, no_Row)

end

function sliceByCount()
	if main_dialog.data.clear then
		clearSlice()
	end
	data = main_dialog.data

	selection = sprite.selection
	if selection.isEmpty then return app.alert("Please select an area to create slices") end
	bounds_W = selection.bounds.width
	bounds_H = selection.bounds.height

	cell_W = math.floor( bounds_W / data.no_Col )
	cell_H = math.floor( bounds_H / data.no_Row )

	newSliceGrid(data, selection, cell_W, cell_H, data.no_Col, data.no_Row)
end

--Create a Grid of slices based on the cells' size and the number of Collumns, Rows
function newSliceGrid(data, selection, cellW, cellH, noCol, noRow)
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


function clearSlice()
	while #sprite.slices > 0 do 
		for i, slice in ipairs(sprite.slices) do
			sprite:deleteSlice(slice)
		end
	end
end

main_dialog:show{}

