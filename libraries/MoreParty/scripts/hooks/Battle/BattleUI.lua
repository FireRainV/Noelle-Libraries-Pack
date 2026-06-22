local BattleUI, super = HookSystem.hookScript(BattleUI)

-- Adjust the position of the action boxes
function BattleUI:init()
    super.init(self)

    local per_row = Mod.libs["moreparty"]:getPartyPerRowAmount()
    local row_height = Game:getConfig("oldUIPositions") and 36 or 37
    local party_count = #Game.battle.party
    local two_by_two = Mod.libs["moreparty"]:getTwoByTwo(party_count)
    local boxes_per_row = two_by_two and 2 or per_row

    if party_count > per_row then
        self.y = self.y + row_height
    end

    if party_count <= 3 then return end

    local realW = ((SCREEN_WIDTH - 1) / per_row)

    for k, v in ipairs(self.action_boxes) do
        local index = k - 1
        local row = math.floor(index / boxes_per_row)
        local col = index % boxes_per_row

        local boxes_in_this_row = math.min(boxes_per_row, party_count - row * boxes_per_row)
        local row_offset = 0

        if boxes_in_this_row < per_row then
            row_offset = ((per_row - boxes_in_this_row) * realW) / 2
        end

        v.x = row_offset + (col * realW)
        v.y = row * row_height
        v.realWidth = realW
    end

    if party_count > per_row then
        for _, v in ipairs(self.action_boxes) do
            v.y = v.y - row_height
        end
    end

    self.current_row = 1
    self.top_visible_row = 1

    self.party_alpha = 0
end

function BattleUI:update()
    super.update(self)

    if #Game.battle.party <= Mod.libs["moreparty"]:getPartyPerRowAmount() then return end

    -- Make the current active action box be layed above the rest
    for k, v in ipairs(self.action_boxes) do
        if k == Game.battle.current_selecting then
            v:setLayer(BATTLE_LAYERS["ui"] + 0.5)
        else
            v:setLayer(BATTLE_LAYERS["ui"])
        end
    end

    if Game.battle.current_selecting > 0 then
        self.current_row = math.ceil(Game.battle.current_selecting / Mod.libs["moreparty"]:getPartyPerRowAmount())
    else
        self.current_row = 1
    end

    local new_top_row = self.top_visible_row

    if self.current_row < self.top_visible_row then
        new_top_row = self.current_row
    elseif self.current_row > self.top_visible_row + 1 then
        new_top_row = self.current_row - 1
    end

    -- Tween to the new row
    if new_top_row ~= self.top_visible_row then
        local per_row = Mod.libs["moreparty"]:getPartyPerRowAmount()
        local row_height = Game:getConfig("oldUIPositions") and 36 or 37

        for k, v in ipairs(self.action_boxes) do
            local row = math.ceil(k / per_row)
            local target_y = (row - (new_top_row + 1)) * row_height

            Game.battle.timer:tween(6 / 30, v, { y = target_y }, "out-cubic")
        end

        self.top_visible_row = new_top_row
    end

    -- Set the alpha for the exceeding amount of party members that can't fit in the rows while it's the enemy's turn
    if TableUtils.contains({ "DEFENDING", "DEFENDINGBEGIN" }, Game.battle.state) then
        self.party_alpha = self.party_alpha + DT * 2
    else
        self.party_alpha = self.party_alpha - DT * 2
    end
    self.party_alpha = MathUtils.clamp(self.party_alpha, 0, 1)
end

-- Add UI background for the second row
function BattleUI:drawActionStrip()
    super.drawActionStrip(self)

    if #Game.battle.party <= Mod.libs["moreparty"]:getPartyPerRowAmount() then return end

    -- Draw the top line of the action strip
    Draw.setColor(PALETTE["action_strip"])
    love.graphics.rectangle("fill", 0, Game:getConfig("oldUIPositions") and -35 or -37, 640, Game:getConfig("oldUIPositions") and 3 or 2)
    -- Draw the background of the action strip
    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0, Game:getConfig("oldUIPositions") and -32 or -35, 640, Game:getConfig("oldUIPositions") and 33 or 35)
end

