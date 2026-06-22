if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightSoul, super = HookSystem.hookScript("LightSoul")

-- Movement
function LightSoul:doMovement()
    if not self.index then
        super.doMovement(self)
    else
        local speed = self.speed

        -- Do speed calculations here if required.

        if self.allow_focus then
            if Input.down("p" .. self.index + 1 .. "_cancel") then
                speed = speed / 2
            end -- Focus mode.
        end

        local move_x, move_y = 0, 0

        -- Keyboard input:
        if Input.down("p" .. self.index + 1 .. "_left")  then move_x = move_x - 1 end
        if Input.down("p" .. self.index + 1 .. "_right") then move_x = move_x + 1 end
        if Input.down("p" .. self.index + 1 .. "_up")    then move_y = move_y - 1 end
        if Input.down("p" .. self.index + 1 .. "_down")  then move_y = move_y + 1 end

        self.moving_x = move_x
        self.moving_y = move_y

        if move_x ~= 0 or move_y ~= 0 then
            if not self:move(move_x, move_y, speed * DTMULT) then
                self.moving_x = 0
                self.moving_y = 0
            end
        end
    end
end

-- Hurt the party member that the player controls if they take damage (only if the bullet target is "ANY")
-- If the party member is already down, then target randomly
function LightSoul:onDamage(bullet, amount)
    super.onDamage(self, bullet, amount)

    if bullet:getTarget() == "ANY" and (not self.index or Game.battle.party[self.index + 1]) then
        if not self.index then
            if not Game.battle.party[1].is_down then
                Game.battle.party[1]:hurt(amount)
                return Game.battle.party[1]
            else
                Game.battle:hurt(amount, false, bullet:getTarget())
            end
        else
            if not Game.battle.party[self.index + 1].is_down then
                Game.battle.party[self.index + 1]:hurt(amount)
                return Game.battle.party[self.index + 1]
            else
                Game.battle:hurt(amount, false, bullet:getTarget())
            end
        end
    else
        Game.battle:hurt(amount, false, bullet:getTarget())
    end

    return bullet:getTarget()
end

return LightSoul