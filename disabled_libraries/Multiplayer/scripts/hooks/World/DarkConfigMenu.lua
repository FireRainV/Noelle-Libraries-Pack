local DarkConfigMenu, super = HookSystem.hookScript(DarkConfigMenu)

-- Allow binding new controls for controllers in the inputs config menu
-- The new controls will be applied to all players
function DarkConfigMenu:update()
    if self.state == "MAIN" and Input.pressed("confirm") and self.currently_selected == 2 then
        Input.gamepad_bindings = Mod.libs["multiplayer"].gamepad_bindings
        Mod.libs["multiplayer"].gamepad_bindings = {}
    end

    super.update(self)
end

function DarkConfigMenu:onKeyPressed(key)
    local clear_gamepad = false

    if self.state == "CONTROLS" and Input.pressed("confirm") and self.currently_selected == 9 then
        Mod.libs["multiplayer"].gamepad_bindings = Input.gamepad_bindings
        clear_gamepad = true
    end

    super.onKeyPressed(self, key)

    if clear_gamepad then
        Input.gamepad_bindings = {}
    end
end

return DarkConfigMenu