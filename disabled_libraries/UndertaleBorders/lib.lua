local Lib = {}

-- for the "undertale/sepia" border, spin the flowers if the player is idle for at least 5 minutes

function Lib:init()
   -- Undertale Borders
    self.active_keys = {}
    self.flower_positions = {
        { 34, 679 },
        { 94, 939 },
        { 269, 489 },
        { 0, 319 },
        { 209, 34 },
        { 1734, 0 },
        { 1829, 359 },
        { 1789, 709 },
        { 1584, 1049 }
    }

    self.idle_time = RUNTIME * 1000
    self.idle = false
end

-- Undertale Borders
function Lib:onKeyPressed(key, is_repeat)
    if not is_repeat then
        self.active_keys[key] = true
    end
end

-- Undertale Borders
function Lib:onKeyReleased(key)
    self.active_keys[key] = nil
end

function Lib:onBorderDraw(border_sprite)
    -- Undertale Border
    if border_sprite == "undertale/sepia" then
        local idle_min = 300000
        local idle_time = 0
        local current_time = RUNTIME * 1000
        if (self.idle and current_time >= (self.idle_time + idle_min)) then
            idle_time = (current_time - (self.idle_time + idle_min))
        end

        local idle_frame = (math.floor((idle_time / 100)) % 3)

        if idle_frame > 0 then
            for index, pos in pairs(self.flower_positions) do
                local x, y = (pos[1] * BORDER_SCALE), (pos[2] * BORDER_SCALE) - 1
                local round = MathUtils.round
                love.graphics.setBlendMode("replace")
                local flower = Assets.getTexture("borders_addons/undertale/sepia/" .. tostring(index) .. ((idle_frame == 1) and "a" or "b"))
                Draw.setColor(1, 1, 1, BORDER_ALPHA)
                Draw.draw(flower, round(x), round(y), 0, BORDER_SCALE, BORDER_SCALE)
                Draw.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("alpha")
            end
        end
    end
end

function Lib:postInit()
    -- Undertale Borders
    if Utils.equal(self.active_keys, {}, false) then
        self.idle_time = 0
        self.idle = false
    else
        if not self.idle then
            self.idle_time = RUNTIME * 1000
        end
        self.idle = true
    end
end

return Lib