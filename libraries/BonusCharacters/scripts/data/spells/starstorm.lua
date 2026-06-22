local spell, super = Class(Spell, "starstorm")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "StarStorm"
    -- Name displayed when cast (optional)
    self.cast_name = "STAR STORM"


    -- Battle description
    self.effect = "Star\nto All."
    -- Menu description
    self.description = "Deals magical Star damage to\nall foes."
    self.check = "Deals magical\nstar damage to all foes."

    -- TP cost
    self.cost = 60

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "enemies"

    -- Tags that apply to this spell
    self.tags = { "damage" }
end

function spell:onCast(user, target)

    Assets.playSound("falling_star")

    Game.battle.timer:every(0.01, function(wait)
        local random = MathUtils.round(MathUtils.random(0, 2))

        local starparticle = nil
        if random == 0 then
            starparticle = Sprite("effects/stars/starstorm_big", MathUtils.random(SCREEN_WIDTH), MathUtils.random(SCREEN_HEIGHT))
        elseif random == 1 then
            starparticle = Sprite("effects/stars/starstorm_medium", MathUtils.random(SCREEN_WIDTH), MathUtils.random(SCREEN_HEIGHT))
        else
            starparticle = Sprite("effects/stars/starstorm_small", MathUtils.random(SCREEN_WIDTH), MathUtils.random(SCREEN_HEIGHT))
        end

        starparticle:setOrigin(0.5, 0.5)
        starparticle:setScale(2)
        starparticle.layer = BATTLE_LAYERS["above_battlers"]
        Game.battle:addChild(starparticle)
        starparticle:play(0.1, false)
        starparticle:slideToSpeed(starparticle.x + 32, starparticle.y, 5)
        starparticle:fadeOutAndRemove(0.5)
    end, 250)

    Game.battle.timer:after(3, function(wait)
        local damage = self:getDamage(user, target)
        local i = 0

        Game.battle.timer:every(0.1, function()
            i = i + 1
            Assets.playSound("celestial_hit", 1.0, 1.4)
            Assets.playSound("damage")
            target[i]:hurt(damage, user)
            target[i]:flash()
            target[i]:shake(6, 0, 0.5)

            if i == #target then
                Game.battle:finishActionBy(user)
            end
        end, #target)
    end)

    return false
end

function spell:onLightCast(user, target)
    Assets.playSound("falling_star")

    Game.battle.timer:every(0.01, function(wait)
        local random = MathUtils.round(MathUtils.random(0, 2))

        local starparticle = nil
        if random == 0 then
            starparticle = Sprite("effects/stars/starstorm_big", MathUtils.random(SCREEN_WIDTH), MathUtils.random(SCREEN_HEIGHT))
        elseif random == 1 then
            starparticle = Sprite("effects/stars/starstorm_medium", MathUtils.random(SCREEN_WIDTH), MathUtils.random(SCREEN_HEIGHT))
        else
            starparticle = Sprite("effects/stars/starstorm_small", MathUtils.random(SCREEN_WIDTH), MathUtils.random(SCREEN_HEIGHT))
        end

        starparticle:setOrigin(0.5, 0.5)
        starparticle:setScale(2)
        starparticle.layer = LIGHT_BATTLE_LAYERS["above_arena_border"]
        Game.battle:addChild(starparticle)
        starparticle:play(0.1, false)
        starparticle:slideToSpeed(starparticle.x + 32, starparticle.y, 5)
        starparticle:fadeOutAndRemove(0.5)
    end, 250)

    Game.battle.timer:after(3, function(wait)
        local damage = self:getDamage(user, target)
        local i = 0

        Game.battle.timer:every(0.1, function()
            i = i + 1
            Assets.playSound("celestial_hit", 1.0, 1.4)
            Assets.playSound("damage")
            target[i]:hurt(damage, user)
            target[i]:flash()
            target[i]:shake(6, 0, 0.5)

            if i == #target then
                Game.battle:finishActionBy(user)
            end
        end, #target)
    end)

    return false
end

function spell:getDamage(user, target)
    if Game:isLight() then
        return math.ceil((user.chara:getStat("magic") * 10) + 70 + MathUtils.random(10))
    else
        return math.ceil((user.chara:getStat("magic") * 20) + 130 + (MathUtils.random(10) * 4))
    end
end

return spell