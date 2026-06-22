local OtherPlayer, super = Class(Player)

function OtherPlayer:init(chara, x, y, index)
    super.init(self, chara, x, y)

    -- The index of the other players (Player 2 will have an index of 1 for example)
    self.index = index or 0
end

-- The controls of each player
function OtherPlayer:handleMovement()
    local walk_x = 0
    local walk_y = 0

    if     Input.down("p" .. self.index + 1 .. "_left")  then walk_x = walk_x - 1
    elseif Input.down("p" .. self.index + 1 .. "_right") then walk_x = walk_x + 1 end
    if     Input.down("p" .. self.index + 1 .. "_up")    then walk_y = walk_y - 1
    elseif Input.down("p" .. self.index + 1 .. "_down")  then walk_y = walk_y + 1 end

    self.moving_x = walk_x
    self.moving_y = walk_y

    local running = (Input.down("p" .. self.index + 1 .. "_cancel") or self.force_run) and not self.force_walk
    if Kristal.Config["autoRun"] and not self.force_run and not self.force_walk then
        running = not running
    end

    if self.force_run and not self.force_walk then
        self.run_timer = 200
    end

    local speed = self:getCurrentSpeed(running)

    self:move(walk_x, walk_y, speed * DTMULT)

    if not running or self.last_collided_x or self.last_collided_y then
        self.run_timer = 0
    elseif running then
        if walk_x ~= 0 or walk_y ~= 0 then
            self.run_timer = self.run_timer + DTMULT
            self.run_timer_grace = 0
        else
            -- Dont reset running until 2 frames after you release the movement keys
            if self.run_timer_grace >= 2 then
                self.run_timer = 0
            end
            self.run_timer_grace = self.run_timer_grace + DTMULT
        end
    end
end

function OtherPlayer:updateSlide()
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
function OtherPlayer:interpolateFollowers() end
function OtherPlayer:alignFollowers(facing, x, y, dist) end
function OtherPlayer:resetFollowerHistory() end
function OtherPlayer:updateHistory() end

return OtherPlayer
