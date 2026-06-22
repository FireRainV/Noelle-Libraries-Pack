local item, super = Class(LightEquipItem, "test/super_stick")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Super Stick"
    self.short_name = "SprStick"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    self.price = 200
    self.sell_price = 13

    -- Item description text (unused by light items outside of debug menu)
    self.description = "Attacks Twice!"

    -- Light world check text
    self.check = "Weapon AT 0\n* Attacks Twice!"

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.attacks_amount = 2
end

function item:onLightAttack(battler, enemy, damage, stretch)
    if damage <= 0 then
        enemy:onDodge(battler, true)
    end

    local counter = 0
    Game.battle.timer:everyInstant(stretch / 1.5, function()
        damage = damage + MathUtils.round(MathUtils.random(-5, 5))
        counter = counter + 1

        local sprite = self:startLightAttackAnimation(battler, enemy, damage, stretch, crit, nil, function()
            Game.battle.timer:after(3 / 30, function()
                self:onLightAttackHurt(battler, enemy, damage, stretch, crit, counter >= self.attacks_amount and true or false)
            end)
        end)

        sprite.rotation = math.rad(counter % 2 == 1 and -45 or 45)
    end, self.attacks_amount)

    return false
end

return item