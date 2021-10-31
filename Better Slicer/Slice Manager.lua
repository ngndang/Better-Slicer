--[[
    Manager for deleting Slices
    Author: NgnDang
--]]
------------------Common Variables-------------------
local selectionMissing_msg = "Selection is missing or empty. Please select slices with Rectangular Marquee tool "

local sprite = app.activeSprite
local initial_bounds = sprite.bounds
local selection = sprite.selection

------------------Start Functions-------------------
function getPath(string, separator)
    separator = separator or '/'
    return string:match("(.*".. separator ..")")
end
 
function getFileName(string, separator)
    string = string:match("^.+"..separator.."(.+)$")
    return string:match("(.+)%..+")
end

local separator
if (string.sub(sprite.filename, 1, 1) == "/") then
   separator = "/" --Linux
else
   separator = "\\" --Windows
end

---------------------Dialogs-----------------------

local export_dialog = Dialog("Export slices") 
export_dialog
    :file{ id="dir", label="Output directory:", filename = sprite.filename, open = false}
    :combobox{  
        id = "extension",
        label = "File type",
        option = ".png",
        options = { ".png", ".jpg", ".svg"}}
    :combobox{  
        id = "scale",
        label = "Scale (%)",
        option = 100,
        options = { 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 25, 50}}
    :check{ id="subfolder", text="Create sub folder", selected = true}
    :newrow{}
    :check{ id="prefix", text="Add sprite name as prefix", selected = false}
    :separator{}
    :button{ id="ok", text="Ok", onclick = function() 
        exportSlices()
        app.refresh() 
        export_dialog:close()
    end }
    :button{ id="cancel", text="Cancel", onclick = function() 
        export_dialog:close()
    end }

local manager_dialog = Dialog("Slice Manager")
manager_dialog
    :separator{ text = "Modify Selected Slices"} --Modify specs of slices inside current selection

    :entry{ id = "name", label = "Name", text = "Slice"}
	:color{ id = "color", label = "Color", color = Color{ r = 0, g = 0, b = 250, a = 150 }}

    :button{ text = "Rename", onclick= function() 
        Check()
        Rename()
        app.refresh()
    end }
    :button{ text = "Renumber", onclick= function() 
        Check()
        Renumber()
        app.refresh()
    end }
    :button{ text = "Recolor", onclick= function() 
        Check()
        Recolor()
        app.refresh()
    end }
    :newrow{}
    :button{ label = "Do all: ", text = "Reapply", onclick= function() 
        Check()
        ReapplyAll()
        app.refresh()
    end }
    :newrow{}

    :separator{ text = "Remove Slices"} --Remove slices 
    :button{ text = "Remove Slices", onclick= function() 
        removeSelectedSlices()
        app.refresh()
    end }
    :newrow{}
    :button{ text = "Remove All Slices", onclick= function()
        clearSlice()
        app.refresh()
    end }

    :separator{ text = "Export"}
    :button{ text = "Export Selected Slices", onclick= function() 
        export_dialog:show{wait = false}
    end }

    :separator{}
    :button{ text = "Close", onclick= function() 
        manager_dialog:close()
    end }

manager_dialog:show{wait = false}

--------------------Modify Functions-----------------------
function Check()
    if selection.isEmpty then return app.alert(selectionMissing_msg) end
end
local function finishedAlert(number, action)
    if number > 1 then app.alert(number .. " slices were ".. action) else app.alert(number .. " slice was ".. action) end
end

function Rename()
    app.transaction( function()
        local renamed = 0
        for i, slice in ipairs(sprite.slices) do
            if  selection.bounds:contains(slice.bounds)                   --Check if slice is inside the selection
            then
                local number = slice.name:match("(%d+)$")                 --Find number digits at the far back of the slice's name
                slice.name = manager_dialog.data.name .. "_" .. number    --Set new name
                renamed = renamed + 1
            end
        end
        finishedAlert(renamed, "renamed")
    end)
