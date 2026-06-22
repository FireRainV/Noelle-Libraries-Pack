local AttackBox, super = HookSystem.hookScript(AttackBox)

-- Flash the attack box if any player pressed the confirm button
function AttackBox:update()
    super.update(self)

    local pressed_confirm = false

    for i = 2, math.min(Mod.libs["multiplayer"].max_players, #Game.battle.party) do
        if Input.pressed("p" .. i .. "_confirm") then
            pressed_confirm = true
        end
    end

    if not Game.battle.cancel_attack and pressed_confirm then
        self.flash = 1
    end
end

return AttackBox