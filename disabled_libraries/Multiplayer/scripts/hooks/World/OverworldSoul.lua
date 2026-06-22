local OverworldSoul, super = HookSystem.hookScript(OverworldSoul)

function OverworldSoul:init(x, y)
    -- The index of the other overworld souls (Player 2 will have an index of 1 for example)
    self.index = 0

    super.init(self, x, y)
end

function OverworldSoul:update()
    super.update(self)

    -- Add the red outline for the other players when any player is inside a overworld battle area
    local progress = 0

    if self.index > 0 and Game.world.other_players[self.index] then
        self.x, self.y = Game.world.other_players[self.index]:getRelativePos(Game.world.other_players[self.index].actor:getSoulOffset())
        if Game.world.other_players[self.index].battle_alpha > 0 then
            progress = Game.world.other_players[self.index].battle_alpha * 2
        end

        self.alpha = MathUtils.clamp(progress, 0, 1)
    end
end

-- Draw the debug collider for all the souls
function OverworldSoul:draw()
    if DEBUG_RENDER then
        self.collider:draw(0, 1, 0)
    end

    Object.draw(self)
end

return OverworldSoul