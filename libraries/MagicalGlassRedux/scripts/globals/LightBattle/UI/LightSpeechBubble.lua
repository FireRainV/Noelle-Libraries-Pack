local LightSpeechBubble, super = Class(SpeechBubble)

function LightSpeechBubble:init(text, x, y, options, speaker)
    Object.init(self, x, y, 0, 0)

    options = options or {}

    self.layer = LIGHT_BATTLE_LAYERS["above_arena_border"] - 1

    self.text = DialogueText("", 0, 0, 1, 1, {
        font = options["font"] or "plain",
        style = "none",
        line_offset = 0,
    })
    self:addChild(self.text)

    self.text_width = 1
    self.text_height = 1

    self.right = options["right"]

    self.speaker = speaker
    self.actor = options["actor"]
    if type(self.actor) == "string" then
        self.actor = Registry.createActor(self.actor)
    end
    if self.speaker then
        self.actor = self.speaker.actor
        self.speaker.bubble = self
    end
    self.text.actor = self.actor

    self:setCallback(options["after"])
    self:setLineCallback(options["line_callback"])

    self.text:registerCommand("noautoskip", function(text, node)
        Game.battle.use_textbox_timer = false
    end)
    self.text:registerCommand("emote", function(text, node)
        speaker:onEmote(node.arguments[1])
    end)

    self:setStyle(options["style"])
    self:setText(text)
end

function LightSpeechBubble:setStyle(style)
    self.bubble = style and "lightbattle/" .. style or "lightbattle/round"
    self.bubble_data = Assets.getBubbleData(self.bubble)
    self.auto = self.bubble_data["auto"] or false -- Whether the bubble automatically resizes.
    self.padding = self.bubble_data["text_padding"] or { left = 0, top = 0, right = 0, bottom = 0 }
    self.text_bounds = self.bubble_data["text_bounds"] or { left = 0, top = 0, width = 0, height = 0 }
    self.text_color = self.bubble_data["text_color"] or { 0, 0, 0, 1 }
    self.bubble_speed = self.bubble_data["speed"] or 0.5
    self.bubble_anim_timer = 0
    self.text:setTextColor(unpack(self.text_color))
    if self.auto then
        self.sprites = {
            left         = self.bubble_data["sprites"]["left"        ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["left"        ]),
            right        = self.bubble_data["sprites"]["right"       ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["right"       ]),
            top          = self.bubble_data["sprites"]["top"         ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["top"         ]),
            bottom       = self.bubble_data["sprites"]["bottom"      ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["bottom"      ]),
            top_left     = self.bubble_data["sprites"]["top_left"    ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["top_left"    ]),
            top_right    = self.bubble_data["sprites"]["top_right"   ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["top_right"   ]),
            bottom_left  = self.bubble_data["sprites"]["bottom_left" ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["bottom_left" ]),
            bottom_right = self.bubble_data["sprites"]["bottom_right"] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["bottom_right"]),
            tail         = self.bubble_data["sprites"]["tail"        ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["tail"        ]),
            fill         = self.bubble_data["sprites"]["fill"        ] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"]["fill"        ])
        }
    else
        self.sprites = self.bubble_data["sprites"] and Assets.getFramesOrTexture("bubbles/lightbattle/" .. self.bubble_data["sprites"])
    end

    self.text.x = self.text_bounds["left"] or 0
    self.text.y = self.text_bounds["top"]  or 0
    if not self.auto then
        self.text.width  = self.text_bounds["width"]  or SCREEN_WIDTH
        self.text.height = self.text_bounds["height"] or SCREEN_HEIGHT
        self.text.wrap = true
        self.text.auto_size = false
    else
        self.text.wrap = false
        self.text.auto_size = true
    end

    if self.bubble_data["origin"] then
        self:setOrigin(self.bubble_data["origin"][1], self.bubble_data["origin"][2])
    elseif self.right then
        self:setOrigin(0, 0.5)
    else
        self:setOrigin(1, 0.5)
    end

    if self.right and self.auto then
        local left_width, _ = self:getSpriteSize("left")
        self.text.x = self:getTailWidth() + self.padding["left"] + left_width + 1
    end

    self:updateSize()
end

function LightSpeechBubble:draw()
    if not self.auto then
        if self.right then
            local width = self:getSpriteSize()
            Draw.draw(self:getSprite(), width - 12, 0, 0, -1, 1)
        else
            Draw.draw(self:getSprite(), 0, 0)
        end

        Object.draw(self)
    else
        super.draw(self)
    end
end

return LightSpeechBubble