-- Set the position of the attack bolts to the correct position (since they're smaller)
function BattleUI:beginAttack()
    if #Game.battle.party <= 3 then
        super.beginAttack(self)
        return
    end

    local attack_order = Utils.pickMultiple(Game.battle.normal_attackers, #Game.battle.normal_attackers)

    for _, box in ipairs(self.attack_boxes) do
        box:remove()
    end
    self.attack_boxes = {}

    local last_offset = -1
    local offset = 0
    local height = math.floor(112 / #Game.battle.party)
    for i = 1, #attack_order do
        offset = offset + last_offset

        local battler = attack_order[i]
        local index = Game.battle:getPartyIndex(battler.chara.id)
        local attack_box = AttackBox(battler, 30 + offset, index, 0, 40 + (height * (index - 1)))
        attack_box.layer = -10 + (index * 0.01)
        self:addChild(attack_box)
        table.insert(self.attack_boxes, attack_box)

        if i < #attack_order and last_offset ~= 0 then
            last_offset = TableUtils.pick{ 0, 10, 15 }
        else
            last_offset = TableUtils.pick{ 10, 15 }
        end
    end
    self.attacking = true
end

function BattleUI:drawState()
    if #Game.battle.party <= 3 then
        super.drawState(self)
        return
    end

    if Game.battle.state == "ATTACKING" or self.attacking then -- Blue lines in the attack box
        local y = 40
        local h = math.floor((115 - (#Game.battle.party % 4)) / #Game.battle.party)

        local ch1_offset = Game:getConfig("oldUIPositions")

        for c = 1, (#Game.battle.party - 1) do
            Draw.setColor(PALETTE["battle_attack_lines"])
            y = y + h
            if not ch1_offset then
                love.graphics.rectangle("fill", 79, y, 224, 2)
            else
                local has_index = {}
                for _, box in ipairs(self.attack_boxes) do
                    has_index[box.index] = true
                end
                love.graphics.rectangle("fill", has_index[c + 1] and 77 or 2, y, has_index[c + 1] and 226 or 301, 3)
            end
        end
    elseif Game.battle.state == "MENUSELECT" then -- scale the size of the heads for acts or spells that require a lot of party members to use
        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#Game.battle.menu_items / 6) - 1

        local x = 0
        local y = 0
        Draw.setColor(Game.battle.encounter:getSoulColor())
        Draw.draw(self.heart_sprite, 5 + ((Game.battle.current_menu_x - 1) * 230), 30 + ((Game.battle.current_menu_y - (page * 3)) * 30))

        local font = Assets.getFont("main")
        love.graphics.setFont(font)

        local page_offset = page * 6
        for i = page_offset + 1, math.min(page_offset + 6, #Game.battle.menu_items) do
            local item = Game.battle.menu_items[i]

            Draw.setColor(1, 1, 1, 1)
            local text_offset = 0
            -- Are we able to select this?
            local able = Game.battle:canSelectMenuItem(item)
            if item.party then
                if not able then
                    -- We're not able to select this, so make the heads gray.
                    Draw.setColor(COLORS.gray)
                end
                -- Head counter
                local heads = 0
                for _, party_id in ipairs(item.party) do
                    if Game.battle:getPartyIndex(party_id) ~= Game.battle.current_selecting then
                        heads = heads + 1
                    end
                end
                for _, party_id in ipairs(item.party) do
                    local chara = Game:getPartyMember(party_id)
                    -- Draw head only if it isn't the currently selected character
                    if Game.battle:getPartyIndex(party_id) ~= Game.battle.current_selecting then
                        local ox, oy = chara:getHeadIconOffset()
                        local party_n = 0
                        if heads > 2 then
                            party_n = heads - 2
                        end
                        Draw.draw(Assets.getTexture(chara:getHeadIcons() .. "/head"), text_offset + 30 + (x * 230) + ox, 50 + (y * 30) + oy + (party_n ~= 0 and (3.6 + ((party_n * 7) / (20 + party_n * 7)) * 16) or 0), 0, 1 / (1 + party_n * 7 / 20))
                        text_offset = text_offset + (30 / (1 + party_n * 0.5))
                    end
                end
            end
            if item.icons then
                if not able then
                    -- We're not able to select this, so make the heads gray.
                    Draw.setColor(COLORS.gray)
                end

                for _, icon in ipairs(item.icons) do
                    if type(icon) == "string" then
                        icon = { icon, false, 0, 0, nil }
                    end
                    if not icon[2] then
                        local texture = Assets.getTexture(icon[1])
                        Draw.draw(texture, text_offset + 30 + (x * 230) + (icon[3] or 0), 50 + (y * 30) + (icon[4] or 0))
                        text_offset = text_offset + (icon[5] or texture:getWidth())
                    end
                end
            end

            if able then
                Draw.setColor(item:color() or { 1, 1, 1, 1 })
            else
                Draw.setColor(COLORS.gray)
            end
            love.graphics.print(item.name, text_offset + 30 + (x * 230), 50 + (y * 30))
            text_offset = text_offset + font:getWidth(item.name)

            if item.icons then
                if able then
                    Draw.setColor(1, 1, 1)
                end

                for _, icon in ipairs(item.icons) do
                    if type(icon) == "string" then
                        icon = { icon, false, 0, 0, nil }
                    end
                    if icon[2] then
                        local texture = Assets.getTexture(icon[1])
                        Draw.draw(texture, text_offset + 30 + (x * 230) + (icon[3] or 0), 50 + (y * 30) + (icon[4] or 0))
                        text_offset = text_offset + (icon[5] or texture:getWidth())
                    end
                end
            end

            if x == 0 then
                x = 1
            else
                x = 0
                y = y + 1
            end
        end

        -- Print information about currently selected item
        local tp_offset = 0
        local current_item = Game.battle.menu_items[Game.battle:getItemIndex()]
        if current_item.description then
            Draw.setColor(COLORS.gray)
            love.graphics.print(current_item.description, 260 + 240, 50)
            Draw.setColor(1, 1, 1, 1)
            _, tp_offset = current_item.description:gsub("\n", "\n")
            tp_offset = tp_offset + 1
        end

        if current_item.tp and current_item.tp ~= 0 then
            Draw.setColor(PALETTE["tension_desc"])
            love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "% " .. Game:getConfig("tpName"), 260 + 240, 50 + (tp_offset * 32))
            Game:setTensionPreview(current_item.tp)
        else
            Game:setTensionPreview(0)
        end

        Draw.setColor(1, 1, 1, 1)
        if page < max_page then
            Draw.draw(self.arrow_sprite, 470, 120 + (math.sin(Kristal.getTime() * 6) * 2))
        end
        if page > 0 then
            Draw.draw(self.arrow_sprite, 470, 70 - (math.sin(Kristal.getTime() * 6) * 2), 0, 1, -1)
        end
    else
        super.drawState(self)
    end

    -- Display exceeding party battlers' health
    local per_row = 6
    local total_rows = 4
    local skip_amount = Mod.libs["moreparty"]:getPartyPerRowAmount(true)

    local x_spacing = 105
    local y_spacing = 28

    if self.party_alpha > 0 then
        for i = (1 + skip_amount), math.min(#Game.battle.party, #Game.battle.party + per_row * total_rows) do
            local battler = Game.battle.party[i]
            local zero_index = i - 1 - skip_amount
            local row = math.floor(zero_index / per_row)
            local col = zero_index % per_row

            local boxes_in_this_row = math.min(per_row, #Game.battle.party - skip_amount - row * per_row)

            -- Calculate the exact center X for this specific column
            local center_x = (SCREEN_WIDTH / 2) + 11 + (col - (boxes_in_this_row - 1) / 2) * x_spacing

            -- Calculate the Y offset for this row
            local base_y = row * y_spacing

            local color = PALETTE["action_health_text"]
            if battler.chara:getHealth() <= 0 then
                color = PALETTE["action_health_text_down"]
            elseif Mod.libs["magical-glass"] and battler.karma > 0 then
                color = MG_PALETTE["player_karma_text"]
            elseif (battler.chara:getHealth() <= (battler.chara:getStat("health") / 4)) then
                color = PALETTE["action_health_text_low"]
            else
                color = PALETTE["action_health_text"]
            end
            local r, g, b, a = ColorUtils.unpackColor(color)

            local health_offset = 0
            health_offset = (#tostring(battler.chara:getHealth()) - 1) * 8

            Draw.setColor(r, g, b, a * self.party_alpha)
            love.graphics.setFont(Assets.getFont("smallnumbers"))
            love.graphics.print(battler.chara:getHealth(), center_x - 8 - health_offset, 50 + base_y)

            local r2, g2, b2, a2 = ColorUtils.unpackColor(PALETTE["action_health_text"])
            Draw.setColor(r2, g2, b2, a2 * self.party_alpha)
            love.graphics.print("/", center_x, 50 + base_y)

            local string_width = love.graphics.getFont():getWidth(tostring(battler.chara:getStat("health")))
            Draw.setColor(r, g, b, a * self.party_alpha)
            love.graphics.print(battler.chara:getStat("health"), center_x + 38 - string_width, 50 + base_y)

            Draw.setColor(1, 1, 1, self.party_alpha)
            if Mod.libs["magical-glass"] and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
                Draw.pushShader("color", { targetColor = MG_PALETTE["light_world_dark_battle_color"] })
                Draw.draw(Game.battle.battle_ui.action_boxes[i].head_sprite.texture, center_x - 58, 43 + base_y)
                Draw.popShader()
            else
                Draw.draw(Game.battle.battle_ui.action_boxes[i].head_sprite.texture, center_x - 58, 43 + base_y)
            end
        end
    end
end

-- Increase he transition bounds size when there're 2 rows of party battlers
function BattleUI:getTransitionBounds()
    if #Game.battle.party <= Mod.libs["moreparty"]:getPartyPerRowAmount() then
        return super.getTransitionBounds(self)
    end

    return 480 + (Game:getConfig("oldUIPositions") and 36 or 37), 325
end

return BattleUI