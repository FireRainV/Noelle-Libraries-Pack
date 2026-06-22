if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local OtherUnderPlayer, super = Class("UnderPlayer")

function OtherUnderPlayer:init(chara, x, y, index)
    super.init(self, chara, x, y)

    -- The index of the other players (Player 2 will have an index of 1 for example)
    self.index = index or 0
end

-- The controls of each player
function OtherUnderPlayer:handleMovement()
    if self.can_dance and Input.down("p" .. self.index + 1 .. "_up") and Input.down("p" .. self.index + 1 .. "_down") and not self.event_collide then
        self.dancing["buttons"] = true
    else
        self.dancing["buttons"] = false
        self.dancing["collided"] = false
        self.dancing["facing"] = false
    end

    local walk_x = 0
    local walk_y = 0

    if Input.down("p" .. self.index + 1 .. "_left") then
        walk_x = walk_x - 1
    elseif Input.down("p" .. self.index + 1 .. "_right") then
        walk_x = walk_x + 1
    end

    if self.dancing["collided"] == true then
        walk_y = walk_y + 1
        self.dancing["collided"] = false
    else
        if Input.down("p" .. self.index + 1 .. "_up") then
            walk_y = walk_y - 1
        elseif Input.down("p" .. self.index + 1 .. "_down") then
            walk_y = walk_y + 1
        end
    end

    if self.dancing["buttons"] and self.last_collided_x == true then
        walk_y = 0
    end

    self.moving_x = walk_x
    self.moving_y = walk_y

    local running = (Input.down("p" .. self.index + 1 .. "_cancel") or self.force_run) and not self.force_walk
    if Kristal.Config["autoRun"] and not self.force_run and not self.force_walk then
        running = not running
    end

    local speed = self:getCurrentSpeed(running)

    if walk_x == 0 or walk_y == 0 then
        self.event_collide = false
    end

    self:move(walk_x, walk_y, speed * DTMULT)

    if self.dancing["buttons"] == true and self.last_collided_y == true then
        if self.dancing["facing"] == false then
            self:move(0, walk_y, speed * DTMULT)
        end
        self.dancing["collided"] = true
        self.dancing["facing"] = true
    end
end

function OtherUnderPlayer:updateSlide()
    local slide_x = 0
    local slide_y = 0

    if self:isMovementEnabled() then
        if Input.down("p" .. self.index + 1 .. "_right") then slide_x = slide_x + 1 end
        if Input.down("p" .. self.index + 1 .. "_left") then slide_x = slide_x - 1 end
        if Input.down("p" .. self.index + 1 .. "_down") then slide_y = slide_y + 1 end
        if Input.down("p" .. self.index + 1 .. "_up") then slide_y = slide_y - 1 end
    end

    if not self.slide_in_place then
        slide_y = 2
    end

    self.run_timer = 50
    local speed = self:getBaseWalkSpeed() + 4

    self:move(slide_x, slide_y, speed * DTMULT)

    self:updateSlideDust()
end

-- Since the non-main player not going to have followers, disable functions which have to do with it
function OtherUnderPlayer:interpolateFollowers() end
function OtherUnderPlayer:alignFollowers(facing, x, y, dist) end
function OtherUnderPlayer:resetFollowerHistory() end
function OtherUnderPlayer:updateHistory() end

return OtherUnderPlayer
