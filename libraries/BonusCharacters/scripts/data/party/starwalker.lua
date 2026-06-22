local character, super = Class(PartyMember, "starwalker")

function character:init()
    super.init(self)

    -- Display name
    self.name = "Starwalker"
    self.short_name = "O.S.W."

    -- Actor (handles overworld/battle sprites)
    self:setActor("party/starwalker")
    -- Light World Actor (handles overworld/battle sprites in light world maps) (optional)
    -- No need for it here

    -- Display level (saved to the save file)
    self.level = 1
    -- Default title / class (saved to the save file)
    self.title = "Star\nThe original."

    -- Determines which character the soul comes from (higher number = higher priority)
    self.soul_priority = -1
    -- Gives a shield in the light world
    self.darkner_shield = true

    -- Whether the party member can act / use spells
    self.has_act = false
    self.has_spells = true

    -- Whether the party member can use their X-Action
    self.has_xact = true
    -- X-Action name (displayed in this character's spell menu)
    self.xact_name = "O-Action"

    -- Spells
    self:addSpell("starshot")
    self:addSpell("starstorm")
    self:addSpell("heal_prayer")

    -- Current health (saved to the save file)
    self.health = 120

    -- Base stats (saved to the save file)
    self.stats = {
        health = 120,
        attack = 7,
        defense = 2,
        magic = 10
    }

    -- Max stats from level-ups
    self.max_stats = {
        health = 160
    }

    self.lw_health = 20
    -- Light world base stats (saved to the save file)
    self.lw_stats = {
        health = 20,
        attack = 10,
        defense = 10,
        magic = 1
    }

    -- Weapon icon in equip menu
    self.weapon_icon = "ui/menu/equip/star"

    -- Equipment (saved to the save file)
    self:setWeapon("gold_bell")

    -- Default light world equipment item IDs (saves current equipment)
    self.lw_weapon_default = "light/pencil"
    self.lw_armor_default = "light/bandage"

    -- Character color (for action box outline and hp bar)
    self.color = { 255 / 255, 242 / 255, 0 / 255 }
    -- Damage color (for the number when attacking enemies) (defaults to the main color)
    self.dmg_color = { 255 / 255, 232 / 255, 0 / 255 }
    -- Attack bar color (for the target bar used in attack mode) (defaults to the main color)
    self.attack_bar_color = nil
    -- Attack box color (for the attack area in attack mode) (defaults to darkened main color)
    self.attack_box_color = { 255 / 255, 202 / 255, 0 / 255 }
    -- X-Action color (for the color of X-Action menu items) (defaults to the main color)
    self.xact_color = nil

    -- Head icon in the equip / power menu
    self.menu_icon = "party/starwalker/head"
    -- Path to head icons used in battle
    self.head_icons = "party/starwalker/icon"
    -- Name sprite (optional)
    self.name_sprite = "party/starwalker/name"

    -- Effect shown above enemy after attacking it
    self.attack_sprite = "effects/attack/slap_n"
    -- Sound played when this character attacks
    self.attack_sound = "laz_c"
    -- Pitch of the attack sound
    self.attack_pitch = 1

    -- Battle position offset (optional)
    self.battle_offset = { -2, -1 }
    -- Head icon position offset (optional)
    self.head_icon_offset = nil
    -- Menu icon position offset (optional)
    self.menu_icon_offset = nil

    -- Message shown on gameover (optional)
    self.gameover_message = nil
end

function character:lightLVStats()
    return {
        health = self:getLightLV() == 20 and 99 or 16 + self:getLightLV() * 4,
        attack = 9 + self:getLightLV() + math.floor(self:getLightLV() / 3),
        defense = 9 + math.ceil(self:getLightLV() / 4),
        magic = self:getLightLV()
    }
end

function character:onLevelUp(level)
   self:increaseStat("health", 2)
   if level % 10 == 0 then
       self:increaseStat("attack", 1)
       self:increaseStat("magic", 1)
   end
end

function character:drawPowerStat(index, x, y, menu)
    if index == 1 then

        local icon = Assets.getTexture("ui/menu/icon/shard")
        Draw.draw(icon, x - 26, y + 8, 0, 2, 2)

        love.graphics.print("Pointy", x, y, 0, 1, 1)
        love.graphics.print("Yes", x + 130, y)

        return true

    elseif index == 2 then

        local icon = Assets.getTexture("ui/menu/icon/star")
        Draw.draw(icon, x - 26, y + 6, 0, 2, 2)

        local icon = Assets.getTexture("ui/menu/icon/starface")
        love.graphics.print("Star Status", x, y, 0, 0.75, 1)
        Draw.draw(icon, x + 128, y + 6, 0, 2, 2)

        return true

    elseif index == 3 then
        local icon = Assets.getTexture("ui/menu/icon/fire")
        Draw.draw(icon, x - 26, y + 6, 0, 2, 2)
        love.graphics.print("Guts:", x, y)

        Draw.draw(icon, x + 90, y + 6, 0, 2, 2)
        if Game.chapter >= 2 then
            Draw.draw(icon, x + 110, y + 6, 0, 2, 2)
        end

        return true

    end
end

return character