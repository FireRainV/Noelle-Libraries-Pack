local Shop, super = HookSystem.hookScript(Shop)

function Shop:init()
    super.init(self)

    self.defense_bonus_counter = 0
end

-- If the party member doesn't have enough slots, replace the stat change with "X"
function Shop:drawBonuses(party_member, old_item, bonuses, stat, x, y)
    if stat == "defense" then
        self.defense_bonus_counter = self.defense_bonus_counter + 1
    end

    if stat == "defense" and self.defense_bonus_counter > Kristal.getLibConfig("extra_equip_slots", "max_armors") or stat ~= "defense" and Kristal.getLibConfig("extra_equip_slots", "max_weapons") < 1 then
        love.graphics.setFont(self.plain_font)
        Draw.setColor(COLORS.white)
        love.graphics.print("X", x, y)
        Draw.setColor(COLORS.white)
    else
        super.drawBonuses(self, party_member, old_item, bonuses, stat, x, y)
    end

    if self.defense_bonus_counter >= 2 then
        self.defense_bonus_counter = 0
    end
end

return Shop