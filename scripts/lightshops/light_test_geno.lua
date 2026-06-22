local TestShop, super = Class(LightShop)

function TestShop:init()
    super.init(self)

    self.encounter_text = "* But nobody came."
    self.shop_text = "* But nobody came."
    self.leaving_text = "* ..."
    -- Shown when you're in the BUY menu
    self.buy_menu_text = ""
    -- Shown when you're about to buy something.
    self.buy_confirmation_text = "Take it."
    -- Shown when you refuse to buy something
    self.buy_refuse_text = ""
    -- Shown when you buy something
    self.buy_text = ""
    -- Shown when you buy something and it goes in your storage
    self.buy_storage_text = ""
    -- Shown when you don't have enough space to buy something.
    self.buy_no_space_text = ""

    self.free_items = true

    self.menu_options = {
        { "Take",  "BUYMENU" },
        { "Steal", function()
            local flag_name = "lightshop#" .. self.id ..":stolen"
            if Game:getFlag(flag_name, false) then
                self:startDialogue("* Nothing left.")
            else
                local amount = MathUtils.round(MathUtils.random(1, 500))
                Game.lw_money = Game.lw_money + amount
                Game:setFlag(flag_name, true)
                self:startDialogue("* You took " .. string.format(self.currency_text, amount) .. " from the void.")
            end
        end },
        { "Read",  function() self:startDialogue({ "* (There's a note here.)", "* I'm on a break, call me tomorrow." }) end },
        { "Exit",  "LEAVE"   }
    }

    self:registerItem("undertale/tough_glove")
    self:registerItem("undertale/cloudy_glasses", { stock = 3, price = 0 })
    self:registerItem("undertale/torn_notebook", { description = "WEAPON\nWEAPON 2\nWEAPON 3", dont_show_change = true })
    self:registerItem("undertale/crab_apple")
    self:registerItem("mg/snowflake_ring", { description = "This is a\ntest." })
    self:registerItem("undertale/bisicle")
    self:registerItem("undertale/legendary_hero")
    self:registerItem("undertale/temy_armor")
    self:registerItem("undertale/annoying_dog")
    self:registerItem("mg/tough_glove")

    self:registerTalk("Reflect")
    self:registerTalk("Where I Am")
    self:registerTalk("Who Am I Talking To")
    self:registerTalk("What Is Going To Happen")

    self:registerTalkAfter("Myself", 1)
    self:registerTalkAfter("Why Am I Here", 2)

    self.background = nil
end

return TestShop