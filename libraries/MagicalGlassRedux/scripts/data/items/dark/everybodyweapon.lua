local item, super = Class("everybodyweapon", true)

function item:init()
    super.init(self)

    -- Attack sprite (only used for simple animations)
    self.attack_sprite = "effects/lightattack/slap"
    self.attack_pitch = 1.5
end

return item