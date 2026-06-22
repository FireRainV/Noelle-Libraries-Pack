local Game, super = HookSystem.hookScript(Game)

-- Set the party equipment table for weapons from the "equipment" config
function Game:load(data, index, fade)
    local new_file = data == nil

    if new_file then
        for id, equipped in pairs(Kristal.getModOption("equipment") or {}) do
            if type(equipped["weapon"]) == "table" then
                equipped["weapon_table"] = equipped["weapon"]
                equipped["weapon"] = equipped["weapon"][1]
            end
        end
    end

    super.load(self, data, index, fade)
end

return Game