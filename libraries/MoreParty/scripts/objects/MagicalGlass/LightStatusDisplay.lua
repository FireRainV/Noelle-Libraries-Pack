if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightStatusDisplay, super = HookSystem.hookScript("LightStatusDisplay")

function LightStatusDisplay:drawStatusStrip()
    if not Game.battle.multi_mode or #Game.battle.party <= 3 then -- Use MGR's normal code
        super.drawStatusStrip(self)
    else
        local per_row = Mod.libs["moreparty"]:getPartyPerRowAmount()
        local party_count = #Game.battle.party
        local two_by_two = Mod.libs["moreparty"]:getTwoByTwo(party_count)
        local boxes_per_row = two_by_two and 2 or per_row

        local width = 160

        self.view_start_row = self.view_start_row or 0

        local current_selecting = Game.battle.current_selecting or 0
        if current_selecting == 0 then
            current_selecting = 1
        end

        -- Only move the camera if a valid character is actively selected!
        if current_selecting > 0 then
            local selected_index = current_selecting - 1
            local selected_row = math.floor(selected_index / boxes_per_row)

            if selected_row < self.view_start_row then
                self.view_start_row = selected_row
            elseif selected_row > self.view_start_row + 1 then
                self.view_start_row = selected_row - 1
            end
        end

        local start_row = self.view_start_row
        local is_four_flat = party_count == 4 and not Kristal.getLibConfig("moreparty", "three_per_row")

        for k = 1, party_count do
            local index = k - 1
            local row = math.floor(index / boxes_per_row)
            local col = index % boxes_per_row

            local display_row = row - start_row

            if is_four_flat or (display_row >= 0 and display_row <= 1) then
                local boxes_in_this_row = math.min(boxes_per_row, party_count - row * boxes_per_row)
                local x = 83 + ((3 - boxes_in_this_row) * 80) + (col * width)
                local y = 8 + (display_row * 20)

                if is_four_flat then
                    x = 83 + (3 - party_count) * 80 + (k - 1) * 160
                    y = 10
                end

                -- Use a stencil to prevent overlapping of the "TARGET" box
                local function target_text_area()
                    love.graphics.rectangle("fill", x + 1, y - 9, 25, 4)
                end
                love.graphics.stencil(target_text_area, "replace", 1, true)
            end
        end

        for index, battler in ipairs(Game.battle.party) do
            local zero_index = index - 1
            local row = math.floor(zero_index / boxes_per_row)
            local display_row = row - start_row

            -- There's only 1 row
            if is_four_flat or (display_row >= 0 and display_row <= 1) then
                local name = battler.chara:getShortName()
                local level = Game:isLight() and battler.chara:getLightLV() or battler.chara:getLevel()

                local current = battler.chara:getHealth()
                local max = battler.chara:getStat("health")
                local karma = battler.karma

                local small = false
                for _, party in ipairs(Game.battle.party) do
                    if party.chara:getStat("health") >= 100 then
                        small = true
                        break
                    end
                end

                local karma_mode = Game.battle.encounter.karma_mode

                local color = MG_PALETTE["player_text"]
                if battler.is_down then
                    color = MG_PALETTE["player_down_text"]
                elseif battler.sleeping then
                    color = MG_PALETTE["player_sleeping_text"]
                elseif Game.battle:getActionBy(battler) and Game.battle:getActionBy(battler).action == "DEFEND" then
                    color = MG_PALETTE["player_defending_text"]
                elseif Game.battle:getActionBy(battler) and TableUtils.contains({ "ACTIONSELECT", "MENUSELECT", "ENEMYSELECT", "PARTYSELECT" }, Game.battle:getState()) and Game.battle:getActionBy(battler).action ~= "AUTOATTACK" then
                    color = MG_PALETTE["player_action_text"]
                elseif karma > 0 then
                    color = MG_PALETTE["player_karma_text"]
                end

                local col = zero_index % boxes_per_row
                local boxes_in_this_row = math.min(boxes_per_row, party_count - row * boxes_per_row)

                local x = 83 + ((3 - boxes_in_this_row) * 80) + (col * width)

                -- Use display_row to lock the Y coordinates to our viewport
                local y = 8 + (display_row * 20)

                -- We have exactly 4 party members in a singular row
                if is_four_flat then
                    x = 83 + (3 - party_count) * 80 + (index - 1) * 160
                    y = 10

                    if Kristal.getLibConfig("magical-glass", "multi_minimal_ui") then
                        love.graphics.setFont(Assets.getFont("namelv", 16))
                        Draw.setColor(MG_PALETTE["player_text"])
                        love.graphics.print(name, x + 1, y + 3)

                        Draw.setColor(Game:isLight() and (karma_mode and MG_PALETTE["player_karma_health_bg"] or MG_PALETTE["player_health_bg"]) or (karma_mode and MG_PALETTE["player_karma_health_bg_dark"] or PALETTE["action_health_bg"]))
                        love.graphics.rectangle("fill", x + 62, y + 5, (small and 12 or 23) * 1.2 + 1, 10)
                        if current > 0 then
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_karma_health"] or MG_PALETTE["player_karma_health_dark"])
                            love.graphics.rectangle("fill", x + 62, y + 5, math.ceil((MathUtils.clamp(current, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1, 10)
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_health"] or { battler.chara:getColor() })
                            love.graphics.rectangle("fill", x + 62, y + 5, math.ceil((MathUtils.clamp(current - karma, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1 - (karma_mode and 1 or 0), 10)
                        end

                        love.graphics.setFont(Assets.getFont("namelv", 16))

                        current = string.format("%02d", current)
                        max = string.format("%02d", max)

                        Draw.setColor(color)
                        Draw.printAlign(current .. "/" .. max, x + 155, y + 3, "right")
                    else
                        love.graphics.setFont(Assets.getFont("namelv", 16))
                        Draw.setColor(MG_PALETTE["player_text"])
                        love.graphics.print(name, x, y - 2)
                        love.graphics.setFont(Assets.getFont("namelv", 8))
                        love.graphics.print("LV" .. " " .. level, x, y + 13)

                        Draw.draw(Assets.getTexture("ui/lightbattle/hp"), x + 49, y + 14, 0, 0.5)

                        if karma_mode then
                            Draw.draw(Assets.getTexture("ui/lightbattle/kr"), x + 64 + (small and 12 or 23) * 1.2 + 1, y + 14, 0, 0.5)
                        end

                        Draw.setColor(Game:isLight() and (karma_mode and MG_PALETTE["player_karma_health_bg"] or MG_PALETTE["player_health_bg"]) or (karma_mode and MG_PALETTE["player_karma_health_bg_dark"] or PALETTE["action_health_bg"]))
                        love.graphics.rectangle("fill", x + 62, y + (small and 3 or 0), (small and 12 or 23) * 1.2 + 1, small and 14 or 21)
                        if current > 0 then
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_karma_health"] or MG_PALETTE["player_karma_health_dark"])
                            love.graphics.rectangle("fill", x + 62, y + (small and 3 or 0), math.ceil((MathUtils.clamp(current, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1, small and 14 or 21)
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_health"] or { battler.chara:getColor() })
                            love.graphics.rectangle("fill", x + 62, y + (small and 3 or 0), math.ceil((MathUtils.clamp(current - karma, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1 - (karma_mode and 1 or 0), small and 14 or 21)
                        end

                        love.graphics.setFont(Assets.getFont("namelv", 16))

                        current = string.format("%02d", current)
                        max = string.format("%02d", max)

                        Draw.setColor(color)
                        Draw.printAlign(current .. "/" .. max, x + 156, y + 3 - (karma_mode and 3 or 0), "right")
                    end

                    if Game.battle.current_selecting == index or DEBUG_RENDER and Input.alt() then
                        Draw.setColor(battler.chara:getColor())
                        love.graphics.setLineWidth(2)
                        love.graphics.rectangle("line", x - 2, y - 7, 158, 35)
                    end

                    if battler:isTargeted() and Game:getConfig("targetSystem") and Game.battle.state == "ENEMYDIALOGUE" then
                        Draw.setColor(1, 1, 1, 1)
                        love.graphics.setLineWidth(2)
                        love.graphics.setStencilTest("equal", 0)
                        if math.floor(Kristal.getTime() * 3) % 2 == 0 then
                            love.graphics.rectangle("line", x - 2, y - 7, 158, 35)
                        else
                            love.graphics.rectangle("line", x - 1, y - 6, 156, 33)
                        end
                        love.graphics.setStencilTest()
                        Draw.draw(Assets.getTexture("ui/lightbattle/chartarget"), x + 2, y - 9)
                    end
                else
                    if Kristal.getLibConfig("magical-glass", "multi_minimal_ui") then
                        love.graphics.setFont(Assets.getFont("namelv", 16))
                        Draw.setColor(MG_PALETTE["player_text"])
                        love.graphics.print(name, x + 1, y - 4)

                        Draw.setColor(Game:isLight() and (karma_mode and MG_PALETTE["player_karma_health_bg"] or MG_PALETTE["player_health_bg"]) or (karma_mode and MG_PALETTE["player_karma_health_bg_dark"] or PALETTE["action_health_bg"]))
                        love.graphics.rectangle("fill", x + 62, y - 2, (small and 12 or 23) * 1.2 + 1, 10)
                        if current > 0 then
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_karma_health"] or MG_PALETTE["player_karma_health_dark"])
                            love.graphics.rectangle("fill", x + 62, y - 2, math.ceil((MathUtils.clamp(current, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1, 10)
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_health"] or { battler.chara:getColor() })
                            love.graphics.rectangle("fill", x + 62, y - 2, math.ceil((MathUtils.clamp(current - karma, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1 - (karma_mode and 1 or 0), 10)
                        end

                        love.graphics.setFont(Assets.getFont("namelv", 16))

                        current = string.format("%02d", current)
                        max = string.format("%02d", max)

                        Draw.setColor(color)
                        Draw.printAlign(current .. "/" .. max, x + 155, y - 4, "right")
                    else
                        love.graphics.setFont(Assets.getFont("namelv", 16))
                        Draw.setColor(MG_PALETTE["player_text"])
                        love.graphics.print(name, x, y - 7)
                        love.graphics.setFont(Assets.getFont("namelv", 8))
                        love.graphics.print("LV" .. " " .. level, x, y + 5)

                        Draw.draw(Assets.getTexture("ui/lightbattle/hp"), x + 49, y + 6, 0, 0.5)

                        if karma_mode then
                            Draw.draw(Assets.getTexture("ui/lightbattle/kr"), x + 64 + (small and 12 or 23) * 1.2 + 1, y + 6, 0, 0.5)
                        end

                        Draw.setColor(Game:isLight() and (karma_mode and MG_PALETTE["player_karma_health_bg"] or MG_PALETTE["player_health_bg"]) or (karma_mode and MG_PALETTE["player_karma_health_bg_dark"] or PALETTE["action_health_bg"]))
                        love.graphics.rectangle("fill", x + 62, y - 2, (small and 12 or 23) * 1.2 + 1, 10)
                        if current > 0 then
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_karma_health"] or MG_PALETTE["player_karma_health_dark"])
                            love.graphics.rectangle("fill", x + 62, y - 2, math.ceil((MathUtils.clamp(current, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1, 10)
                            Draw.setColor(Game:isLight() and MG_PALETTE["player_health"] or { battler.chara:getColor() })
                            love.graphics.rectangle("fill", x + 62, y - 2, math.ceil((MathUtils.clamp(current - karma, 0, max) / max) * (small and 12 or 23)) * 1.2 + 1 - (karma_mode and 1 or 0), 10)
                        end

                        love.graphics.setFont(Assets.getFont("namelv", 16))

                        current = string.format("%02d", current)
                        max = string.format("%02d", max)

                        Draw.setColor(color)
                        Draw.printAlign(current .. "/" .. max, x + 156, y - 4 - (karma_mode and 3 or 0), "right")
                    end

                    -- box outline for the current party battler turn
                    if Game.battle.current_selecting == index or DEBUG_RENDER and Input.alt() then
                        Draw.setColor(battler.chara:getColor())
                        love.graphics.setLineWidth(2)
                        love.graphics.rectangle("line", x - 2, y - 7, 158, 20)
                    end

                    -- "TARGET" system
                    -- Use a stencil to prevent overlapping of the "TARGET" box
                    if battler:isTargeted() and Game:getConfig("targetSystem") and Game.battle.state == "ENEMYDIALOGUE" then
                        Draw.setColor(1, 1, 1, 1)
                        love.graphics.setLineWidth(2)
                        love.graphics.setStencilTest("equal", 0)
                        if math.floor(Kristal.getTime() * 3) % 2 == 0 then
                            love.graphics.rectangle("line", x - 2, y - 7, 158, 20)
                        else
                            love.graphics.rectangle("line", x - 1, y - 6, 156, 18)
                        end
                        love.graphics.setStencilTest()
                        Draw.draw(Assets.getTexture("ui/lightbattle/chartarget"), x + 2, y - 9)
                    end
                end
            end
        end

        local per_row = 6
        local total_rows = 4
        local skip_amount = Mod.libs["moreparty"]:getPartyPerRowAmount(true)

        local x_spacing = 107
        local y_spacing = 12

        -- Display exceeding party battlers' health during the enemy's turn
        if TableUtils.contains({ "DEFENDING", "DEFENDINGBEGIN", "DEFENDINGEND", "ENEMYDIALOGUE" }, Game.battle.state) then
            for i = (1 + skip_amount), math.min(#Game.battle.party, #Game.battle.party + per_row * total_rows) do
                local battler = Game.battle.party[i]
                local zero_index = i - 1 - skip_amount
                local row = math.floor(zero_index / per_row)
                local col = zero_index % per_row

                local boxes_in_this_row = math.min(per_row, #Game.battle.party - skip_amount - row * per_row)

                -- Calculate the exact center X for this specific column
                local center_x = (SCREEN_WIDTH / 2) + 11 + (col - (boxes_in_this_row - 1) / 2) * x_spacing

                -- Calculate the Y offset for this row
                local base_y = row * y_spacing

                Draw.setColor(MG_PALETTE["player_text"])
                love.graphics.setFont(Assets.getFont("namelv", 16))
                local name = StringUtils.sub(battler.chara:getName(), 1, 3)
                love.graphics.print("(" .. name, center_x - 64, 40 + base_y)
                love.graphics.setFont(Assets.getFont("main", 16))
                love.graphics.print(":", Assets.getFont("namelv", 16):getWidth(name) + center_x - 56, 37.5 + base_y)

                local color = MG_PALETTE["player_text"]
                if battler.is_down then
                    color = MG_PALETTE["player_down_text"]
                elseif battler.sleeping then
                    color = MG_PALETTE["player_sleeping_text"]
                elseif Game.battle:getActionBy(battler) and Game.battle:getActionBy(battler).action == "DEFEND" then
                    color = MG_PALETTE["player_defending_text"]
                elseif Game.battle:getActionBy(battler) and TableUtils.contains({ "ACTIONSELECT", "MENUSELECT", "ENEMYSELECT", "PARTYSELECT" }, Game.battle:getState()) and Game.battle:getActionBy(battler).action ~= "AUTOATTACK" then
                    color = MG_PALETTE["player_action_text"]
                elseif battler.karma > 0 then
                    color = MG_PALETTE["player_karma_text"]
                end

                Draw.setColor(color)
                if StringUtils.len(tostring(battler.chara:getStat("health"))) > 2 or StringUtils.len(tostring(battler.chara:getHealth())) > 3 then
                    love.graphics.setFont(Assets.getFont("namelv", 8))
                    Draw.printAlign(battler.chara:getHealth() .. "/" .. battler.chara:getStat("health"), center_x + 35 - 1, 40 + 4 + base_y, "right")
                else
                    love.graphics.setFont(Assets.getFont("namelv", 16))
                    Draw.printAlign(battler.chara:getHealth() .. "/" .. battler.chara:getStat("health"), center_x + 35, 40 + base_y, "right")
                end
                Draw.setColor(MG_PALETTE["player_text"])
                love.graphics.setFont(Assets.getFont("namelv", 16))
                Draw.printAlign(")", center_x + 35 + 8, 40 + base_y, "right")
            end
        end
    end
end

return LightStatusDisplay