local HealthBar, super = HookSystem.hookScript(HealthBar)

function HealthBar:init()
    super.init(self)

    self.view_start_row = 0
    self.selected_index = -1

    if #Game.party <= Mod.libs["moreparty"]:getPartyPerRowAmount() then return end
    self.animation_y = -126
end

function HealthBar:update()
    if #Game.party <= 3 then
        super.update(self)
        return
    end

    self.animation_timer = self.animation_timer + DTMULT
    self.auto_hide_timer = self.auto_hide_timer + DTMULT
    if Game.world.menu or Game.world:inBattle() then
        -- If we're in an overworld battle, or the menu is open, we don't want the health bar to disappear
        self.auto_hide_timer = 0
    end

    if self.auto_hide_timer > 60 then -- After two seconds outside of a battle, we hide the health bar
        self:transitionOut()
    end

    local max_time = self.animate_out and 3 or 8

    if self.animation_timer > max_time + 1 then
        self.animation_done = true
        self.animation_timer = max_time + 1
        if self.animate_out then
            Game.world.healthbar = nil
            self:remove()
            return
        end
    end

    if not self.animate_out then
        if self.animation_y < 0 then
            if self.animation_y > -103 then
                self.animation_y = self.animation_y + math.ceil(-self.animation_y / 2.5) * DTMULT
            else
                self.animation_y = self.animation_y + 30 * DTMULT
            end
        else
            self.animation_y = 0
        end
    else
        if self.animation_y > -126 then
            if self.animation_y > 0 then
                self.animation_y = self.animation_y - math.floor(self.animation_y / 2.5) * DTMULT
            else
                self.animation_y = self.animation_y - 30 * DTMULT
            end
        else
            self.animation_y = -126
        end
    end

    self.y = 480 - (self.animation_y + 63)

    -- sliding Window
    if self.action_boxes then
        local per_row = Mod.libs["moreparty"]:getPartyPerRowAmount()
        local row_height = 44
        local party_count = #Game.party
        local two_by_two = Mod.libs["moreparty"]:getTwoByTwo(party_count)
        local boxes_per_row = two_by_two and 2 or per_row

        local double_row = math.ceil(party_count / per_row) > 1
        local realW = ((SCREEN_WIDTH - 1) / per_row)

        -- find which box is currently selected
        if Game.world.menu then
            self.selected_index = -1
            for k, v in ipairs(self.action_boxes) do
                if v.selected then
                    self.selected_index = k - 1
                    break
                end
            end
            if self.selected_index == -1 then
                if Game.world.menu and Game.world.menu.selected_party then
                    self.selected_index = Game.world.menu.selected_party - 1
                else
                    self.selected_index = 0
                end
            end
        end

        -- update the Sliding Window
        local selected_row = math.floor(self.selected_index / boxes_per_row)

        if selected_row < self.view_start_row then
            self.view_start_row = selected_row
        elseif selected_row > self.view_start_row + 1 then
            self.view_start_row = selected_row - 1
        end

        local start_row = self.view_start_row

        -- position all children mathematically
        for k, v in ipairs(self.action_boxes) do
            local index = k - 1
            local row = math.floor(index / boxes_per_row)
            local col = index % boxes_per_row

            local boxes_in_this_row = math.min(boxes_per_row, party_count - row * boxes_per_row)
            local row_offset = 0

            if boxes_in_this_row < per_row then
                row_offset = ((per_row - boxes_in_this_row) * realW) / 2
            end

            v.x = row_offset + (col * realW)

            local display_row = row - start_row
            v.y = display_row * row_height - (double_row and row_height or 0)
            v.realWidth = realW

            -- hide off-screen boxes
            v.visible = (display_row >= 0 and display_row <= 1)
        end
    end

    Object.update(self)
end

function HealthBar:draw()
    if #Game.party <= Mod.libs["moreparty"]:getPartyPerRowAmount() then
        super.draw(self)
        return
    end

    -- Draw the black background
    Draw.setColor(PALETTE["world_fill"])
    love.graphics.rectangle("fill", 0, -23, 640, 124)

    Object.draw(self)

    -- Indicator
    local selected_row = math.floor(self.selected_index / Mod.libs["moreparty"]:getPartyPerRowAmount()) + 1
    local total_rows = math.ceil(#Game.party / Mod.libs["moreparty"]:getPartyPerRowAmount())

    if total_rows > 2 and Game.world.menu and Game.world.menu.state == "PARTYSELECT" then
        for i = 1, total_rows do
            local percentage = (i - 1) / (total_rows - 1)
            if selected_row == i or Game.world.menu.party_select_mode == "ALL" then
                Draw.setColor(COLORS.white)
                love.graphics.rectangle("fill", -5 + SCREEN_WIDTH, -21 + percentage * 78, 4, 4)
            else
                Draw.setColor(COLORS.gray)
                love.graphics.rectangle("fill", -4 + SCREEN_WIDTH, -20 + percentage * 78, 2, 2)
            end
        end
    end
end

return HealthBar