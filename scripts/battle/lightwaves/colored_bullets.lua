local ColoredBullets, super = Class(LightWave)

function ColoredBullets:init()
    super.init(self)

    self:setArenaSize(100)

    self.time = 15
end

function ColoredBullets:onStart()
    -- Every 0.33 seconds...
    self.timer:every(1 / 3, function()
        local side = TableUtils.pick({ "left", "right" })
        -- Our X position is offscreen
        local x = side == "right" and SCREEN_WIDTH + 20 or -20
        -- Get a random Y position between the top and the bottom of the arena
        local y = MathUtils.random(Game.battle.arena.top, Game.battle.arena.bottom)

        -- Spawn smallbullet going left with speed 8 (see scripts/battle/lightbullets/smallbullet.lua)
        local bullet = self:spawnBullet("smallbullet", x, y, math.rad(180), side == "right" and 8 or -8)
        bullet:setType(TableUtils.pick({ "white", "blue", "orange", "green" }))
        if not bullet.attacker then
            bullet.damage = 5
            bullet.heal_amount = 2
        end

        -- Dont remove the bullet offscreen, because we spawn it offscreen
        bullet.remove_offscreen = false
    end)
end

function ColoredBullets:update()
    -- Code here gets called every frame

    super.update(self)
end

return ColoredBullets