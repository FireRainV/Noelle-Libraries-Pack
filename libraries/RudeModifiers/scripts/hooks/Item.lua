local Item, super = HookSystem.hookScript(Item)

function Item:init()
    super.init(self)

    self.bolt_count = nil -- The amount of bolts (default: 1)
    self.bolt_speed = nil -- The speed of the bolts (default: 8)
    self.bolt_offset = nil -- The spawn offset of the bolts (default: 0)
    self.bolt_acceleration = nil -- Bolts acceleration speed [also affected by 'self.bolt_speed'] (default: 0)
    self.multibolt_variance = nil -- Distance between each bolt [can be a table to specify distance for each bolt { can also be a nested table to randomly choose the distance }] (default: 80)
end

function Item:getBoltCount()
    return self.bolt_count or 1
end

function Item:getBoltSpeed()
    return self.bolt_speed or AttackBox.BOLTSPEED
end

function Item:getBoltOffset()
    return self.bolt_offset or 0
end

function Item:getBoltAcceleration()
    return self.bolt_acceleration or 0
end

function Item:getMultiboltVariance()
    return self.multibolt_variance or 80
end

function Item:onHit(battler, score, bolts, close)
    local attackbox
    for _, box in ipairs(Game.battle.battle_ui.attack_boxes) do
        if box.battler == battler then
            attackbox = box
            break
        end
    end

    local bolt = bolts[1]

    attackbox.score = attackbox.score + self:evaluateHit(battler, close)
    bolt:resetPhysics()
    self:onBoltBurst(battler, score, bolts, close)
    table.remove(bolts, 1)

    return self:checkAttackEnd(battler, attackbox.score, bolts, close)
end

function Item:onAttack(action, battler, enemy, score, bolts, close)
    local attacksound = battler.chara:getWeapon() and battler.chara:getWeapon():getAttackSound(battler, enemy, action.points) or battler.chara:getAttackSound()
    local attackpitch  = battler.chara:getWeapon() and battler.chara:getWeapon():getAttackPitch(battler, enemy, action.points) or battler.chara:getAttackPitch()
    local src = Assets.stopAndPlaySound(attacksound or "laz_c")
    assert(src, "Attempted to play non-existent attack sound \"" .. (attacksound or "laz_c") .. "\" for " .. battler.chara:getName())
    src:setPitch(attackpitch or 1)

    Game.battle.actions_done_timer = 1.2

    local crit = (self.crit == nil and action.points >= 150 or self.crit == true) and action.action ~= "AUTOATTACK"
    if crit then
        Assets.stopAndPlaySound("criticalswing")

        for i = 1, 3 do
            local sx, sy = battler:getRelativePos(battler.width, 0)
            local sparkle = Sprite("effects/criticalswing/sparkle", sx + MathUtils.random(50), sy + 30 + MathUtils.random(30))
            sparkle:play(4 / 30, true)
            sparkle:setScale(2)
            sparkle.layer = BATTLE_LAYERS["above_battlers"]
            sparkle.physics.speed_x = MathUtils.random(2, 6)
            sparkle.physics.friction = -0.25
            sparkle:fadeOutSpeedAndRemove()
            Game.battle:addChild(sparkle)
        end
    end

    self.crit = nil

    battler:setAnimation("battle/attack", function()
        action.icon = nil

        if action.target and action.target.done_state then
            enemy = Game.battle:retargetEnemy()
            action.target = enemy
            if not enemy then
                Game.battle.cancel_attack = true
                Game.battle:finishAction(action)
                return
            end
        end

        local damage = MathUtils.round(enemy:getAttackDamage(action.damage or 0, battler, action.points or 0))
        if damage < 0 then
            damage = 0
        end

        if damage > 0 then
            local bolt_count = (battler.chara:getWeapon() and battler.chara:getWeapon():getBoltCount()) or 1
            Game:giveTension(MathUtils.round(enemy:getAttackTension(Game.battle:getActionBy(battler).action == "AUTOATTACK" and action.points or score / bolt_count or 0)))

            local attacksprite = battler.chara:getWeapon() and battler.chara:getWeapon():getAttackSprite(battler, enemy, action.points) or battler.chara:getAttackSprite()
            local dmg_sprite = Sprite(attacksprite or "effects/attack/cut")
            dmg_sprite:setOrigin(0.5, 0.5)
            if crit then
                dmg_sprite:setScale(2.5, 2.5)
            else
                dmg_sprite:setScale(2, 2)
            end
            local relative_pos_x, relative_pos_y = enemy:getRelativePos(enemy.width / 2, enemy.height / 2)
            dmg_sprite:setPosition(relative_pos_x + enemy.dmg_sprite_offset[1], relative_pos_y + enemy.dmg_sprite_offset[2])
            dmg_sprite.layer = enemy.layer + 0.01
            dmg_sprite.battler_id = action.character_id or nil
            table.insert(enemy.dmg_sprites, dmg_sprite)
            local dmg_anim_speed = 1 / 15
            if attacksprite == "effects/attack/shard" then
                -- Ugly hardcoding BlackShard animation speed accuracy for now
                dmg_anim_speed = 1 / 10
            end
            dmg_sprite:play(dmg_anim_speed, false, function(s) s:remove(); TableUtils.removeValue(enemy.dmg_sprites, dmg_sprite) end) -- Remove itself and Remove the dmg_sprite from the enemy's dmg_sprite table when its removed
            enemy.parent:addChild(dmg_sprite)

            local sound = enemy:getDamageSound() or "damage"
            if sound and type(sound) == "string" then
                Assets.stopAndPlaySound(sound)
            end
            enemy:hurt(damage, battler)

            -- TODO: Call this even if damage is 0, will be a breaking change
            battler.chara:onAttackHit(enemy, damage)
        else
            enemy:hurt(0, battler, nil, nil, nil, action.points ~= 0)
        end

        for _, item in ipairs(battler.chara:getEquipment()) do
            item:onAttackHit(battler, enemy, damage)
        end

        Game.battle:finishAction(action)

        TableUtils.removeValue(Game.battle.normal_attackers, battler)
        TableUtils.removeValue(Game.battle.auto_attackers, battler)

        if not Game.battle:retargetEnemy() then
            Game.battle.cancel_attack = true
        elseif #Game.battle.normal_attackers == 0 and #Game.battle.auto_attackers > 0 then
            local next_attacker = Game.battle.auto_attackers[1]

            local next_action = Game.battle:getActionBy(next_attacker, true)
            if next_action then
                Game.battle:beginAction(next_action)
                Game.battle:processAction(next_action)
            end
        end
    end)
