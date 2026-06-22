local Spikes, super = Class(Event)

function Spikes:init(data)
    super.init(self, data.center_x, data.center_y, data.width, data.height)

    self.hurt_timer = 0
    self.damage = 1
    self:setOrigin(0.5, 0.5)
    self:setSprite("objects/spikes")

    self.collider = Hitbox(self, self.sprite.x + self.sprite.width / 2, self.sprite.y + self.sprite.height / 2, self.sprite.width, self.sprite.height)
end

function Spikes:update()

end

function Spikes:onCollide(player)
    if player == Game.world.player then
        self.hurt_timer = self.hurt_timer + DT
        if self.hurt_timer >= 1 then
            Game.world:hurtParty(self.damage)
            self.hurt_timer = 0
        end
    end
end

function Spikes:onExit(player)
    if player == Game.world.player then
        self.hurt_timer = 0
    end
end

return Spikes