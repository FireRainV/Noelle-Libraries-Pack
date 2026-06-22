if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local RandomEncounter, super = HookSystem.hookScript("RandomEncounter")

-- Alert other players when a random encounter starts
function RandomEncounter:start()
    super.start(self)

    if self.bubble then
        for _, player in ipairs(Game.world.other_players) do
            player:alert(nil, { sprite = self.bubble, play_sound = false })
        end
    end
end

return RandomEncounter