end

function Item:onWeaponMiss(battler, score, bolts, close)
    local attackbox
    for _, box in ipairs(Game.battle.battle_ui.attack_boxes) do
        if box.battler == battler then
            attackbox = box
            break
        end
    end

    local bolt = bolts[1]
    bolt:resetPhysics()
    bolt:remove()
    table.remove(bolts, 1)

    return self:checkAttackEnd(battler, attackbox.score, bolts, close)
end

function Item:checkAttackEnd(battler, score, bolts, close)
    local attackbox
    for _, box in ipairs(Game.battle.battle_ui.attack_boxes) do
        if box.battler == battler then
            attackbox = box
            break
        end
    end

    if #bolts == 0 then
        attackbox.attacked = true
        return self:evaluateScore(battler, score, bolts, close)
    end
end

function Item:onBoltBurst(battler, score, bolts, close)
    local bolt = bolts[1]

    bolt:burst()
    bolt.layer = 1
    bolt:setPosition(bolt:getRelativePos(0, 0, Game.battle.battle_ui))
    bolt:setParent(Game.battle.battle_ui)

    local bolt_count = (battler.chara:getWeapon() and battler.chara:getWeapon():getBoltCount()) or 1

    if bolt_count > 1 then
        local p = math.abs(close)
        if p <= 0.25 then
            Assets.stopAndPlaySound("victor")
            bolt:setColor(1, 1, 0)
            bolt.burst_speed = 0.2
        elseif p > 2.6 then
            bolt:setColor(battler.chara:getDamageColor())
        else
            Assets.stopAndPlaySound("hit")
        end
    else
        local p = math.abs(close)

        if p <= 0.25 then
            bolt:setColor(1, 1, 0)
            bolt.burst_speed = 0.2
        elseif p > 2.6 then
            bolt:setColor(battler.chara:getDamageColor())
        end
    end
end

function Item:evaluateHit(battler, close)
    local p = math.abs(close)

    if p <= 0.25 then
        return 150
    elseif p <= 1.3 then
        return 120
    elseif p <= 2.6 then
        return 110
    else
        return 100 - (p * 2)
    end
end

-- Not 100% accurate damage for multi-bolt, but pretty close
function Item:evaluateScore(battler, score, bolts, close)
    local bolt_count = (battler.chara:getWeapon() and battler.chara:getWeapon():getBoltCount()) or 1

    if bolt_count > 1 then
        self.crit = false
        local perfect_score = 150 * bolt_count
        local increased = bolt_count >= 4

        if perfect_score - score <= 0 then
            self.crit = true
            Assets.stopAndPlaySound("saber3")
            return increased and 422 or 187.5
        elseif perfect_score - score <= 30 then
            self.crit = true
            Assets.stopAndPlaySound("saber3")
            return increased and 224 or 176
        elseif perfect_score - score <= 60 then
            return increased and 162 or 153.5
        elseif perfect_score - score <= 90 then
            return increased and 136.5 or 131
        else
            return MathUtils.round(score / bolt_count / (increased and 0.9375 or 1.135))
        end
    else
        return score
    end
end

return Item