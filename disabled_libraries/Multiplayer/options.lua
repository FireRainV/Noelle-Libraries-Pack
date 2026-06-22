local OptionsHandler, super = Class(StateClass)

-- Active when using the libray as a plugin
function OptionsHandler:init(menu)
    self.menu = menu
    if Kristal.Config["plugins/multiplayer"] == nil then
        Kristal.Config["plugins/multiplayer"] = {
            max_players = 2,
			controller_type = 1
        }
    end
    self.myconfig = Kristal.Config["plugins/multiplayer"]
    self.state_manager = StateManager("NONE", self, true)

    self.options = {
		max_players = self.myconfig.max_players,
		controller_type = self.myconfig.controller_type
    }
    self.selected_option = 1

    self.input_pos_x = 0
    self.input_pos_y = 0
end

function OptionsHandler:registerEvents()
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("keypressed", self.onKeyPressed)
    self:registerEvent("draw", self.draw)
end

-------------------------------------------------------------------------------
-- Callbacks
-------------------------------------------------------------------------------

function OptionsHandler:onEnter(old_state)
    if old_state == "MODCONFIG" then
        self.selected_option = 4

        local y_off = (4 - 1) * 32
        self.menu.heart_target_x = 45
        self.menu.heart_target_y = 147 + y_off

        return
    end

    self.options = {
		max_players = self.myconfig.max_players,
		controller_type = self.myconfig.controller_type
    }
    self.selected_option = 1

    self.input_pos_x = 0
    self.input_pos_y = 0

    self.menu.mod_config:registerOptions()

    self:setState("MENU")

    self.menu.heart_target_x = 45
    self.menu.heart_target_y = 147
end

function OptionsHandler:onKeyPressed(key, is_repeat)
    if self.state == "MENU" then
        if Input.isCancel(key) then
            self.menu:setState("plugins")
            Assets.stopAndPlaySound("ui_move")
            return
        end

        local old = self.selected_option
        if Input.is("up"   , key)                              then self.selected_option = self.selected_option - 1  end
        if Input.is("down" , key)                              then self.selected_option = self.selected_option + 1  end
        if Input.is("left" , key) and not Input.usingGamepad() then self.selected_option = self.selected_option - 1  end
        if Input.is("right", key) and not Input.usingGamepad() then self.selected_option = self.selected_option + 1  end
        if self.selected_option > 3 then self.selected_option = is_repeat and 3 or 1    end
        if self.selected_option < 1 then self.selected_option = is_repeat and 1 or 3    end

        local y_off = (self.selected_option - 1) * 32
        if self.selected_option >= 3 then
            y_off = y_off + 32
        end

        self.menu.heart_target_x = 45
        self.menu.heart_target_y = 147 + y_off

        if old ~= self.selected_option then
            Assets.stopAndPlaySound("ui_move")
        end

        if Input.isConfirm(key) then
            if self.selected_option == 1 then
                Assets.stopAndPlaySound("ui_select")
                local value = self.options.max_players - 1
				value = (value + 1)%4
				self.options.max_players = value + 1
				self.myconfig["max_players"] = self.options.max_players

            elseif self.selected_option == 2 then
                Assets.stopAndPlaySound("ui_select")
                local value = self.options.controller_type - 1
				value = (value + 1)%3
				self.options.controller_type = value + 1
				self.myconfig["controller_type"] = self.options.controller_type

            elseif self.selected_option == 3 then
                Assets.stopAndPlaySound("ui_select")
                self.menu:setState("plugins")
            end
        end

    elseif self.state == "WAIT_TIME" then
        if key == "escape" then
            self:onInputCancel()
            self:setState("MENU")
            Assets.stopAndPlaySound("ui_move")
            return
        end
	end
end

