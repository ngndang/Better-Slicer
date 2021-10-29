--[[
    Manager for deleting Slices
    Author: NgnDang
--]]

local sprite = app.activeSprite
local initial_bounds = sprite.bounds
local selection = sprite.selection

-- Auxiliar functions.
-- Source for Auxialiar Functions: https://gist.github.com/PKGaspi/72ef17de468d87c790c8e76f22abc9b4
function getPath(str,sep)
     sep=sep or'/'
     return str:match("(.*"..sep..")")
end
 
function getFileName(str,sep)
    str = str:match("^.+"..sep.."(.+)$")
    return str:match("(.+)%..+")
end

-- Identify operative system.
local separator
if (string.sub(sprite.filename, 1, 1) == "/") then
   separator = "/"
else
   separator = "\\"
end
------------------

local initial_path = getPath(sprite.filename, separator)

local export_dialog = Dialog("Export slices") 
export_dialog
    :file{ id="dir", label="Output directory:", filename = sprite.filename, open = false}
    :combobox{  
        id = "extension",
        label = "File type",
        option = ".png",
        options = { ".png", ".jpg", ".ico", ".svg"}}
    :combobox{  
        id = "scale",
        label = "Scale (%)",
        option = 100,
        options = { 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 25, 50}}
    :check{ id="subfolder", label="Create sub folder", selected = true}
    :check{ id="prefix", label="Add sprite name as prefix", selected = false}
    :separator{}
    :button{ id="ok", text="Ok", onclick = function() 
        exportSlices()
        app.refresh() 
        export_dialog:close()
    end }
    :button{ id="cancel", text="Cancel", onclick = function() 
        export_dialog:close()
    end }

local spriteName = getFileName(sprite.filename, separator)
local path
if export_dialog.data.subfolder then
    path = getPath(export_dialog.data.dir, separator) .. spriteName .. "_Slices" .. separator
else 
    path = getPath(export_dialog.data.dir, separator)
end


local manager_dialog = Dialog("Slice Manager")
manager_dialog
    :separator{ text = "Selection"}
    :button{ text = "&Remove Slices in Selection", onclick= function() 
        removeSelectedSlices()
        app.refresh()
    end }
    :button{ text = "&Export Slices", onclick= function() 
        export_dialog:show()
    end }

    :separator{ text = "Remove All Slices"}
    :button{ text = "&Remove All Current Slices", onclick= function()
        clearSlice()
        app.refresh()
    end }

    :separator{}
    :button{ text = "&Close", onclick= function() 
        manager_dialog:close()
    end }

manager_dialog:show()


function clearSlice() -- Clear all Slices on the canvas
    while #sprite.slices > 0 do 
        for i, slice in ipairs(sprite.slices) do
            sprite:deleteSlice(slice)
        end
    end
end

function removeSelectedSlices() -- Remove selected Slices
    deleted = 0
    for n = 0, 10, 1 do
        for i, slice in ipairs(sprite.slices) do
            
            --Check if this slice is inside the selection
            if  selection.bounds:contains(slice.bounds)
            then
                sprite:deleteSlice(slice)
                deleted = deleted + 1
            end
        end
    end

    if deleted > 1 then app.alert(deleted .. " slices were deleted") else app.alert(deleted .. " slice was deleted") end
end

function exportSlices()
    exported = 0

    --Create a temporary Rectangle to crop the sprite into the size of the slices
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
            -- Crop the sprite to this slice.
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




