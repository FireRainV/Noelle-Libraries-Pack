local Lib = {}

-- Used to prevent a crash when attacking without a weapon
function Lib:onRegisterItems()
    Lib.fallback_weapon = Registry.getItem("everybodyweapon")
end

-- Applies the new attacking system
function Lib:onBattleAction(action, action_type, battler, enemy)
    local battler_weapon = battler.chara:getWeapon() or Lib.fallback_weapon

    local attackbox
    for _, box in ipairs(Game.battle.battle_ui.attack_boxes) do
        if box.battler == battler then
            attackbox = box
            break
        end
    end

    if action_type == "ATTACK" or action_type == "AUTOATTACK" then
        if action.action == "ATTACK" and attackbox.attacked then
            battler_weapon:onAttack(action, battler, enemy, attackbox.score, attackbox.bolts, attackbox.close)
        elseif action.action == "AUTOATTACK" then
            battler_weapon:onAttack(action, battler, enemy, 150, 1, 0)
        end

        return false
    end
end

return Lib