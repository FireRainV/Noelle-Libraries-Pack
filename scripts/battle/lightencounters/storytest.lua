local encounter, super = Class(LightEncounter)

function encounter:init()
    super.init(self)

    self.music = false

    self.event = true
    self.background = false

    self.no_end_message = true

    self.soul_offset = { -4, 0 }

    -- Add the dummy enemy to the encounter
    self:addEnemy("froggit", SCREEN_WIDTH / 2, 246)
end

function encounter:getDialogueCutscene()
    return function(cutscene)
        cutscene:wait(1)
        local dialogue = "[speed:0.5][voice:none]Ribbit.[wait:60]\nKris is nice."
        local x = Game.battle.enemies[1].x + Game.battle.enemies[1].width * 2
        local bubble = LightSpeechBubble(dialogue, x, 78, { style = "above" })
        Game.battle:addChild(bubble)
        bubble:setSkippable(false)
        bubble:setCallback(function()
            bubble:remove()
            Game.battle:setState("TRANSITIONOUT")
            self:onBattleEnd()
        end)
    end
end

return encounter