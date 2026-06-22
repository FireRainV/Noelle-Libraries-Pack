if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightPartyBattler, super = HookSystem.hookScript("LightPartyBattler")

-- Update the equipment for party members in battles
function LightPartyBattler:update()
    super.update(self)

    for i = 2, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
        if self.chara:getWeapon(i) then
            self.chara:getWeapon(i):onLightBattleUpdate(self)
        end
    end
    for i = 3, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
        if self.chara:getArmor(i) then
            self.chara:getArmor(i):onLightBattleUpdate(self)
        end
    end
end

return LightPartyBattler