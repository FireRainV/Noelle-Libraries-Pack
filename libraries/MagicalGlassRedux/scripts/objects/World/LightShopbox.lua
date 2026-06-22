local LightShopbox, super = Class(Object)

-- The Undertale shop menu that appears when you're going to buy something in the overworld
-- Shows your money and space
function LightShopbox:init()
    super.init(self, 432, 208)

    self:setParallax(0, 0)

    -- In Undertale, the menu always stick to the right, but I think doing this is an improvement
    if Game.world and Game.world.player and Game.world.camera then
        local player_x, _ = Game.world.player:localToScreenPos()
        if player_x >= 376 then
            self.x = self.x - 376
        end
    end

    self.box = UIBox(0, 0, 154, 60)
    self.box.layer = -1
    self:addChild(self.box)

    self.font = Assets.getFont("main")
end

function LightShopbox:draw()
    super.draw(self)

    love.graphics.setFont(self.font)
    Draw.setColor(PALETTE["world_text"])
    love.graphics.print("$ - " .. (Game:getConfig("lightCurrencyShort") ~= "$" and Game.lw_money .. Game:getConfig("lightCurrencyShort") or Game:getConfig("lightCurrencyShort") .. Game.lw_money), 40 - 36, 312 - 220 - 100)
    love.graphics.print("SPACE - " .. Game.inventory:getItemCount("items") .. "/" .. (Game.inventory:getItemCount("items") + Game.inventory:getFreeSpace("items")), 40 - 36, 300 + 60 - 8 - 220 - 100)
end

return LightShopbox