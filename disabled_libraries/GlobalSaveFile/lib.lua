local Lib = {}

-- Shortcut variable to the library
GlobalSaveFile = Lib

local read = love.filesystem.read
local write = love.filesystem.write

function Lib:cleanup()
    GlobalSaveFile = nil
end

-- Initialize the global save file
function Lib:initGlobalSave()
    local data = {}

    data["global"] = {}

    data["files"] = {}
    for i = 1, 3 do
        data["files"][i] = {}
    end

    return JSON.encode(data)
end

-- Get the global save file
-- If 'create' is true, it will create one if it doesn't exist
function Lib:get(create)
    if create and not love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        love.filesystem.write("saves/" .. Mod.info.id .. "/global.json", self:initGlobalSave())
    end
    return love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json")
end

-- Write data to the global save file to the 'key' value
function Lib:write(key, data, save_slot)
    save_slot = save_slot == nil and Game.save_id or save_slot
    assert(type(key) == "string", "key isn't a string value")
    assert(type(save_slot) == "number" or save_slot == "global", "save_slot value is invalid")

    if self:get(true) then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        if save_slot == "global" then
            global_data.global[key] = data
        else
            global_data.files[save_slot][key] = data
        end
        write("saves/" .. Mod.info.id .. "/global.json", JSON.encode(global_data))
    end
end

-- Read data from the global save file from the 'key' value
function Lib:read(key, save_slot)
    save_slot = save_slot == nil and Game.save_id or save_slot
    assert(type(key) == "string", "key isn't a string value")
    assert(type(save_slot) == "number" or save_slot == "global", "save_slot value is invalid")

    if self:get(false) then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        if save_slot == "global" then
            return global_data.global[key]
        else
            return global_data.files[save_slot][key]
        end
    else
        return nil
    end
end

-- Clear the global save file data from the 'save_slot'
-- if 'save_slot' is undefined, delete the global save data file
function Lib:clear(save_slot)
    assert(type(save_slot) == "number" or save_slot == "global" or save_slot == nil, "save_slot value is invalid")

    if self:get(false) then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))

        if save_slot == nil then
            love.filesystem.remove("saves/" .. Mod.info.id .. "/global.json")
        else
            if save_slot == "global" then
                global_data.global = {}
            else
                global_data.files[save_slot] = {}
            end
            write("saves/" .. Mod.info.id .. "/global.json", JSON.encode(global_data))
        end
        return true
    end
    return false
end

return Lib