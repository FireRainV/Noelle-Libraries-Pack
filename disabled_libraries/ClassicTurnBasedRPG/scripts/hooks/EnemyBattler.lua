local EnemyBattler, super = HookSystem.hookScript(EnemyBattler)

-- The enemy classic attack function
function EnemyBattler:onAttack(cutscene)
    local miss = MathUtils.random(0, 100) < 10
    local critical_hit = not miss and MathUtils.random(0, 100) < 12.5
    local extra_text = ""
    if not miss then
        local battlers = Game.battle:hurt(self.attack * (Game:isLight() and 1 or 5) * (critical_hit and 2 or 1), false, self.current_target)
        if critical_hit then
            extra_text = extra_text .. "\n* A critical hit!"
            Assets.stopAndPlaySound("criticalswing")

            for i = 1, 3 do
                local sx, sy = self:getRelativePos(0, 0)
                local sparkle = Sprite("effects/criticalswing/sparkle", sx - MathUtils.random(50), sy + 30 + MathUtils.random(30))
                sparkle:play(4 / 30, true)
                sparkle:setScale(2)
                sparkle.layer = BATTLE_LAYERS["above_battlers"]
                sparkle.physics.speed_x = -MathUtils.random(2, 6)
                sparkle.physics.friction = -0.25
                sparkle:fadeOutSpeedAndRemove()
                Game.battle:addChild(sparkle)
            end
        end
        if #battlers == 1 then
            cutscene:text(string.format("* %s attacked %s!" .. extra_text, self.name, battlers[1].chara:getName()))
        else
            cutscene:text(string.format("* %s attacked!" .. extra_text, self.name))
        end
    else
        cutscene:text(string.format("* %s missed!" .. extra_text, self.name))
    end

    return false
end

return EnemyBattler