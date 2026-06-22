local ActionBox, super = HookSystem.hookScript(ActionBox)


function ActionBox:drawActionBox()
    if #Game.battle.party <= 3 then
        super.drawActionBox(self)
        return
    end

    local x = self.realWidth
    if Game.battle.current_selecting == self.index then
        Draw.setColor(self.battler.chara:getColor())
        love.graphics.setLineWidth(2)
        love.graphics.line(1, 2, 1, 37)
        love.graphics.line(Game:getConfig("oldUIPositions") and Kristal.getLibConfig("moreparty", "three_per_row") and (x - 1) or x, 2, Game:getConfig("oldUIPositions") and Kristal.getLibConfig("moreparty", "three_per_row") and (x - 1) or x, 37)
        love.graphics.line(0, 6, x, 6)
    end
    Draw.setColor(1, 1, 1, 1)
end

-- Adjusted selection matrix size
function ActionBox:drawSelectionMatrix()
    if #Game.battle.party <= 3 then
        super.drawSelectionMatrix(self)
        return
    end

    local x = self.realWidth

    -- Draw the background of the selection matrix
    Draw.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 2, 2, x - 3, 35)

    if Game.battle.current_selecting == self.index then
        local r, g, b, a = self.battler.chara:getColor()

        for i = 0, 11 do
            local siner = self.selection_siner + (i * (10 * math.pi))

            love.graphics.setLineWidth(2)
            Draw.setColor(r, g, b, a * math.sin(siner / 60))
            if math.cos(siner / 60) < 0 then
                love.graphics.line(1 - (math.sin(siner / 60) * 30) + 30, 0, 1 - (math.sin(siner / 60) * 30) + 30, 37)
                love.graphics.line(x - 1 + (math.sin(siner / 60) * 30) - 30, 0, x - 1 + (math.sin(siner / 60) * 30) - 30, 37)
            end
        end

        Draw.setColor(1, 1, 1, 1)
    end
end

function ActionBox:draw()
    if #Game.battle.party <= 3 then
        super.draw(self)
        return
    end

    -- Cut all boxes that are out of bounds when the amount of shown party members is above the limit
    if #Game.battle.party > Mod.libs["moreparty"]:getPartyPerRowAmount(true) then
        local selected = Game.battle.current_selecting == self.index
        local animate_out = Game.battle.battle_ui.animate_out and (Game:getConfig("oldUIPositions") and 36 or 37) or 0
        local y = (selected and 256 or 288) + (Game.battle.battle_ui.y - select(2, Game.battle.battle_ui:getTransitionBounds())) - animate_out
        local h = (selected and 109 or 76) + animate_out

        love.graphics.setScissor(0, y, SCREEN_WIDTH, h)
    end

    self:drawSelectionMatrix()
    self:drawActionBox()

    Object.draw(self)

    -- Adjust battlers' name position
    if not self.name_sprite then
        local font = Assets.getFont("name")
        love.graphics.setFont(font)
        Draw.setColor(1, 1, 1, 1)

        local name = self.battler.chara:getName():upper()
        local spacing = 5 - name:len()

        local off = 0
        for i = 1, name:len() do
            local letter = name:sub(i, i)
            love.graphics.print(letter, self.box.x + (Kristal.getLibConfig("moreparty", "three_per_row") and 51 or 41) + off, self.box.y + 14 - self.data_offset - 1)
            off = off + font:getWidth(letter) + spacing
        end
    end

    -- Finish the cut
    love.graphics.setScissor()
end

-- Fix the position of the action buttons to be in the middle
function ActionBox:createButtons()
    super.createButtons(self)

    if #Game.battle.party > 3 and Kristal.getLibConfig("moreparty", "three_per_row") then
        for _, button in ipairs(self.buttons) do
            button.x = button.x + 1
        end
    end
end

-- When not using the "three_per_row" config, hide the action buttons of the non-active party members and adjust them to the middle of the action box
function ActionBox:update()
    super.update(self)

    if #Game.battle.party <= 3 or Kristal.getLibConfig("moreparty", "three_per_row") then return end

    local x = 16 + (5 - #self.buttons) * 16

    for _, button in ipairs(self.buttons) do
        button.visible = (Game.battle.current_selecting == self.index)
        button.x = x

        x = x + 32
    end
end

return ActionBox