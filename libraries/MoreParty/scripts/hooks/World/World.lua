local World, super = HookSystem.hookScript(World)

function World:heal(target, amount, text)
    if not Game:isLight() and self.healthbar then
        if type(target) == "string" then
            target = Game:getPartyMember(target)
        end

        local maxed = target:heal(amount)

        for _, actionbox in ipairs(self.healthbar.action_boxes) do
            if actionbox.chara.id == target.id and actionbox.visible then
                local text = HPText("+" .. amount, self.healthbar.x + actionbox.x + 69, self.healthbar.y + actionbox.y + 15)
                text.layer = WORLD_LAYERS["ui"] + 1
                Game.world:addChild(text)
                return
            end
        end
    else
        super.heal(self, target, amount, text)
    end
end

return World