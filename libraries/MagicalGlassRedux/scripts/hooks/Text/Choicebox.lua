local Choicebox, super = HookSystem.hookScript(Choicebox)

-- Support for choicer in light battles and the Undertale variation of choicer
function Choicebox:init(x, y, width, height, battle_box, options)
    options = options or {}

    -- Whether to use an Undertale variation choicer
    self.undertale = options["undertale"] and true or false

    super.init(self, x, y, width, height, battle_box, options)
end

function Choicebox:clearChoices()
    super.clearChoices(self)

    if Game.battle and Game.battle.light then
        for i = 1, 4 do
            Game.battle.battle_ui.choice_option[i]:setText("")
        end
    end
    if self.undertale then
        self.current_choice = 1
        Input.clear("confirm")
    end
end

function Choicebox:setColors(main, hover)
    if self.undertale then
        main = main or { 1, 1, 1 }
        hover = hover or { 1, 1, 1 }
    end

    super.setColors(self, main, hover)
end

function Choicebox:update()
    local old_choice = self.current_choice

    if Game.battle and Game.battle.light then
        if self.undertale then
            if Input.pressed("left") then self.current_choice = 1 end
            if Input.pressed("right") then self.current_choice = 2 end

            if Input.pressed("left") and old_choice == 1 then self.current_choice = 2 end
            if Input.pressed("right") and old_choice == 2 then self.current_choice = 1 end

            if self.ui_sound ~= false and self.current_choice ~= old_choice then
                Game.battle.ui_move:stop()
                Game.battle.ui_move:play()
            end
        else
            if Input.pressed("left") then self.current_choice = 1 end
            if Input.pressed("right") then self.current_choice = 2 end
            if Input.pressed("up") then self.current_choice = 3 end
            if Input.pressed("down") then self.current_choice = 4 end
        end

        if self.current_choice > #self.choices then
            self.current_choice = old_choice
        end

        for i = 1, 4 do
            Game.battle.battle_ui.choice_option[i]:setColor(self.main_colors[i])
            if self.current_choice == i then
                Game.battle.battle_ui.choice_option[i]:setColor(self.hover_colors[i])
            end
        end

        if Input.pressed("confirm") then
            if self.current_choice ~= 0 then
                self.selected_choice = self.current_choice

                self.done = true
                Game.battle:toggleSoul(false)

                if not self.battle_box then
                    self:remove()
                    if Game.world:hasCutscene() then
                        Game.world.cutscene.choice = self.selected_choice
                        Game.world.cutscene:tryResume()
                    end
                else
                    self:clearChoices()
                    self.active = false
                    self.visible = false
                    Game.battle.battle_ui.encounter_text.active = true
                    Game.battle.battle_ui.encounter_text.visible = true
                    if Game.battle:hasCutscene() then
                        Game.battle.cutscene.choice = self.selected_choice
                        Game.battle.cutscene:tryResume()
                    end
                end
            end
        end

        Object.update(self)
    else
        if self.undertale then
            for i = 4, 3, -1 do
                table.remove(self.choices, i)
            end
        end

        super.update(self)

        if self.undertale then
            if Input.pressed("left") and old_choice == 1 then self.current_choice = 2 end
            if Input.pressed("right") and old_choice == 2 then self.current_choice = 1 end

            if self.ui_sound ~= false and self.current_choice ~= old_choice then
                Game.battle.ui_move:stop()
                Game.battle.ui_move:play()
            end
        end
    end
end

function Choicebox:draw()
    if Game.battle and Game.battle.light then
        Object.draw(self)

        local soul_positions = {}
        if self.undertale then
            if self.choices[1] then
                Game.battle.battle_ui.choice_option[1]:setPosition(48, 30 - (select(2, string.gsub(self.choices[1], "\n", "")) >= 2 and self.font:getHeight() or 0))
                Game.battle.battle_ui.choice_option[1]:setText("[font:main_mono][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. self.choices[1])
            end
            if self.choices[2] then
                Game.battle.battle_ui.choice_option[2]:setPosition(304, 30 - (select(2, string.gsub(self.choices[2], "\n", "")) >= 2 and self.font:getHeight() or 0))
                Game.battle.battle_ui.choice_option[2]:setText("[font:main_mono][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. self.choices[2])
            end

            soul_positions = {
                --[[ Center: ]] { 260, 318 },
                --[[ Left:   ]] { 80, 318 },
                --[[ Right:  ]] { 340, 318 },
            }
        else
            if self.choices[1] then
                Game.battle.battle_ui.choice_option[1]:setPosition(39, 20)
                Game.battle.battle_ui.choice_option[1]:setText("[font:main][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. self.choices[1])
            end
            if self.choices[2] then
                Game.battle.battle_ui.choice_option[2]:setPosition(530 - self.font:getWidth(self.choices[2]), 20)
                Game.battle.battle_ui.choice_option[2]:setText("[font:main][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. self.choices[2])
            end
            if self.choices[3] then
                Game.battle.battle_ui.choice_option[3]:setPosition(20 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(self.choices[3]) / 2), -7)
                Game.battle.battle_ui.choice_option[3]:setText("[font:main][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. self.choices[3])
            end
            if self.choices[4] then
                Game.battle.battle_ui.choice_option[4]:setPosition(20 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(self.choices[4]) / 2), 69)
                Game.battle.battle_ui.choice_option[4]:setText("[font:main][shake:" .. Mod.libs["magical-glass"].light_battle_shake_text .. "]" .. self.choices[4])
            end

            soul_positions = {
                --[[ Center: ]] { 288, 316 },
                --[[ Left:   ]] { 68, 308 },
                --[[ Right:  ]] { 591 - self.font:getWidth(self.choices[2] or "") - 32, 308 },
                --[[ Top:    ]] { 81 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(self.choices[3] or "") / 2) - 32, 281 },
                --[[ Bottom: ]] { 81 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(self.choices[4] or "") / 2) - 32, 357 }
            }
        end

        local arena_ox, arena_oy = Game.battle.arena:getOffset()

        local heart_x = arena_ox + soul_positions[self.current_choice + 1][1]
        local heart_y = arena_oy + soul_positions[self.current_choice + 1][2]

        Game.battle:toggleSoul(true)
        Game.battle.soul:setPosition(heart_x, heart_y)
    elseif self.undertale then
        Object.draw(self)

        love.graphics.setFont(self.font)
        if self.choices[1] then
            Draw.setColor(self.main_colors[1])
            if self.current_choice == 1 then Draw.setColor(self.hover_colors[1]) end
            love.graphics.print(self.choices[1], 36, 24 - (select(2, string.gsub(self.choices[1], "\n", "")) >= 2 and self.font:getHeight() or 0))
        end
        if self.choices[2] then
            Draw.setColor(self.main_colors[2])
            if self.current_choice == 2 then Draw.setColor(self.hover_colors[2]) end
            love.graphics.print(self.choices[2], 528 - self.font:getWidth(self.choices[2]), 24 - (select(2, string.gsub(self.choices[2], "\n", "")) >= 2 and self.font:getHeight() or 0))
        end

        local soul_positions = {
            --[[ Center: ]] { 224, 38 },
            --[[ Left:   ]] { 4,   34 },
            --[[ Right:  ]] { 528 - self.font:getWidth(self.choices[2] or "") - 32, 34 }
        }

        local heart_x = soul_positions[self.current_choice + 1][1]
        local heart_y = soul_positions[self.current_choice + 1][2]

        Draw.setColor(Game:getSoulColor())
        Draw.draw(self.heart, heart_x, heart_y, 0, 2, 2)
    else
        super.draw(self)
    end
end

return Choicebox