local Dummy, super = Class(LightEnemyBattler)

function Dummy:init()
    super.init(self)

    -- Enemy name
    self.name = "Kris"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("lightbattle/kris")

    -- Enemy health
    self.max_health = 90
    self.health = 90
    -- Enemy attack (determines bullet damage)
    self.attack = 6
    -- Enemy defense (usually 0)
    self.defense = 0
    -- Enemy reward
    self.money = 0
    self.experience = 0

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        "basic",
        "aiming",
        "movingarena"
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "[wave:3][speed:0.5][emote:reset]This is a test! Holy hell!",
        "[wave:3][speed:0.5][emote:happy]This test is making\nme happy!"
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "ATK 6 DEF 0\n* Test."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* ...?"
    }
    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* Low HP."

    self:registerActFor("noelle", "Noelle Only", "hi")
    self:registerAct("Test", "", nil, nil, { { "ui/battle/msg/dumbass", false } })
    self:registerAct("Test", "", nil, nil, { { "ui/battle/msg/dumbass", true } })
    self:registerAct("Test", "", { "kris" }, 100, { { "ui/battle/msg/dumbass", false } })
    self:registerAct("Test", "", { "kris" }, 100, { { "ui/battle/msg/dumbass", true } })
    self:registerAct("Test", "", { "kris", "susie" }, 100, { { "ui/battle/msg/dumbass", false } })
    self:registerAct("Test", "", { "kris", "susie" }, 100, { { "ui/battle/msg/dumbass", true } })
    self:registerAct("", "", nil, 100, { { "ui/battle/msg/dumbass", false } })
    self:registerAct("", "", nil, 100, { { "ui/battle/msg/dumbass", true } })

    self.talk_sprite = "head"
end

function Dummy:update()
    super.update(self)

    if Game.battle:getState() == "DEFENDING" then
        self:addTemporaryMercy(1)
    end
end

function Dummy:getTarget()
    return Game.battle:targetAll()
end

function Dummy:onAct(battler, name)

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    if name ~= "Check" then
        return "* Nothing happened."
    end

    return super.onAct(self, battler, name)
end

return Dummy