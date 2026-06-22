local Dummy, super = Class(Recruit)

function Dummy:init()
    super.init(self)

    -- Display Name
    self.name = "Dummy"

    -- How many times an enemy needs to be spared to be recruited
    self.recruit_amount = 1

    -- Organize the order that recruits show up in the recruit menu
    self.index = 2

    -- Selection Display
    self.description = "A dummy made of cotton.\nRalsei made it to look\nlike himself."
    self.chapter = 1
    self.level = 1
    self.attack = 1
    self.defense = 1
    self.element = "COTTON"
    self.like = "Hugs"
    self.dislike = "Standing Still"

    -- Controls the type of the box gradient
    -- Available options: dark, bright
    self.box_gradient_type = "dark"

    -- Dyes the box gradient
    self.box_gradient_color = { 1, 1, 1, 1 }

    -- Sets the animated sprite in the box
    -- Syntax: Sprite/Animation path, offset_x, offset_y, animation_speed
    self.box_sprite = { "enemies/dummy/idle", 0, 12, 4 / 30 }

    -- Recruit Status (saved to the save file)
    -- Number: Recruit Progress
    -- Boolean: True = Recruited | False = Lost Forever
    self.recruited = 0

    -- Whether this recruit will only be displayed in a specific world
    self.light = nil

    -- Whether the recruit will be hidden from the recruit menu (saved to the save file)
    self.hidden = false
end

return Dummy