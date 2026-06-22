local Input, super = HookSystem.hookScript(Input)

-- Set the controller type buttons layout
function Input:getControllerType()
    return MULTIPLAYER_IS_PLUGIN and ({ "xbox", "ps4", "switch" })[self:getConfig("controller_type")] or Kristal.getLibConfig("multiplayer", "controller_type")
end

-- Use the new controller input format to take the bindings from for the button textures
function Input:getTexture(alias, gamepad)
    if Mod.libs["multiplayer"].gamepad_bindings[alias] and Mod.libs["multiplayer"].gamepad_bindings[alias][1] then
        return _G.Input.getButtonTexture(Mod.libs["multiplayer"].gamepad_bindings[alias][1])
    else
        return Assets.getTexture("kristal/buttons/unknown")
    end
end

-- Check if any controller is conntected
function Input:usingGamepad()
    return _G.Input.hasGamepad()
end

return Input