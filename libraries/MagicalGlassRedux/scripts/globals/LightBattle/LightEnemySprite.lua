local LightEnemySprite, super = Class(Object)

function LightEnemySprite:init(actor, enemy)
    if type(actor) == "string" then
        actor = Registry.createActor(actor)
    end

    super.init(self)

    self.actor = actor
    self.enemy = enemy
    self.parts = self.actor.light_battler_parts

    for _, part in pairs(self.parts) do
        if part.init then
            part:init(part)
        end
    end

    if actor then
        actor:onSpriteInit(self)
    end

    self:resetSprite()
end

function LightEnemySprite:setActor(actor)
    if type(actor) == "string" then
        actor = Registry.createActor(actor)
    end

    if self.actor and self.actor.id == actor.id then
        return
    end

    for _, child in ipairs(self.children) do
        self:removeChild(child)
    end

    self.actor = actor
    self.parts = self.actor.light_battler_parts

    self.width = actor:getWidth()
    self.height = actor:getHeight()
    self.path = actor:getSpritePath()

    actor:onSpriteInit(self)
    self:resetSprite()
end

function LightEnemySprite:resetSprite(ignore_actor_callback)
    if not ignore_actor_callback and self.actor:preResetSprite(self) then
        return
    end

    for _, child in ipairs(self.children) do
        self:removeChild(child)
    end

    for _, part in pairs(self.parts) do
        if not part.sprite_func then
            part.sprite_func = part.sprite
        end
        part.sprite = nil

        if part.sprite_func then
            if type(part.sprite_func) == "string" then
                part.sprite = Sprite(part.sprite_func)
            elseif type(part.sprite_func) == "function" then
                if type(part.sprite_func()) == "string" then
                    part.sprite = Sprite(part.sprite_func())
                elseif part.sprite_func():includes(Sprite) then
                    part.sprite = part.sprite_func()
                end
            end
            part.sprite.debug_select = false
            self:addChild(part.sprite)
        else
            if self.actor:getDefaultAnim() then
                part.sprite = Sprite(self.actor.path .. "/" .. self.actor:getDefaultAnim())
            elseif self.actor:getDefaultSprite() then
                part.sprite = Sprite(self.actor.path .. "/" .. self.actor:getDefaultSprite())
            else
                part.sprite = Sprite(self.actor.path .. "/" .. self.actor:getDefault())
            end
            part.sprite.debug_select = false
            self:addChild(part.sprite)
        end
    end

    self.actor:onResetSprite(self)
end

function LightEnemySprite:flash(offset_x, offset_y, layer)
    if ClassUtils.getClassName(self.enemy:getActiveSprite()) == "LightEnemySprite" then
        local flashed_sprites = {}
        for _, part in pairs(self.parts) do
            table.insert(flashed_sprites, part.sprite:flash(offset_x, offset_y, layer))
        end
        return flashed_sprites
    else
        return self.enemy:getActiveSprite():flash(offset_x, offset_y, layer)
    end
end

-- Emotes need to be in a folder that's named the same as emote name and have the new sprite parts with the same name as the original inside that folder
-- If the new part doesn't exist, it will stay the same as before
function LightEnemySprite:onEmote(emote)
    self:resetSprite()
    local success = false
    if emote and emote ~= "reset" then
        if self.actor:getAnimation(emote) then
            self.enemy.overlay_sprite:setAnimation(emote)
            success = true
        else
            for _, part in pairs(self.parts) do
                local full_path = Assets.getFramesFor(part.sprite.texture_path) or part.sprite.texture_path

                local path_tbl = StringUtils.splitFast(full_path, "/")

                local name = table.remove(path_tbl, #path_tbl)
                local path = table.concat(path_tbl, "/")

                if Assets.getFramesOrTexture(path .. "/" .. emote .. "/" .. name) then
                    part.sprite:setSprite(path .. "/" .. emote .. "/" .. name)
                    success = true
                end
            end
        end
    else
        success = nil
    end

    return success
end

function LightEnemySprite:getPart(id)
    return self.parts[id] and self.parts[id].sprite or nil
end

function LightEnemySprite:update()
    for _, part in pairs(self.parts) do
        if part.update then
            part:update(part)
        end
    end

    -- Talking animation
    if self.enemy.bubble then
        if self.enemy.talk_sprite == true then
            self.enemy.bubble.text.talk_sprite_parts = self.parts
        elseif type(self.enemy.talk_sprite) == "table" then
            self.enemy.bubble.text.talk_sprite_parts = {}
            for _, part in ipairs(self.enemy.talk_sprite) do
                table.insert(self.enemy.bubble.text.talk_sprite_parts, self:getPart(part))
            end
        elseif type(self.enemy.talk_sprite) == "string" then
            self.enemy.bubble.text.talk_sprite_parts = self:getPart(self.enemy.talk_sprite)
        else
            self.enemy.bubble.text.talk_sprite_parts = nil
        end
    end

    super.update(self)

    self.actor:onSpriteUpdate(self)
end

return LightEnemySprite