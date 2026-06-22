local PartyBattler, super = HookSystem.hookScript(PartyBattler)

-- Update the equipment for party members in battles
function PartyBattler:update()
    super.update(self)

    for i = 2, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        if self.chara:getWeapon(i) then
            self.chara:getWeapon(i):onBattleUpdate(self)
        end
    end
    for i = 3, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        if self.chara:getArmor(i) then
            self.chara:getArmor(i):onBattleUpdate(self)
        end
    end
end

return PartyBattler