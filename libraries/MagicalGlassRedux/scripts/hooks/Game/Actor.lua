local Actor, super = HookSystem.hookScript(Actor)

function Actor:init()
    super.init(self)

    self.light_battler_sprite = false
    self.light_battler_parts = {}
end

function Actor:getWidth()
    if Game.battle and Game.battle.light and not Game.battle.ended and self.light_battler_sprite and self.light_battle_width then
        return self.light_battle_width
    else
        return super.getWidth(self)
    end
end

function Actor:getHeight()
    if Game.battle and Game.battle.light and not Game.battle.ended and self.light_battler_sprite and self.light_battle_height then
        return self.light_battle_height
    else
        return super.getHeight(self)
    end
end

-- A light battler part
-- 'id' contains the name of the part
-- 'data' can contain functions of 'sprite' (which you also need to return the sprite), 'update' and 'init'.
function Actor:addLightBattlerPart(id, data)
    self.light_battler_sprite = true
    if type(data) == "string" then
        self.light_battler_parts[id] = { ["sprite"] = self.path .. "/" .. data }
    else
        self.light_battler_parts[id] = data
    end
end

-- Light battler part getter
function Actor:getLightBattlerPart(part)
    return self.light_battler_parts and self.light_battler_parts[part] or nil
end

function Actor:createLightBattleSprite(enemy)
    return LightEnemySprite(self, enemy)
end

return Actor