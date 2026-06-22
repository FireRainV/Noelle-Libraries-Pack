local LightEquipItem, super = HookSystem.hookScript(LightEquipItem)

function LightEquipItem:createArmorItems()
    local armors = self:getFlag("dark_armors")
    if armors then
        local armor_items = {}

        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            if armors[tostring(i)] then
                armor_items[i] = Registry.createItem(armors[tostring(i)].id)
                armor_items[i]:load(armors[tostring(i)])
            end
        end

        return armor_items
    else
        local armor_result = super.convertToDark(self)
        if type(armor_result) == "string" then
            armor_result = Registry.createItem(armor_result)
        end
        if armor_result and isClass(armor_result) then
            return { armor_result }
        else
            return {}
        end
    end
end

function LightEquipItem:setArmorItems(armor_items)
    local armors = {}

    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        if armor_items[i] then
            armors[tostring(i)] = armor_items[i]:save()
        end
    end

    self:setFlag("dark_armors", armors)
end

function LightEquipItem:convertToDarkEquip(chara)
    if self.type == "armor" then
        local armors = self:createArmorItems()
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            if armors[i] then
                chara:setArmor(i, armors[i])
            end
        end
        return true
    end
    return self:convertToDark()
end

return LightEquipItem