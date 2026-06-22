if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightEncounter, super = HookSystem.hookScript("LightEncounter")

function LightEncounter:init()
    super.init(self)

    -- Manual control on whether the tension bar will be shown when the battle starts
    self.enemy_tension_bar_on_start = false
end

return LightEncounter