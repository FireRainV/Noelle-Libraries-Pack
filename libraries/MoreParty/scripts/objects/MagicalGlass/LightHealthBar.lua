if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightHealthBar, super = HookSystem.hookScript("LightHealthBar")

function LightHealthBar:init()
    super.init(self)

    if #Game.party <= 3 then return end

    if Kristal.getLibConfig("moreparty", "three_per_row") then
        self.box.x = 103
        self.box.width = 434
    else
        self.box.x = 26
        self.box.width = 588
    end
end

function LightHealthBar:draw()
    if #Game.party <= 3 then
        super.draw(self)
        return
    end

    Object.draw(self)

    local per_row = Mod.libs["moreparty"]:getPartyPerRowAmount()
    local party_count = #Game.party
    local two_by_two = Mod.libs["moreparty"]:getTwoByTwo(party_count)
    local boxes_per_row = two_by_two and 2 or per_row

    -- Box width (77 * 2)
    local width = 154

    -- Sliding window Logic (passive display)
    self.view_start_row = self.view_start_row or 0

    local selected_index = 0 -- should show just the top 2 rows

    local selected_row = math.floor(selected_index / boxes_per_row)
    if selected_row < self.view_start_row then
        self.view_start_row = selected_row
    elseif selected_row > self.view_start_row + 1 then
        self.view_start_row = selected_row - 1
    end

    local start_row = self.view_start_row
    local is_four_flat = party_count == 4 and not Kristal.getLibConfig("moreparty", "three_per_row")

    local small = false
    for _, target in ipairs(Game.party) do
        if target:getStat("health") >= 100 then
            small = true
            break
        end
    end

    for index, party in ipairs(Game.party) do
        local zero_index = index - 1
        local row = math.floor(zero_index / boxes_per_row)

        -- Calculate the visual position relative to our sliding camera
        local display_row = row - start_row

        -- Only draw the character if they are in the active 2 rows (or it's the 4-flat layout)
        if is_four_flat or (display_row >= 0 and display_row <= 1) then
            local col = zero_index % boxes_per_row
            local boxes_in_this_row = math.min(boxes_per_row, party_count - row * boxes_per_row)

            local x = 93 + ((3 - boxes_in_this_row) * 77) + (col * width)

            -- Lock the Y coordinate visually using display_row
            local y = 8 + (display_row * 20)

            local name = party:getShortName()
            local current = party:getHealth()
            local max = party:getStat("health")

            local max_str = tostring(max)
            if max < 10 and max >= 0 then
                max_str = "0" .. max_str
            end

            local current_str = tostring(current)
            if current < 10 and current >= 0 then
                current_str = "0" .. current_str
            end

            if is_four_flat then
                x = 93 + (3 - party_count) * 77 + (index - 1) * width
                y = 10

                love.graphics.setFont(Assets.getFont("namelv", 16))
                Draw.setColor(PALETTE["world_text"])
                love.graphics.print(name, x, y + 3)

                Draw.setColor(MG_PALETTE["player_health_bg"])
                love.graphics.rectangle("fill", x + 62, y + (small and 3 or 0), (small and 12 or 26) * 1.2 + 1, small and 14 or 21)
                if current > 0 then
                    Draw.setColor(MG_PALETTE["player_health"])
                    love.graphics.rectangle("fill", x + 62, y + (small and 3 or 0), math.ceil((MathUtils.clamp(current, 0, max) / max) * (small and 12 or 26)) * 1.2 + 1, small and 14 or 21)
                end

                love.graphics.setFont(Assets.getFont("namelv", 16))
                Draw.setColor(PALETTE["world_text"])
                Draw.printAlign(current_str .. "/" .. max_str, x + 148, y + 3, "right")
            else
                love.graphics.setFont(Assets.getFont("namelv", 16))
                Draw.setColor(PALETTE["world_text"])
                love.graphics.print(name, x, y - 4)

                Draw.setColor(MG_PALETTE["player_health_bg"])
                love.graphics.rectangle("fill", x + 62, y - 2, (small and 12 or 26) * 1.2 + 1, 10)
                if current > 0 then
                    Draw.setColor(MG_PALETTE["player_health"])
                    love.graphics.rectangle("fill", x + 62, y - 2, math.ceil((MathUtils.clamp(current, 0, max) / max) * (small and 12 or 26)) * 1.2 + 1, 10)
                end

                love.graphics.setFont(Assets.getFont("namelv", 16))
                Draw.setColor(PALETTE["world_text"])
                Draw.printAlign(current_str .. "/" .. max_str, x + 148, y - 4, "right")
            end
        end
    end
end

return LightHealthBar