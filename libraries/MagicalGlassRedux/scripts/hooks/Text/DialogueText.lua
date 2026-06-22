local DialogueText, super = HookSystem.hookScript(DialogueText)

function DialogueText:init(text, x, y, w, h, options)
    options = options or {}

    -- Prevent playing the same voice sound at the same time
    self.default_sound = options["default_sound"] or "default"
    self.no_sound_overlap = options["no_sound_overlap"] or false
    if options["no_sound_overlap"] == nil and Game.battle and Game.battle.light then
        self.no_sound_overlap = true
    end

    super.init(self, text, x, y, w, h, options)
end

function DialogueText:resetState()
    super.resetState(self)
    self.state["typing_sound"] = self.default_sound
end

-- In Undertale, the first voice sound will always play, even if you skip it immediately
function DialogueText:playTextSound(current_node)
    if self:isSkipping() and (Input.down("cancel") and Kristal.getLibConfig("magical-glass", "undertale_text_skipping") ~= true or self.played_first_sound) then
        return
    end

    if current_node.type ~= "character" then
        return
    end

    local no_sound = { "\n", " ", "^", "!", ".", "?", ",", ":", "/", "\\", "|", "*" }

    if (TableUtils.contains(no_sound, current_node.character)) then
        return
    end

    if (self.state.typing_sound ~= nil) and (self.state.typing_sound ~= "") then
        self.played_first_sound = true
        if Kristal.callEvent(KRISTAL_EVENT.onTextSound, self.state.typing_sound, current_node, self.state) then
            return
        end
        if self:getActor()
        and (self:getActor():getVoice() or "default") == self.state.typing_sound
        and self:getActor():onTextSound(current_node, self.state) then
            return
        end

        if not self.no_sound_overlap then
            Assets.playSound("voice/" .. self.state.typing_sound)
        else
            Assets.stopAndPlaySound("voice/" .. self.state.typing_sound)
        end
    end
end

-- Uses the Undertale variation of text skipping (can't skip with the 'menu' button for example)
function DialogueText:skip()
    if Kristal.getLibConfig("magical-glass", "undertale_text_skipping") ~= true or Input.pressed("cancel") then
        super.skip(self)
    end
end

function DialogueText:skipHeld()
    if Kristal.getLibConfig("magical-glass", "undertale_text_skipping") == true then
        return Input.down("cancel")
    end
    return super.skipHeld(self)
end

-- Support for light battler parts
function DialogueText:updateTalkSprite(typing)
    if self.talk_sprite_parts then
        if isClass(self.talk_sprite_parts) then self.talk_sprite_parts = { self.talk_sprite_parts } end
        for _, talk_sprite in ipairs(self.talk_sprite_parts) do
            local can_talk, talk_speed = true, 0.25
            if talk_sprite:includes(ActorSprite) then
                if typing and not self.last_talking then
                    talk_sprite.actor:onTalkStart(self, talk_sprite)
                end
                can_talk, talk_speed = talk_sprite:canTalk()
            end
            if can_talk then
                if typing and not talk_sprite.playing then
                    talk_sprite:play(talk_speed, true)
                elseif self.last_talking and not typing then
                    if talk_sprite.playing then
                        talk_sprite:stop()
                    end
                    if talk_sprite:includes(ActorSprite) then
                        talk_sprite.actor:onTalkEnd(self, talk_sprite)
                    end
                end
            elseif self.last_talking and not typing then
                if talk_sprite:includes(ActorSprite) then
                    talk_sprite.actor:onTalkEnd(self, talk_sprite)
                end
            end
        end
    end

    super.updateTalkSprite(self, typing)
end

return DialogueText