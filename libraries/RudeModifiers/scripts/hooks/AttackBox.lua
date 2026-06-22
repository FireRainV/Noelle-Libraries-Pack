local AttackBox, super = HookSystem.hookScript(AttackBox)

function AttackBox:init(battler, offset, index, x, y)
    super.init(self, battler, offset, index, x, y)

    self.bolt:remove() -- Remove the original bolt

    self.battler = battler
    self.weapon = battler.chara:getWeapon() or Mod.libs["rude_modifiers"].fallback_weapon

    local bolt_offset = (battler.chara:getWeapon() and battler.chara:getWeapon():getBoltOffset()) or 0
    local bolt_speed  = (battler.chara:getWeapon() and battler.chara:getWeapon():getBoltSpeed())  or self.BOLTSPEED
    local bolt_count  = (battler.chara:getWeapon() and battler.chara:getWeapon():getBoltCount())  or 1

    self.offset = offset + bolt_offset
    self.index = index

    self.bolt_target = 80 + 2
    self.bolt_start_x = self.bolt_target + (self.offset * bolt_speed)

    self.bolts = {}
    self.score = 0

    for i = 1, bolt_count do
        local bolt

        if i == 1 then
            bolt = AttackBar(self.bolt_start_x, 0, 6, 38)
        else
            local next_bolt_x
            local variance = self.weapon:getMultiboltVariance()
            if type(variance) == "table" then
                local var_index = variance[i - 1] and (i - 1) or #variance
                if type(variance[var_index]) == "number" then
                    next_bolt_x = variance[var_index]
                elseif type(variance[var_index]) == "table" then
                    next_bolt_x = TableUtils.pick(variance[var_index])
                else
                    error("self.multibolt_variance must either be an integer, a table populated with integers, or a table of tables populated with integers.")
                end
            elseif type(variance) == "number" then
                next_bolt_x = variance
            else
                error("self.multibolt_variance must be either a table or a number value.")
            end

            bolt = AttackBar(self.bolts[i - 1].x + next_bolt_x, 0, 6, 38)
        end

        bolt.layer = 1
        bolt.target_magnet = 0 -- Used for acceleration bolts to stick the bolt to the target for 1 frame (1 / 30)
        if #Game.battle.party > 3 then -- MoreParty support
            bolt.height = math.floor(112 / #Game.battle.party)
        end
        table.insert(self.bolts, bolt)
        self:addChild(bolt)
    end
end

function AttackBox:getClose()
    local close = self.bolts[1].x - self.bolt_target - 2

    local bolt_speed = (self.battler.chara:getWeapon() and self.battler.chara:getWeapon():getBoltSpeed()) or self.BOLTSPEED

    if bolt_speed < 8 and self.bolts[1].x <= self.bolt_target + 10 then
        return close / 8 -- Fixes an issue with slow moving bolts being unable to crit consistently
    else
        return close / bolt_speed
    end
end

function AttackBox:hit()
    local close = self:getClose()
    local equip = self.battler.chara:getWeapon() or Mod.libs["rude_modifiers"].fallback_weapon
    return equip:onHit(self.battler, self.score, self.bolts, close)
end

function AttackBox:miss()
    local close = self:getClose()
    local equip = self.battler.chara:getWeapon() or Mod.libs["rude_modifiers"].fallback_weapon
    return equip:onWeaponMiss(self.battler, self.score, self.bolts, close)
end

-- Bolts movement
function AttackBox:update()
    local attacked = self.attacked
    self.attacked = true

    super.update(self)

    self.attacked = attacked

    if not self.attacked then
        self.afterimage_timer = self.afterimage_timer + DTMULT / 2

        local bolt_speed = (self.battler.chara:getWeapon() and self.battler.chara:getWeapon():getBoltSpeed()) or self.BOLTSPEED
        local bolt_accel = (self.battler.chara:getWeapon() and self.battler.chara:getWeapon():getBoltAcceleration()) or 0

        local acceleration = (bolt_accel * (bolt_speed / 8)) / 10

        for _, bolt in ipairs(self.bolts) do
            if acceleration > 0 then
                if bolt.x <= 84 + bolt_speed + DTMULT and bolt.target_magnet < 1 then
                    if not bolt.last_speed then
                        bolt.last_speed = bolt.physics.speed_x
                    end
                    bolt:resetPhysics()
                    bolt.x = 84
                    bolt.target_magnet = bolt.target_magnet + DTMULT
                else
                    if bolt.last_speed then
                        bolt.physics.speed_x = bolt.last_speed
                        bolt.last_speed = nil
                    end
                    bolt.physics.gravity = acceleration
                    bolt.physics.gravity_direction = math.pi
                end
            else
                bolt:move(-(bolt_speed) * DTMULT, 0)
            end
        end

        while math.floor(self.afterimage_timer) > self.afterimage_count do
            self.afterimage_count = self.afterimage_count + 1
            for _, bolt in ipairs(self.bolts) do
                local afterimg = AttackBar(bolt.x, 0, 6, #Game.battle.party > 3 and math.floor(112 / #Game.battle.party) or 38)
                afterimg.layer = 3
                afterimg.alpha = 0.4
                afterimg:fadeOutSpeedAndRemove()
                self:addChild(afterimg)
            end
        end
    end
end

return AttackBox