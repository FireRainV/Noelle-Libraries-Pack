local BigShot, super = Class("YellowSoulShot")

function BigShot:init(x, y, angle)
    super.init(self, x, y, angle)

    if Game.battle.soul.undertale then
        self:setSprite("effects/yellowsoul/bigshot_undertale")
        self.collider = CircleCollider(self, 30, 12, 12)
    else
        self:setSprite("effects/yellowsoul/bigshot")
        self.collider = CircleCollider(self, 30, 14, 14)
    end

    self.alpha = 0.5
    self:setScale(0.1, 2)

    if Game.battle.light then
        self.layer = LIGHT_BATTLE_LAYERS["above_bullets"]
    else
        self.layer = BATTLE_LAYERS["above_bullets"]
    end

    self.physics.speed = 9
    self.physics.friction = -0.4
    self.damage = 4
    self.big = true
end

-- Update the bigshot the longer it travels
function BigShot:update()
    self.scale_x = MathUtils.approach(self.scale_x, 1, 0.2 * DTMULT)
    self.scale_y = MathUtils.approach(self.scale_y, 1, 0.2 * DTMULT)
    self.alpha = MathUtils.approach(self.alpha, 1, 0.2 * DTMULT)

    super.update(self)
end

return BigShot