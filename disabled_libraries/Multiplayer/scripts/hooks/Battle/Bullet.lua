local Bullet, super = HookSystem.hookScript(Bullet)

-- Set invulnerability frames for the other players' soul
function Bullet:onDamage(soul)
    local damage = self:getDamage()

    if damage > 0 then
        soul.inv_timer = self.inv_timer
        return soul:onDamage(self, damage)
    end

    return {}
end

return Bullet