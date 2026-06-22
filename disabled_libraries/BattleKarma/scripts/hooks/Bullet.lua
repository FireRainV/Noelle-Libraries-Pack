local Bullet, super = HookSystem.hookScript(Bullet)

-- Karma value for the bullet
function Bullet:init(x, y, texture)
    super.init(self, x, y, texture)

    -- The amount of karma this bullet deals
    self.karma = nil
end

function Bullet:getKarma()
    return self.karma or 0
end

function Bullet:onDamage(soul)
    local battlers = super.onDamage(self, soul)

    if self:getDamage() > 0 then
        for _, battler in ipairs(battlers) do
            battler:addKarma(self:getKarma())
        end
    end

    return battlers
end

return Bullet