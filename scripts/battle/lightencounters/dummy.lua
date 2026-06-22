local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* You encountered the Dummy...?"

    self.music = nil
    -- self.music = Game:isLight() and "prebattle_ut" or "prebattle_dt"

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy")

    self.wave_mode = false
end

function Dummy:createBackground()
    if Game.battle.background then
        Game.battle.background:remove()
    end
    if self.wave_mode then
        Game.battle.background = Game.battle:addChild(WaveLightBattleBackground())
    else
        Game.battle.background = super.createBackground(self)
    end
    return Game.battle.background
end

return Dummy