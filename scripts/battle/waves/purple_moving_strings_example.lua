local Basic, super = Class(Wave)

function Basic:init()
    super.init(self)

    -- Initialize timer
    self.time = 11

    -- Set the arena's size
    self:setArenaSize(142, 300)
end

function Basic:onStart()
    -- Swap the soul to purple
    Game.battle:swapSoul(PurpleSoul())

    -- Create the strings table
    self.strings = {
        self:spawnObject(PurpleString(
            255, Game.battle.arena:getTop() + 150,
            385, Game.battle.arena:getTop() + 150
        )),
    }

    -- Assign the only string we have at the moment to be the player's string
    Game.battle.soul.current_string = self.strings[1]

    -- Give the string a y speed of 4 (down)
    self.strings[1].physics.speed_y = 4

    -- Create strings in a random pattern so the every loop later flows with these strings
    for i = 1, 5 do
        local x = love.math.random(Game.battle.arena.left + 32, Game.battle.arena.right - 32)
        local y = Game.battle.arena:getTop() + 150 - 30 * i

        local string = self:spawnObject(PurpleString(
            x - 30, y,
            x + 30, y
        ))

        string.physics.speed_y = 4
        table.insert(self.strings, string)
    end

    -- Spawn a new string in a random x between the left and right of the arena
    -- every quarter second, repeats 20 times
    self.timer:every(0.25, function()
        local x = love.math.random(Game.battle.arena.left + 32, Game.battle.arena.right - 32)
        local y = Game.battle.arena:getTop()

        local string = self:spawnObject(PurpleString(
            x - 30, y,
            x + 30, y
        ))

        string.physics.speed_y = 4
        table.insert(self.strings, string)
    end, 20)

    -- After 5 seconds, spawn more strings moving up with a speed of -4, repeats 20 times
    self.timer:after(5, function()
        self.timer:every(0.25, function()
            local x = love.math.random(Game.battle.arena.left + 32, Game.battle.arena.right - 32)
            local y = Game.battle.arena:getBottom()

            local string = self:spawnObject(PurpleString(
                x + 30, y,
                x - 30, y
            ))

            string.physics.speed_y = -4
            table.insert(self.strings, string)
        end, 20)
    end)

    -- Spawn spikes on top of arena
    self:spawnBulletTo(Game.battle.arena, "arenahazard", Game.battle.arena.width / 2, 0, math.rad(0))

    -- Spawn spikes on bottom of arena (rotated 180 degrees)
    self:spawnBulletTo(Game.battle.arena, "arenahazard", Game.battle.arena.width / 2, Game.battle.arena.height, math.rad(180))
end

function Basic:update()
    super.update(self)

    -- Check if the strings go outside of the arena and despawn them
    for k, string in ipairs(self.strings) do
        if string.y > Game.battle.arena:getBottom() then
            string:remove()
            table.remove(self.strings, k)
        elseif string.y < Game.battle.arena:getTop() then
            string:remove()
            table.remove(self.strings, k)
        end
    end
end

return Basic