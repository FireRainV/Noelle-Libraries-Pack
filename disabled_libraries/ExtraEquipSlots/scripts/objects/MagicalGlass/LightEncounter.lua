if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightEncounter, super = HookSystem.hookScript("LightEncounter")

-- Select a random equipped weapon that will be used when attacking
function LightEncounter:onTurnStart()
    for _, battler in ipairs(Game.battle.party) do
        battler.current_battle_weapon = TableUtils.pick(battler.chara.equipped.weapon)
    end

    super.onTurnStart(self)
end

return LightEncounter