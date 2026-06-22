local Lib = {}

-- Get the library's (or plugin if it's loaded as one) config options
function Lib:getConfig(name)
	if Mod.libs.multiplayer then
		return Kristal.getLibConfig("multiplayer", name)
	elseif Kristal.Config["plugins/multiplayer"] and Kristal.Config["plugins/multiplayer"][name] then
		return Kristal.Config["plugins/multiplayer"][name]
	else
		return ({
			["max_players"] = 2,
			["controller_type"] = 1
		 })[name]
	end
end

function Lib:cleanup()
    -- Clear the check of whether the library is loaded as a plugin
    MULTIPLAYER_IS_PLUGIN = nil
end

function Lib:getMonsterSoul()
    -- Disables the monster soul feature in MGR since the library itself sets it on its own.
    return false
end

function Lib:init()
    -- Clear all inputs variable for the library
    self.clear_inputs = false

    -- Soul colors for players who don't have a party member to control
    self.colors = { COLORS.white, COLORS.gray, COLORS.dkgray }

    -- Clamp the amount of max players from the config option
    self.max_players = MathUtils.clamp(MULTIPLAYER_IS_PLUGIN and self:getConfig("max_players") or Kristal.getLibConfig("multiplayer", "max_players"), 1, Mod.libs["moreparty"] and 4 or 3)

    -- Store the original input bindings for restoration
    self.gamepad_bindings = Input.gamepad_bindings
    Input.gamepad_bindings = {}
    self.gamepad_pressed = {}
    self.gamepad_order = {}
end

function Lib:unload()
    -- Fix a bug where reloading the mod could cause inputs to still be processed
    Input.clear(nil, true)
end

-- Check whether any player presses a button, it will process that button as Player 1,
-- allowing all players to control the same stuff without having to add those inputs for each player separately
-- 'menu_mode' is set when it's currently a menu
function Lib:sharedControl(menu_mode)
    local play_mode = not OVERLAY_OPEN and not Game.lock_movement and Game.state == "OVERWORLD" and Game.world.player and Game.world.player.world.state == "GAMEPLAY"
    if menu_mode then
        return Game.world.player and play_mode
    else
        return Game.world.player and not play_mode and Game.state ~= "BATTLE" or Game.state == "BATTLE" and Game.battle:getState() ~= "DEFENDING" and Game.battle:getState() ~= "ATTACKING" or not Game.world.player and Game.state ~= "BATTLE"
    end
end

-- Handle shared controls
function Lib:onKeyPressed(key, is_repeat)
    if not is_repeat then
        if Lib:sharedControl(false) then
            for i = 2, Lib.max_players do
                if Game.state ~= "BATTLE" or Game.battle and (Game.battle.current_selecting == i or Game.battle.current_selecting == 0) then
                    if Input.is("p" .. i .. "_left", key) then
                        Input.onKeyPressed(Input.getBoundKeys("left", false)[1])
                    end
                    if Input.is("p" .. i .. "_up", key) then
                        Input.onKeyPressed(Input.getBoundKeys("up", false)[1])
                    end
                    if Input.is("p" .. i .. "_down", key) then
                        Input.onKeyPressed(Input.getBoundKeys("down", false)[1])
                    end
                    if Input.is("p" .. i .. "_right", key) then
                        Input.onKeyPressed(Input.getBoundKeys("right", false)[1])
                    end
                    if Input.is("p" .. i .. "_confirm", key) then
                        Input.onKeyPressed(Input.getBoundKeys("confirm", false)[1])
                    end
                    if Input.is("p" .. i .. "_cancel", key) then
                        Input.onKeyPressed(Input.getBoundKeys("cancel", false)[1])
                    end
                    if Input.is("p" .. i .. "_menu", key) then
                        Input.onKeyPressed(Input.getBoundKeys("menu", false)[1])
                    end
                end
            end
        elseif Lib:sharedControl(true) then
            for i = 2, Lib.max_players do
                if Input.is("p" .. i .. "_menu", key) then
                    Input.onKeyPressed(Input.getBoundKeys("menu", false)[1])
                end
            end
        end
    end
end

