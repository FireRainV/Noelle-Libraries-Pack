local Character, super = HookSystem.hookScript(Character)

-- Update the equipment for party members in the overworld
function Character:update()
    super.update(self)

    local party_member = self:getPartyMember()
    if party_member then
        for i = 2, Kristal.getLibConfig("extra_equip_slots", "max_weapons") do
            if party_member:getWeapon(i) then
                party_member:getWeapon(i):onWorldUpdate(self)
            end
        end
        for i = 3, Kristal.getLibConfig("extra_equip_slots", "max_armors") do
            if party_member:getArmor(i) then
                party_member:getArmor(i):onWorldUpdate(self)
            end
        end
    end
end

return Character