local Noelle, super = Class(LightRecruit)

function Noelle:init()
    super.init(self)

    -- Display Name
    self.name = "Noelle"

    -- How many times an enemy needs to be spared to be recruited
    self.recruit_amount = 2

    -- Organize the order that recruits show up in the recruit menu
    self.index = 1

    -- Selection Display
    self.description = "A sweetheart reindeer\nthat will gladly help others.\nShe has a open heart for love."
    self.chapter = 2
    self.level = 14
    self.attack = 38
    self.defense = 4
    self.element = "ICE:CANDY"
    self.like = "Holidays"
    self.dislike = "Going to date with Berdly"

    -- Controls the type of the box gradient
    -- Available options: dark, bright
    self.box_gradient_type = "bright"

    -- Dyes the box gradient
    self.box_gradient_color = { 0, 1, 1, 1 }

    -- Sets the animated sprite in the box
    -- Syntax: Sprite/Animation path, offset_x, offset_y, animation_speed
    self.box_sprite = { "party/noelle/light/walk/down_1", 0, 12, 4 / 30 }

    -- Recruit Status (saved to the save file)
    -- Number: Recruit Progress
    -- Boolean: True = Recruited | False = Lost Forever
    self.recruited = 0

    -- Whether this recruit will only be displayed in a specific world
    self.light = true

    -- Whether the recruit will be hidden from the recruit menu (saved to the save file)
    self.hidden = false
end

return Noelle