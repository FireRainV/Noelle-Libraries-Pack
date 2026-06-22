local Lib = {}

-- Get the party equipment for extended weapons and armors from the "equipment" config
function Lib:load(new_file)
    if new_file then
        for id, equipped in pairs(Kristal.getModOption("equipment") or {}) do
            local weapons = equipped["weapon_table"] or {}
            for i = 2, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
                if weapons[i] then
                    if Game.light and i >= 2 then
                        local main_weapon = Game.party_data[id]:getweapon(1)
                        if not main_weapon:includes(LightEquipItem) then
                            error("Cannot set another weapon, 1st weapon must be a LightEquipItem")
                        end
                        Game.party_data[id]:setWeapon(i, weapons[i])
                    else
                        Game.party_data[id]:setWeapon(i, weapons[i] ~= "" and weapons[i] or nil)
                    end
                end
            end
            if equipped["weapon_table"] then
                equipped["weapon"] = equipped["weapon_table"]
                equipped["weapon_table"] = nil
            end
            local armors = equipped["armor"] or {}
            for i = 3, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
                if armors[i] then
                    if Game.light and i >= 2 then
                        local main_armor = Game.party_data[id]:getArmor(1)
                        if not main_armor:includes(LightEquipItem) then
                            error("Cannot set another armor, 1st armor must be a LightEquipItem")
                        end
                        Game.party_data[id]:setArmor(i, armors[i])
                    else
                        Game.party_data[id]:setArmor(i, armors[i] ~= "" and armors[i] or nil)
                    end
                end
            end
        end
    end
end

return Lib