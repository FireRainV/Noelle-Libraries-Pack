local actor, super = Class(Actor)

function actor:init()
    super.init(self)

    -- Display name (optional)
    self.name = "Dummy"

    -- Width and height for this actor, used to determine its center
    self.width = 20
    self.height = 30

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = { 0, 12, 19, 14 }

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = { 1, 0, 0 }

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = "lightenemies/dummy"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "idle"

    -- Sound to play when this actor speaks (optional)
    self.voice = nil
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite animations
    self.animations = {
        ["lightbattle/hurt"] = { "lightbattle/hurt", 1, true },
    }

    self.light_battle_width = 49
    self.light_battle_height = 53

    self:addLightBattlerPart("body", "lightbattle/body")
end

return actor