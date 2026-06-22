if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightBattle, super = HookSystem.hookScript(LightBattle)

-- Don't adjust the arena when the enemies are about to do a classic attack
function LightBattle:onEnemyDialogueState()
    if #self:getActiveEnemies() > 0 and self.encounter:getEnemyAutoAttack() and not self.encounter.event then
        self.current_selecting = 0
        self.battle_ui:clearEncounterText()
        self.textbox_timer = 3 * 30
        self.use_textbox_timer = true

        for _, enemy in ipairs(self:getActiveEnemies()) do
            enemy.current_target = enemy:getTarget()
        end
        local cutscene_args = { self.encounter:getDialogueCutscene() }
        if #cutscene_args > 0 then
            self:startCutscene(TableUtils.unpack(cutscene_args)):after(function()
                self:setState("DIALOGUEEND")
            end)
        else
            local any_dialogue = false
            for _, enemy in ipairs(self:getActiveEnemies()) do
                local dialogue = enemy:getEnemyDialogue()
                if dialogue then
                    any_dialogue = true
                    local bubble = enemy:spawnSpeechBubble(dialogue, { no_sound_overlap = true })
                    if Kristal.getLibConfig("magical-glass", "undertale_text_skipping") then
                        bubble:setSkippable(false)
                    end
                    table.insert(self.enemy_dialogue, bubble)
                end
            end
            if not any_dialogue then
                self:setState("DIALOGUEEND")
            end
        end
    else
        super.onEnemyDialogueState(self)
    end
end

return LightBattle