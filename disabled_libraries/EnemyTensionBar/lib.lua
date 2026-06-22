local Lib = {}

function Lib:cleanup()
    ETB_PALETTE = nil
end

function Lib:preInit()
    ETB_PALETTE = {
        ["tension_maxtext"] = { 0, 255 / 255, 255 / 255, 1 },
        ["tension_back"] = { 100 / 255, 100 / 255, 255 / 255, 1 },
        ["tension_decrease"] = { 1, 0, 0, 1 },
        ["tension_fill"] = { 200 / 255, 200 / 255, 255 / 255, 1 },
        ["tension_max"] = { 109 / 255, 153 / 255, 255 / 255, 1 },
    }
end

return Lib