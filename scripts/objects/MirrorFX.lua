---@class MirrorFX : FXBase
---@overload fun(...) : MirrorFX
local MirrorFX, super = Class(FXBase)

function MirrorFX:init(strength, priority)
    super.init(self, priority)

    self.strength = strength or 0.6
end

function MirrorFX:isActive()
    return super.isActive(self) and self.strength > 0
end

function MirrorFX:draw(texture)
    Draw.drawCanvas(texture)

    local ox, oy, ow, oh = self:getObjectBounds()

    Draw.setColor(1, 1, 1, self.strength)

    Draw.draw(texture,
        ox,
        oy + oh + 2,
        0,
        1,
        -1,
        ox,
        oy + oh
    )
end

return MirrorFX