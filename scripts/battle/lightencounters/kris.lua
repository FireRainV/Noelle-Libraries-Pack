local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Light Actor Test."

    -- Add the dummy enemy to the encounter
    self:addEnemy("kris")
end

return Dummy