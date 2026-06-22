local Shop, super = HookSystem.hookScript(Shop)

function Shop:init()
    super.init(self)

    self.arrow = Assets.getTexture("ui/flat_arrow_left")
    self.party_page = 1
end

function Shop:drawPartyBonusInfo(box_y, item, item_options)
    if #Game.party <= 4 then
        super.drawPartyBonusInfo(self, box_y, item, item_options)
        return
    end

    local party_members_per_page = Mod.libs["moreparty"]:getPartyPerRowAmount(true)
    local start_index = (self.party_page - 1) * party_members_per_page + 1

    for i = start_index, math.min(self.party_page * party_members_per_page, #Game.party) do
        -- Turn the index into a 2 wide grid (0-indexed)
        local transformed_x = (i - start_index) % 2
        local transformed_y = math.floor((i - start_index) / 2) - ((#Game.party <= 6 or Kristal.getLibConfig("moreparty", "three_per_row")) and 0 or 0.9)

        -- Transform the grid into coordinates
        local offset_x = transformed_x * 100
        local offset_y = transformed_y * 26

        local party_member = Game.party[i]
        local can_equip = party_member:canEquip(item)
        local head_path

        Draw.setColor(COLORS.white)

        if can_equip then
            head_path = Assets.getTexture(party_member:getHeadIcons() .. "/head")
            if item.type == "armor" then
                Draw.draw(self.stat_icons["defense_1"], offset_x + 470, offset_y + 132 + box_y)
                Draw.draw(self.stat_icons["defense_2"], offset_x + 470, offset_y + 145 + box_y)

                for j = 1, 2 do
                    self:drawBonuses(party_member, party_member:getArmor(j), item_options["bonuses"], "defense", offset_x + 470 + 21, offset_y + 132 + ((j - 1) * 13) + box_y)
                end
            elseif item.type == "weapon" then
                Draw.draw(self.stat_icons["attack"], offset_x + 470, offset_y + 134 + box_y)
                Draw.draw(self.stat_icons["magic"], offset_x + 470, offset_y + 146 + box_y)

                self:drawBonuses(
                    party_member,
                    party_member:getWeapon(),
                    item_options["bonuses"],
                    "attack", offset_x + 470 + 21,
                    offset_y + 132 + box_y
                )

                self:drawBonuses(
                    party_member,
                    party_member:getWeapon(),
                    item_options["bonuses"],
                    "magic",
                    offset_x + 470 + 21,
                    offset_y + 145 + box_y
                )

            end
        else
            head_path = Assets.getTexture(party_member:getHeadIcons() .. "/head_error")
        end

        Draw.draw(head_path, offset_x + 426, offset_y + 134 + box_y)
    end

    -- Draw arrows
    local box_left, box_top = self.info_box:getBorder()

    local left = self.info_box.x - math.floor(self.info_box.width) - (box_left / 2) * 1.5
    local right = self.info_box.x + (box_left / 2) * 1.5
    local height = math.floor(self.info_box.height) + box_y * 1.5

    if party_members_per_page < #Game.party and (item.type == "armor" or item.type == "weapon") then
        Draw.draw(self.arrow, left, box_y + height / 2)
        Draw.draw(self.arrow, right, box_y + height / 2, 0, -1, 1)
    end
end

function Shop:processBuyMenuInput()
    local party_members_per_page = Mod.libs["moreparty"]:getPartyPerRowAmount(true)
    local max_pages = math.ceil(#Game.party / party_members_per_page)
    local item_type = self.items[self.current_selected_item] and self.items[self.current_selected_item].item and self.items[self.current_selected_item].item.type

    if item_type == "weapon" or item_type == "armor" then
        if Input.pressed("right") then
            self.party_page = (self.party_page % max_pages) + 1
        end
        if Input.pressed("left") then
            self.party_page = ((self.party_page - 2) % max_pages) + 1
        end
    end

    if Input.pressed("cancel") then
        self.party_page = 1
    end

    super.processBuyMenuInput(self)
end

return Shop