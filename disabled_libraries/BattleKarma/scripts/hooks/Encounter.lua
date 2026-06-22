local Encounter, super = HookSystem.hookScript(Encounter)

function Encounter:init()
    super.init(self)

    -- Whether Karma (KR) UI changes will appear.
    self.karma_mode = false
end

return Encounter