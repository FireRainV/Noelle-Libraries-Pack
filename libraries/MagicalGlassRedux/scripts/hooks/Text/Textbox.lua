local Textbox, super = HookSystem.hookScript(Textbox)

function Textbox:init(x, y, width, height, default_font, default_font_size, battle_box)
    super.init(self, x, y, width, height, default_font, default_font_size, battle_box)

    if battle_box then
        if Game.battle.light then
            -- Custom reactions, portraits and text positions for light battles
            Mod.libs["magical-glass"].ORIG_REACTION_X_BATTLE = self.REACTION_X_BATTLE
            Mod.libs["magical-glass"].ORIG_REACTION_Y_BATTLE = self.REACTION_Y_BATTLE

            self.REACTION_X_BATTLE = Mod.libs["magical-glass"].REACTION_X_BATTLE
            self.REACTION_Y_BATTLE = Mod.libs["magical-glass"].REACTION_Y_BATTLE

            self.face_x = 6
            self.face_y = -3

            self.text_x = 0
            self.text_y = -2

            self.face:setPosition(self.face_x, self.face_y)
            self.text:setPosition(self.text_x, self.text_y)
        else
            -- Reset back to default values
            self.REACTION_X_BATTLE = Mod.libs["magical-glass"].ORIG_REACTION_X_BATTLE
            self.REACTION_Y_BATTLE = Mod.libs["magical-glass"].ORIG_REACTION_Y_BATTLE
        end
    end
end

return Textbox