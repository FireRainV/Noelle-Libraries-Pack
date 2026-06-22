local actor, super = Class(Actor)

function actor:init()
    super.init(self)

    self.animations = {
        ["spared"] = { "spared", 0, false },
        ["hurt"] = { "hurt", 0, false }
    }

    -- Display name (optional)
    self.name = "Noelle"

    -- Width and height for this actor, used to determine its center
    self.width = 58
    self.height = 117

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    -- self.hitbox = { 0, 25, 19, 14 }

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = { 1, 1, 0 }

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = "lightenemies/noelle"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "idle"

    -- Sound to play when this actor speaks (optional)
    self.voice = "noelle"
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {}
end

return actor