function OptionsHandler:draw()
    love.graphics.setFont(Assets.getFont("main"))
    Draw.printShadow("Multiplayer", 0, 48, 2, "center", 640)

    local menu_x = 64
    local menu_y = 128

	Draw.printShadow("Max Players:", menu_x, menu_y + (32 * 0))
	Draw.printShadow(tostring(self.options.max_players), menu_x + (32 * 12), menu_y + (32 * 0))
	Draw.printShadow("Controller Type:", menu_x, menu_y + (32 * 1))
	Draw.printShadow(({ "XBOX", "PS4", "SWITCH" })[self.options.controller_type], menu_x + (32 * 12), menu_y + (32 * 1))
    Draw.printShadow(  "Done",          menu_x, menu_y + (32 * 3))

    local off = 256

    if TextInput.active and (self.state ~= "MENU") then
        TextInput.draw({
            x = self.input_pos_x,
            y = self.input_pos_y,
            font = Assets.getFont("main"),
            print = function(text, x, y) Draw.printShadow(text, x, y) end,
        })
    end
end

-------------------------------------------------------------------------------
-- Class Methods
-------------------------------------------------------------------------------

function OptionsHandler:setState(state, ...)
    self.state_manager:setState(state, ...)
end

function OptionsHandler:onStateChange(old_state, state)
    if state == "MENU" then
        self.menu.heart_target_x = 45
    end
end

function OptionsHandler:onInputCancel()
    TextInput.input = { "" }
    TextInput.endInput()
    self:setState("MENU")
end

function OptionsHandler:onInputSubmit(id)
    Assets.stopAndPlaySound("ui_select")
    TextInput.input = { "" }
    TextInput.endInput()

    if id == "wait_time" then
        self.myconfig["wait_time"] = tonumber(self.options.wait_time[1])
    elseif id == "speed" then
        self.myconfig["speed"] = tonumber(self.options.speed[1])
    elseif id == "thunder_increment" then
        self.myconfig["thunder_increment"] = tonumber(self.options.thunder_increment[1])
    end

    Input.clear("return")

    self:setState("MENU")
end

function OptionsHandler:openInput(id, restriction)
    TextInput.attachInput(self.options[id], {
        multiline = false,
        enter_submits = true,
        clear_after_submit = false,
        text_restriction = restriction,
    })
    TextInput.submit_callback = function() self:onInputSubmit(id) end
    TextInput.text_callback = nil
end

function OptionsHandler:drawSelectionField(x, y, id, options, state)
    Draw.printShadow(options[self.options[id]], x, y)

    if self.state == state then
        Draw.setColor(COLORS.white)
        local off = (math.sin(Kristal.getTime() / 0.2) * 2) + 2
        Draw.draw(Assets.getTexture("kristal/menu_arrow_left"), x - 16 - 8 - off, y + 4, 0, 2, 2)
        Draw.draw(Assets.getTexture("kristal/menu_arrow_right"), x + 16 + 8 - 4 + off, y + 4, 0, 2, 2)
    end
end

function OptionsHandler:drawCheckbox(x, y, id)
    x = x - 8
    local checked = self.options[id]
    love.graphics.setLineWidth(2)
    Draw.setColor(COLORS.black)
    love.graphics.rectangle("line", x + 2 + 2, y + 2 + 2, 32 - 4, 32 - 4)
    Draw.setColor(checked and COLORS.white or COLORS.silver)
    love.graphics.rectangle("line", x + 2, y + 2, 32 - 4, 32 - 4)
    if checked then
        Draw.setColor(COLORS.black)
        love.graphics.rectangle("line", x + 6 + 2, y + 6 + 2, 32 - 12, 32 - 12)
        Draw.setColor(COLORS.aqua)
        love.graphics.rectangle("fill", x + 6, y + 6, 32 - 12, 32 - 12)
    end
end

function OptionsHandler:drawInputLine(name, x, y, id, leng)
    Draw.printShadow(name, x, y)
    love.graphics.setLineWidth(2)
    local line_x  = x + 128 + 32 + 16
    local line_x2 = line_x + leng - 32
    local line_y = 32 - 4 - 1 + 2
    Draw.setColor(0, 0, 0)
    love.graphics.line(line_x + 2, y + line_y + 2, line_x2 + 2, y + line_y + 2)
    Draw.setColor(COLORS.silver)
    love.graphics.line(line_x, y + line_y, line_x2, y + line_y)
    Draw.setColor(1, 1, 1)

    if self.options[id] ~= TextInput.input then
        Draw.printShadow(self.options[id][1], line_x, y)
    else
        self.input_pos_x = line_x
        self.input_pos_y = y
    end
end

return OptionsHandler