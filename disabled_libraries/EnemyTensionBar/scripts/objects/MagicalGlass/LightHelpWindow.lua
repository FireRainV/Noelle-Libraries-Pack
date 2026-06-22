if not Mod.libs["magical-glass"] then
    return HookSystem.hookScript("Kristal")
end

local LightHelpWindow, super = HookSystem.hookScript("LightHelpWindow")

-- Tween the tension bar just like the normal tension bar when the help window open or close
function LightHelpWindow:update()
    local battle = Game.battle
    local item = battle.state == "MENUSELECT" and #battle.menu_items > 0 and Game.battle.menu_items[Game.battle:getItemIndex()]
    if item and (#item.description > 0 or (item.tp and item.tp > 0)) then
        if not self.showing then
            if self.top then
                if Game.battle.enemy_tension_bar then
                    Game.battle.timer:tween(6 / 30, Game.battle.enemy_tension_bar, { y = 16 }, "out-cubic")
                end
            end
        end
    else
        if self.showing then
            if self.top then
                if Game.battle.enemy_tension_bar then
                    Game.battle.timer:tween(6 / 30, Game.battle.enemy_tension_bar, { y = 54 }, "out-cubic")
                end
            end
        end
    end

    super.update(self)
end

return LightHelpWindow