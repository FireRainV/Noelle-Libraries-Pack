local Battle, super = HookSystem.hookScript(Battle)

-- Support for the new attacking system
function Battle:updateAttacking()
    if self.cancel_attack then
        self:finishAllActions()
        self:setState("ACTIONSDONE")
        return
    end

    if not self.attack_done then
        if not self.battle_ui.attacking then
            self.battle_ui:beginAttack()
        end

        if #self.attackers == #self.auto_attackers and self.auto_attack_timer < 4 then
            self.auto_attack_timer = self.auto_attack_timer + DTMULT

            if self.auto_attack_timer >= 4 then
                local next_attacker = self.auto_attackers[1]

                local next_action = self:getActionBy(next_attacker)
                if next_action then
                    self:beginAction(next_action)
                    self:processAction(next_action)
                end
            end
        end

        local all_done = true

        for _, box in ipairs(self.battle_ui.attack_boxes) do
            if not box.attacked and box.fade_rect.alpha < 1 then
                local close = box:getClose()

                if close <= -2 and #box.bolts > 1 then
                    all_done = false
                    box:miss()
                elseif close <= -2 then
                    local points = box:miss()

                    local action = self:getActionBy(box.battler)
                    action.points = points

                    if self:processAction(action) then
                        self:finishAction(action)
                    end
                else
                    all_done = false
                end
            end
        end

        if #self.auto_attackers > 0 then
            all_done = false
        end

        if all_done then
            self.attack_done = true
        end
    else
        if self:allActionsDone() then
            self:setState("ACTIONSDONE")
        end
    end
end

function Battle:drawDebug()
    super.drawDebug(self)

    local ui = self.battle_ui

    for i, box in ipairs(self.battle_ui.attack_boxes) do
        local battler = box.battler

        local bolt_count = (battler.chara:getWeapon() and battler.chara:getWeapon():getBoltCount()) or 1

        if bolt_count > 1 then
            local perfect_score = (150 * bolt_count)
            local crit_req = perfect_score - 30

            if self.state == "ATTACKING" or self.state == "ACTIONSDONE" and ui.attack_boxes[i] then
                if perfect_score - ui.attack_boxes[i].score <= 0 then
                    Draw.setColor(0, 1, 0, 1)
                elseif perfect_score - ui.attack_boxes[i].score <= 30 then
                    Draw.setColor(0, 1, 1, 1)
                elseif perfect_score - ui.attack_boxes[i].score <= 60 then
                    Draw.setColor(1, 1, 0, 1)
                elseif perfect_score - ui.attack_boxes[i].score <= 90 then
                    Draw.setColor(1, 0, 0, 1)
                end

                self:debugPrintOutline(battler.chara.name .. "'s score: " .. math.floor(ui.attack_boxes[i].score) .. ", (" .. crit_req .. " for a crit)", 4, ui.attack_boxes[i].y + 310)
            end
        end
    end
end

return Battle