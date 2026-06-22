local Lib = {}

-- Add sparkles when the classic party attack is enabled and the attacker managed to land a critical hit
function Lib:onBattleAction(action, action_type, battler, enemy)
    if action.action == "AUTOATTACK" and action.critical then
        Assets.stopAndPlaySound("criticalswing")

        for i = 1, 3 do
            local sx, sy = battler:getRelativePos(battler.width, 0)
            local sparkle = Sprite("effects/criticalswing/sparkle", sx + MathUtils.random(50), sy + 30 + MathUtils.random(30))
            sparkle:play(4 / 30, true)
            sparkle:setScale(2)
            sparkle.layer = BATTLE_LAYERS["above_battlers"]
            sparkle.physics.speed_x = MathUtils.random(2, 6)
            sparkle.physics.friction = -0.25
            sparkle:fadeOutSpeedAndRemove()
            Game.battle:addChild(sparkle)
        end
    end
end

return Lib