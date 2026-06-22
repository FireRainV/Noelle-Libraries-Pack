local plugin = love.filesystem.load(Kristal.Mods.data.multiplayer.path .. "/lib.lua")()

plugin.init = HookSystem.override(plugin.init, function(orig, self, ...)
    -- Checks whether the library is loaded as a plugin
    MULTIPLAYER_IS_PLUGIN = true

    orig(self, ...)
end)

return plugin