local Toriel, super = Class(LightEncounter)

function Toriel:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Light Actor Test."

    -- Add the toriel enemy to the encounter
    self:addEnemy("toriel", SCREEN_WIDTH / 2 + 2, 246)

    self.music = nil
end

function Toriel:createBackground()
    local background = super.createBackground(self)
    background:setSprite("ui/lightbattle/backgrounds/split")
    return background
end

return Toriel