end 
function Renumber()
    app.transaction( function()
        local no = 0
        for i, slice in ipairs(sprite.slices) do
            if  selection.bounds:contains(slice.bounds)             --Check if slice is inside the selection
            then
                local number = slice.name:match("(%d+)$")           --Find number digits at the far back of the slice's name
                slice.name = string.gsub(slice.name , number, no)   --Replace current number with new one
                no = no + 1
            end
        end
        finishedAlert(no, "renumbered")
    end)
end 
function Recolor()
    app.transaction( function()
        local colored = 0
        for i, slice in ipairs(sprite.slices) do
            if  selection.bounds:contains(slice.bounds) --Check if slice is inside the selection
            then
                slice.color = manager_dialog.data.color
                colored = colored + 1
            end
        end
        finishedAlert(colored, "recolored")
    end)
end 
function ReapplyAll()
    app.transaction( function()
        local no = 0
        for i, slice in ipairs(sprite.slices) do
            if  selection.bounds:contains(slice.bounds) --Check if slice is inside the selection
            then
                slice.color = manager_dialog.data.color
                --slice.name = main_dialog.data.name .. "_" .. no
                no = no + 1
            end
        end
        finishedAlert(no, "changed")
    end)
end
--------------------Remove Functions-----------------------
function clearSlice() -- Clear all Slices on the canvas
    app.transaction( function()
        while #sprite.slices > 0 do 
            for i, slice in ipairs(sprite.slices) do
                sprite:deleteSlice(slice)
            end
        end
    end)
end

function removeSelectedSlices() -- Remove selected Slices
    if selection.isEmpty then return app.alert(selectionMissing_msg) end
    app.transaction( function()
        deleted = 0
        for n = 0, 10, 1 do
            for i, slice in ipairs(sprite.slices) do
                --Check if this slice is inside the selection
                if selection.bounds:contains(slice.bounds)
                then
                    sprite:deleteSlice(slice)
                    deleted = deleted + 1
                end
            end
        end

        if deleted > 1 then app.alert(deleted .. " slices were deleted") else app.alert(deleted .. " slice was deleted") end
    end)
end
--------------------Export Functions-----------------------

local initial_path = getPath(sprite.filename, separator)
local spriteName = getFileName(sprite.filename, separator)
local path
if export_dialog.data.subfolder then
    path = getPath(export_dialog.data.dir, separator) .. spriteName .. "_Slices" .. separator
else 
    path = getPath(export_dialog.data.dir, separator)
end

function exportSlices()
    exported = 0
    local temp_bounds = initial_bounds
    local ratio = export_dialog.data.scale * 0.01  

    for i, slice in ipairs(sprite.slices) do
        sli = slice.bounds
        sel = selection.bounds

        --Check if this slice is inside the selection
        if  sli.x + 1 > sel.x and sli.x + sli.width - 1 < sel.x + sel.width and
            sli.y + 1 > sel.y and sli.y + sli.height - 1 < sel.y + sel.height
        then
            temp_bounds.x = temp_bounds.x - slice.bounds.x
            temp_bounds.y = temp_bounds.y - slice.bounds.y
            
            -- Duplicate this sprite to safely resize and not affect the source sprite
            newSprite = Sprite(sprite)
            -- Crop the sprite to the size of this slice.
            newSprite:crop(slice.bounds)
            -- Resize 
            newSprite:resize(newSprite.bounds.width * ratio, newSprite.bounds.height * ratio)

            -- Save the cropped sprite
            if export_dialog.data.prefix then
                newSprite:saveCopyAs(path .. spriteName .. "_" .. slice.name .. export_dialog.data.extension)
            else 
                newSprite:saveCopyAs(path .. slice.name .. export_dialog.data.extension)
            end  
            -- Close the temporary sprite after exporting
            newSprite:close()
            exported = exported + 1
        end
    end
    
    if exported > 1 then app.alert(exported .. " slices were exported") else app.alert(exported .. " slice was exported") end
end 




