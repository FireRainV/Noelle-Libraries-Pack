local Battle, super = HookSystem.hookScript(Battle)

function Battle:init()
    self.other_souls = {}

    super.init(self)
end

-- Spawn the other players' soul
function Battle:spawnOtherSoul(x, y, index)
    self.other_souls[index] = self.encounter:createSoul(
        x,
        y,
        self.party[index + 1]
            and (
                Mod.libs["magical-glass"]
                and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true
                and Game:isLight()
                and self.party[index + 1].chara.color
                or { self.party[index + 1].chara:getColor() }
            )
            or Mod.libs["multiplayer"].colors[index]
    )

    self.other_souls[index].index = index
    self.other_souls[index].inv_timer = self.soul.inv_timer

    if (self.party[index + 1] and self.party[index + 1].chara.soul_priority < 2 or not self.party[index + 1])
        and ClassUtils.getClassName(self.other_souls[index]) == "Soul" then
        self.other_souls[index].rotation = math.pi
    end

    self:addChild(self.other_souls[index])
end

-- Add support for the soul mode swapping for the rest of the souls
-- Color the souls to their characters' main color
function Battle:swapSoul(object)
    super.swapSoul(self, object)

    self.timer:after(1 / 30, function()
        self.soul:setColor(
            Mod.libs["magical-glass"]
            and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true
            and Game:isLight()
            and self.party[1].chara.color
            or { self.party[1].chara:getColor() }
        )
    end)

    local objects = {}

    for i = 1, #self.other_souls do
        local index = i

        if self.other_souls[i] then
            index = self.other_souls[i].index
            self.other_souls[i]:remove()
        end

        objects[i] = TableUtils.copy(object, true)
        objects[i]:setPosition(self.other_souls[i]:getPosition())
        objects[i].layer = self.other_souls[i].layer

        self.other_souls[i] = objects[i]
        self.other_souls[i].index = index

        self:addChild(objects[i])

        self.timer:after(1 / 30, function()
            self.other_souls[i]:setColor(
                self.party[i + 1]
                and (
                    Mod.libs["magical-glass"]
                    and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true
                    and Game:isLight()
                    and self.party[i + 1].chara.color
                    or { self.party[i + 1].chara:getColor() }
                )
                or Mod.libs["multiplayer"].colors[i]
            )
        end)
    end
end

-- Spawn the other players' soul at the position of the main soul
-- Color the souls to their characters' main color
-- If the player's party member has a soul priority below 2, turn it into a monster soul (by rotating it upside-down)
function Battle:onStateChange(old, new)
    super.onStateChange(self, old, new)

    if new == "DEFENDING" then
        if self.soul then
            local x, y = self:getSoulLocation()

            for i = 1, Mod.libs["multiplayer"].max_players - 1 do
                self:spawnOtherSoul(x, y, i)

                self.other_souls[i]:setColor(
                    self.party[i + 1]
                    and (
                        Mod.libs["magical-glass"]
                        and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true
                        and Game:isLight()
                        and self.party[i + 1].chara.color
                        or { self.party[i + 1].chara:getColor() }
                    )
                    or Mod.libs["multiplayer"].colors[i]
                )
            end

            self.soul:setColor(
                Mod.libs["magical-glass"]
                and Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true
                and Game:isLight()
                and self.party[1].chara.color
                or { self.party[1].chara:getColor() }
            )

            if self.party[1].chara.soul_priority < 2 and ClassUtils.getClassName(self.soul) == "Soul" then
                self.soul.rotation = math.pi
            end
        end
    end
end

-- Remove the players' soul
function Battle:returnSoul(dont_destroy)
    if self.soul then
        self.soul:setColor({ self.encounter:getSoulColor() })
        if not self.soul:includes(YellowSoul) then
            self.soul.rotation = 0
        end
    end

    super.returnSoul(self, dont_destroy)

    for _, soul in ipairs(self.other_souls) do
        soul:remove()
    end
end

