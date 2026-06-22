if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightBattle, super = HookSystem.hookScript("LightBattle")

function LightBattle:postInit(state, encounter)
    super.postInit(self, state, encounter)

    self.enemy_tension_bar = LightEnemyTensionBar(SCREEN_WIDTH - 55, 54, true)
    if not self.encounter.enemy_tension_bar_on_start then
        self.enemy_tension_bar.visible = false
    end
    self:addChild(self.enemy_tension_bar)
end

return LightBattle