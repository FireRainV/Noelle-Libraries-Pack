local DarkEquipMenu, super = HookSystem.hookScript(DarkEquipMenu)

function DarkEquipMenu:init()
    super.init(self)

    if #Game.party <= 3 then return end

    if not Kristal.getLibConfig("moreparty", "three_per_row") and #Game.party >= 4 or Mod.libs["moreparty"]:getTwoByTwo(#Game.party) then
        self.party:setPosition(-15, 48)
    end

    if not Kristal.getLibConfig("moreparty", "scroller") and #Game.party > Mod.libs["moreparty"]:getPartyPerRowAmount() then
        self.party:setScale(0.5)
    end
end

return DarkEquipMenu