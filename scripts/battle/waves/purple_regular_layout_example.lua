local Basic, super = Class(Wave)

function Basic:init()
    super.init(self)

    -- Initialize timer
    self.time = -1

    -- Change the arena's size
    self:setArenaSize(235, 130)

    -- Set an offset for the soul
    self.soul_offset_x = -1
end

function Basic:onStart()
    -- Swaps the soul to be purple (if you wanna change the whole encounter to use the purple soul then you can move the next few lines to init)
    Game.battle:swapSoul(PurpleSoul())

    local arena = Game.battle.arena
    local half_lenght = arena.width / 2 - 18
    local height = arena.y + 1

    -- Create the strings
    self.strings = {
        self:spawnObject(PurpleString(arena.x - half_lenght - 1, height - 40, arena.x + half_lenght, height - 40)),
        self:spawnObject(PurpleString(arena.x - half_lenght - 1, height, arena.x + half_lenght, height)),
        self:spawnObject(PurpleString(arena.x - half_lenght - 1, height + 40, arena.x + half_lenght, height + 40)),
    }

    -- Assign the fourth string (the bottom one) as the soul's current string
    Game.battle.soul.current_string = self.strings[2]
end

return Basic