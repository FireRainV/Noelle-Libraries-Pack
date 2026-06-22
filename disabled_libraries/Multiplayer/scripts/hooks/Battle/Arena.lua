local Arena, super = HookSystem.hookScript(Arena)

-- Add collison to the players' soul with the arena
function Arena:update()
    super.update(self)

    for _, soul in ipairs(Game.battle.other_souls) do
        if soul.collidable then
            Object.startCache()

            local angle_diff = self.clockwise and -(math.pi / 2) or (math.pi / 2)

            for _, line in ipairs(self.collider.colliders) do
                local angle

                while soul:collidesWith(line) do
                    if not angle then
                        local x1, y1 = self:getRelativePos(line.x, line.y, Game.battle)
                        local x2, y2 = self:getRelativePos(line.x2, line.y2, Game.battle)
                        angle = MathUtils.angle(x1, y1, x2, y2)
                    end

                    Object.uncache(soul)

                    soul:setPosition(
                        soul.x + (math.cos(angle + angle_diff)),
                        soul.y + (math.sin(angle + angle_diff))
                    )
                end
            end

            Object.endCache()
        end
    end
end

return Arena