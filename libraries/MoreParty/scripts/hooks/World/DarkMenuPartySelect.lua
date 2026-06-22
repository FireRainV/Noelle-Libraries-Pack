local DarkMenuPartySelect, super = HookSystem.hookScript(DarkMenuPartySelect)

function DarkMenuPartySelect:init(x, y)
    super.init(self, x, y)

    self.shown = Mod.libs["moreparty"]:getPartyPerRowAmount()
    self.arrow = Assets.getTexture("ui/flat_arrow_left")
end

function DarkMenuPartySelect:draw()
    local three_per_row = Kristal.getLibConfig("moreparty", "three_per_row")
    local scroller = Kristal.getLibConfig("moreparty", "scroller")

    local normal_shown = Mod.libs["moreparty"]:getPartyPerRowAmount()
    local expanded_shown = Mod.libs["moreparty"]:getPartyPerRowAmount(true)
    local visible_count = scroller and normal_shown or expanded_shown

    if (#Game.party <= visible_count and not scroller) or #Game.party <= (Mod.libs["moreparty"]:getTwoByTwo(#Game.party) and 4 or 3) then
        if not scroller and #Game.party > normal_shown then
            for i, party in ipairs(Game.party) do
                if self.selected_party ~= i then
                    Draw.setColor(1, 1, 1, 0.4)
                else
                    Draw.setColor(1, 1, 1, 1)
                end
                local ox, oy = party:getMenuIconOffset()
                Draw.draw(Assets.getTexture(party:getMenuIcon()), (i - 1) * 50 + (ox * 2), oy * 2, 0, 2, 2)
            end
            if self.focused then
                local frames = Assets.getFrames("player/heart_harrows")
                Draw.setColor(Game:getSoulColor())
                Draw.draw(frames[(math.floor(self.heart_siner / 20) - 1) % #frames + 1], ((self.selected_party - 1) * 50 - 5), -36, 0, 2)
            end
            Object.draw(self)
            return
        else
            super.draw(self)
            return
        end
    end

    local offset = math.sin(Kristal.getTime() * 2.5)

    if self.selected_party >= #Game.party then
        self.shown = #Game.party
    elseif self.selected_party > self.shown then
        self.shown = self.shown + 1
    end

    if self.selected_party <= 1 then
        self.shown = visible_count
    elseif self.selected_party + (visible_count - 1) < self.shown then
        self.shown = self.shown - 1
    end

    if self.shown ~= visible_count then
        if scroller then
            Draw.draw(self.arrow, -8 - offset, 14)
        else
            Draw.draw(self.arrow, -8 - (offset * 2) - 8, 14, 0, 2, 2)
        end
    end

    local right_arrow_x
    if scroller then
        right_arrow_x = (three_per_row and 158 or 208) + offset
    else
        right_arrow_x = (three_per_row and 308 or 408) + (offset * 2) + 8
    end

    if self.shown ~= #Game.party then
        if scroller then
            Draw.draw(self.arrow, right_arrow_x, 14, 0, -1, 1)
        else
            Draw.draw(self.arrow, right_arrow_x, 14, 0, -2, 2)
        end
    end

    Draw.pushScissor()
    Draw.scissor(0, -18, visible_count * 50, 64)

    for i, party in ipairs(Game.party) do
        if self.selected_party ~= i then
            Draw.setColor(1, 1, 1, 0.4)
        else
            Draw.setColor(1, 1, 1, 1)
        end
        local ox, oy = party:getMenuIconOffset()
        Draw.draw(
            Assets.getTexture(party:getMenuIcon()),
            (i - 1) * 50 + (ox * 2) - (self.shown - visible_count) * 50,
            oy * 2,
            0,
            2,
            2
        )
    end

    Draw.popScissor()

    if self.focused then
        local frames = Assets.getFrames("player/heart_harrows")
        Draw.setColor(Game:getSoulColor())
        if scroller then
            Draw.draw(
                frames[(math.floor(self.heart_siner / 20) - 1) % #frames + 1],
                (self.selected_party - 1) * 50 + 10 - (self.shown - visible_count) * 50,
                -18
            )
        else
            Draw.draw(
                frames[(math.floor(self.heart_siner / 20) - 1) % #frames + 1],
                (self.selected_party - 1) * 50 - (self.shown - visible_count) * 50 - 5,
                -36,
                0,
                2
            )
        end
    end

    Object.draw(self)
end

return DarkMenuPartySelect