local Basic, super = Class(Wave)

function Basic:init()
    super.init(self)

    -- Initialize timer
    self.time = -1

    -- Change the arena's size
    self:setArenaSize(300, 300)
end

function Basic:onStart()
    -- Swaps the soul to be purple(if you wanna change the whole encounter to use the purple soul then you can move the next few lines to init)
    Game.battle:swapSoul(PurpleSoul())
    Game.battle.soul.limit_progress = true

    -- Create the strings
    self.strings = {
        self:spawnObject(PurpleString(420, 72, 220, 72)),
        self:spawnObject(PurpleString(220, 272, 420, 72)),
        self:spawnObject(PurpleString(220, 72, 420, 272)),
        self:spawnObject(PurpleString(220, 272, 420, 272)),
        self:spawnObject(PurpleString(420, 272, 420, 72)),
        self:spawnObject(PurpleString(220, 72, 220, 272))
    }

    -- Assign the fourth string(the bottom one) as the soul's current string
    Game.battle.soul.current_string = self.strings[4]
end

return Basic