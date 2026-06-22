local SlideArea, super = HookSystem.hookScript(SlideArea)

-- Support for other players sliding in slide areas
function SlideArea:update()
    super.update(self)

    for _, player in ipairs(Game.world.other_players) do
        local stopped = false

        Object.startCache()

        if player.y > self.y + self.height and not player:collidesWith(self.collider) then
            self.solid = true

            if player.state == "SLIDE" and player.current_slide_area == self then
                stopped = true
            end
        else
            self.solid = false
        end

        if not stopped and player.state == "SLIDE" and player.current_slide_area == self then
            stopped = self:checkAgainstWall(player)
        end

        Object.endCache()

        if stopped then
            player:setState("WALK")

            player.current_slide_area = nil
        end
    end
end

return SlideArea