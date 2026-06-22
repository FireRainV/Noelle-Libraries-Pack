local encounter, super = Class(LightEncounter)

function encounter:init()
    super.init(self)

    self.text = "* Holy Hell!"

    self.music = Game:isLight() and "hardbattle_ut" or "hardbattle_dt"

    for i = 1, 100 do
        local frog = self:addEnemy("froggit", MathUtils.random(SCREEN_WIDTH), MathUtils.random(SCREEN_HEIGHT / 2) + 50)
        frog:addFX(ShaderFX("color", { targetColor = { MathUtils.random(), MathUtils.random(), MathUtils.random(), 1 } }))
    end

end

return encounter