if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightBattle, super = HookSystem.hookScript("LightBattle")

function LightBattle:init()
    self.other_souls = {}
    super.init(self)
end

function LightBattle:spawnOtherSoul(x, y, index)
    self.other_souls[index] = self.encounter:createSoul(
        x,
        y,
        self.party[index + 1] and { self.party[index + 1].chara:getColor() } or Mod.libs["multiplayer"].colors[index]
    )

    self.other_souls[index].alpha = 1
    self.other_souls[index].sprite:set("player/heart_light")
    self.other_souls[index].index = index

    if (self.party[index + 1] and self.party[index + 1].chara.soul_priority < 2 or not self.party[index + 1])
        and ClassUtils.getClassName(self.other_souls[index]) == "LightSoul" then
        self.other_souls[index].rotation = math.pi
    end

    self:addChild(self.other_souls[index])
end

function LightBattle:handleAttackingInput(key)
    if Input.isConfirm(key) then
        if not self.attack_done and not self.cancel_attack and self.battle_ui.attack_box then
            local closest
            local closest_attacks = {}
            local close

            for _, attack in ipairs(self.battle_ui.attack_box.attacks) do
                if not attack.attacked and (TableUtils.getIndex(Game.battle.party, attack.battler) == 1 or TableUtils.getIndex(Game.battle.party, attack.battler) > Mod.libs["multiplayer"].max_players) then
                    close = self.battle_ui.attack_box:getFirstBolt(attack)
                    if not closest then
                        closest = close
                        table.insert(closest_attacks, attack)
                    elseif close == closest then
                        table.insert(closest_attacks, attack)
                    elseif close < closest then
                        closest = close
                        closest_attacks = { attack }
                    end
                end
            end

            if closest and (closest <= 280 or not Game.battle.multi_mode) then
                for _, attack in ipairs(closest_attacks) do
                    local points, stretch = self.battle_ui.attack_box:hit(attack)

                    local action = self:getActionBy(attack.battler)
                    action.points = points
                    action.stretch = stretch

                    if self:processAction(action) then
                        self:finishAction(action)
                    end
                end
            end
        end
    end

    for i = 2, math.min(Mod.libs["multiplayer"].max_players, #Game.battle.party) do
        if Input.is("p" .. i .. "_confirm", key) then
            if not self.attack_done and not self.cancel_attack and self.battle_ui.attack_box then
                local closest
                local closest_attacks = {}
                local close

                for _, attack in ipairs(self.battle_ui.attack_box.attacks) do
                    if not attack.attacked and TableUtils.getIndex(Game.battle.party, attack.battler) == i then
                        close = self.battle_ui.attack_box:getFirstBolt(attack)
                        if not closest then
                            closest = close
                            table.insert(closest_attacks, attack)
                        elseif close == closest then
                            table.insert(closest_attacks, attack)
                        elseif close < closest then
                            closest = close
                            closest_attacks = { attack }
                        end
                    end
                end

                if closest and (closest <= 280 or not Game.battle.multi_mode) then
                    for _, attack in ipairs(closest_attacks) do
                        local points, stretch = self.battle_ui.attack_box:hit(attack)

                        local action = self:getActionBy(attack.battler)
                        action.points = points
                        action.stretch = stretch

                        if self:processAction(action) then
                            self:finishAction(action)
                        end
                    end
                end
            end
        end
    end
end

function LightBattle:update()
    super.update(self)

    if self.soul then
        for _, soul in ipairs(self.other_souls) do
            soul.visible = self.soul.visible
            soul.collidable = self.soul.collidable
        end
    end
end

function LightBattle:onStateChange(old, new)
    super.onStateChange(self, old, new)

    if new == "DEFENDING" then
        if self.soul then
            local x, y = self:getSoulLocation()

            for i = 1, Mod.libs["multiplayer"].max_players - 1 do
                self:spawnOtherSoul(x, y, i)
                self.other_souls[i]:setColor(self.party[i + 1] and { self.party[i + 1].chara:getColor() } or Mod.libs["multiplayer"].colors[i])
            end

            self.soul:setColor({ self.party[1].chara:getColor() })

            if self.party[1].chara.soul_priority < 2 and ClassUtils.getClassName(self.soul) == "LightSoul" then
                self.soul.rotation = math.pi
            end
        end
    end

    if new == "DEFENDINGEND" then
        if self.soul then
            self.soul:setColor({ self.encounter:getSoulColor() })

            if not self.soul:includes(YellowSoul) then
                self.soul.rotation = 0
            end
        end

        for _, soul in ipairs(self.other_souls) do
            soul:remove()
        end
    end
end

return LightBattle