-- Handle shared controls
function Lib:onKeyReleased(key)
    if Lib:sharedControl(false) then
        for i = 2, Lib.max_players do
            if Game.state ~= "BATTLE" or Game.battle and (Game.battle.current_selecting == i or Game.battle.current_selecting == 0) then
                if Input.is("p" .. i .. "_left", key) then
                    Input.onKeyReleased(Input.getBoundKeys("left", false)[1])
                    Lib.clear_inputs = true
                end
                if Input.is("p" .. i .. "_up", key) then
                    Input.onKeyReleased(Input.getBoundKeys("up", false)[1])
                    Lib.clear_inputs = true
                end
                if Input.is("p" .. i .. "_down", key) then
                    Input.onKeyReleased(Input.getBoundKeys("down", false)[1])
                    Lib.clear_inputs = true
                end
                if Input.is("p" .. i .. "_right", key) then
                    Input.onKeyReleased(Input.getBoundKeys("right", false)[1])
                    Lib.clear_inputs = true
                end
                if Input.is("p" .. i .. "_confirm", key) then
                    Input.onKeyReleased(Input.getBoundKeys("confirm", false)[1])
                    Lib.clear_inputs = true
                end
                if Input.is("p" .. i .. "_cancel", key) then
                    Input.onKeyReleased(Input.getBoundKeys("cancel", false)[1])
                    Lib.clear_inputs = true
                end
                if Input.is("p" .. i .. "_menu", key) then
                    Input.onKeyReleased(Input.getBoundKeys("menu", false)[1])
                    Lib.clear_inputs = true
                end
            end
        end
    elseif Lib:sharedControl(true) then
        for i = 2, Lib.max_players do
            if Input.is("p" .. i .. "_menu", key) then
                Input.onKeyReleased(Input.getBoundKeys("menu", false)[1])
            end
        end
    end
end

-- Setup controllers
-- The order of each player depends on which player pressed any button first
function Lib:gamepad_to_game_control(pressed, button, joystick)
    -- Unique key based on joystick and button
    local key_prefix = "joy#" .. joystick .. "_"

    -- Add joystick to gamepad_order if it's new
    if pressed and not TableUtils.contains(self.gamepad_order, joystick) then
        table.insert(self.gamepad_order, joystick)
    end

    local i = TableUtils.getIndex(self.gamepad_order, joystick)
    if i then
        local key = key_prefix .. button  -- Unique key for this joystick and button
        if pressed and not (i == 1 and Game.battle and Game.battle.current_selecting > 1 and Game.battle.current_selecting <= self.max_players) then
            if i == 1 and not self.gamepad_pressed[key] and Input.getBoundKeys(button, false) and #Input.getBoundKeys(button, false) > 0 then
                Input.onKeyPressed(Input.getBoundKeys(button, false)[1])
                self.gamepad_pressed[key] = true
            end
            if i > 1 and not self.gamepad_pressed[key] and Input.getBoundKeys("p" .. i .. "_" .. button, false) and #Input.getBoundKeys("p" .. i .. "_" .. button, false) > 0 then
                Input.onKeyPressed(Input.getBoundKeys("p" .. i .. "_" .. button, false)[1])
                self.gamepad_pressed[key] = true
            end
        else
            if i == 1 and self.gamepad_pressed[key] and Input.getBoundKeys(button, false) and #Input.getBoundKeys(button, false) > 0 then
                Input.onKeyReleased(Input.getBoundKeys(button, false)[1])
                self.gamepad_pressed[key] = false
            end
            if i > 1 and self.gamepad_pressed[key] and Input.getBoundKeys("p" .. i .. "_" .. button, false) and #Input.getBoundKeys("p" .. i .. "_" .. button, false) > 0 then
                Input.onKeyReleased(Input.getBoundKeys("p" .. i .. "_" .. button, false)[1])
                self.gamepad_pressed[key] = false
            end
        end
    end
end

-- Setup controllers' inputs
function Lib:preUpdate()
    local joysticks = love.joystick.getJoysticks()
    local stick_threshold = 0.5
    local trigger_threshold = 0.9

    for _, joystick in ipairs(joysticks) do
        for btn, input in pairs(self.gamepad_bindings) do
            local pressed = false
            for j, gamepadkey in ipairs(input) do
                local key = select(2, StringUtils.startsWith(gamepadkey, "gamepad:"))
                if key then
                    if StringUtils.sub(key, 1, 2) == "ls" or StringUtils.sub(key, 1, 2) == "rs" or StringUtils.sub(key, -7) == "trigger" then
                        local side = "left"
                        local stick = "ls"
                        if StringUtils.sub(key, 1, 2) == "rs" then
                            side = "right"
                            stick = "rs"
                        elseif StringUtils.sub(key, -7) == "trigger" then
                            side = StringUtils.sub(key, 1, -8)
                            stick = nil
                        end

                        if stick and (key == stick .. "left" and joystick:getGamepadAxis(side .. "x") < -stick_threshold or
                        key == stick .. "right" and joystick:getGamepadAxis(side .. "x") > stick_threshold or
                        key == stick .. "up" and joystick:getGamepadAxis(side .. "y") < -stick_threshold or
                        key == stick .. "down" and joystick:getGamepadAxis(side .. "y") > stick_threshold) or
                        not stick and key == side .. "trigger" and joystick:getGamepadAxis("trigger" .. side) > trigger_threshold then
                            pressed = true
                        end
                    else
                        if joystick:isGamepadDown(key) then
                            pressed = true
                        end
                    end
                end
            end
            self:gamepad_to_game_control(pressed, btn, joystick:getID())
        end
    end

    -- Clear all inputs
    if Lib.clear_inputs and not Lib:sharedControl(false) then
        Input.clear(nil, true)
        Lib.clear_inputs = false
    end
end

return Lib