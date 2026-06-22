if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightShop, super = HookSystem.hookScript("LightShop")

function LightShop:init()
    super.init(self)

    self.arrow = Assets.getTexture("ui/flat_arrow_left")
    self.party_page = 1
end

function LightShop:drawBonuses(old_item, bonuses, stat, stat_name, x, y)
    if #Game.party <= Mod.libs["moreparty"]:getPartyPerRowAmount() then
        return super.drawBonuses(self, old_item, bonuses, stat, stat_name, x, y)
    end

    local stats_display = {}
    for i = 1, 2 do
        table.insert(stats_display, { "(" })
    end

    local display_slot = 1

    local old_stat = 0

    if old_item then
        old_stat = old_item:getStatBonus(stat) or 0
    end

    local amount = (bonuses[stat] or 0) - old_stat
    local amount_string = tostring(amount)

    if amount >= 0 then
        amount_string = "+" .. amount_string
    end

    local per_row = Mod.libs["moreparty"]:getPartyPerRowAmount()
    local row_height = 10
    local party_count = #Game.party
    local two_by_two = Mod.libs["moreparty"]:getTwoByTwo(party_count)
    local stats_per_row = two_by_two and 2 or per_row

    local party_members_per_page = Mod.libs["moreparty"]:getPartyPerRowAmount(true)
    local start_index = (self.party_page - 1) * party_members_per_page + 1

    for i = start_index, math.min(self.party_page * party_members_per_page, party_count) do
        display_slot = 1

        if i - ((self.party_page - 1) * party_members_per_page) > stats_per_row then
            display_slot = 2
        end

        local party_member = Game.party[i]
        local can_equip = party_member:canEquip(old_item)

        table.insert(stats_display[display_slot], { party_member:getColor() })

        if not can_equip then
            amount_string = "XX"
        end
        table.insert(stats_display[display_slot], amount_string .. " ")

        table.insert(stats_display[display_slot], { 1, 1, 1 })
    end

    for i = 1, 2 do
        table.insert(stats_display[i], stat_name .. ")")
    end

    if display_slot == 1 then
        love.graphics.print(stats_display[1], x, y)
    else
        for i = 1, 2 do
            love.graphics.print(stats_display[i], x, y + (i == 1 and -row_height or row_height))
        end
    end

    -- Draw arrows
    local box_left, box_top = self.info_box:getBorder()

    local left = self.info_box.x - math.floor(self.info_box.width) - (box_left / 2) * 1.5
    local top = self.info_box.y - math.floor(self.info_box.height) - (box_top / 2) * 1.5
    local right = self.info_box.x + (box_left / 2) * 1.5
    local height = math.floor(self.info_box.height) - 5

    if party_members_per_page < party_count then
        Draw.draw(self.arrow, left, top + height / 2)
        Draw.draw(self.arrow, right, top + height / 2, 0, -1, 1)
    end
end

-- function LightShop:drawBonuses(party_member, old_item, bonuses, stat, x, y)
    -- local stats_display = { { "(" }, { "(" } }
    -- local slot = 1

    -- local old_stat = 0

    -- if old_item then
        -- old_stat = old_item:getStatBonus(stat[1]) or 0
    -- end

    -- local amount = (bonuses[stat[1]] or 0) - old_stat
    -- local amount_string = tostring(amount)

    -- if amount >= 0 then
        -- amount_string = "+" .. amount_string
    -- end

    -- if Mod.libs["moreparty"] and Game:getPartyIndex(party_member) > Mod.libs["moreparty"]:getPartyPerRowAmount() then
        -- slot = 2
    -- end
    -- if #Game.party > 1 then
        -- table.insert(stats_display[slot], { party_member:getColor() })
    -- end

    -- table.insert(stats_display[slot], amount_string .. " ")
    -- for i = 1, 2 do
        -- if #Game.party > 1 then
            -- table.insert(stats_display[i], { 1, 1, 1 })
        -- end
        -- table.insert(stats_display[i], stat[2] .. ")")
    -- end

    -- if slot == 2 then
        -- love.graphics.print(stats_display[1], x, y - 10)
        -- love.graphics.print(stats_display[2], x, y + 10)
    -- else
        -- love.graphics.print(stats_display[1], x, y)
    -- end
-- end

function LightShop:processBuyMenuInput()
    local party_members_per_page = Mod.libs["moreparty"]:getPartyPerRowAmount(true)
    local max_pages = math.ceil(#Game.party / party_members_per_page)
    local item_type = self.items[self.current_selected_item] and self.items[self.current_selected_item].item and self.items[self.current_selected_item].item.type

    if item_type == "weapon" or item_type == "armor" then
        if Input.pressed("right") then
            self.party_page = (self.party_page % max_pages) + 1
        end
        if Input.pressed("left") then
            self.party_page = ((self.party_page - 2) % max_pages) + 1
        end
    end

    if Input.pressed("cancel") then
        self.party_page = 1
    end

    super.processBuyMenuInput(self)
end

return LightShop