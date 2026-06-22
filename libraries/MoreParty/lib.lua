local Lib = {}

function Lib:init()
    -- print("Loaded MoreParty Library " .. self.info.version .. "!")
end

-- If the "three_per_row" config option and the party battler can both ACT and cast spells, they'll be combined into a singular "skill" button
function Lib:getActionButtons(battler, buttons)
    if not Kristal.getLibConfig("moreparty", "three_per_row") and #Game.battle.party > 3 then
        if TableUtils.contains(buttons, "act") and TableUtils.contains(buttons, "magic") then
            TableUtils.removeValue(buttons, "magic")
            local index = TableUtils.getIndex(buttons, "act")
            table.remove(buttons, index)
            table.insert(buttons, index, SkillButton())
        end
    end
end

-- Whether the amount of party members per is
function Lib:getPartyPerRowAmount(multiply)
    return (Kristal.getLibConfig("moreparty", "three_per_row") and 3 or 4) * (multiply and 2 or 1)
end

-- Whether a 2x2 grid can be used
-- Returns true if the config options ["two_by_two" and "three_per_row"] are enabled and there're exactly 4 party members in the current party
-- 'party_count' should be the amount of the party members you want to get counted (example: #Game.party or #Game.battle.party)
function Lib:getTwoByTwo(party_count)
    return Kristal.getLibConfig("moreparty", "two_by_two") and Kristal.getLibConfig("moreparty", "three_per_row") and party_count == 4
end


-- Used for menus to work exceeding amount of party members (above 3)
-- 'current_selecting' is the value of the current selected index
-- 'dir' is the direction you're tring to move to ("up", "down", "left", "right")
-- if 'no_wrapping' is true, it won't wrap around when you attempt to move beyond the menu
--
-- Returns the new 'current_selecting' value and whether the movement was successful
--
function Lib:partySelectMovement(current_selecting, dir, no_wrapping)
    local party_boxes = #Game.party
    local rowLimit = self:getTwoByTwo(party_boxes) and 2 or self:getPartyPerRowAmount()

    local current_row = math.ceil(current_selecting / rowLimit)
    local max_rows = math.ceil(party_boxes / rowLimit)

    if dir == "left" or dir == "right" then
        if party_boxes <= 1 then
            return current_selecting, false
        end

        -- Calculate the bounds of the current row
        local start_of_row = (current_row - 1) * rowLimit + 1
        local end_of_row = math.min(current_row * rowLimit, party_boxes)

        if dir == "right" then
            if current_selecting < end_of_row then
                current_selecting = current_selecting + 1
                return current_selecting, true
            elseif not no_wrapping then
                current_selecting = start_of_row -- Wrap to start of the same row
                return current_selecting, true
            end
        elseif dir == "left" then
            if current_selecting > start_of_row then
                current_selecting = current_selecting - 1
                return current_selecting, true
            elseif not no_wrapping then
                current_selecting = end_of_row -- Wrap to end of the same row
                return current_selecting, true
            end
        end

        return current_selecting, false
    elseif dir == "up" or dir == "down" then
        if party_boxes <= rowLimit then
            return current_selecting, false
        end

        -- Determine target row based on direction
        local direction = dir == "up" and -1 or dir == "down" and 1 or 0
        local target_row = current_row + direction

        -- Handle bounds and wrapping checks
        if target_row < 1 then
            if no_wrapping then
                return current_selecting, false
            end
            target_row = max_rows
        elseif target_row > max_rows then
            if no_wrapping then
                return current_selecting, false
            end
            target_row = 1
        end

        -- Calculate visual column of the current item (to handle centered bottom rows)
        local current_row_items = math.min(rowLimit, party_boxes - (current_row - 1) * rowLimit)
        local current_start_col = math.floor((rowLimit - current_row_items) / 2) + 1
        local index_within_current_row = (current_selecting - 1) % rowLimit
        local visual_col = current_start_col + index_within_current_row

        -- Calculate position on the target row based on that visual column
        local target_row_items = math.min(rowLimit, party_boxes - (target_row - 1) * rowLimit)
        local target_start_col = math.floor((rowLimit - target_row_items) / 2) + 1
        local target_end_col = target_start_col + target_row_items - 1

        local index_within_target_row

        -- Snap to the nearest box if moving into a partially filled, centered row
        if visual_col < target_start_col then
            index_within_target_row = 0 -- Snap to left-most available
        elseif visual_col > target_end_col then
            index_within_target_row = target_row_items - 1 -- Snap to right-most available
        else
            index_within_target_row = visual_col - target_start_col -- Exact alignment
        end

        -- Convert the row and index back into the absolute selection number
        current_selecting = (target_row - 1) * rowLimit + 1 + index_within_target_row

        return current_selecting, true
    end
    return current_selecting, false
end

function Lib:postUpdate()
    -- Dynamically adjust the amount of the maximum followers' history
    Game.max_followers = math.max(Kristal.getModOption("maxFollowers") or 10, #Game.world.followers + 2, #Game.party + 2)
end

return Lib