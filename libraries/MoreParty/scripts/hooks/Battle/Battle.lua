local Battle, super = HookSystem.hookScript(Battle)

-- Remove the limit on how many party members can be inside a battle
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

-- Allow an infinte amount of short act text instead of just 3
function Battle:shortActText(text)
    local advances = 3 -- initial override so we can run it
    local function displayShortActText()
        advances = advances + 1
        if advances >= 3 then
            self.battle_ui:clearEncounterText()
            advances = 0

            local text_1, text_2, text_3 = table.remove(text, 1), table.remove(text, 1), table.remove(text, 1)
            local text_exhausted = not (text_1 and text_2 and text_3) or #text == 0
            local advance_to_next = not text_exhausted and displayShortActText
            self.battle_ui.short_act_text_1:setText(text_1 or "", advance_to_next)
            self.battle_ui.short_act_text_2:setText(text_2 or "", advance_to_next)
            self.battle_ui.short_act_text_3:setText(text_3 or "", advance_to_next)

            if text_exhausted then
                self:setState("SHORTACTTEXT")
            end
        end
    end

    displayShortActText()
end

return Battle