local spell, super = Class(Spell, "x_slash")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "X-Slash"
    -- Name displayed when cast (optional)
    self.cast_name = "X-Slash"
    -- Battle description
    self.effect = "Physical\ndamage"
    -- Menu description
    self.description = "Deals large Physical damage to\none enemy."
    -- Check description
    self.check = "Deals large\nPhysical damage to one enemy."

    -- TP cost
    self.cost = 25

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "enemy"

    -- Tags that apply to this spell
    self.tags = { "damage" }

    -- Number of attacks
    self.attacks_count = 2
end

function spell:getCastMessage(user, target)
    return "* " .. user.chara:getName() .. " used " .. self:getCastName() .. "!"
end

function spell:onCast(user, target)
    local damage = MathUtils.round(target:getAttackDamage(0, user, 150) * 1.25)
    if damage < 0 then
        damage = 0
    end

    local counter = 0
    Game.battle.timer:everyInstant(0.5, function()
        counter = counter + 1

        local attacksprite = user.chara:getWeapon() and user.chara:getWeapon():getAttackSprite(user, target, 150) or user.chara:getAttackSprite()
        local attackpitch  = user.chara:getWeapon() and user.chara:getWeapon():getAttackPitch(user, target, 150) or user.chara:getAttackPitch()
        local dmg_sprite = Sprite(attacksprite or "effects/attack/cut")

        Assets.playSound("scytheburst")
        Assets.playSound("criticalswing", 1.2, MathUtils.clamp(((counter % 2) == 1 and 1.3 or 1) + (attackpitch - 1), 0.3, 2.3))

        user.overlay_sprite:setAnimation("battle/attack")
        user:toggleOverlay(true)

        local afterimage = { AfterImage(user, 0.5), AfterImage(user, 0.6) }
        user:toggleOverlay(false)
        user:setAnimation("battle/attack", function()
            if counter == self.attacks_count then
                user:setAnimation("battle/idle")
                Game.battle:finishAction()
            end
        end)

        user:flash()

        dmg_sprite:setOrigin(0.5, 0.5)
        dmg_sprite:setScale(2.5 * ((counter % 2) == 1 and 1 or -1), 2.5)

        local relative_pos_x, relative_pos_y = target:getRelativePos(target.width / 2, target.height / 2)
        dmg_sprite:setPosition(relative_pos_x + target.dmg_sprite_offset[1], relative_pos_y + target.dmg_sprite_offset[2])
        dmg_sprite.layer = target.layer + 0.01
        dmg_sprite.user_id = Game.battle:getPartyIndex(user.chara.id) or nil
        table.insert(target.dmg_sprites, dmg_sprite)

        local dmg_sprite_speed = 1 / 15
        if attacksprite == "effects/attack/shard" then
            -- Ugly hardcoding BlackShard animation speed accuracy for now
            dmg_sprite_speed = 1 / 10
        end
        dmg_sprite:play(dmg_sprite_speed, false, function(s) s:remove(); TableUtils.removeValue(target.dmg_sprites, dmg_sprite) end)
        target.parent:addChild(dmg_sprite)

        for i, image in ipairs(afterimage) do
            image.physics.speed_x = 2.5 * i
            image:setLayer(afterimage[1].layer - (i - 1))
            Game.battle:addChild(image)
        end

        target:hurt(damage, user)
    end, self.attacks_count)

    return false
end

function spell:getLightCastMessage(user, target)
    return "* " .. user.chara:getNameOrYou() .. " used " .. self:getCastName() .. "!"
end

function spell:onLightCast(user, target)
    local damage = MathUtils.round(target:getAttackDamage(0, user, 0, 1, true, false) * 1.25)
    if damage < 0 then
        damage = 0
    end

    local counter = 0
    Game.battle.timer:everyInstant(0.5, function()
        counter = counter + 1

        local attacksprite = user.chara:getWeapon() and user.chara:getWeapon():getAttackSprite(user, target, 150) or user.chara:getAttackSprite()
        local attackpitch  = user.chara:getWeapon() and user.chara:getWeapon():getAttackPitch(user, target, 150) or user.chara:getAttackPitch()
        local dmg_sprite = Sprite(attacksprite or "effects/attack/cut")

        Assets.playSound("scytheburst")
        Assets.playSound("criticalswing", 1.2, MathUtils.clamp(((counter % 2) == 1 and 1.3 or 1) + (attackpitch - 1), 0.3, 2.3))

        dmg_sprite:setOrigin(0.5, 0.5)
        dmg_sprite:setScale(2.5 * ((counter % 2) == 1 and 1 or -1), 2.5)

        local relative_pos_x, relative_pos_y = target:getRelativePos(target.width / 2, target.height / 2)
        dmg_sprite:setPosition(relative_pos_x + target.dmg_sprite_offset[1], relative_pos_y + target.dmg_sprite_offset[2])
        dmg_sprite.layer = target.layer + 0.01
        dmg_sprite.user_id = Game.battle:getPartyIndex(user.chara.id) or nil
        table.insert(target.dmg_sprites, dmg_sprite)

        local dmg_sprite_speed = 1 / 15
        if attacksprite == "effects/attack/shard" then
            -- Ugly hardcoding BlackShard animation speed accuracy for now
            dmg_sprite_speed = 1 / 10
        end
        dmg_sprite:play(dmg_sprite_speed, false, function(s) s:remove(); TableUtils.removeValue(target.dmg_sprites, dmg_sprite) end)
        target.parent:addChild(dmg_sprite)

        target:hurt(damage, user)

        if counter == self.attacks_count then
            Game.battle:finishAction()
        end
    end, self.attacks_count)

    return false
end

return spell
