local Noelle, super = Class(LightEnemyBattler)

function Noelle:init()
    super.init(self)

    -- Enemy name
    self.name = "Noelle"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("lightbattle/noelle")

    -- Enemy health
    self.max_health = 90
    self.health = 90
    -- Enemy attack (determines bullet damage)
    self.attack = 6
    -- Enemy defense (usually 0)
    self.defense = 2
    -- Enemy reward
    self.money = 87
    self.experience = 50

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        "scud_storm"
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "[emote:reset]Let's take a\nselfie together!",
        "[emote:reset]I can teach you\nhow to build a\nSCUD Storm!",
        "[emote:reset]Let's be\nfriends!"
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "ATK 6 DEF 2\n* Seems like she wants to show you\nhow to construct a SCUD Storm."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* It's getting a bit cold here,\nisn't it?",
        "* Noelle is posing like her life depends on it.",
        "* Noelle is looking into your eyes directly."
    }

    self.dialogue_bubble = "round"
    self.dialogue_offset = { 0, -40 }

    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* " .. self.name .. " is afraid of dying."
    self.spareable_text = "* " .. self.name .. " doesn't want to\nfight anymore."

    self:registerAct("Sniff")
    self:registerShortAct("Befriend")

    -- can be a table or a number. if it's a number, it determines the width, and the height will be 13 (the ut default).
    -- if it's a table, the first value is the width, and the second is the height
    self.gauge_size = 150

    self.damage_offset = { 0, 40 }

    self.line_dust = nil

    self.sniff = 0
    self.befriend = 0
    self.sniff_tired = false

    self.talk_sprite = true
end

function Noelle:onSaveAction(battler)
    print(battler.chara.name .. " SAVED " .. self.name .. "!")
end

function Noelle:isXActionShort(battler)
    return true
end

function Noelle:onShortAct(battler, name)
    self:addMercy(20)
    return "* " .. battler.chara:getName() .. " said hi!"
end

function Noelle:update()
    super.update(self)

    if not self.sniff_tired and self.sniff >= 3 and Game.battle.state == "ACTIONSELECT" then
       self:setTired(true)
       self.sniff_tired = true
    end
end

function Noelle:onHurt(damage, battler)
    self.dialogue_override = TableUtils.pick({ "Ouch!\n[wait:5]Stop that!", "Hey!\n[wait:5]That hurts!", "Why are you\nhitting me?" })
    self.dialogue_override = "[emote:sad]" .. self.dialogue_override

    super.onHurt(self, damage, battler)
end

function Noelle:onAct(battler, name)
    if name == "Sniff" then
        self.sniff = self.sniff + 1
        if self.sniff == 1 then
           self.dialogue_override = "[emote:reset]I know I'm Smelly."
           return "* You sniffed " .. self.name .. ".\n* Smells like lemons."
        elseif self.sniff == 2 then
           self.dialogue_override = "[emote:reset]Oranges are\na funny smell!"
           return "* You sniffed " .. self.name .. " again.\n* Smells like oranges."
        elseif self.sniff == 3 then
           self.dialogue_override = { "[emote:reset]My apples\nshampoo is\nalmost empty.", "I'm getting sleepy\nfrom all those\nsniffes of yours..." }
           return "* You sniffed " .. self.name .. " again.\n* Smells like apples."
        else
           self.dialogue_override = "..."
           return "* You've sniffed " .. self.name .. " enough."
        end
    elseif name == "Befriend" then
        self.befriend = self.befriend + 1
        if self.befriend == 1 then
           self:addMercy(20)
           return "* You asked " .. self.name .. " if she can be\nyour pal.\n* She's really excited about that."
        elseif self.befriend == 2 then
            self:addMercy(20)
           return "* You asked " .. self.name .. " if you two \ncan get along.\n* She's planning a surprise!"
        elseif self.befriend == 3 then
           self.sprite:setSprite("spared")
           self.dialogue_override = { "Together, we will\nbe able to\ncapture the\nGLA and...", "Build our own\nSCUD Storm!" }
           self:addMercy(100)
           self.waves = {}
           self.defense = -80
           return "* You asked " .. self.name .. " to be\nyour friend."
        else
           self.dialogue_override = "..."
           return "* " .. self.name .. " is already accepting your friendship."
        end
    elseif name == "Standard" then
        self:addMercy(20)
        return "* " .. battler.chara:getName() .. " said hi!"
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super.onAct(self, battler, name)
end

return Noelle