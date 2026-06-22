local Encounter, super = HookSystem.hookScript(Encounter)

function Encounter:init()
    super.init(self)

    -- Manual control on whether the tension bar will be shown when the battle starts
    self.enemy_tension_bar_on_start = false
end

return Encounter