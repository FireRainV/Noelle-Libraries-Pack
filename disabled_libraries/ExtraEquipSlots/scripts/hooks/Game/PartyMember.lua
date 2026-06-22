local PartyMember, super = HookSystem.hookScript(PartyMember)

function PartyMember:init()
    super.init(self)

    self.equipped = {
        weapon = {},
        armor = {}
    }

    -- Set the maximum amount of equipment slot this party member can have
    -- Cannot be above the amount of max global slots of the equipment
    self.max_equip_slots = {
        weapons = nil,
        armors = nil
    }

    if Mod.libs["magical-glass"] then
        if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
            Game.stage.timer:after(1 / 30, function()
                if not Game:isLight() and Mod.libs["magical-glass"].initialize_armor_conversion then
                    for i = 3, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
                        if self.equipped.armor[i] and self.equipped.armor[i]:convertToLightEquip(self) == self.lw_armor_default then
                            self:setFlag("converted_light_armor", "light/bandage")
                            break
                        end
                    end
                end
            end)
        end
    end
end

-- Getter to the maximum amount of equipment slot this party member can have
-- Cannot be above the amount of max global slots of the equipment
function PartyMember:getMaxEquipSlots(type)
    return self.max_equip_slots[type]
end

-- 'self.weapon_icon' can be a table to change the icon slot of each weapon slot for that party member
function PartyMember:getWeaponIcon(i) return type(self.weapon_icon) == "table" and self.weapon_icon[math.min(i or 1, #self.weapon_icon)] or self.weapon_icon end

function PartyMember:getEquipment()
    local result = {}
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        if self.equipped.weapon[i] then
            table.insert(result, self.equipped.weapon[i])
        end
    end
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        if self.equipped.armor[i] then
            table.insert(result, self.equipped.armor[i])
        end
    end
    return result
end

-- If 'i' is unset, it will use the first weapon slot to not break existing calls
function PartyMember:getWeapon(i)
    local battle_weapon = i == nil and Game.battle and Game.battle:getPartyBattler(self.id) and Game.battle:getPartyBattler(self.id).current_battle_weapon or nil
    if battle_weapon then
        return battle_weapon
    end
    return self.equipped.weapon[(i or 1)]
end

-- Allows you to set a weapon to a certain slot, similar to armors
function PartyMember:setWeapon(i, item)
    if type(i) ~= "number" then
        item = i
        i = 1
    end
    if type(item) == "string" then
        item = Registry.createItem(item)
    end
    self.equipped.weapon[i] = item
end

function PartyMember:checkWeapon(id)
    local result, count = false, 0
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        if self:getWeapon(i) and self:getWeapon(i).id == id then
            result = true
            count = count + 1
        end
    end
    return result, count
end

function PartyMember:checkArmor(id)
    local result, count = false, 0
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        if self:getArmor(i) and self:getArmor(i).id == id then
            result = true
            count = count + 1
        end
    end
    return result, count
end

if Mod.libs["magical-glass"] then -- Support for MGR equipment conversion system
    function PartyMember:convertToLight()
        local last_weapons = {}
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
            last_weapons[i] = self:getWeapon(i) and self:getWeapon(i).id or false
        end
        local last_armors = {}
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            last_armors[i] = self:getArmor(i) and self:getArmor(i).id or false
        end

        self.equipped = { weapon = {}, armor = {} }

        if self:getFlag("light_weapon") then
            self.equipped.weapon[1] = Registry.createItem(self:getFlag("light_weapon"))
        end
        if self:getFlag("light_armor") then
            self.equipped.armor[1] = Registry.createItem(self:getFlag("light_armor"))
        end

        if self:getFlag("light_weapon") == nil then
            self.equipped.weapon[1] = self.lw_weapon_default and Registry.createItem(self.lw_weapon_default) or nil
        end
        if self:getFlag("light_armor") == nil then
            self.equipped.armor[1] = self.lw_armor_default and Registry.createItem(self.lw_armor_default) or nil
        end

        if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
            for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
                if last_weapons[i] then
                    local result = Registry.createItem(last_weapons[i]):convertToLightEquip(self)
                    if result then
                        if type(result) == "string" then
                            result = Registry.createItem(result)
                        end
                        if isClass(result) and self:canEquip(result, "weapon", i) and self.equipped.weapon[i] and self.equipped.weapon[i].dark_item and self.equipped.weapon[i].equip_can_convert ~= false then
                            self.equipped.weapon[i] = result
                        end
                    end
                end
            end
            local converted = false
            for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
                if last_armors[i] then
                    local result = Registry.createItem(last_armors[i]):convertToLightEquip(self)
                    if result then
                        if type(result) == "string" then
                            result = Registry.createItem(result)
                        end
                        if isClass(result) and self:canEquip(result, "armor", 1) and (self.equipped.armor[1] and (self.equipped.armor[1].equip_can_convert or self.equipped.armor[1].id == result.id) or not self.equipped.armor[1]) then
                            if self:getFlag("converted_light_armor") == nil then
                                if self.equipped.armor[1] and self.equipped.armor[1].id == result.id then
                                    self:setFlag("converted_light_armor", "light/bandage")
                                else
                                    self:setFlag("converted_light_armor", self.equipped.armor[1] and self.equipped.armor[1].id or "light/bandage")
                                end
                            end
                            converted = true
                            self.equipped.armor[1] = result
                            break
                        end
                    end
                end
            end
            if not converted and self:getFlag("converted_light_armor") ~= nil then
                self.equipped.armor[1] = self:getFlag("converted_light_armor") and Registry.createItem(self:getFlag("converted_light_armor")) or nil
                self:setFlag("converted_light_armor", nil)
            end
        end

        self:setFlag("dark_weapons", last_weapons)
        self:setFlag("dark_armors", last_armors)

        if Kristal.getLibConfig("magical-glass", "health_conversion") then
            if self.last_converted_health ~= self.health then
                self.lw_health = math.ceil((self.health / self:getStat("health", 1, false)) * self:getStat("health", 1, true))
                if self.lw_health == self:getStat("health", 1, true) and self.health < self:getStat("health", 1, false) then
                    self.lw_health = math.max(self.lw_health - 1, 1)
                end
                self.last_converted_health = self.lw_health
            end
        elseif Kristal.getLibConfig("magical-glass", "health_conversion") == nil then
            if Game:getConfig("healthConversion") then
                self.lw_health = math.ceil((self.health / self:getStat("health", 1, false)) * self:getStat("health", 1, true))
            else
                -- The formula is broken in chapters 1 & 3.
                self.lw_health = math.ceil(self.health / self:getStat("health", 1, false)) * self:getStat("health", 1, true)
            end

            if self.lw_health <= 0 then
                self.lw_health = 1
            end
        end
    end

    function PartyMember:convertToDark()
        local last_weapon = self:getWeapon(1) and self:getWeapon(1).id or false
        local last_armor = self:getArmor(1) and self:getArmor(1).id or false

        self.equipped = { weapon = {}, armor = {} }

        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
            if self:getFlag("dark_weapon") and i == 1 then
                self.equipped.weapon[i] = Registry.createItem(self:getFlag("dark_weapon"))
            elseif self:getFlag("dark_weapons") and self:getFlag("dark_weapons")[i] then
                self.equipped.weapon[i] = Registry.createItem(self:getFlag("dark_weapons")[i])
            end
        end
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            if self:getFlag("dark_armors") and self:getFlag("dark_armors")[i] then
                self.equipped.armor[i] = Registry.createItem(self:getFlag("dark_armors")[i])
            end
        end

        self:setFlag("dark_weapon", nil)

        if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
            if last_weapon then
                local result = Registry.createItem(last_weapon).dark_item
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
                        if isClass(result) and self:canEquip(result, "weapon", i) and self.equipped.weapon[i] and self.equipped.weapon[i]:convertToLightEquip(self) and self.equipped.weapon[i].equip_can_convert ~= false then
                            self.equipped.weapon[i] = result
                        end
                    end
                end
            end
            if last_armor then
                local result = Registry.createItem(last_armor).dark_item
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    if isClass(result) then
                        local slot
                        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
                            if self:canEquip(result, "armor", i) then
                                slot = i
                                break
                            end
                        end
                        if slot then
                            if self:getFlag("converted_light_armor") == nil then
                                self:setFlag("converted_light_armor", "light/bandage")
                            end
                            local already_equipped = false
                            for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
                                if self.equipped.armor[i] and (self.equipped.armor[i].id == result.id or self.equipped.armor[i].equip_can_convert == false) then
                                    already_equipped = true
                                end
                            end
                            if not already_equipped then
                                for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
                                    if self.equipped.armor[i] then
                                        Game.inventory:addItem(self.equipped.armor[i].id)
                                    end
                                    self.equipped.armor[i] = nil
                                end
                                self.equipped.armor[slot] = result
                            end
                        end
                    end
                else
                    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
                        if self:getFlag("converted_light_armor") ~= nil and self.equipped.armor[i] and self.equipped.armor[i]:convertToLightEquip(self) then
                            self.equipped.armor[i] = nil
                            self:setFlag("converted_light_armor", nil)
                            break
                        end
                    end
                end
            end
        end

        self:setFlag("light_weapon", last_weapon)
        self:setFlag("light_armor", last_armor)

        if Kristal.getLibConfig("magical-glass", "health_conversion") then
            if self.last_converted_health ~= self.lw_health then
                self.health = math.ceil((self.lw_health / self:getStat("health", 1, true)) * self:getStat("health", 1, false))
                if self.health == self:getStat("health", 1, false) and self.lw_health < self:getStat("health", 1, true) then
                    self.health = math.max(self.health - 1, 1)
                end
                self.last_converted_health = self.health
            end
        elseif Kristal.getLibConfig("magical-glass", "health_conversion") == nil then
            if Game:getConfig("healthConversion") then
                self.health = math.ceil((self.lw_health / self:getStat("health", 1, true)) * self:getStat("health", 1, false))
            else
                -- The formula is broken in chapters 1 & 3.
                self.health = math.ceil(self.lw_health / self:getStat("health", 1, true)) * self:getStat("health", 1, false)
            end

            if self.health <= 0 then
                self.health = 1
            end
        end
    end
else
    function PartyMember:convertToLight()
        local last_weapons = {}
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
            table.insert(last_weapons, self:getWeapon(i))
        end
        local last_armors = {}
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            table.insert(last_armors, self:getArmor(i))
        end

        self.equipped = { weapon = {}, armor = {} }

        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
            if last_weapons[i] then
                local result = last_weapons[i]:convertToLightEquip(self)
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    if isClass(result) then
                        self.equipped.armor[1] = result
                    end
                    break
                end
            end
        end
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            if last_armors[i] then
                local result = last_armors[i]:convertToLightEquip(self)
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    if isClass(result) then
                        self.equipped.armor[1] = result
                    end
                    break
                end
            end
        end

        if not self.equipped.weapon[1] then
            self.equipped.weapon[1] = Registry.createItem(self.lw_weapon_default)
        end
        if not self.equipped.armor[1] then
            self.equipped.armor[1] = Registry.createItem(self.lw_armor_default)
        end

        self.equipped.weapon.dark_item = last_weapons[1]
        local armor_flags = {}
        for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            armor_flags[tostring(i)] = last_armors[i] and last_armors[i]:save()
        end

        self.equipped.armor[1]:setFlag("dark_armors", armor_flags)

        if Game:getConfig("healthConversion") then
            self.lw_health = math.ceil((self.health / self:getStat("health", 1, false)) * self:getStat("health", 1, true))
        else
            -- The formula is broken in chapters 1 & 3.
            self.lw_health = math.ceil(self.health / self:getStat("health", 1, false)) * self:getStat("health", 1, true)
        end

        if self.lw_health <= 0 then
            self.lw_health = 1
        end
    end

    function PartyMember:convertToDark()
        local last_weapon = self:getWeapon(1)
        local last_armor = self:getArmor(1)

        self.equipped = { weapon = {}, armor = {} }

        if last_weapon then
            local result = last_weapon:convertToDarkEquip(self)
            if result then
                if type(result) == "string" then
                    result = Registry.createItem(result)
                end
                if isClass(result) then
                    self.equipped.weapon[1] = result
                end
            end
        end
        if last_armor then
            local result = last_armor:convertToDarkEquip(self)
            if result then
                if type(result) == "string" then
                    result = Registry.createItem(result)
                end
                if isClass(result) then
                    self.equipped.armor[1] = result
                end
            end
        end

        if Game:getConfig("healthConversion") then
            self.health = math.ceil((self.lw_health / self:getStat("health", 1, true)) * self:getStat("health", 1, false))
        else
            -- The formula is broken in chapters 1 & 3.
            self.health = math.ceil(self.lw_health / self:getStat("health", 1, true)) * self:getStat("health", 1, false)
        end

        if self.health <= 0 then
            self.health = 1
        end
    end
end

function PartyMember:saveEquipment()
    local result = { weapon = {}, armor = {} }
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        if self.equipped.weapon[i] then
            result.weapon[tostring(i)] = self.equipped.weapon[i]:save()
        end
    end
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        if self.equipped.armor[i] then
            result.armor[tostring(i)] = self.equipped.armor[i]:save()
        end
    end
    return result
end

function PartyMember:loadEquipment(data)
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        self:setWeapon(i, nil)
    end
    if data.weapon then
        if Registry.getItem(data.weapon.id) then data.weapon = { data.weapon } end
        for k, v in pairs(data.weapon) do
            if type(v) == "table" then
                if Registry.getItem(v.id) then
                    local weapon = Registry.createItem(v.id)
                    if weapon then
                        weapon:load(v)
                        self:setWeapon(tonumber(k), weapon)
                    else
                        Kristal.Console:error("Could not load weapon \"" .. v.id .. "\"")
                    end
                else
                    Kristal.Console:error("Could not load weapon \"" .. v.id .. "\"")
                end
            else
                if Registry.getItem(v) then
                    self:setWeapon(tonumber(k), v)
                else
                    Kristal.Console:error("Could not load weapon \"" .. (v or "nil") .. "\"")
                end
            end
        end
    end
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        self:setArmor(i, nil)
    end
    if data.armor then
        for k, v in pairs(data.armor) do
            if type(v) == "table" then
                if Registry.getItem(v.id) then
                    local armor = Registry.createItem(v.id)
                    if armor then
                        armor:load(v)
                        self:setArmor(tonumber(k), armor)
                    else
                        Kristal.Console:error("Could not load armor \"" .. v.id .. "\"")
                    end
                else
                    Kristal.Console:error("Could not load armor \"" .. v.id .. "\"")
                end
            else
                if Registry.getItem(v) then
                    self:setArmor(tonumber(k), v)
                else
                    Kristal.Console:error("Could not load armor \"" .. (v or "nil") .. "\"")
                end
            end
        end
    end
end

return PartyMember