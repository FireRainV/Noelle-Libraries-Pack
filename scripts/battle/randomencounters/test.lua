local EncGroup, super = Class(RandomEncounter, "test")

function EncGroup:init()
    super.init(self)

    self.population = 5
    self.use_population_factor = true

    -- Table with the encounters that can be triggered by this random encounter
    self.encounters = { "froggit", "froggit2" }
    self.light = true
end

return EncGroup