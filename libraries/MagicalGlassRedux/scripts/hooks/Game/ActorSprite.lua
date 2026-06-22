local ActorSprite, super = HookSystem.hookScript(ActorSprite)

function ActorSprite:init(actor)
    super.init(self, actor)

     -- Used for fleeing enemies in light battles
    self.run_away_light = false
     -- Used when fleeing in dark battles
    self.run_away_party = false
end

-- Emote argument for speech bubbles in light battles
function ActorSprite:onEmote(emote)
    self:resetSprite()

    local success = false
    if emote and emote ~= "reset" then
        if self:hasSprite(emote) then
            self:set(emote)
            success = true
        end
    else
        success = nil
    end

    return success
end

function ActorSprite:update()
    super.update(self)

    if self.run_away_light then
        self.run_away_timer = self.run_away_timer + DTMULT
    end
    if self.run_away_party then
        self.run_away_timer = self.run_away_timer + DTMULT
    end
end

function ActorSprite:draw()
    if self.actor:preSpriteDraw(self) then
        return
    end

    if self.texture and self.run_away_light then
        local r, g, b, a = self:getDrawColor()
        for i = 0, 80 do
            local alph = a * 0.4
            Draw.setColor(r, g, b, ((alph - (self.run_away_timer / 8)) + (i / 200)))
            Draw.draw(self.texture, i * 4, 0)
        end

        return
    end

    if self.texture and self.run_away_party then
        local r, g, b, a = self:getDrawColor()
        for i = 0, 80 do
            local alph = a * 0.4
            Draw.setColor(r, g, b, ((alph - (self.run_away_timer / 8)) + (i / 200)))
            Draw.draw(self.texture, i * (-2), 0)
        end

        return
    end

    super.draw(self)
end

-- Enables talking animation for emotes
function ActorSprite:canTalk()
    if self.parent and self.parent:includes(LightEnemyBattler) then
        return true, 0.25
    end
end

return ActorSprite