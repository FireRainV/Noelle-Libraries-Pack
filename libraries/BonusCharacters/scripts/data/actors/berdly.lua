local actor, super = Class(Actor, "party/berdly")

function actor:init()
    super.init(self)

    -- Display name (optional)
    self.name = "Berdly"

    -- Width and height for this actor, used to determine its center
    self.width = 24
    self.height = 40

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = { 2, 27, 20, 14 }

    -- A table that defines where the Soul should be placed on this actor if they are a player.
    -- First value is x, second value is y.
    self.soul_offset = { 13, 23 }

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = { 0, 1, 1 }

    -- Path to this actor's sprites (defaults to "")
    self.path = "party/berdly/dark"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "walk"

    -- Sound to play when this actor speaks (optional)
    self.voice = "berdly"
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = "face/berdly"
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = { -10, 0 }

    -- Whether this actor as a follower will blush when close to the player
    self.can_blush = false

    -- Table of sprite animations
    self.animations = {
        -- Movement animations
        ["fall"]               = { "fall", 4 / 30, true },

        -- Battle animations
        ["battle/idle"]         = { "battle/idle", 0.2, true },

        ["battle/attack"]       = { "battle/attack", 1 / 15, false },
        ["battle/act"]          = { "battle/act", 1 / 15, false },
        ["battle/spell"]        = { "battle/spell", 1 / 15, false, next="battle/idle" },
        ["battle/item"]         = { "battle/item", 1 / 12, false, next="battle/idle" },
        ["battle/spare"]        = { "battle/act", 1 / 15, false, next="battle/idle" },

        ["battle/attack_ready"] = { "battle/attackready", 0.2, true },
        ["battle/act_ready"]    = { "battle/actready", 0.2, true },
        ["battle/spell_ready"]  = { "battle/spellready", 0.2, true },
        ["battle/item_ready"]   = { "battle/itemready", 0.2, true },
        ["battle/defend_ready"] = { "battle/defend", 1 / 15, false },

        ["battle/act_end"]      = { "battle/actend", 1 / 15, false, next="battle/idle" },

        ["battle/super_jump"]   = { "battle/super_jump", 1 / 15, false, next="battle/super_jump_loop" },
        ["battle/super_jump_loop"] = { "battle/super_jump_loop", 1 / 15, true },

        ["battle/hurt"]         = { "battle/hurt", 1 / 15, false, temp=true, duration=0.5 },
        ["battle/defeat"]       = { "battle/defeat", 1 / 15, false },
        ["battle/swooned"]      = { "battle/defeat", 1 / 15, false },

        ["battle/transition"]   = { self.default .. "/right_1", 1 / 15, false },
        ["battle/intro"]        = { "battle/attack", 1 / 15, true },
        ["battle/victory"]      = { "battle/victory", 1 / 10, false },
        ["battle/transition_out"] = { "battle/transition_out", 1 / 15, false },
        ["battle/flee"]         = { "battle/hurt", 1 / 15 },

        -- Cutscene animations
        ["jump_ball"]           = { "ball", 1 / 15, true },
    }

    -- Tables of sprites to change into in mirrors
    self.mirror_sprites = {
        ["walk/down"] = "walk/up",
        ["walk/up"] = "walk/down",
        ["walk/left"] = "walk/left",
        ["walk/right"] = "walk/right",

        ["walk_unhappy/down"] = "walk_unhappy/up",
        ["walk_unhappy/up"] = "walk_unhappy/down",
        ["walk_unhappy/left"] = "walk_unhappy/left",
        ["walk_unhappy/right"] = "walk_unhappy/right",
    }

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {
        -- Movement offsets
        ["walk/left"] = { 1, 0 },
        ["walk/right"] = { 1, 0 },
        ["walk/up"] = { 1, 0 },
        ["walk/down"] = { 1, 0 },

        ["walk_unhappy/down"] = { 1, 0 },
        ["walk_unhappy/left"] = { 1, 0 },
        ["walk_unhappy/right"] = { 1, 0 },
        ["walk_unhappy/up"] = { 1, 0 },

        -- Battle offsets
        ["battle/idle"] = { -5, -1 },

        ["battle/attack"] = { -15, -25 },
        ["battle/attackready"] = { -15, -25 },
        ["battle/act"] = { -6, -6 },
        ["battle/actend"] = { -6, -6 },
        ["battle/actready"] = { -6, -6 },
        ["battle/spell"] = { -30, -38 },
        ["battle/spellready"] = { -25, -23 },
        ["battle/super_jump"] = { -42, -61 },
        ["battle/super_jump_loop"] = { -42, -61 },
        ["battle/item"] = { -20, -13 },
        ["battle/itemready"] = { -20, -15 },
        ["battle/defend"] = { -30, -20 },

        ["battle/defeat"] = { -8, -5 },
        ["battle/hurt"] = { -5, -6 },

        ["battle/intro"] = { -35, -35 },
        ["battle/victory"] = { -37, -14 },
    }
end

return actor