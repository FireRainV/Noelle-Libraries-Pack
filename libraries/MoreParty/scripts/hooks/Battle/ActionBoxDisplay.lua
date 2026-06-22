local ActionBoxDisplay, super = HookSystem.hookScript(ActionBoxDisplay)

-- Health bar and HP amount display
function ActionBoxDisplay:draw()
    if #Game.battle.party <= 3 then
        super.draw(self)
        return
    end

    local x = self.parent.realWidth

    if Game.battle.current_selecting == self.actbox.index then
        Draw.setColor(self.actbox.battler.chara:getColor())
    else
        Draw.setColor(PALETTE["action_strip"], 1)
    end

    -- Box outline
    love.graphics.setLineWidth(2)
    love.graphics.line((Game.battle.current_selecting == self.actbox.index) and 0 or 2, Game:getConfig("oldUIPositions") and 2 or 1, x + 1, Game:getConfig("oldUIPositions") and 2 or 1)

    love.graphics.setLineWidth(2)
    if Game.battle.current_selecting == self.actbox.index then
        love.graphics.line(1, 2, 1, 36)
        love.graphics.line(x, 2, x, 36)
    end

    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 2, Game:getConfig("oldUIPositions") and 3 or 2, x - 3, Game:getConfig("oldUIPositions") and 34 or 35)

    if not Kristal.getLibConfig("moreparty", "three_per_row") then
        Draw.setColor(Mod.libs["magical-glass"] and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() and (Game.battle.encounter.karma_mode and MG_PALETTE["player_karma_health_bg"] or MG_PALETTE["player_health_bg"]) or (Mod.libs["magical-glass"] and Game.battle.encounter.karma_mode and MG_PALETTE["player_karma_health_bg_dark"] or PALETTE["action_health_bg"])) -- Compatibility with  'magical-glass' Library.
        love.graphics.rectangle("fill", 118, 22 - self.actbox.data_offset, 39, 9)
        local health = (self.actbox.battler.chara:getHealth() / self.actbox.battler.chara:getStat("health")) * 39
        local karma_health
        if Mod.libs["magical-glass"] then
            karma_health = ((self.actbox.battler.chara:getHealth() - self.actbox.battler.karma) / self.actbox.battler.chara:getStat("health")) * 39
        end

        if health > 0 then
            if Mod.libs["magical-glass"] then
                if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
                    Draw.setColor(MG_PALETTE["player_karma_health"])
                else
                    Draw.setColor(MG_PALETTE["player_karma_health_dark"])
                end
                love.graphics.rectangle("fill", 118, 22 - self.actbox.data_offset, math.min(math.ceil(health), 39), 9)
            end
            if Mod.libs["magical-glass"] and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then -- Compatibility with 'magical-glass' Library.
                Draw.setColor(MG_PALETTE["player_health"])
            else
                Draw.setColor(self.actbox.battler.chara:getColor())
            end
            love.graphics.rectangle("fill", 118, 22 - self.actbox.data_offset, math.min(math.ceil(Mod.libs["magical-glass"] and karma_health or health), 39), 9)
        end

        local color = PALETTE["action_health_text"]
        if health <= 0 then
            color = PALETTE["action_health_text_down"]
        elseif Mod.libs["magical-glass"] and self.actbox.battler.karma > 0 then
            color = MG_PALETTE["player_karma_text"]
        elseif (self.actbox.battler.chara:getHealth() <= (self.actbox.battler.chara:getStat("health") / 4)) then
            color = PALETTE["action_health_text_low"]
        else
            color = PALETTE["action_health_text"]
        end

        local health_offset = 0
        health_offset = (#tostring(self.actbox.battler.chara:getHealth()) - 1) * 8

        Draw.setColor(color)
        love.graphics.setFont(self.font)
        love.graphics.print(self.actbox.battler.chara:getHealth(), 113 - health_offset, 9 - self.actbox.data_offset)
        Draw.setColor(PALETTE["action_health_text"])
        love.graphics.print("/", 121, 9 - self.actbox.data_offset)
        Draw.setColor(color)
        local string_width = self.font:getWidth(tostring(self.actbox.battler.chara:getStat("health")))
        love.graphics.print(self.actbox.battler.chara:getStat("health"), 159 - string_width, 9 - self.actbox.data_offset)
        local x, y = -10, 0
        love.graphics.translate(x, y)
        local objects = TableUtils.copy(self.children)
        table.insert(objects, 1, self)
        for _, object in ipairs(objects) do
            object.debug_rect = { x, y, object.width, object.height }
        end
    else
        Draw.setColor(Mod.libs["magical-glass"] and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() and (Game.battle.encounter.karma_mode and MG_PALETTE["player_karma_health_bg"] or MG_PALETTE["player_health_bg"]) or (Mod.libs["magical-glass"] and Game.battle.encounter.karma_mode and MG_PALETTE["player_karma_health_bg_dark"] or PALETTE["action_health_bg"])) -- Compatibility with 'magical-glass' Library.
        love.graphics.rectangle("fill", 128, 22 - self.actbox.data_offset, 76, 9)

        local health = (self.actbox.battler.chara:getHealth() / self.actbox.battler.chara:getStat("health")) * 76
        local karma_health
        if Mod.libs["magical-glass"] then
            karma_health = ((self.actbox.battler.chara:getHealth() - self.actbox.battler.karma) / self.actbox.battler.chara:getStat("health")) * 76
        end

        if health > 0 then
            if Mod.libs["magical-glass"] then
                if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
                    Draw.setColor(MG_PALETTE["player_karma_health"])
                else
                    Draw.setColor(MG_PALETTE["player_karma_health_dark"])
                end
                love.graphics.rectangle("fill", 128, 22 - self.actbox.data_offset, math.min(math.ceil(health), 76), 9)
            end
            if Mod.libs["magical-glass"] and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then -- Compatibility with 'magical-glass' Library.
                Draw.setColor(MG_PALETTE["player_health"])
            else
                Draw.setColor(self.actbox.battler.chara:getColor())
            end
            love.graphics.rectangle("fill", 128, 22 - self.actbox.data_offset, math.min(math.ceil(Mod.libs["magical-glass"] and karma_health or health), 76), 9)
        end

        local color = PALETTE["action_health_text"]
        if health <= 0 then
            color = PALETTE["action_health_text_down"]
        elseif Mod.libs["magical-glass"] and self.actbox.battler.karma > 0 then
            color = MG_PALETTE["player_karma_text"]
        elseif (self.actbox.battler.chara:getHealth() <= (self.actbox.battler.chara:getStat("health") / 4)) then
            color = PALETTE["action_health_text_low"]
        else
            color = PALETTE["action_health_text"]
        end

        local health_offset = 0
        health_offset = (#tostring(self.actbox.battler.chara:getHealth()) - 1) * 8

        Draw.setColor(color)
        love.graphics.setFont(self.font)
        love.graphics.print(self.actbox.battler.chara:getHealth(), 152 - health_offset, 9 - self.actbox.data_offset)
        Draw.setColor(PALETTE["action_health_text"])
        love.graphics.print("/", 161, 9 - self.actbox.data_offset)
        local string_width = self.font:getWidth(tostring(self.actbox.battler.chara:getStat("health")))
        Draw.setColor(color)
        love.graphics.print(self.actbox.battler.chara:getStat("health"), 205 - string_width, 9 - self.actbox.data_offset)
    end

    Object.draw(self)
end

return ActionBoxDisplay