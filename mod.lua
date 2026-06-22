function Mod:init()

    -- Clear Video Preview
    if self.info.PREVIEW_VIDEO then
        self.info.PREVIEW_VIDEO:remove()
        self.info.PREVIEW_VIDEO = nil
        Assets.data.videos[self.info.id .. "/preview"] = nil
    end
    self.info.PREVIEW_STAGE = nil

    print("Loaded " .. self.info.name .. "!")
end

function Mod:load(data, new_file)
    if new_file then
        -- Game:getPartyMember("frisk"):setLightLV(19)
        Game.money = Kristal.getLibConfig("magical-glass", "debug") and 1000 or 0
        Game.lw_money = Kristal.getLibConfig("magical-glass", "debug") and 1000 or 0
        -- Mod.libs["magical-glass"]:setLightBattleShakingText(true)
        Mod.libs["magical-glass"]:setCellCallsRearrangement(true)
        -- local party = Game:getPartyMember("noelle")
        -- party:setLightEXP(69420)
        -- party.lw_health = party.lw_stats.health

        Game.world:registerCall("Dimensional Box A", "mg_cell.box_a")
        Game.world:registerCall("Dimensional Box B", "mg_cell.box_b")
        Game.world:registerCall("Settings", "mg_cell.settings")
        Game.world:registerCall("Recruits Menu", "mg_cell.recruits")
    end
end


-- Set the color of text boxes
function Mod:setTextboxColor(color)
    self.textbox_color = color
end

function Mod:postUpdate()
    if Game.world:hasCutscene() and self.textbox_color then
        for _, mode in ipairs({ "textbox", "choicebox", "textchoicebox" }) do
            if Game.world.cutscene[mode] then
                Game.world.cutscene[mode].box:setColor(self.textbox_color)
                break
            end
        end
    end
end

-- function Mod:postDraw()
    -- love.graphics.setFont(Assets.getFont("main"))
    -- local text = "will you promise to spend the most time with me?"
    -- local printed_text = (text .. "\n"):rep(20)
    -- love.graphics.print({ { 1, 0, 0 }, printed_text }, 4, 0)
-- end

    -- for _, enemy in ipairs(Game.stage:getObjects(ChaserEnemy)) do
        -- if enemy.encountered then
            -- Assets.stopSound("tensionhorn")
        -- end
    -- end

-- function Mod:onGameOver(x, y)
    -- return true
-- end

-- function Mod:getUISkin()
    -- return "dark"
-- end

-- function Mod:postUpdate()
    -- -- Text shakiness depending on HP
    -- if Game.state == "BATTLE" and Game.battle.light then
        -- local current_hp = 0
        -- local max_hp = 0
        -- for _, party in ipairs (Game.battle.party) do
             -- current_hp = current_hp + party.chara:getHealth()
             -- max_hp = max_hp + party.chara:getStat("health")
        -- end
        -- local average_hp = math.ceil(max_hp / current_hp / #Game.battle.party)
        -- Mod.libs["magical-glass"]:setLightBattleShakingText(MathUtils.clamp((average_hp - 1) / 4, 0.501, 2))
    -- end
-- end

-- function Mod:getLightActionButtons(battler, buttons)
    -- return { "fight", "mercy" }
-- end

-- function Mod:getActionButtons(battler, buttons)
    -- return { "act", FleeButton() }
-- end

-- function Mod:getLightActionButtonPairs(pairs)
    -- for _, pair in ipairs(pairs) do
        -- if TableUtils.contains(pair, "act") then
            -- table.insert(pair, "mercy")
            -- break
        -- end
    -- end