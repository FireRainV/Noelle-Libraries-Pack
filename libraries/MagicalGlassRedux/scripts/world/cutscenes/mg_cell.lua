return {
    -- Dimensional Box A
    box_a = function(cutscene)
        Assets.stopSound("phone")
        Assets.stopAndPlaySound("dimbox")
        cutscene:wait(7 / 30)
        cutscene:after(function() Game.world:openMenu(LightStorageMenu("items", "box_a")) end)
    end,

    -- Dimensional Box B
    box_b = function(cutscene)
        Assets.stopSound("phone")
        Assets.stopAndPlaySound("dimbox")
        cutscene:wait(7 / 30)
        cutscene:after(function() Game.world:openMenu(LightStorageMenu("items", "box_b")) end)
    end,

    -- Settings Menu (like in the dark world)
    settings = function(cutscene)
        Assets.stopSound("phone")
        Assets.stopAndPlaySound("ui_select")
        cutscene:wait(2 / 30)
        cutscene:after(function() Game.world:openMenu(LightConfigMenu()) end)
    end,

    -- Recruits Menu (like the one from save points in the dark world)
    recruits = function(cutscene)
        Assets.stopSound("phone")
        if not Game:getConfig("enableRecruits") then
            cutscene:text("* You tried to open the recruits menu, [wait:10]but recruits are disabled.")
        elseif #Game:getRecruits(true) > 0 then
            Assets.stopAndPlaySound("ui_select")
            cutscene:wait(2 / 30)
            cutscene:after(function() Game.world:openMenu(RecruitMenu()) end)
        else
            cutscene:text("* You tried to open the recruits menu, [wait:10]but you have no recruits.")
        end
    end,
}