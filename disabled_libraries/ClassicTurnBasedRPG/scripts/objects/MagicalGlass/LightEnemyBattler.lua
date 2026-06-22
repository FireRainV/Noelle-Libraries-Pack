if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightEnemyBattler, super = HookSystem.hookScript(LightEnemyBattler)

function LightEnemyBattler:onAttack(cutscene)
    local miss = MathUtils.random(0, 100) < 10
    local critical_hit = not miss and MathUtils.random(0, 100) < 12.5
    local extra_text = ""
    if not miss then
        local battlers = Game.battle:hurt(self.attack * (Game:isLight() and 1 or 5) * (critical_hit and 2 or 1), false, self.current_target)
        if critical_hit then
            extra_text = extra_text .. "\n* A critical hit!"
            Assets.stopAndPlaySound("criticalswing")
        end
        if #battlers == 1 then
            cutscene:text(string.format("* %s attacked %s!" .. extra_text, self.name, battlers[1].chara:getNameOrYou(true)))
        else
            cutscene:text(string.format("* %s attacked!" .. extra_text, self.name))
        end
    else
        cutscene:text(string.format("* %s missed!" .. extra_text, self.name))
    end

    return false
end

return LightEnemyBattler