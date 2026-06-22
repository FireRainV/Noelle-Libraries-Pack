local Basic, super = Class(LightWave)

function Basic:init()
    super.init(self)

    self.darken = "alt"
    self:setArenaSize(100)
    self.arena_x = SCREEN_WIDTH / 2
    self.arena_y = 150
end

function Basic:onStart()
    -- Every 0.33 seconds...
    self.timer:every(1 / 3, function()
        -- Our X position is offscreen, to the right
        local x = SCREEN_WIDTH + 20
        -- Get a random Y position between the top and the bottom of the arena
        local y = MathUtils.random(Game.battle.arena.top, Game.battle.arena.bottom)

        -- Spawn smallbullet going left with speed 8 (see scripts/battle/lightbullets/smallbullet.lua)
        local bullet = self:spawnBullet("smallbullet", x, y, math.rad(180), 8)
        if not bullet.attacker then
            bullet.damage = 30
        end

        -- Dont remove the bullet offscreen, because we spawn it offscreen
        bullet.remove_offscreen = false
    end)
end

function Basic:update()
    -- Code here gets called every frame

    super.update(self)
end

return Basic