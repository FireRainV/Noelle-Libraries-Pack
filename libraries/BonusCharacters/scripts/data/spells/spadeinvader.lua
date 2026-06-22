local spell, super = Class(Spell, "spadeinvader")

function spell:init()
    super.init(self)

    self.name = "SpadeInvader"

    self.effect = "Dig &\nDetonate"
    self.description = "Summons a large spade that shoots smaller\nspades that explode upon impact."
    self.check = { "Summons a large\nspade that shoots smaller\nspades.", "* ...[wait:5] which explode upon impact." }

    self.cost = 50

    self.target = "enemies"

    self.tags = { "damage" }
end

function spell:onCast(user, target)
    local userX, userY = user:getRelativePos(user.width, user.height / 2, Game.battle)
    Assets.playSound("spearappear")
    local bigspade = Sprite("effects/cardspell/spade", userX + 32, userY)
    bigspade:setOrigin(0.5, 0.5)
    bigspade:setScale(2, 2)
    bigspade.layer = BATTLE_LAYERS["above_arena"] + 1
    Game.battle:addChild(bigspade)
    bigspade:play(1 / 10)
    bigspade:slideToSpeed(320, 180, 20, function()
        Game.battle.timer:after(1, function()
            bigspade:fadeOutAndRemove(0.5)
        end)
    end)
    for _, enemy in ipairs(target) do
        local targetX, targetY = enemy:getRelativePos(enemy.width / 2, enemy.height / 2, Game.battle)
        Game.battle.timer:script(function(wait)
            wait(1)

            Assets.playSound("spearappear")
            local spade = Sprite("effects/cardspell/spade", bigspade.x, bigspade.y)
            spade:setOrigin(0.5, 0.5)
            spade:setScale(1, 1)
            spade.layer = BATTLE_LAYERS["above_battlers"]
            Game.battle:addChild(spade)
            spade:play(1 / 10)
            spade:slideToSpeed(targetX, targetY, 20, function()
                local damage = self:getDamage(user, target)
                enemy:hurt(damage, user)

                Assets.playSound("damage")
                Assets.playSound("bigcut")
                enemy:shake(6, 0, 0.5)
                spade:remove()
                local explosion = Sprite("effects/cardspell/explosion", targetX, targetY)
                explosion:setOrigin(0.5, 0.5)
                explosion:setScale(1, 1)
                explosion.layer = BATTLE_LAYERS["above_battlers"]
                Game.battle:addChild(explosion)
                explosion:play(1 / 10, false, function(this)
                    this:remove()
                end)
            end)

               wait(1 / 30)
        end)

        Game.battle.timer:after(2.65, function()
            Game.battle:finishActionBy(user)
        end)
    end

    return false
end

function spell:onLightCast(user, target)
    Assets.playSound("spearappear")
    local bigspade = Sprite("effects/cardspell/spade", 320, 580)
    bigspade:setOrigin(0.5, 0.5)
    bigspade:setScale(3, 3)
    bigspade.layer = LIGHT_BATTLE_LAYERS["above_arena_border"] + 1
    Game.battle:addChild(bigspade)
    bigspade:play(1 / 10)
    bigspade:slideToSpeed(320, 320, 20, function()
        Game.battle.timer:after(1, function()
            bigspade:fadeOutAndRemove(0.5)
        end)
    end)
    for _, enemy in ipairs(target) do
        local targetX, targetY = enemy:getRelativePos(enemy.width / 2, enemy.height / 2, Game.battle)

        Game.battle.timer:script(function(wait)
            wait(1)

            Assets.playSound("spearappear")
            local spade = Sprite("effects/cardspell/spade", bigspade.x, bigspade.y)
            spade:setOrigin(0.5, 0.5)
            spade:setScale(2, 2)
            spade.layer = LIGHT_BATTLE_LAYERS["above_arena_border"]
            Game.battle:addChild(spade)
            spade:play(1 / 10)
            spade:slideToSpeed(targetX, targetY, 20, function()
                local damage = self:getDamage(user, target)
                enemy:hurt(damage, user)

                Assets.playSound("damage")
                Assets.playSound("bigcut")
                enemy:shake(6, 0, 0.5)
                spade:remove()
                local explosion = Sprite("effects/cardspell/explosion", targetX, targetY)
                explosion:setOrigin(0.5, 0.5)
                explosion:setScale(2, 2)
                explosion.layer = LIGHT_BATTLE_LAYERS["above_arena_border"] - 1
                Game.battle:addChild(explosion)
                explosion:play(1 / 10, false, function(this)
                    this:remove()
                end)
            end)

               wait(1 / 30)
        end)

        Game.battle.timer:after(2, function()
            Game.battle:finishActionBy(user)
        end)
    end

    return false
end

function spell:getDamage(user, target)
    if Game:isLight() then
        return math.ceil((user.chara:getStat("magic") * 7) + 15 + MathUtils.random(5))
    else
        return math.ceil((user.chara:getStat("magic") * 9) + 30 + MathUtils.random(10))
    end
end

return spell