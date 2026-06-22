local DarkEquipMenu, super = HookSystem.hookScript(DarkEquipMenu)

function DarkEquipMenu:init()
    super.init(self)

    -- Define icons for armor slots
    -- By default, there're 10 sprites (which you can continue to create) and a 'other' one for the exceeding slots
    self.armor_icons = {}
    local i = 1
    while Assets.getTexture("ui/menu/equip/armor_" .. i) do
        table.insert(self.armor_icons, Assets.getTexture("ui/menu/equip/armor_" .. i))
        i = i + 1
    end
    table.insert(self.armor_icons, Assets.getTexture("ui/menu/equip/armor_other"))

    self.caption_sprites["unknown"] = Assets.getTexture("ui/menu/caption_unknown")

    self.slot_scroll = 1
end

-- The order of the equip slots
function DarkEquipMenu:getEquipOrder()
    return { "weapons", "armors" }
end

-- Gets the position of the equip slot (like armors starting from index 2 for example)
-- 'early' means if it should count before or after the amount of equip slots
-- (example: if it's armor and set to 'early', since weapons have just 1 slot by default, it will start from 1. And not early will start from 3 [after both weapons and armors slots were counted].)
-- If 'equip' is unset, it will count the total amount of equip slots
function DarkEquipMenu:getEquipSlots(equip, early)
    local total_slots = 0
    local equip_slots = {}
    for _, type in ipairs(self:getEquipOrder()) do
        table.insert(equip_slots, math.min(self.party:getSelected():getMaxEquipSlots(type) or math.huge, Kristal.getLibConfig("extra_equip_slots", "max_" .. type)))
    end
    for i, slots in ipairs(equip_slots) do
        if early and equip == self:getEquipOrder()[i] then
            break
        else
            total_slots = total_slots + slots
            if equip == self:getEquipOrder()[i] then
                break
            end
        end
    end
    return total_slots
end

function DarkEquipMenu:getCurrentItemType(single)
    for _, type in ipairs(self:getEquipOrder()) do
        if self.selected_slot <= self:getEquipSlots(type, false) then
            return single and StringUtils.sub(type, 1, -2) or type
        end
    end
end

function DarkEquipMenu:canEquipSelected()
    local item = self:getSelectedItem()
    local character = self.party:getSelected()

    return character:canEquip(item, self:getCurrentItemType(true), self.selected_slot - self:getEquipSlots(self:getCurrentItemType(), true))
end

function DarkEquipMenu:getEquipPreview()
    local party = self.party:getSelected()
    local equipped = {}
    local item = self:getSelectedItem()
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        if self.selected_slot == i then
            equipped[i] = item
        else
            equipped[i] = party.equipped.weapon[i]
        end
    end
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        if self.selected_slot == i + self:getEquipSlots("armors", true) then
            equipped[i + self:getEquipSlots("armors", true)] = item
        else
            equipped[i + self:getEquipSlots("armors", true)] = party.equipped.armor[i]
        end
    end
    return equipped
end

function DarkEquipMenu:getStatsPreview()
    local party = self.party:getSelected()
    local current_stats = party:getStats()
    if self.state == "ITEMS" and self:canEquipSelected() then
        local preview_stats = TableUtils.copy(party.stats)
        local equipment = self:getEquipPreview()
        for i = 1, self:getEquipSlots() do
            if equipment[i] then
                for stat, amount in pairs(equipment[i].bonuses) do
                    if preview_stats[stat] then
                        preview_stats[stat] = preview_stats[stat] + amount
                    end
                end
            end
        end
        return preview_stats, current_stats
    else
        return current_stats, current_stats
    end
end

function DarkEquipMenu:getAbilityPreview()
    local party = self.party:getSelected()
    local current_abilities = {}
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        local weapon = party.equipped.weapon[i]
        if weapon and weapon:getBonusName() then
            current_abilities[i] = { name = weapon:getBonusName(), icon = weapon.bonus_icon, color = weapon.bonus_color }
        end
    end
    for i = 1, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        local armor = party.equipped.armor[i]
        if armor and armor:getBonusName() then
            current_abilities[i + self:getEquipSlots("armors", true)] = { name = armor:getBonusName(), icon = armor.bonus_icon, color = armor.bonus_color }
        end
    end
    if self.state == "ITEMS" and self:canEquipSelected() then
        local preview_abilities = {}
        local equipment = self:getEquipPreview()
        for i = self.slot_scroll, (self.slot_scroll + 2) do
            if equipment[i] and equipment[i]:getBonusName() then
                preview_abilities[i] = {
                    name = equipment[i]:getBonusName(),
                    icon = equipment[i].bonus_icon,
                    color = equipment[i].bonus_color
                }
            end
        end
        return preview_abilities, current_abilities
    else
        return current_abilities, current_abilities
    end
end

function DarkEquipMenu:updateDescription()
    if self.state == "SLOTS" then
        local party = self.party:getSelected()
        local item
        if self.selected_slot <= self:getEquipSlots("weapons", false) then
            item = party:getWeapon(self.selected_slot)
        else
            item = party:getArmor(self.selected_slot - self:getEquipSlots("armors", true))
        end
        Game.world.menu:setDescription(item and item:getDescription() or "", true)
    else
        super.updateDescription(self)
    end
end

function DarkEquipMenu:update()
    if self.state == "PARTY" and Input.pressed("confirm") and self:getEquipSlots() <= 0 then
        Input.clear("confirm")
    elseif self.state == "SLOTS" then
        if Input.pressed("cancel") then
            self.state = "PARTY"

            self.ui_cancel_small:stop()
            self.ui_cancel_small:play()

            self.party.focused = true
            self.slot_scroll = 1
            self:updateDescription()
            return
        elseif Input.pressed("confirm") then
            self.state = "ITEMS"

            self.ui_select:stop()
            self.ui_select:play()

            self:updateDescription()
        end
        local old_selected = self.selected_slot
        if Input.pressed("up") then
            self.selected_slot = self.selected_slot - 1
        end
        if Input.pressed("down") then
            self.selected_slot = self.selected_slot + 1
        end
        self.selected_slot = (self.selected_slot - 1) % self:getEquipSlots() + 1
        if old_selected ~= self.selected_slot then
            if self.selected_slot < self.slot_scroll then
                self.slot_scroll = self.selected_slot
            elseif self.selected_slot > self.slot_scroll + 2 then
                self.slot_scroll = self.selected_slot - 2
            end
        end
        if old_selected ~= self.selected_slot then
            self.ui_move:stop()
            self.ui_move:play()
            self:updateDescription()
        end

        Object.update(self)
        return
    elseif self.state == "ITEMS" and not Input.pressed("cancel") then
        local type = self:getCurrentItemType()
        local max_items = self:getMaxItems()
        local old_selected = self.selected_item[type]
        if Input.pressed("up", true) then
            self.selected_item[type] = self.selected_item[type] - 1
        end
        if Input.pressed("down", true) then
            self.selected_item[type] = self.selected_item[type] + 1
        end
        self.selected_item[type] = MathUtils.clamp(self.selected_item[type], 1, max_items)
        if self.selected_item[type] ~= old_selected then
            local min_scroll = math.max(1, self.selected_item[type] - 5)
            local max_scroll = math.min(math.max(1, max_items - 5), self.selected_item[type])
            self.item_scroll[type] = MathUtils.clamp(self.item_scroll[type], min_scroll, max_scroll)

            self.ui_move:stop()
            self.ui_move:play()

            self:updateDescription()
        end
        if Input.pressed("confirm") then
            self:react()
            local item, party = self:getSelectedItem(), self.party:getSelected()
            if not self:canEquipSelected() then
                self.ui_cant_select:stop()
                self.ui_cant_select:play()
            else
                local swap_with = (self.selected_slot <= self:getEquipSlots("weapons", false)) and party:getWeapon(self.selected_slot) or
                    party:getArmor(self.selected_slot - self:getEquipSlots("armors", true))

                local can_continue = true

                if item and (not item:onEquip(party, swap_with)) then can_continue = false end
                if swap_with and (not swap_with:onUnequip(party, item)) then can_continue = false end
                if (not party:onEquip(item, swap_with)) then can_continue = false end
                if (not party:onUnequip(swap_with, item)) then can_continue = false end

                -- If one of the functions returned false, don't continue

                if (not can_continue) then
                    self.ui_cant_select:stop()
                    self.ui_cant_select:play()
                    return
                end

                Assets.playSound("equip")

                if self.selected_slot <= self:getEquipSlots("weapons", false) then
                    party:setWeapon(self.selected_slot, item)
                else
                    party:setArmor(self.selected_slot - self:getEquipSlots("armors", true), item)
                end

                Game.inventory:setItem(self:getCurrentStorage(), self.selected_item[type], swap_with)

                self.state = "SLOTS"
                self:updateDescription()
            end
        end

        Object.update(self)
        return
    end

    super.update(self)
end

function DarkEquipMenu:draw()
    love.graphics.setFont(self.font)

    Draw.setColor(PALETTE["world_border"])
    love.graphics.rectangle("fill", 188, -24, 6, 139)
    love.graphics.rectangle("fill", -24, 109, 58, 6)
    love.graphics.rectangle("fill", 130, 109, 160, 6)
    love.graphics.rectangle("fill", 422, 109, 79, 6)
    love.graphics.rectangle("fill", 241, 109, 6, 192)

    Draw.setColor(1, 1, 1, 1)
    Draw.draw(self.caption_sprites["char"], 36, -26, 0, 2, 2)
    Draw.draw(self.caption_sprites["equipped"], 294, -26, 0, 2, 2)
    Draw.draw(self.caption_sprites["stats"], 34, 104, 0, 2, 2)
    if self:getEquipSlots() <= 0 then
        Draw.draw(self.caption_sprites["unknown"], 290, 104, 0, 2, 2)
    elseif self.selected_slot <= self:getEquipSlots("weapons", false) then
        Draw.draw(self.caption_sprites["weapons"], 290, 104, 0, 2, 2)
    else
        Draw.draw(self.caption_sprites["armors"], 290, 104, 0, 2, 2)
    end

    self:drawChar()
    self:drawEquipped()
    if self:getEquipSlots() > 0 then
        self:drawItems()
    end
    self:drawStats()

    Object.draw(self)
end

function DarkEquipMenu:drawEquipped()
    local party = self.party:getSelected()
    Draw.setColor(1, 1, 1, 1)

    if self.state == "SLOTS" then
        Draw.setColor(Game:getSoulColor())
        Draw.draw(self.heart_sprite, 226, 10 + ((self.selected_slot - self.slot_scroll) * 30))

        if self:getEquipSlots() > 3 then
            Draw.setColor(1, 1, 1)
            local sine_off = math.sin((Kristal.getTime() * 30) / 12) * 3
            if self.slot_scroll + 3 <= self:getEquipSlots() then
                Draw.draw(self.arrow_sprite, 282 + 187, 124 + 149 - 133 - 53 + sine_off)
            end
            if self.slot_scroll > 1 then
                Draw.draw(self.arrow_sprite, 282 + 187, 124 + 14 - 133 - sine_off, 0, 1, -1)
            end

            Draw.setColor(0.25, 0.25, 0.25)
            love.graphics.rectangle("fill", 282 + 191, 124 + 24 - 133, 6, 66)
            local percent = (self.slot_scroll - 1) / (self:getEquipSlots() - 3)
            Draw.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 282 + 191, 124 + 24 - 133 + math.floor(percent * (66 - 6)), 6, 6)
        end
    end

    for i = self.slot_scroll, math.min(self:getEquipSlots(), self.slot_scroll + 2) do
        local offset = i - self.slot_scroll

        Draw.setColor(1, 1, 1, 1)
        if self.state ~= "SLOTS" or self.selected_slot ~= i then
            if i <= self:getEquipSlots("weapons", false) then
                local weapon_icon = Assets.getTexture(party:getWeaponIcon(i))
                if weapon_icon then
                    Draw.draw(weapon_icon, 220, (-4) + offset * 30, 0, 2, 2)
                end
            else
                Draw.draw(self.armor_icons[math.min(i - self:getEquipSlots("armors", true), #self.armor_icons)], 220, offset * 30, 0, 2, 2)
            end
        end

        self:drawEquippedItem(i, 261, 6 + (offset * 30))
    end
end

function DarkEquipMenu:drawEquippedItem(index, x, y)
    local party = self.party:getSelected()
    local item
    if index <= self:getEquipSlots("weapons", false) then
        item = party:getWeapon(index)
    else
        item = party:getArmor(index - self:getEquipSlots("armors", true))
    end
    if item then
        Draw.setColor(1, 1, 1)
        if item.icon and Assets.getTexture(item.icon) then
            Draw.draw(Assets.getTexture(item.icon), x, y, 0, 2, 2)
        end
        love.graphics.print(item:getName(), x + 22, y - 6)
    else
        Draw.setColor(PALETTE["world_dark_gray"])
        love.graphics.print("(Nothing)", x + 22, y - 6)
    end
end

function DarkEquipMenu:drawStats()
    local party = self.party:getSelected()
    Draw.setColor(1, 1, 1, 1)
    Draw.draw(self.stat_icons["attack"], -8, 124, 0, 2, 2)
    Draw.draw(self.stat_icons["defense"], -8, 151, 0, 2, 2)
    Draw.draw(self.stat_icons["magic"], -8, 178, 0, 2, 2)
    love.graphics.print("Attack:", 18, 118)
    love.graphics.print("Defense:", 18, 145)
    love.graphics.print("Magic:", 18, 172)
    local stats, compare = self:getStatsPreview()
    self:drawStatPreview("attack", 148, 118, stats, compare, self:getCurrentItemType() == "weapons")
    self:drawStatPreview("defense", 148, 145, stats, compare, false)
    self:drawStatPreview("magic", 148, 172, stats, compare, false)

    -- Shows the ability of the current 3 visible slots
    local abilities, ability_comp = self:getAbilityPreview()
    local preview_slot = 0
    for i = self.slot_scroll, (self.slot_scroll + 2) do
        preview_slot = preview_slot + 1
        self:drawAbilityPreview(i, -8, 178 + (27 * preview_slot), abilities, ability_comp)
    end
end

return DarkEquipMenu