local DarkMenu, super = HookSystem.hookScript(DarkMenu)

function DarkMenu:onKeyPressed(key)
    local before_selected = self.selected_party

    super.onKeyPressed(self, key)

    if not self.animation_done then return end

    if self.state == "PARTYSELECT" and self.party_select_mode == "SINGLE" then
        local old_selected = self.selected_party
        if Input.is("up", key) then
            local selected_party, success = Mod.libs["moreparty"]:partySelectMovement(self.selected_party, "up")
            if success then
                self.selected_party = selected_party
                self.ui_move:stop()
                self.ui_move:play()
            end
        end
        if Input.is("down", key) then
            local selected_party, success = Mod.libs["moreparty"]:partySelectMovement(self.selected_party, "down")
            if success then
                self.selected_party = selected_party
                self.ui_move:stop()
                self.ui_move:play()
            end
        end
        if Input.is("right", key) then
            local selected_party, success = Mod.libs["moreparty"]:partySelectMovement(before_selected, "right")
            if success then
                self.selected_party = selected_party
            end
        end
        if Input.is("left", key) then
            local selected_party, success = Mod.libs["moreparty"]:partySelectMovement(before_selected, "left")
            if success then
                self.selected_party = selected_party
            end
        end
        if old_selected ~= self.selected_party then
            self:updateSelectedBoxes()
        end
    end
end

return DarkMenu