local Object, super = HookSystem.hookScript(Object)

function Object:paletteSwap(...)
    -- The amount of supported amount of palette swaps for a single object
    local max_swaps = 32

    -- Check if the table is a color table
    local function isColor(t)
        return type(t) == "table"
           and type(t[1]) == "number"
           and type(t[2]) == "number"
           and type(t[3]) == "number"
    end

    -- Check if the table has 2 color tables
    local function isRange(t)
        return type(t) == "table"
           and isColor(t[1])
           and isColor(t[2])
    end

    -- Check if the color table is valid
    local function getValue(v)
        if isColor(v) then
            return v, v
        elseif isRange(v) then
            return v[1], v[2]
        else
            error("Invalid palette swap value. Must be color { r,g,b } or range { { r,g,b },{ r,g,b } }")
        end
    end

    local swaps = { ... }

    local fx = self:getFX("palette_swap")
    if #swaps == 0 then
        if fx then
            self:removeFX(fx)
        end
        return
    end
    if not fx then
        fx = self:addFX(ShaderFX("palette_swap"), "palette_swap")
    end

    for i = 1, max_swaps do
        fx.vars["enabled" .. i] = 0
        fx.vars["srcMin" .. i] = { 0, 0, 0 }
        fx.vars["srcMax" .. i] = { 0, 0, 0 }
        fx.vars["dstMin" .. i] = { 0, 0, 0 }
        fx.vars["dstMax" .. i] = { 0, 0, 0 }
    end

    local count = math.min(#swaps, max_swaps)

    for i = 1, count do
        local value = swaps[i]
        assert(type(value) == "table" and value[1] and value[2], "Each swap must be { from, to }")

        local s0, s1 = getValue(value[1])
        local d0, d1 = getValue(value[2])

        fx.vars["enabled" .. i] = 1
        fx.vars["srcMin" .. i] = s0
        fx.vars["srcMax" .. i] = s1
        fx.vars["dstMin" .. i] = d0
        fx.vars["dstMax" .. i] = d1
    end

    fx.vars.epsilon = 1 / 255
end

return Object