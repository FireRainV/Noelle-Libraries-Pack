local WaveLightBattleBackground, super = Class(Object)

function WaveLightBattleBackground:init()
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    self.debug_select = false

    self.layer = LIGHT_BATTLE_LAYERS["background"]

    self:setParallax(0, 0)

    self.bg_siners = { 0, 15, 30, 45, 60, 75 }
end

function WaveLightBattleBackground:update()
    super.update(self)

    for i = 1, #self.bg_siners do
        self.bg_siners[i] = self.bg_siners[i] + DTMULT
    end
end

--- Returns whether the battle background is currently fading out or not.
---@return boolean
function WaveLightBattleBackground:isFading()
    return self.fading_out
end

--- Request the battle background to fade out. The background will automatically be removed once it has fully faded out.
function WaveLightBattleBackground:fadeOut()
    self.fading_out = true
end

function WaveLightBattleBackground:drawBackground()
    local offset = 0
    for i = 1, 6 do
        local sine = (math.sin(self.bg_siners[i] / 14) * 8) + 12
        Draw.setColor(0, 107 / 255, 183 / 255)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", 18 + offset, sine, 101, 118)
        love.graphics.rectangle("line", 18 + offset, sine + 118, 101, 118)
        offset = offset + 101
    end
end

function WaveLightBattleBackground:draw()
    self:drawBackground()
    Draw.setColor(1, 1, 1)
    super.draw(self)
end

return WaveLightBattleBackground
