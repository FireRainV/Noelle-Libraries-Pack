local Arena, super = HookSystem.hookScript(Arena)

-- Sets the arena default color in the light world to white
function Arena:init(x, y, shape)
    super.init(self, x, y, shape)

    if Game:isLight() then
        self.color = { 1, 1, 1 }
    end
end

return Arena