local LightBullet, super = Class(Bullet)

function LightBullet:init(x, y, texture)
    super.init(self, x, y, texture)

    -- 'alt' is whether to only remove the bullet if you took damage from it (colliding with it while not having invulnerability frames)
    self.destroy_on_hit = "alt"
    -- Whether the bullet can damage you even when it's your turn (similar to Sans' menu bones)
    self.can_collide_while_not_defending = false

    self.layer = LIGHT_BATTLE_LAYERS["bullets"]
end

function LightBullet:onCollide(soul)
    if Game.battle:getState() == "DEFENDING" or self.can_collide_while_not_defending then
        super.onCollide(self, soul)
    end
end

return LightBullet