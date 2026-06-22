local bullet, super = Class(LightBullet)

function bullet:init(x, y)
    super.init(self, x, y, "bullets/froggit/bulletsm")

    self.remove_on_arena_collision = true

    self:setScale(1, 1)
    self:setOrigin(0.5, 0.5)
    self:setHitbox(2, 2, 3, 3)

    local angle = MathUtils.angle(x, y, Game.battle.soul.x + 2, Game.battle.soul.y + 2)
    self.physics.direction = angle
    self.physics.speed = 2.5
end

return bullet