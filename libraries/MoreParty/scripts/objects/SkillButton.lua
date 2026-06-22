local SkillButton, super = Class(ActionButton)

-- Include a combined button of both ACT and Magic
function SkillButton:init()
    super.init(self, "skill")
end

function SkillButton:select()
    Game.battle:clearMenuItems()
    Game.battle:addMenuItem({
        ["name"] = Kristal.getLibConfig("moreparty", "custom_act_name")[1],
        ["description"] = Kristal.getLibConfig("moreparty", "custom_act_name")[2],
        ["color"] = { 1, 1, 1, 1 },
        ["callback"] = function() Game.battle:setState("ENEMYSELECT", "ACT") end
    })
    local magic_color = { 1, 1, 1, 1 }
    if self.battler then
        local has_tired = false
        for _, enemy in ipairs(Game.battle:getActiveEnemies()) do
            if enemy.tired then
                has_tired = true
                break
            end
        end
        if has_tired then
            local has_pacify = false
            for _, spell in ipairs(self.battler.chara:getSpells()) do
                if spell and spell:hasTag("spare_tired") then
                    if spell:isUsable(self.battler.chara) and spell:getTPCost(self.battler.chara) <= Game:getTension() then
                        has_pacify = true
                        break
                    end
                end
            end
            if has_pacify then
                magic_color = { 0, 178 / 255, 1, 1 }
                if Game:getConfig("pacifyGlow") then
                    magic_color = function()
                        return Utils.mergeColor({ 0, 0.7, 1, 1 }, COLORS.white, 0.5 + math.sin(Game.battle.pacify_glow_timer / 4) * 0.5)
                    end
                end
            end
        end
    end
    Game.battle:addMenuItem({
        ["name"] = Kristal.getLibConfig("moreparty", "custom_magic_name")[1],
        ["description"] = Kristal.getLibConfig("moreparty", "custom_magic_name")[2],
        ["color"] = magic_color,
        ["callback"] = function()
            self:onMagicSelect()
        end
    })
    Game.battle:setState("MENUSELECT", "ACTMENU")
end

function SkillButton:hasSpecial()
    local has_tired = false
    for _, enemy in ipairs(Game.battle:getActiveEnemies()) do
        if enemy.tired then
            has_tired = true
            break
        end
    end
    if has_tired then
        local has_pacify = false
        for _, spell in ipairs(self.battler.chara:getSpells()) do
            if spell and spell:hasTag("spare_tired") then
                if spell:isUsable(self.battler.chara) and spell:getTPCost(self.battler.chara) <= Game:getTension() then
                    has_pacify = true
                    break
                end
            end
        end
        return has_pacify
    end
    return false
end

return SkillButton