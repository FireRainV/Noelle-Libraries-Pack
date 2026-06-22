local character, super = Class("noelle", true)

function character:init()
    super.init(self)

    if Kristal.getLibConfig("magical-glass", "debug") then
        -- Whether the party member can act / use spells
        self.has_act = true
        self.has_spells = true

        self:addSpell("snowgrave")
        self:addSpell("rude_buster")
        self:addSpell("red_buster")
        self:addSpell("pacify")
        self:addSpell("dual_heal")
        self:addSpell("ultimate_heal")
        self:addSpell("x_slash")

        self.undertale_movement = true
    end
end

if Kristal.getLibConfig("magical-glass", "debug") then
    function character:onTurnStart(battler)
        super.onTurnStart(self, battler)

        if self:getFlag("auto_attack", false) then
            Game.battle:pushForcedAction(battler, "AUTOATTACK", Game.battle:getActiveEnemies()[1], nil, { points = 150 })
        end
    end

    function character:onLightTurnStart(battler)
        super.onLightTurnStart(self, battler)

        if self:getFlag("auto_attack", false) then
            Game.battle:pushForcedAction(battler, "AUTOATTACK", Game.battle:getActiveEnemies()[1], nil, { points = 150 })
        end
    end
end

return character