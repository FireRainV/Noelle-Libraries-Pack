local OverworldActionBox, super = HookSystem.hookScript(OverworldActionBox)

function OverworldActionBox:draw()
    local per_row = Mod.libs["moreparty"]:getPartyPerRowAmount()
    local party_count = #Game.party

    if party_count <= 3 then
        super.draw(self)
        return
    end

    -- Abort drawing if this box is currently scrolled off-screen
    if not self.visible then return end

    local double_row = math.ceil(party_count / per_row) > 1

    local realW = self.realWidth

    local string_width = self.font:getWidth(tostring(self.chara:getStat("health")))

    -- Draw the line at the top
    if self.selected then
        Draw.setColor(self.chara:getColor())
    else
        Draw.setColor(PALETTE["action_strip"])
    end

    love.graphics.setLineWidth(2)
    love.graphics.line(0, double_row and 20 or 1, realW, double_row and 20 or 1)

    if Game:getConfig("oldUIPositions") then
        love.graphics.line(0, double_row and 21 or 2, 2, double_row and 21 or 2)
        love.graphics.line(realW - 2, double_row and 21 or 2, realW, double_row and 21 or 2)
    end

    local y_bar = double_row and 36 or 24
    local y_hp = double_row and 24 or 11

    if not Kristal.getLibConfig("moreparty", "three_per_row") then
        -- Draw health
        Draw.setColor(PALETTE["action_health_bg"])
        love.graphics.rectangle("fill", 118, y_bar, 39, 9)

        local health = (self.chara.health / self.chara:getStat("health")) * 39

        if health > 0 then
            Draw.setColor(self.chara:getColor())
            love.graphics.rectangle("fill", 118, y_bar, math.min(math.ceil(health), 39), 9)
        end

        local color = PALETTE["action_health_text"]
        if health <= 0 then
            color = PALETTE["action_health_text_down"]
        elseif (self.chara:getHealth() <= (self.chara:getStat("health") / 4)) then
            color = PALETTE["action_health_text_low"]
        else
            color = PALETTE["action_health_text"]
        end

        local health_offset = 0
        health_offset = (#tostring(self.chara.health) - 1) * 8

        Draw.setColor(color)
        love.graphics.setFont(self.font)
        love.graphics.print(self.chara.health, 113 - health_offset, y_hp)
        Draw.setColor(PALETTE["action_health_text"])
        love.graphics.print("/", 121, y_hp)
        Draw.setColor(color)
        love.graphics.print(self.chara:getStat("health"), 159 - string_width, y_hp)
    else
        -- Draw health
        Draw.setColor(PALETTE["action_health_bg"])
        love.graphics.rectangle("fill", 128, y_bar, 76, 9)

        local health = (self.chara:getHealth() / self.chara:getStat("health")) * 76

        if health > 0 then
            Draw.setColor(self.chara:getColor())
            love.graphics.rectangle("fill", 128, y_bar, math.min(math.ceil(health), 76), 9)
        end

        local color = PALETTE["action_health_text"]
        if health <= 0 then
            color = PALETTE["action_health_text_down"]
        elseif (self.chara:getHealth() <= (self.chara:getStat("health") / 4)) then
            color = PALETTE["action_health_text_low"]
        else
            color = PALETTE["action_health_text"]
        end

        local health_offset = 0
        health_offset = (#tostring(self.chara:getHealth()) - 1) * 8

        Draw.setColor(color)
        love.graphics.setFont(self.font)
        love.graphics.print(self.chara:getHealth(), 152 - health_offset, y_hp)
        Draw.setColor(PALETTE["action_health_text"])
        love.graphics.print("/", 161, y_hp)
        local string_width2 = self.font:getWidth(tostring(self.chara:getStat("health")))
        Draw.setColor(color)
        love.graphics.print(self.chara:getStat("health"), 205 - string_width2, y_hp)
    end

    -- Draw name text if there's no sprite
    if not self.name_sprite then
        local font = Assets.getFont("name")
        love.graphics.setFont(font)
        Draw.setColor(1, 1, 1, 1)

        local name = self.chara:getName():upper()
        local spacing = 5 - name:len()

        local off = 0
        for i = 1, name:len() do
            local letter = name:sub(i, i)
            love.graphics.print(letter, (Kristal.getLibConfig("moreparty", "three_per_row") and 51 or 41) + off, 16 - 1)
            off = off + font:getWidth(letter) + spacing
        end
    end

    local reaction_x = -1

    if self.x == 0 then -- lazy check for leftmost party member
        reaction_x = 3
    end

    love.graphics.setFont(self.main_font)
    Draw.setColor(1, 1, 1, self.reaction_alpha / 6)
    if double_row then
        love.graphics.print(self.reaction_text, reaction_x, 46, 0, 0.5, 0.5)
        local x, y = Kristal.getLibConfig("moreparty", "three_per_row") and 0 or -10, 12
        love.graphics.translate(x, y)
        local objects = TableUtils.copy(self.children)
        table.insert(objects, 1, self)
        for _, object in ipairs(objects) do
            object.debug_rect = { x, y, object.width, object.height }
        end
    else
        love.graphics.print(self.reaction_text, reaction_x, 43, 0, 0.5, 0.5)
        local x, y = Kristal.getLibConfig("moreparty", "three_per_row") and 0 or -10, 0
        love.graphics.translate(x, y)
        local objects = TableUtils.copy(self.children)
        table.insert(objects, 1, self)
        for _, object in ipairs(objects) do
            object.debug_rect = { x, y, object.width, object.height }
        end
    end

    Object.draw(self)
end

return OverworldActionBox