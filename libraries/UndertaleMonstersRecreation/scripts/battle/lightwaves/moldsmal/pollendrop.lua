local wave, super = Class(LightWave)

function wave:init()
    super.init(self)

    self.time = 4
end

function wave:onStart()
    local x = MathUtils.random(Game.battle.arena.left + 20, Game.battle.arena.right - 20)

    local bullet = self:spawnBullet("pollendrop", x, Game.battle.arena.top + 1)

    local time = 15 / 30
    if #Game.battle.enemies == 2 then
        time = 1
    elseif #Game.battle.enemies >= 3 then
        time = 22.5 / 30
    end

    self.timer:every(time, function()
        x = MathUtils.random(Game.battle.arena.left + 20, Game.battle.arena.right - 20)

        bullet = self:spawnBullet("pollendrop", x, Game.battle.arena.top + 1)
    end)
end

return wave