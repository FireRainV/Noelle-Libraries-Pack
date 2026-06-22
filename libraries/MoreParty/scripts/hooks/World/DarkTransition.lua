local DarkTransition, super = HookSystem.hookScript(DarkTransition)

function DarkTransition:init(final_y, options)
    super.init(self, final_y, options)

    options = options or {}

    self.character_data = {}

    local movement_table = {}
    for i, character in ipairs(self.characters) do
        table.insert(movement_table, math.floor((i + 1) / 2) * 1 * ((i % 2 == 0) and -1 or 1))
    end
    if #self.characters % 2 == 1 then
        movement_table[#movement_table] = 0
    end
    for i, character in ipairs(self.characters) do
        local x, y = character:localToScreenPos(0, 0)
        x = x / 2
        y = y / 2
        local movement = (options["movement_table"] or movement_table)[i] or 0
        local sprite_holder = self:addChild(Object(x, y))
        local data = {
            x = x,
            y = y,
            movement = movement,
            remx = 0,
            remy = 0,
            character = character,
            party = character:getPartyMember(),
            sprite_holder = sprite_holder,
            sprite_1 = sprite_holder:addChild(ActorSprite(character.actor)),
            sprite_2 = sprite_holder:addChild(ActorSprite(character.actor)),
            sprite_3 = sprite_holder:addChild(ActorSprite(character.actor))
        }
        data.sprite_1.visible = false
        data.sprite_2.visible = false
        data.sprite_3.visible = false
        table.insert(self.character_data, data)
    end

    self.radius_applied = false
    self.transition_radius = options["transition_radius"]

    if self.has_head_object then
        if self.kris_head_object then
            self.kris_head_object:remove()
            self.kris_head_object = nil
        end

        self.kris_head_object = HeadObject(
            self.head_object_sprite,
            options["head_object_off_x"] + 14 - (self.head_object_sprite:getWidth() / 2),
            options["head_object_off_y"] + -2 - (self.head_object_sprite:getHeight() / 2)
        )
        self.kris_head_object.sparkles = options["head_object_sparkles"] or 30
        self.kris_head_object.visible = true
        self.character_data[1].sprite_holder:addChild(self.kris_head_object)
    end
end

function DarkTransition:draw()
    super.draw(self)

    if self.radius and not self.radius_applied then
        self.radius_applied = true
        self.radius = self.transition_radius or 60
        for i, data in ipairs(self.character_data) do
            data.x_current = data.x
            if not self.transition_radius and i % 2 == 0 then
                self.radius = 120 / i
            end
        end
    end
end

return DarkTransition
