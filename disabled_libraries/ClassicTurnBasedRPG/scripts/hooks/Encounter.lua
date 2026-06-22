local Encounter, super = HookSystem.hookScript(Encounter)

function Encounter:init()
    super.init(self)

    -- manual encounter variables to enable or disable classic attacks for either the part of the enemies
    self.party_auto_attack = Kristal.getLibConfig("classic_turn_based_rpg", "classic_party_attack")
    self.enemy_auto_attack = Kristal.getLibConfig("classic_turn_based_rpg", "classic_enemy_attack")

    -- Used for the waves that are launched after the enemy finish its classic attack
    self.wave_enemies = nil
end

function Encounter:onDialogueEnd()
    -- enemy classic attack state
    if self:getEnemyAutoAttack() then
        Game.battle:setState("ENEMYATTACKING")
    else
        super.onDialogueEnd(self)
    end
end

function Encounter:onTurnStart()
    super.onTurnStart(self)

    self.wave_enemies = nil
end

function Encounter:getPartyAutoAttack()
    return self.party_auto_attack
end

function Encounter:getEnemyAutoAttack()
    return self.enemy_auto_attack
end

function Encounter:getAutoAttackPoints(battler)
    if MathUtils.random(0, 100) < 5 then
        return 0 -- miss
    else
        return TableUtils.pick({ 150, 120, 120, 110 }) -- 150 is a critical hit
    end
end

function Encounter:beforeStateChange(old, new)
    if new == "ENEMYATTACKING" then -- auto attacking enemies
        Game.battle:startCutscene(function(cutscene)
            -- activate bullet patterns after the classic attack if they're set
            self.wave_enemies = {}
            for _, enemy in ipairs(Game.battle:getActiveEnemies()) do
                local use_wave = enemy:onAttack(cutscene)
                if use_wave then
                    table.insert(self.wave_enemies, enemy)
                end
            end
            cutscene:after(function()
                if #self.wave_enemies > 0 then
                    Game.battle:setState("DEFENDINGBEGIN")
                else
                    Game.battle:setState("ACTIONSELECT", "ENEMYATTACKED")
                end
            end)
        end)
    elseif new == "ATTACKING" and self:getPartyAutoAttack() then -- auto attacking party
        for i, battler in ipairs(Game.battle.party) do
            local action = Game.battle.character_actions[i]
            if action and action.action == "ATTACK" then
                action.action = "AUTOATTACK"
                action.cancellable = false
                local points, crit = self:getAutoAttackPoints(battler)
                action.points = points
                action.critical = crit == nil and action.points >= 150 or crit
            end
        end
    end

    return super.beforeStateChange(self, old, new)
end

function Encounter:getNextWaves()
    if self.wave_enemies then
        local waves = {}
        for _, enemy in ipairs(self.wave_enemies) do
            local wave = enemy:selectWave()
            if wave then
                table.insert(waves, wave)
            end
        end
        return waves
    else
        return super.getNextWaves(self)
    end
end

return Encounter