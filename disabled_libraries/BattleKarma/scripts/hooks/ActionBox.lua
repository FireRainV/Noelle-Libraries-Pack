local ActionBox, super = HookSystem.hookScript(ActionBox)

-- Replace the HP sprite with HP|KR sprite when 'encounter.karma_mode' is true
function ActionBox:init(x, y, index, battler)
    super.init(self, x, y, index, battler)

    self.hp_karma_sprite = false
end

function ActionBox:update()
    super.update(self)

    if Game.battle.encounter.karma_mode then
        if not self.hp_karma_sprite then
            self.hp_sprite:setSprite("ui/hp_kr")
            self.hp_karma_sprite = true
        end
    else
        if self.hp_karma_sprite then
            self.hp_sprite:setSprite("ui/hp")
            self.hp_karma_sprite = false
        end
    end
end

return ActionBox