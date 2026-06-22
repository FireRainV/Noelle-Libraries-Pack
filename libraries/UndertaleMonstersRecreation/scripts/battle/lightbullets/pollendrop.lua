local bullet, super = Class(LightBullet)

function bullet:init(x, y)
    super.init(self, x, y, "bullets/bulletmd")

    self.remove_on_arena_collision = true

    self:setScale(1, 1)
    self:setOrigin(0.5, 0.5)
    self:setHitbox(4, 4, 5, 5)

    self.timer = 0
    self.timelimit = 10

    self.hspeed = 1.5
    self.vspeed = 1.2
    self.physics.gravity = 0.02
    self.physics.gravity_direction = math.rad(90)
end

function bullet:update()
    super.update(self)

    self.timer = self.timer + 1 * DTMULT
    self:move(self.hspeed * DTMULT, self.vspeed * DTMULT)

    if self.timer >= self.timelimit then
        self.timer = 0
        self.timelimit = 20
        self.hspeed = -self.hspeed
    end
end

return bullet