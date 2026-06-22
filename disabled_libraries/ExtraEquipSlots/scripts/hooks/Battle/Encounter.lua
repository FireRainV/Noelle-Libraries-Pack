local Encounter, super = HookSystem.hookScript(Encounter)

-- Select a random equipped weapon that will be used when attacking
function Encounter:onTurnStart()
    for _, battler in ipairs(Game.battle.party) do
        battler.current_battle_weapon = TableUtils.pick(battler.chara.equipped.weapon)
    end

    super.onTurnStart(self)
end

return Encounter