-- Add the other players to the battle
function Battle:createPartyBattlers()
    for i = 1, #Game.party do
        local party_member = Game.party[i]

        if Game.world.player and Game.world.player.visible and Game.world.player.actor.id == party_member:getActor().id then
            -- Create the player battler
            local player_x, player_y = Game.world.player:getScreenPos()
            local player_battler = PartyBattler(party_member, player_x, player_y)
            player_battler:setAnimation("battle/transition")
            self:addChild(player_battler)
            table.insert(self.party, player_battler)
            table.insert(self.party_beginning_positions, { player_x, player_y })
            self.party_world_characters[party_member.id] = Game.world.player

            Game.world.player.visible = false
        else
            local found = false

            for _, follower in ipairs(Game.world.followers) do
                if follower.visible and follower.actor.id == party_member:getActor().id then
                    local chara_x, chara_y = follower:getScreenPos()
                    local chara_battler = PartyBattler(party_member, chara_x, chara_y)
                    chara_battler:setAnimation("battle/transition")
                    self:addChild(chara_battler)
                    table.insert(self.party, chara_battler)
                    table.insert(self.party_beginning_positions, { chara_x, chara_y })
                    self.party_world_characters[party_member.id] = follower

                    follower.visible = false

                    found = true
                    break
                end
            end

            for _, player in ipairs(Game.world.other_players) do
                if player.visible and player.actor.id == party_member:getActor().id then
                    local chara_x, chara_y = player:getScreenPos()
                    local chara_battler = PartyBattler(party_member, chara_x, chara_y)
                    chara_battler:setAnimation("battle/transition")
                    self:addChild(chara_battler)
                    table.insert(self.party, chara_battler)
                    table.insert(self.party_beginning_positions, { chara_x, chara_y })
                    self.party_world_characters[party_member.id] = player

                    player.visible = false

                    found = true
                    break
                end
            end

            if not found then
                local chara_battler = PartyBattler(party_member, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
                chara_battler:setAnimation("battle/transition")
                self:addChild(chara_battler)
                table.insert(self.party, chara_battler)
                table.insert(self.party_beginning_positions, { chara_battler.x, chara_battler.y })
            end
        end
    end
end

-- The player can only attack with their own character
-- If it's Player 1, allow them to attack for party members who don't have a player controlling them
function Battle:handleAttackingInput(key)
    if Input.isConfirm(key) then
        if not self.attack_done and not self.cancel_attack and #self.battle_ui.attack_boxes > 0 then
            local closest
            local closest_attacks = {}

            for _, attack in ipairs(self.battle_ui.attack_boxes) do
                if not attack.attacked and (TableUtils.getIndex(Game.battle.party, attack.battler) == 1 or TableUtils.getIndex(Game.battle.party, attack.battler) > Mod.libs["multiplayer"].max_players) then
                    local close = attack:getClose()
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

            if closest and closest < 14.2 and closest > -2 then
                for _, attack in ipairs(closest_attacks) do
                    local points = attack:hit()

                    local action = self:getActionBy(attack.battler, true)
                    action.points = points

                    if self:processAction(action) then
                        self:finishAction(action)
                    end
                end
            end
        end
    end

    for i = 2, math.min(Mod.libs["multiplayer"].max_players, #Game.battle.party) do
        if Input.is("p" .. i .. "_confirm", key) then
            if not self.attack_done and not self.cancel_attack and #self.battle_ui.attack_boxes > 0 then
                local closest
                local closest_attacks = {}

                for _, attack in ipairs(self.battle_ui.attack_boxes) do
                    if not attack.attacked and TableUtils.getIndex(Game.battle.party, attack.battler) == i then
                        local close = attack:getClose()
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

                if closest and closest < 14.2 and closest > -2 then
                    for _, attack in ipairs(closest_attacks) do
                        local points = attack:hit()

                        local action = self:getActionBy(attack.battler, true)
                        action.points = points

                        if self:processAction(action) then
                            self:finishAction(action)
                        end
                    end
                end
            end
        end
    end
end

return Battle