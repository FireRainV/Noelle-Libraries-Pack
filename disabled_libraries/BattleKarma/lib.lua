local Lib = {}

function Lib:cleanup()
    KARMA_PALETTE = nil
end

function Lib:preInit()
    KARMA_PALETTE = {
        karma = { 213 / 255, 53 / 255, 217 / 255, 1 },
        background = PALETTE["action_health_bg"],
        text = COLORS.fuchsia
    }
end

function Lib:init()
    -- Magical-Glass: Redux already has a karma feature for dark battles
    if Mod.libs["magical-glass"] then error("The library \"" .. self.info.id .. "\" is incompatible with \"" .. Mod.libs["magical-glass"].info.id .. "\"") end
end

return Lib