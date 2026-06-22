local Battle, super = HookSystem.hookScript(Battle)

function Battle:postInit(state, encounter)
    super.postInit(self, state, encounter)

    self.enemy_tension_bar = EnemyTensionBar(SCREEN_WIDTH + 32, 40, true)
    self:addChild(self.enemy_tension_bar)
end

function Battle:showUI()
    super.showUI(self)

    if self.enemy_tension_bar and self.encounter.enemy_tension_bar_on_start then
        self.enemy_tension_bar:show()
    end
end

function Battle:onStateChange(old, new)
    if new == "VICTORY" then
        self.enemy_tension_bar:hide()
    end

    super.onStateChange(self, old, new)
end

return Battle