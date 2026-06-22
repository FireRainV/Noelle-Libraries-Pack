if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightBattle, super = HookSystem.hookScript("LightBattle")

-- Remove the limit on how many party members can be inside a battle
function LightBattle:createPartyBattlers()
    for i = 1, #Game.party do
        local battler = LightPartyBattler(Game.party[i])
        table.insert(self.party, battler)
    end
end

-- Allow an infinte amount of short act text instead of just 3
function LightBattle:shortActText(text)
    local advances = 3 -- initial override so we can run it
    local function displayShortActText()
        advances = advances + 1
        if advances >= 3 then
            self.battle_ui:clearEncounterText()
            advances = 0

            local text_1, text_2, text_3 = table.remove(text, 1), table.remove(text, 1), table.remove(text, 1)
            local text_exhausted = not (text_1 and text_2 and text_3) or #text == 0
            local advance_to_next = not text_exhausted and displayShortActText
            self.battle_ui.short_act_text_1:setText(text_1 and "[voice:battle][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. text_1 or "", advance_to_next)
            self.battle_ui.short_act_text_2:setText(text_2 and "[voice:battle][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. text_2 or "", advance_to_next)
            self.battle_ui.short_act_text_3:setText(text_3 and "[voice:battle][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. text_3 or "", advance_to_next)

            if text_exhausted then
                self:setState("SHORTACTTEXT")
            end
        end
    end

    displayShortActText()
end

function LightBattle:update()
    super.update(self)

    -- Hide the action boxes (where the buttons are displayed) during the enemy turn to show the rest of the party's HP
    if #self.party > Mod.libs["moreparty"]:getPartyPerRowAmount(true) and TableUtils.contains({ "DEFENDING", "DEFENDINGBEGIN", "DEFENDINGEND", "ENEMYDIALOGUE" }, self.state) then
        for _, action_box in ipairs(self.battle_ui.action_boxes) do
            action_box.visible = false
        end
    else
        for _, action_box in ipairs(self.battle_ui.action_boxes) do
            action_box.visible = true
        end
    end
end

return LightBattle