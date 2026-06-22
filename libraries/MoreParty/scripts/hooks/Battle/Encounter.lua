local Encounter, super = HookSystem.hookScript(Encounter)

-- Setup the positon of the party battlers in columns
-- If there're more than 2 columns, adjust their position between the boundaries
-- Last column should have their party battlers aligned to the center
function Encounter:getPartyPosition(index)
    local party = Game.battle.party
    if #party <= 3 then
        return super.getPartyPosition(self, index)
    end

    local three_per_row = Kristal.getLibConfig("moreparty", "three_per_row")
    local two_by_two = Mod.libs["moreparty"]:getTwoByTwo(#party)
    local party_per_row_amount = two_by_two and 2 or Mod.libs["moreparty"]:getPartyPerRowAmount()
    local party_count = #party

    local battler = party[index]
    local ox, oy = battler.chara:getBattleOffset()

    local column = math.ceil(index / party_per_row_amount)
    local row = ((index - 1) % party_per_row_amount) + 1 + (two_by_two and 0.35 or 0)
    local total_columns = math.ceil(party_count / party_per_row_amount)

    local x
    if total_columns == 1 then
        x = 80
    else
        x = 160 - ((column - 1) / (total_columns - 1)) * 80
    end

    local column_start = (column - 1) * party_per_row_amount + 1
    local column_count = math.min(party_per_row_amount, party_count - column_start + 1)

    local row_offset = 0
    if column_count < party_per_row_amount then
        row_offset = (party_per_row_amount - column_count) / 2
    end

    local base_y = (not three_per_row and party_count <= 4) and 120 or 50
    local y = (base_y / party_per_row_amount) + ((SCREEN_HEIGHT * 0.5 * (1 - (two_by_two and 0.35 or 0))) / party_per_row_amount) * ((row - 1) + row_offset)

    x = x + (battler.actor:getWidth() / 2 + ox) * 2
    y = y + (battler.actor:getHeight() + oy) * 2

    return x, y
end

return Encounter