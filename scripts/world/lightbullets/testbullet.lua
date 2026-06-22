local TestBullet, super = Class(LightWorldBullet)

function TestBullet:init(x, y, flip)
    super.init(self, x, y, "bullets/smile_bullet")

    if flip then
        self.flip_x = true
        self.physics.direction = math.pi
    end

    self.physics.speed = 1
    self.physics.friction = -0.5

    self.alpha = 0
    self:fadeToSpeed(1, 0.1)

    self.start_x = x

    self.destroy_on_hit = true

    self.hazard_encounter = "hazardtest"
end

function TestBullet:update()
    if math.abs(self.x - self.start_x) >= self.world.map.tile_width * 9 then
        self:fadeOutSpeedAndRemove(0.5)
    end

    super.update(self)
end

return TestBullet