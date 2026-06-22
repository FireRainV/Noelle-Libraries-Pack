local LightItemMenu, super = HookSystem.hookScript(LightItemMenu)

-- When playing with more than one party member, a menu will open when attempting to use an item, just like in Deltatraveler
function LightItemMenu:init()
    super.init(self)

    self.arrow_sprite = Assets.getTexture("ui/page_arrow_down")
    self.scroll_y = 1

    if Mod.libs["moreparty"] and #Game.party > 3 then
        if not Kristal.getLibConfig("moreparty", "three_per_row") then
            self.party_select_bg = UIBox(-97, 242, 492, (#Game.party == 4 and 52 or 90))
        else
            self.party_select_bg = UIBox(-37, 242, 372, 90)
        end
    else
        self.party_select_bg = UIBox(-37, 242, 372, 52)
    end

    self.party_select_bg.visible = false
    self.party_select_bg.layer = -1
    self.party_selecting = 1
    self:addChild(self.party_select_bg)
end

function LightItemMenu:update()
    if self.state == "ITEMOPTION" then
        if Input.pressed("cancel") then
            self.state = "ITEMSELECT"

            return
        end

        local old_selecting = self.option_selecting

        if Input.pressed("left") then
            self.option_selecting = self.option_selecting - 1
        end
        if Input.pressed("right") then
            self.option_selecting = self.option_selecting + 1
        end

        self.option_selecting = MathUtils.clamp(self.option_selecting, 1, 3)

        if self.option_selecting ~= old_selecting then
            self.ui_move:stop()
            self.ui_move:play()
        end

        if Input.pressed("confirm") then
            local item = Game.inventory:getItem(self.storage, self.item_selecting)
            if self.option_selecting == 1 and (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
                self.party_selecting = 1
                if #Game.party > 1 and item.target == "ally" then
                    self.ui_select:stop()
                    self.ui_select:play()
                    self.party_select_bg.visible = true
                    self.state = "PARTYSELECT"
                else
                    self:useItem(item)
                end
            elseif self.option_selecting == 2 then
                item:onCheck()
            elseif self.option_selecting == 3 then
                self:dropItem(item)
            end
        end
    elseif self.state == "PARTYSELECT" then
        if Input.pressed("cancel") then
            self.party_select_bg.visible = false
            self.state = "ITEMOPTION"

            return
        end

        local old_selecting = self.party_selecting

        if Input.pressed("right") then
            if Mod.libs["moreparty"] then
                self.party_selecting = Mod.libs["moreparty"]:partySelectMovement(self.party_selecting, "right", true)
            else
                self.party_selecting = self.party_selecting + 1
            end
        end

        if Input.pressed("left") then
            if Mod.libs["moreparty"] then
                self.party_selecting = Mod.libs["moreparty"]:partySelectMovement(self.party_selecting, "left", true)
            else
                self.party_selecting = self.party_selecting - 1
            end
        end

        if Mod.libs["moreparty"] then
            if Input.pressed("up") then
                self.party_selecting = Mod.libs["moreparty"]:partySelectMovement(self.party_selecting, "up", true)
            end

            if Input.pressed("down") then
                self.party_selecting = Mod.libs["moreparty"]:partySelectMovement(self.party_selecting, "down", true)
            end
        end

        self.party_selecting = MathUtils.clamp(self.party_selecting, 1, #Game.party)

        if self.party_selecting ~= old_selecting then
            self.ui_move:stop()
            self.ui_move:play()
        end

        if Input.pressed("confirm") then
            local item = Game.inventory:getItem(self.storage, self.item_selecting)
            self:useItem(item)
        end
    else
        local old_selecting_item = self.item_selecting

        super.update(self)

        if self.state == "ITEMSELECT" then
            if self.item_selecting ~= old_selecting_item then
                local item_limit = self:getItemLimit()
                local min_scroll = math.max(1, self.item_selecting - (item_limit - 1))
                local max_scroll = math.min(math.max(1, Game.inventory:getItemCount(self.storage) - (item_limit - 1)), self.item_selecting)
                self.scroll_y = MathUtils.clamp(self.scroll_y, min_scroll, max_scroll)
            end
        end
    end
end

function LightItemMenu:draw()
    love.graphics.setFont(self.font)

    local inventory = Game.inventory:getStorage(self.storage)

    local items = {}
    local item_limit = self:getItemLimit()
    for index, item in ipairs(inventory) do
        table.insert(items, item)
    end

    if self.state == "PARTYSELECT" then
        local function party_box_area()
            local party_box = self.party_select_bg
            love.graphics.rectangle("fill", party_box.x - 24, party_box.y - 24, party_box.width + 48, party_box.height + 48)
        end
        love.graphics.stencil(party_box_area, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
    end

    for i = self.scroll_y, math.min(#items, self.scroll_y + (item_limit - 1)) do
        local item = items[i]
        local offset = i - self.scroll_y

        if (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
            Draw.setColor(PALETTE["world_text"])
        else
            Draw.setColor(PALETTE["world_text_unusable"])
        end
        love.graphics.print(item:getName(), 20, 4 + (offset * 32))
    end

    Draw.setColor(PALETTE["world_text"])
    -- Draw scroll arrows if needed
    if #items > item_limit then
        Draw.setColor(1, 1, 1)

        -- Move the arrows up and down only if we're in the item selection state
        local sine_off = 0
        if self.state == "ITEMSELECT" then
            sine_off = math.sin((Kristal.getTime() * 30) / 12) * 3
        end

        if self.scroll_y > 1 then
            -- up arrow
            Draw.draw(self.arrow_sprite, 294 - 4, (4 + 25 - 3) - sine_off, 0, 1, -1)
        end
        if self.scroll_y + item_limit <= #items then
            -- down arrow
            Draw.draw(self.arrow_sprite, 294 - 4, (4 + (32 * item_limit) - 19) + sine_off)
        end
    end

    -- Draw scrollbar if needed (unless the item limit is 2, in which case the scrollbar is too small)
    if self.state == "ITEMSELECT" and item_limit > 2 and #items > item_limit then
        local scrollbar_height = (item_limit - 2) * 32 + 7
        Draw.setColor(0.25, 0.25, 0.25)
        love.graphics.rectangle("fill", 294, 4 + 30, 6, scrollbar_height)
        local percent = (self.scroll_y - 1) / (#items - item_limit)
        Draw.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 294, 4 + 30 + math.floor(percent * (scrollbar_height - 6)), 6, 6)
    end
    love.graphics.setStencilTest()

    if self.state ~= "PARTYSELECT" then
        local item = Game.inventory:getItem(self.storage, self.item_selecting)
        if (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
            Draw.setColor(PALETTE["world_text"])
        else
            Draw.setColor(PALETTE["world_gray"])
        end
        love.graphics.print("USE", 20, 284)
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print("INFO", 116, 284)
        love.graphics.print("DROP", 230, 284)
    end

    Draw.setColor(Game:getSoulColor())
    if self.state == "ITEMSELECT" then
        Draw.draw(self.heart_sprite, -4, 12 + 32 * (self.item_selecting - self.scroll_y), 0, 2, 2)
    elseif self.state == "ITEMOPTION" then
        if self.option_selecting == 1 then
            Draw.draw(self.heart_sprite, -4, 292, 0, 2, 2)
        elseif self.option_selecting == 2 then
            Draw.draw(self.heart_sprite, 92, 292, 0, 2, 2)
        elseif self.option_selecting == 3 then
            Draw.draw(self.heart_sprite, 206, 292, 0, 2, 2)
        end
    elseif self.state == "PARTYSELECT" then
        local item = Game.inventory:getItem(self.storage, self.item_selecting)
        Draw.setColor(PALETTE["world_text"])

        local per_row = Mod.libs["moreparty"] and Mod.libs["moreparty"]:getPartyPerRowAmount() or 3
        local party_count = #Game.party
        local two_by_two = Mod.libs["moreparty"] and Mod.libs["moreparty"]:getTwoByTwo(party_count) or false
        local boxes_per_row = two_by_two and 2 or per_row

        Draw.printAlign("Use " .. item:getName() .. " on", 150, 231, "center")

        self.view_start_row = self.view_start_row or 0

        local selected_index = self.party_selecting - 1
        local selected_row = math.floor(selected_index / boxes_per_row)

        if selected_row < self.view_start_row then
            self.view_start_row = selected_row
        elseif selected_row > self.view_start_row + 1 then
            self.view_start_row = selected_row - 1
        end

        local start_row = self.view_start_row
        local width = 122

        for i, party in ipairs(Game.party) do
            local zero_index = i - 1
            local row = math.floor(zero_index / boxes_per_row)

            -- Calculate visually where this row should appear relative to the camera
            local display_row = row - start_row

            -- Only draw the character and heart if they are in the active 2 rows
            if display_row >= 0 and display_row <= 1 then
                local col = zero_index % boxes_per_row
                local boxes_in_this_row = math.min(boxes_per_row, party_count - row * boxes_per_row)

                -- Dynamic X and Y based on your original formula
                local x = 63 - (boxes_in_this_row - 2) * 70 + (col * width)
                local y = 269 + (display_row * 38)

                -- draw the character's name
                Draw.setColor(PALETTE["world_text"])
                love.graphics.print(party:getShortName(), x, y)

                -- draw the heart if this is the currently selected member
                if i == self.party_selecting then
                    Draw.setColor(Game:getSoulColor())
                    Draw.draw(self.heart_sprite, x - 24, y + 8, 0, 2, 2)
                end
            end
        end


        -- Indicator
        if Mod.libs["moreparty"] then
            local selected_row = math.floor((self.party_selecting - 1) / Mod.libs["moreparty"]:getPartyPerRowAmount()) + 1
            local total_rows = math.ceil(#Game.party / Mod.libs["moreparty"]:getPartyPerRowAmount())

            if total_rows > 2 then
                for i = 1, total_rows do
                    local percentage = (i - 1) / (total_rows - 1)
                    if selected_row == i then
                        Draw.setColor(COLORS.white)
                        love.graphics.rectangle("fill", 337 + (Mod.libs["moreparty"]:getPartyPerRowAmount() == 4 and 60 or 0), 232 + percentage * 102, 8, 8)
                    else
                        Draw.setColor(COLORS.gray)
                        love.graphics.rectangle("fill", 339 + (Mod.libs["moreparty"]:getPartyPerRowAmount() == 4 and 60 or 0), 234 + percentage * 102, 4, 4)
                    end
                end
            end
        end
    end

    Object.draw(self)
end

function LightItemMenu:getItemLimit()
    return 8
end

function LightItemMenu:useItem(item)
    local result
    if item.target == "ally" then
        result = item:onWorldUse(Game.party[self.party_selecting])
    else
        result = item:onWorldUse(Game.party)
    end

    if result then
        if item:hasResultItem() then
            Game.inventory:replaceItem(item, item:createResultItem())
        else
            Game.inventory:removeItem(item)
        end
    end
end

return LightItemMenu