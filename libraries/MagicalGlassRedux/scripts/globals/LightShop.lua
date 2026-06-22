local LightShop, super = Class(Object)

function LightShop:init()
    self:setShopWorldLight(true)

    super.init(self)

    -- The label used for currency in this shop
    self.currency_text = Game:getConfig("lightCurrencyShort") ~= "$" and "%s" .. Game:getConfig("lightCurrencyShort") or Game:getConfig("lightCurrencyShort") .. "%s"
    self.sell_currency_text = Game:getConfig("lightCurrencyShort") ~= "$" and "(%s " .. Game:getConfig("lightCurrencyShort") .. ")" or "(" .. Game:getConfig("lightCurrencyShort") .. " %s)"

    -- Shown when you first enter a shop
    self.encounter_text = "* Encounter text"
    -- Shown when you return to the main menu of the shop
    self.shop_text = "* Shop text"
    -- Shown when you leave a shop
    self.leaving_text = "* Leaving text"
    -- Shown when you're in the BUY menu
    self.buy_menu_text = "Purchase\ntext"
    -- Shown when you're about to buy something
    self.buy_confirmation_text = "Buy it for\n%s ?"
    self.buy_confirmation_yes_text = "Yes"
    self.buy_confirmation_no_text = "No"
    -- Shown when you refuse to buy something
    self.buy_refuse_text = "Buy\nrefused\ntext"
    -- Shown when you buy something
    self.buy_text = "Buy text"
    -- Shown when you buy something and it goes in your storage
    self.buy_storage_text = "Storage\nbuy text"
    -- Shown when you don't have enough money to buy something
    self.buy_too_expensive_text = "Not\nenough\nmoney."
    -- Shown when you don't have enough space to buy something
    self.buy_no_space_text = "You're\ncarrying\ntoo much."
    -- Shown when you attempt to buy a sold out item
    self.buy_sold_out_text = "Out of\nstock."
    -- Shown when you hover on the sold out item
    self.buy_sold_out_menu_text = "SOLD OUT"
    -- Shown when you're in the SELL menu
    self.sell_menu_text = "Sell\nmenu\ntext"
    -- Shown when you're about to sell something
    self.sell_confirmation_text = "Sell %s for %s ?"
    self.sell_confirmation_yes_text = "Yes"
    self.sell_confirmation_no_text = "No"
    -- Shown when you have sold all your items in a storage
    self.sell_everything_text = "Sold\neverything\ntext"
    -- Shown when you have nothing in a storage
    self.sell_no_storage_text = "Empty\ninventory\ntext"
    -- Shown when you attempt to enter the selling menu from the main menu but your storage is empty
    self.sell_no_storage_encounter_text = "* Empty inventory text"
    -- Shown when you enter the talk menu
    self.talk_text = "Talk\ntext"

    -- Whether to hide the amount of items and space you currently have
    self.hide_storage_text = false

    -- makes all items free to buy (similar to shops in the genocide route)
    self.free_items = false

    -- MAINMENU
    self.menu_options = {
        { "Buy",  "BUYMENU" },
        { "Sell", "SELLING" }, -- Can also be "SELLMENU"
        { "Talk", "TALKMENU" },
        { "Exit", "LEAVE" }
    }

    self.items = {}
    self.talks = {}
    self.talk_replacements = {}

    -- SELLMENU
    self.sell_options = {
        { "Sell Items", "items" },
        { "Sell Box A Items", "box_a" },
        { "Sell Box B Items", "box_b" }
    }

    -- The storage that will be used when going to the sell menu directly from the main menu
    self.selling_menu_from_main_inventory = "items"

    -- Shown when you sell an item
    self.sold_text = "(Thank you!)"
    -- Rotates the name of the items in the selling menu (in degrees)
    self.selling_item_rotation = 0

    self.background = nil
    self.background_speed = 5 / 30

    -- STATES: MAINMENU, BUYMENU, SELLMENU, SELLING, TALKMENU, LEAVE, LEAVING, DIALOGUE
    self.state = "NONE"
    self.state_reason = nil

    self.shop_music = ""
    self.music = Music()

    self.timer = Timer()
    self:addChild(self.timer)

    self.voice = nil

    self.shopkeeper = Shopkeeper()
    self.shopkeeper:setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
    self.shopkeeper.layer = LIGHT_SHOP_LAYERS["shopkeeper"]
    self:addChild(self.shopkeeper)

    self.bg_cover = Rectangle(0, SCREEN_HEIGHT / 2, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.bg_cover:setColor(0, 0, 0)
    self.bg_cover.layer = LIGHT_SHOP_LAYERS["cover"]
    self:addChild(self.bg_cover)

    self.current_selected_main_option = 1

    self.current_selected_item = 1
    self.current_selecting_choice = 1

    self.current_selecting_storage = 1
    self.current_selected_selling_item_x = 1
    self.current_selected_selling_item_y = 1

    self.item_offset = 0
    self.sold_items = 0
    self.sell_page = 1

    self.font = Assets.getFont("main")
    self.heart_sprite = Assets.getTexture("player/heart_menu")
    self.arrow_sprite = Assets.getTexture("ui/page_arrow_down")

    self.fade_alpha = 0
    self.fading_out = false
    self.expand_box = false
    self.draw_divider = false

    self.selling_menu_from_main = false

    self.hide_price = false

    self.leave_options = {}

    self.hide_world = true
    self.hide_main_menu_currency = false
end

function LightShop:postInit()
    -- Mutate talks

    self:processReplacements()

    -- Make a sprite for the background
    if self.background and self.background ~= "" then
        self.background_sprite = Sprite(self.background, 0, 0)
        self.background_sprite:setScale(2, 2)
        self.background_sprite.layer = LIGHT_SHOP_LAYERS["background"]
        self.background_sprite:play(self.background_speed, true)
        self:addChild(self.background_sprite)
    end

    -- Construct the UI
    self.main_box = UIBox(0, 0, 0, 0, Game:isLight() and "lightshop" or "dark")
    local left, top = self.main_box:getBorder()
    self.main_box:setOrigin(0, 1)
    self.main_box.x = left - 8
    self.main_box.y = SCREEN_HEIGHT - top + 10
    self.main_box.width = SCREEN_WIDTH - (top * 2) + 18
    self.main_box.height = 194
    self.main_box:setLayer(LIGHT_SHOP_LAYERS["main_box"])

    self:addChild(self.main_box)

    self.info_box = UIBox(0, 0, 0, 0, "lightshop")
    local left, top = self.info_box:getBorder()
    self.info_box:setOrigin(1, 1)
    self.info_box.x = SCREEN_WIDTH - left + 10
    self.info_box.y = SCREEN_HEIGHT - top - self.main_box.height + 15
    self.info_box.width = 174
    self.info_box.height = -8
    self.info_box:setLayer(LIGHT_SHOP_LAYERS["info_box"])

    self.info_box.visible = false

    self:addChild(self.info_box)

    local emoteCommand = function(text, node)
        self:onEmote(node.arguments[1])
    end

    self.dialogue_text = DialogueText("", 40, 260, 372, 226, {
        font = self:getFont(),
        actor = self.shopkeeper:getActor(),
        indent_string = self:getIndentString()
    })

    self.dialogue_text:registerCommand("emote", emoteCommand)

    self.dialogue_text:setLayer(LIGHT_SHOP_LAYERS["dialogue"])
    self:addChild(self.dialogue_text)
    self:setDialogueText(self.encounter_text)

    self.right_text = DialogueText("", 460, 260, 176, 206, {
        font = self:getFont(),
        actor = self.shopkeeper:getActor(),
        indent_string = self:getIndentString()
    })

    self.right_text:registerCommand("emote", emoteCommand)

    self.right_text:setLayer(LIGHT_SHOP_LAYERS["dialogue"])
    self:addChild(self.right_text)
    self:setRightText("")

    self.talk_dialogue = { self.dialogue_text, self.right_text }
end

-- Automatically sets the world type to the shop type
function LightShop:setShopWorldLight(value)
    if value then
        if Mod.libs["magical-glass"].last_shop_world_type == nil then
            Mod.libs["magical-glass"].last_shop_world_type = Game:isLight()
        end
        Game:setLight(true)
    else
        if Mod.libs["magical-glass"].last_shop_world_type ~= nil then
            Game:setLight(Mod.libs["magical-glass"].last_shop_world_type)
        end
        Mod.libs["magical-glass"].last_shop_world_type = nil
    end
end

-- Runs every time the player selects a topic in the TALK menu
function LightShop:startTalk(talk) end

-- Runs when the player enters the shop, after it has been fully initialised.
function LightShop:onEnter()
    self:setState("MAINMENU")
    self:setDialogueText(self.encounter_text)
    -- Play music
    if self.shop_music and self.shop_music ~= "" then
        self.music:play(self.shop_music)
    end
end

function LightShop:onRemove(parent)
    super.onRemove(self, parent)

    self.music:remove()
end

function LightShop:getVoice()
    local actor = self.shopkeeper:getActor()
    return self.voice or (actor and actor:getVoice())
end

function LightShop:getVoicedText(text)
    local voice = self:getVoice()

    if not voice then
        return text
    end

    if type(text) == "table" then
        local voiced_text = {}

        for _, v in ipairs(text) do
            table.insert(voiced_text, "[voice:" .. voice .. "]" .. v)
        end

        return voiced_text
    else
        return "[voice:" .. voice .. "]" .. text
    end
end

function LightShop:getFont()
    local actor = self.shopkeeper:getActor()
    if actor then
        return actor:getFont()
    end

    return nil
end

function LightShop:getIndentString()
    local actor = self.shopkeeper:getActor()
    if actor then
        return actor:getIndentString()
    end

    return nil
end

function LightShop:setDialogueText(text, no_voice)
    self.dialogue_text:setText(no_voice and text or self:getVoicedText(text))
end

function LightShop:setRightText(text, no_voice)
    self.right_text:setText(no_voice and text or self:getVoicedText(text))
end

-- Changes the shop to a new state
function LightShop:setState(state, reason)
    local old = self.state
    self.state = state
    self.state_reason = reason
    self:onStateChange(old, self.state)
end

function LightShop:getState()
    return self.state
end

-- Shows the info box on the right side of the screen, used in the BUYMENU state
function LightShop:showInfoBox()
    if self.info_box.visible then
        return
    end

    self.info_box.visible = true

    if #self.items > 0 then
        self.expand_box = true
    else
        self.expand_box = false
    end
end

-- Hides the info box on the right side of the screen, used in the BUYMENU state
function LightShop:hideInfoBox()
    self.info_box.visible = false
end

-- Shows the divider on the right side of the screen
function LightShop:showDivider()
    self.draw_divider = true
end

-- Hides the divider on the right side of the screen
function LightShop:hideDivider()
    self.draw_divider = false
end

function LightShop:onMainMenuState(old)
    self:showDivider()

    self:hideInfoBox()

    self.dialogue_text.width = 372
    self:setDialogueText(self.shop_text)
    self:setRightText("")
end

function LightShop:onBuyMenuState(old)
    self:showDivider()
    self:setDialogueText("")
    self:setRightText(self.buy_menu_text)

    self:showInfoBox()

    if old ~= "BUYCONFIRM" then
        self.current_selected_item = 1
        self:adjustBuyScroll()
    end
end

function LightShop:onBuyConfirmState(old)
    self:showDivider()
    self:setDialogueText("")
    self:setRightText("")

    self:showInfoBox()
end

function LightShop:onSellMenuState(old)
    self:showDivider()
    self:setDialogueText("")
    if not self.state_reason then
        self:setRightText(self.sell_menu_text)
    end

    self.current_selected_item = 1

    self:hideInfoBox()
end

function LightShop:onSellingState(old)
    self:hideDivider()
    self:setDialogueText("")
    self:setRightText("")

    self:hideInfoBox()

    if old ~= "SELLCONFIRM" then
        self.current_selected_selling_item_x = 1
        self.current_selected_selling_item_y = 1

        self.sold_items = 0
        self.sell_page = 1

        if old ~= "SELLMENU" then
            self.selected_storage = self.selling_menu_from_main_inventory
            if #Game.inventory:getStorage(self.selected_storage) > 0 then
                self.selling_menu_from_main = true
            else
                self:setState("MAINMENU")
                self:startDialogue(self.sell_no_storage_encounter_text)
            end
        end
    end
end

function LightShop:onSellConfirmState(old)
    self:hideDivider()

    self:hideInfoBox()

    self:setDialogueText("")
    self:setRightText("")
end

function LightShop:onTalkMenuState(old)
    self:showDivider()
    self:setDialogueText("")
    self:setRightText(self.talk_text)

    self:hideInfoBox()

    if self.state_reason ~= "DIALOGUE" then
        self.current_selected_item = 1
    end

    self:processReplacements()
    self:onTalk()
end

function LightShop:onLeaveState(old)
    self:hideDivider()
    self:setRightText("")
    self:hideInfoBox()
    self:onLeave()
end

function LightShop:onLeavingState(old)
    self:hideDivider()
    self:setRightText("")
    self:setDialogueText("")
    self:hideInfoBox()
    self:leave()
end

function LightShop:onDialogueState(old)
    self:hideDivider()
    self.dialogue_text.width = 598
    self:setRightText("")
    self:hideInfoBox()
end

function LightShop:onStateChange(old, new)
    if new == "MAINMENU" then
        self:onMainMenuState(old)
    elseif new == "BUYMENU" then
        self:onBuyMenuState(old)
    elseif new == "BUYCONFIRM" then
        self:onBuyConfirmState(old)
    elseif new == "SELLMENU" then
        self:onSellMenuState(old)
    elseif new == "SELLING" then
        self:onSellingState(old)
    elseif new == "SELLCONFIRM" then
        self:onSellConfirmState(old)
    elseif new == "TALKMENU" then
        self:onTalkMenuState(old)
    elseif new == "LEAVE" then
        self:onLeaveState(old)
    elseif new == "LEAVING" then
        self:onLeavingState(old)
    elseif new == "DIALOGUE" then
        self:onDialogueState(old)
    end
end

-- Called when the player selects to leave the shop from the main menu, happens at the same time the leaving dialogue begins
function LightShop:onLeave()
    self:startDialogue(self.leaving_text, "LEAVING")
end

-- Leaves the shop with a fade out transition
function LightShop:leave()
    if self:shouldFade() then
        self.fading_out = true
        self.music:fade(0, 20 / 30)
    else
        self:leaveImmediate()
    end
end

-- Leaves the shop instantly, without a transition
function LightShop:leaveImmediate()
    self:setShopWorldLight(false)

    self:remove()
    Game.shop = nil
    Mod.libs["magical-glass"].in_light_shop = false
    Game.state = "OVERWORLD"
    if self:shouldFade() then
        Game.fader.alpha = 1
        Game.fader:fadeIn()
    end
    Game.world:setState("GAMEPLAY")

    --self.transition_target.shop = nil
    --Game.world:transitionImmediate(self.transition_target)
    if self.leave_options["menu"] then
        Game:returnToMenu()
    elseif self.leave_options["x"] then
        Game.world:mapTransition(self.leave_options["map"] or Game.world.map.id, self.leave_options["x"], self.leave_options["y"], self.leave_options["facing"])
    elseif self.leave_options["marker"] then
        Game.world:mapTransition(self.leave_options["map"] or Game.world.map.id, self.leave_options["marker"], self.leave_options["facing"])
    else
        if self.leave_options["facing"] then
            Game.world.player:setFacing(self.leave_options["facing"])
        end
        Game.world.music:resume()
    end
end

function LightShop:shouldFade()
    return self.leave_options["fade"] or self:isWorldHidden()
end

function LightShop:onTalk() end

function LightShop:onEmote(emote)
    -- Default behaviour: set sprite / animation
    self.shopkeeper:onEmote(emote)
end

function LightShop:startDialogue(text, callback)

    local state = "MAINMENU"
    if self.state == "TALKMENU" then
        state = "TALKMENU"
    end

    self:setState("DIALOGUE")
    self:setDialogueText(text)

    self.dialogue_text.advance_callback = (function()
        if type(callback) == "string" then
            state = callback
        elseif type(callback) == "function" then
            if callback() then
                return
            end
        end

        self:setState(state, "DIALOGUE")
    end)
end

-- Adds an item to the shop at the next available index
-- 'options' An optional list of properties that can be defined for this item in the shop, overriding the default values set on the item:
-- | "name"         # The name of the item shown in the shop.
-- | "description"  # The description of the item shown in the shop
-- | "hide_change"  # Whether to hide pre-defined stats for weapons, armors and healing items
-- | "price"        # The price of the item in this shop
-- | "bonuses"      # The preview stat bonuses provided by the item (does not affect actual item stat bonuses)
-- | "color"        # The color of the item name text
-- | "flag"         # The name of a flag used to store the remaining stock of this item. Defaults to `stock_<index>_<item.id>`
-- | "stock"        # The default number of stock of this item. Infinite if unspecified.
function LightShop:registerItem(item, options)
    return self:replaceItem(#self.items + 1, item, options)
end

-- Adds or replaces an item in the shop
-- 'options' An optional list of properties that can be defined for this item in the shop, overriding the default values set on the item:
-- | "name"         # The name of the item shown in the shop.
-- | "description"  # The description of the item shown in the shop
-- | "hide_change"  # Whether to hide pre-defined stats for weapons, armors and healing items
-- | "price"        # The price of the item in this shop
-- | "bonuses"      # The preview stat bonuses provided by the item (does not affect actual item stat bonuses)
-- | "color"        # The color of the item name text
-- | "flag"         # The name of a flag used to store the remaining stock of this item. Defaults to `stock_<index>_<item.id>`
-- | "stock"        # The default number of stock of this item. Infinite if unspecified.
function LightShop:replaceItem(index, item, options)
    if type(item) == "string" then
        item = Registry.createItem(item)
    end
    if item then
        options = options or {}
        options["name"]        = options["name"] or item:getName()
        options["description"] = options["description"] or item:getLightShopDescription()
        options["hide_change"] = options["hide_change"] or item:getLightShopHideChange()
        options["price"]       = options["price"] or item:getBuyPrice()
        options["bonuses"]     = options["bonuses"] or item:getStatBonuses()
        options["color"]       = options["color"] or { 1, 1, 1, 1 }
        options["flag"]        = options["flag"] or ("stock_" .. tostring(index) .. "_" .. item.id)

        options["stock"] = self:getFlag(options["flag"], options["stock"])

        self.items[index] = {
            item = item,
            options = options
        }
        return true
    else
        return false
    end
end

-- Registers a talk topic that will appear in the TALK submenu
function LightShop:registerTalk(talk, color)
    table.insert(self.talks, { talk, { color = color or COLORS.white } })
end

-- Replaces one talk topic with another
function LightShop:replaceTalk(talk, index, color)
    self.talks[index] = { talk, { color = color or COLORS.yellow } }
end

-- Registers a talk topic that will appear in the TALK submenu when specific conditions are met
-- By default, the new topic will appear after the current topic at `index` has been chosen once
function LightShop:registerTalkAfter(talk, index, flag, value, color)
    table.insert(self.talk_replacements, { index, { talk, { flag = flag or ("talk_" .. tostring(index)), value = value, color = color or COLORS.yellow } } })
end

function LightShop:processReplacements()
    for i = 1, #self.talks do
        -- Replace talk option if any replacements flag is set
        -- (Replacements registered later have higher priority)
        for j = 1, #self.talk_replacements do
            if self.talk_replacements[j][1] == i then
                local talk_replacement = self.talk_replacements[j][2]
                if self:getFlag(talk_replacement[2].flag) == (talk_replacement[2].value == nil and true or talk_replacement[2].value) then
                    self:replaceTalk(talk_replacement[1], i, talk_replacement[2].color)
                end
            end
        end
    end
end

function LightShop:adjustBuyScroll()
    local total = #self.items + 1
    local visible = 5

    -- keep selection inside visible area
    self.item_offset = MathUtils.clamp(self.item_offset, self.current_selected_item - visible, self.current_selected_item - 1)

    -- clamp to valid range
    self.item_offset = MathUtils.clamp(self.item_offset, 0, total - visible)

    -- dont scroll at all if we have enough
    if total <= visible then
        self.item_offset = 0
    end
end

function LightShop:adjustSellScroll(dir)
    if dir == "up" then
        local old = self.current_selected_selling_item_y

        if self.current_selected_selling_item_y == 5 then
            while not self:isValidMenuLocation() do
                self.current_selected_selling_item_y = self.current_selected_selling_item_y - 1
            end
        else
            self.current_selected_selling_item_y = self.current_selected_selling_item_y - 1
            if not self:isValidMenuLocation() then
                self.current_selected_selling_item_y = old
            end
        end
    elseif dir == "down" then
        local old = self.current_selected_selling_item_y
        self.current_selected_selling_item_y = self.current_selected_selling_item_y + 1

        if not self:isValidMenuLocation() then
            if self.current_selected_selling_item_y <= 8 then
                self.current_selected_selling_item_y = 5
                self.current_selected_selling_item_x = 1
            else
                self.current_selected_selling_item_y = old
            end
        end
    elseif dir == "left" then
        -- Exit button
        if self.current_selected_selling_item_y > 4 then
            return
        end

        local old = self.current_selected_selling_item_x
        self.current_selected_selling_item_x = self.current_selected_selling_item_x - 1

        if self.current_selected_selling_item_x < 1 or not self:isValidMenuLocation() then
            if self:getSellMaxPage() > 1 and self.sell_page >= self:getSellMaxPage() then
                self.sell_page = self.sell_page - 1
                self.current_selected_selling_item_x = 2
            else
                self.current_selected_selling_item_x = old
            end
        end
    elseif dir == "right" then
        -- Exit button
        if self.current_selected_selling_item_y > 4 then
            return
        end

        local old = self.current_selected_selling_item_x
        self.current_selected_selling_item_x = self.current_selected_selling_item_x + 1

        if not self:isValidMenuLocation() then
            if self:getSellMaxPage() > 1 and self.sell_page < self:getSellMaxPage() then
                self.sell_page = self.sell_page + 1
                self.current_selected_selling_item_x = 1
                while not self:isValidMenuLocation() do
                    self.current_selected_selling_item_y = self.current_selected_selling_item_y - 1
                end
            else
                self.current_selected_selling_item_x = old
            end
        end
    end
end

function LightShop:updateExpandingBox()
    if self.expand_box then
        if self.info_box.height < 55 then
            self.info_box.height = self.info_box.height + 2 * DTMULT
        end
        if self.info_box.height < 80 then
            self.info_box.height = self.info_box.height + 4 * DTMULT
        end
        if self.info_box.height < 100 then
            self.info_box.height = self.info_box.height + 5 * DTMULT
        end
        if self.info_box.height < 167 then
            self.info_box.height = self.info_box.height + (3 + 4) * DTMULT
        end
        if self.info_box.height > 167 then
            self.info_box.height = 167
        end
    else
        self.info_box.height = -8
    end
end

function LightShop:slideShopkeeper(away)
    if away then
        local target_x = SCREEN_WIDTH / 2 - 80
        if self.shopkeeper.x > target_x + 60 then
            self.shopkeeper.x = MathUtils.approach(self.shopkeeper.x, target_x, 4 * DTMULT)
        end
        if self.shopkeeper.x > target_x + 40 then
            self.shopkeeper.x = MathUtils.approach(self.shopkeeper.x, target_x, 4 * DTMULT)
        end
        if self.shopkeeper.x > target_x then
            self.shopkeeper.x = MathUtils.approach(self.shopkeeper.x, target_x, 4 * DTMULT)
        end
    else
        local target_x = SCREEN_WIDTH / 2
        if self.shopkeeper.x < target_x - 50 then
            self.shopkeeper.x = MathUtils.approach(self.shopkeeper.x, target_x, 4 * DTMULT)
        end
        if self.shopkeeper.x < target_x - 30 then
            self.shopkeeper.x = MathUtils.approach(self.shopkeeper.x, target_x, 4 * DTMULT)
        end
        if self.shopkeeper.x < target_x then
            self.shopkeeper.x = MathUtils.approach(self.shopkeeper.x, target_x, 4 * DTMULT)
        end
    end
end

function LightShop:updateStates()
    -- Nothing here for now!
end

function LightShop:updateInfoBox()
    if self.info_box.visible then
        self:updateExpandingBox()

        if self.shopkeeper.slide then
            self:slideShopkeeper(true)
        end
    else
        if self.shopkeeper.slide then
            self:slideShopkeeper(false)
        end
    end
end

function LightShop:updateFade()
    if self.fading_out then
        self.fade_alpha = self.fade_alpha + (DT * 2)
        if self.fade_alpha >= 1 then
            self:leaveImmediate()
        end
    end
end

function LightShop:updateTalkSprites()
    for _, object in ipairs(self.talk_dialogue) do
        if self.shopkeeper.talk_sprite then
            object.talk_sprite = self.shopkeeper.sprite
        else
            object.talk_sprite = nil
        end
    end
end

function LightShop:processMainMenuInput()
    if Input.pressed("confirm") then
        local selection = self.menu_options[self.current_selected_main_option][2]
        if type(selection) == "string" then
            self:setState(selection)
        elseif type(selection) == "function" then
            selection()
        end
    elseif Input.pressed("up") then
        self.current_selected_main_option = self.current_selected_main_option - 1
        if (self.current_selected_main_option <= 0) then
            self.current_selected_main_option = #self.menu_options
        end
    elseif Input.pressed("down") then
        self.current_selected_main_option = self.current_selected_main_option + 1
        if (self.current_selected_main_option > #self.menu_options) then
            self.current_selected_main_option = 1
        end
    end
end

function LightShop:processBuyMenuInput()
    local old_selecting = self.current_selected_item

    if Input.pressed("confirm") then
        if self.current_selected_item == math.max(#self.items, 4) + 1 then
            self:setState("MAINMENU")
        elseif self.items[self.current_selected_item] then
            if self.items[self.current_selected_item].options["stock"] then
                if self.items[self.current_selected_item].options["stock"] <= 0 then
                    self:setRightText(self.buy_sold_out_text)
                    return
                end
            end
            self:setState("BUYCONFIRM")
            self.current_selecting_choice = 1
            self:setRightText("")
        end
    elseif Input.pressed("cancel") then
        self:setState("MAINMENU")
    elseif Input.pressed("up") then
        self.current_selected_item = self.current_selected_item - 1
        if (self.current_selected_item <= 0) then
            self.current_selected_item = math.max(#self.items, 4) + 1
        end
        self:adjustBuyScroll()
    elseif Input.pressed("down") then
        self.current_selected_item = self.current_selected_item + 1
        if (self.current_selected_item > math.max(#self.items, 4) + 1) then
            self.current_selected_item = 1
        end
        self:adjustBuyScroll()
    end

    if old_selecting ~= self.current_selected_item then
        if self.current_selected_item >= #self.items + 1 then
            self.expand_box = false
        elseif (old_selecting >= #self.items + 1) and (self.current_selected_item <= #self.items) then
            self.expand_box = true
        end
    end
end

function LightShop:processBuyConfirmInput()
    if Input.pressed("confirm") then
        self:setState("BUYMENU")
        local current_item = self.items[self.current_selected_item]
        if self.current_selecting_choice == 1 then
            self:buyItem(current_item)
        else
            self:setRightText(self.buy_refuse_text)
        end
    elseif Input.pressed("cancel") then
        self:setState("BUYMENU")
        self:setRightText(self.buy_refuse_text)
    elseif Input.pressed("up") or Input.pressed("down") then
        if self.current_selecting_choice == 1 then
            self.current_selecting_choice = 2
        else
            self.current_selecting_choice = 1
        end
    end
end

function LightShop:processSellMenuInput()
    if Input.pressed("confirm") then
        if (self.current_selecting_storage <= #self.sell_options) then
            local data = self.sell_options[self.current_selecting_storage]
            self:enterSellMenu(data[2])
        else
            self:setState("MAINMENU")
        end
    elseif Input.pressed("cancel") then
        self:setState("MAINMENU")
    elseif Input.pressed("up") then
        self.current_selecting_storage = self.current_selecting_storage - 1
        if (self.current_selecting_storage <= 0) then
            self.current_selecting_storage = #self.sell_options + 1
        end
    elseif Input.pressed("down") then
        self.current_selecting_storage = self.current_selecting_storage + 1
        if (self.current_selecting_storage > #self.sell_options + 1) then
            self.current_selecting_storage = 1
        end
    end
end

function LightShop:processSellingInput()
    local inventory = Game.inventory:getStorage(self.selected_storage)
    if not inventory then
        -- Somehow we don't have an inventory for this, so...
        if Input.pressed("confirm") or Input.pressed("cancel") then
            self:setState("MAINMENU")
        end
        return
    end

    if Input.pressed("confirm") then
        if inventory[self:getSellMenuIndex()] then
            if inventory[self:getSellMenuIndex()]:isSellable() then
                self:setState("SELLCONFIRM")
                self.current_selecting_choice = 1
                self:setRightText("")
            else
                Assets.playSound("cantsell")
            end
        else
            if self.selling_menu_from_main then
                self:setState("MAINMENU")
            else
                self:setState("SELLMENU")
                self:setRightText(self.sell_everything_text)
            end
        end
    elseif Input.pressed("cancel") then
        if self.selling_menu_from_main then
            self:setState("MAINMENU")
        else
            self:setState("SELLMENU")
        end
    elseif Input.pressed("up") then
        self:adjustSellScroll("up")
    elseif Input.pressed("down") then
        self:adjustSellScroll("down")
    elseif Input.pressed("left") then
        self:adjustSellScroll("left")
    elseif Input.pressed("right") then
        self:adjustSellScroll("right")
    end
end

function LightShop:processSellConfirmInput()
    local inventory = Game.inventory:getStorage(self.selected_storage)
    if not inventory then
        return
    end

    if Input.pressed("confirm") then
        self:setState("SELLING")

        local current_item = inventory[self:getSellMenuIndex()]
        if self.current_selecting_choice == 1 then
            self:sellItem(current_item)

            if #inventory % 8 == 0 then
                self.sold_items = 0
            else
                self.sold_items = self.sold_items + 1
            end

            if self.sell_page > self:getSellMaxPage() then
                self.sell_page = self.sell_page - 1
                self.current_selected_selling_item_x = 2
                self.current_selected_selling_item_y = 4
            elseif not self:isValidMenuLocation() then
                if self.current_selected_selling_item_x > 1 then
                    self.current_selected_selling_item_x = self.current_selected_selling_item_x - 1
                else
                    self.current_selected_selling_item_x = 2
                    self.current_selected_selling_item_y = self.current_selected_selling_item_y - 1
                end
            end

            if #Game.inventory:getStorage(self.selected_storage) <= 0 then
                if self.selling_menu_from_main then
                    self:setState("MAINMENU")
                else
                    self:setState("SELLMENU")
                    self:setRightText(self.sell_everything_text)
                end
            end
        end
    elseif Input.pressed("cancel") then
        self:setState("SELLING")
    elseif Input.pressed("left") or Input.pressed("right") then
        if self.current_selecting_choice == 1 then
            self.current_selecting_choice = 2
        else
            self.current_selecting_choice = 1
        end
    end
end

function LightShop:processTalkMenuInput()
    if Input.pressed("confirm") then
        if (self.current_selected_item <= #self.talks) then
            local talk = self.talks[self.current_selected_item]
            self:setFlag("talk_" .. self.current_selected_item, true)
            self:startTalk(talk[1])
        elseif self.current_selected_item == math.max(4, #self.talks) + 1 then
            self:setState("MAINMENU")
        end
    elseif Input.pressed("cancel") then
        self:setState("MAINMENU")
    elseif Input.pressed("up") then
        self.current_selected_item = self.current_selected_item - 1
        if (self.current_selected_item <= 0) then
            self.current_selected_item = math.max(4, #self.talks) + 1
        end
    elseif Input.pressed("down") then
        self.current_selected_item = self.current_selected_item + 1
        if (self.current_selected_item > math.max(4, #self.talks) + 1) then
            self.current_selected_item = 1
        end
    end
end

function LightShop:processInput()
    if self.state == "MAINMENU" then
        self:processMainMenuInput()
    elseif self.state == "BUYMENU" then
        self:processBuyMenuInput()
    elseif self.state == "BUYCONFIRM" then
        self:processBuyConfirmInput()
    elseif self.state == "SELLMENU" then
        self:processSellMenuInput()
    elseif self.state == "SELLING" then
        self:processSellingInput()
    elseif self.state == "SELLCONFIRM" then
        self:processSellConfirmInput()
    elseif self.state == "TALKMENU" then
        self:processTalkMenuInput()
    end
end

function LightShop:update()
    self:processInput()

    self:updateTalkSprites()

    super.update(self)

    self:updateStates()
    self:updateInfoBox()

    self:updateFade()
end

function LightShop:drawStorageDisplay()
    Draw.setColor(COLORS.white)
    love.graphics.print(
        Game.inventory:getItemCount("items") .. "/" .. (Game.inventory:getItemCount("items") + Game.inventory:getFreeSpace("items")),
    560, 420)
end

function LightShop:drawMainMenu()
    love.graphics.setFont(self.font)
    Draw.setColor(COLORS.white)

    for i = 1, #self.menu_options do
        love.graphics.print(self.menu_options[i][1], 480, 220 + (i * 40))
    end

    Draw.setColor(Game:getSoulColor())
    Draw.draw(self.heart_sprite, 450, 228 + (self.current_selected_main_option * 40), 0, 2)
end

function LightShop:drawBuyItems(draw_soul)
    local heart_pos = 30
    local text_pos = 60

    local total_items = #self.items + 1
    local visible_items = 5

    local first_item = 1 + self.item_offset
    local last_item = self.item_offset + visible_items

    local return_index = math.max(last_item, total_items)

    -- Show items
    for i = first_item, last_item do
        local y = 220 + ((i - self.item_offset) * 40)
        local item = self.items[i]

        if i == return_index then
            Draw.setColor(COLORS.white)
            love.graphics.print("Exit", text_pos, y)
        elseif item == nil then
            -- If there's no item there, show empty slot
            Draw.setColor(COLORS.dkgray)
            love.graphics.print("--------", text_pos, y)
        elseif item.options["stock"] and (item.options["stock"] <= 0) then
            -- If we've depleted the stock, show a "sold out" message
            Draw.setColor(COLORS.gray)
            love.graphics.print("--- SOLD OUT ---", text_pos, y)
        else
            -- Valid item, show it
            Draw.setColor(item.options["color"])
            local display_item
            if not self.hide_price then
                display_item = string.format(self.currency_text, (self.free_items and string.rep("0", #tostring(math.abs(item.options["price"] or 0)))) or item.options["price"] or 0) .. " - " .. item.options["name"]
                if item.options["price"] and item.options["price"] < 10 and item.options["price"] >= 0 then
                    display_item = "  " .. display_item
                end
            else
                display_item = item.options["name"]
            end
            love.graphics.print(display_item, text_pos, y)
        end

        if draw_soul and (i == self.current_selected_item) then
            -- Draw the soul if we're selecting this option
            Draw.setColor(Game:getSoulColor())
            Draw.draw(self.heart_sprite, heart_pos, y + 8, 0, 2)
        end
    end
end

function LightShop:drawItemInfo(box_y, item, item_options)
    local x = 420 + 28
    local y = box_y + 28
    local font_height = self.font:getHeight()

    if item_options["stock"] and item_options["stock"] <= 0 then
        -- Sold out description
        self:drawItemDescription(self.buy_sold_out_menu_text, x, y)
    elseif not item_options["hide_change"] and (item.type == "weapon" or item.type == "armor") then
        -- Equip Item description
        local stat_type = item:getLightShopShowMagic() and { "magic", "MG" } or item.type == "weapon" and { "attack", "AT" } or item.type == "armor" and { "defense", "DF" } or { "unknown", "??" }
        local stat, stat_name = TableUtils.unpack(stat_type)
        -- First letter should be capital
        local type_name = StringUtils.sub(item.type, 1, 1):upper() .. StringUtils.sub(item.type, 2):lower()

        self:drawItemBonusInfo(item, type_name, stat, stat_name, x, y)
        self:drawBonuses(item, item_options["bonuses"], stat, stat_name, x, y + font_height)
        self:drawItemDescription(item_options["description"], x, y + font_height * 2)
    elseif not item_options["hide_change"] and item:includes(HealItem) then
        -- Health Item description
        self:drawItemHealAmount(item:getHealAmount(), x, y)
        self:drawItemDescription(item_options["description"], x, y + font_height)
    else
        -- Normal description
        self:drawItemDescription(item_options["description"], x, y)
    end
end

function LightShop:drawItemDescription(text, x, y)
    love.graphics.print(text, x, y)
end

function LightShop:drawItemHealAmount(amount, x, y)
    self:drawItemDescription("Heals " .. amount .. "HP", x, y)
end

function LightShop:drawItemBonusInfo(item, type_name, stat, stat_name, x, y)
    self:drawItemDescription(type_name .. ": " .. item:getStatBonus(stat) .. stat_name, x, y)
end

function LightShop:drawBonuses(old_item, bonuses, stat, stat_name, x, y)
    local stats_display = {}
    table.insert(stats_display, "(")

    local old_stat = 0

    if old_item then
        old_stat = old_item:getStatBonus(stat) or 0
    end

    local amount = (bonuses[stat] or 0) - old_stat
    local amount_string = tostring(amount)

    if amount >= 0 then
        amount_string = "+" .. amount_string
    end

    for i, party_member in ipairs(Game.party) do
        local can_equip = party_member:canEquip(old_item)

        if #Game.party > 1 then
            table.insert(stats_display, { party_member:getColor() })
        end

        if not can_equip then
            amount_string = "XX"
        end
        table.insert(stats_display, amount_string .. " ")

        if #Game.party > 1 then
            table.insert(stats_display, { 1, 1, 1 })
        end
    end

    table.insert(stats_display, stat_name .. ")")

    love.graphics.print(stats_display, x, y)
end

function LightShop:drawItemDisplay()
    Draw.setColor(COLORS.white)

    local current_item = self.items[self.current_selected_item]
    if current_item == nil then
        return
    end

    local box_left, box_top = self.info_box:getBorder()

    local left = self.info_box.x - math.floor(self.info_box.width) - (box_left / 2) * 1.5
    local top = self.info_box.y - math.floor(self.info_box.height) - (box_top / 2) * 1.5
    local width = math.floor(self.info_box.width) + box_left * 1.5
    local height = math.floor(self.info_box.height) - 5

    Draw.pushScissor()
    Draw.scissor(left, top, width, height)

    self:drawItemInfo(top, current_item.item, current_item.options)

    Draw.popScissor()
end

function LightShop:drawBuyConfirm()
    Draw.setColor(Game:getSoulColor())

    Draw.draw(self.heart_sprite, 450, 228 + 80 + 10 + (self.current_selecting_choice * 30), 0, 2)

    Draw.setColor(COLORS.white)
    local lines = StringUtils.split(
        string.format(
            self.buy_confirmation_text,
            string.format(
                self.currency_text,
                not self.free_items and self.items[self.current_selected_item].options["price"] or 0
            )
        ),
        "\n"
    )

    for i = 1, #lines do
        love.graphics.print(lines[i], 460, 420 - 160 + ((i - 1) * 30))
    end

    love.graphics.print(self.buy_confirmation_yes_text, 480, 420 - 80)
    love.graphics.print(self.buy_confirmation_no_text, 480, 420 - 80 + 30)
end

function LightShop:drawSellMenu()
    Draw.setColor(Game:getSoulColor())
    Draw.draw(self.heart_sprite, 50, 228 + (self.current_selecting_storage * 40), 0, 2)

    Draw.setColor(COLORS.white)
    love.graphics.setFont(self.font)

    for i, v in ipairs(self.sell_options) do
        love.graphics.print(v[1], 80, 220 + (i * 40))
    end

    love.graphics.print("Return", 80, 220 + ((#self.sell_options + 1) * 40))
end

function LightShop:drawSellItems()
    local inventory = Game.inventory:getStorage(self.selected_storage)

    if inventory == nil then
        Draw.setColor(COLORS.ltgray)
        love.graphics.print("Invalid storage", 60, 260)
        return
    end

    local page = math.ceil(self.current_selected_selling_item_x / 2) - 1

    -- Draw the soul
    Draw.setColor(Game:getSoulColor())
    Draw.draw(self.heart_sprite, 30 + (self.current_selected_selling_item_x - 1 - (page * 2)) * 280, 228 + ((self.current_selected_selling_item_y) * 40), 0, 2)

    local current_page = 8 * (self.sell_page - 1)

    for i = 1 + current_page, 8 + current_page do
        local item = inventory[i]
        love.graphics.setFont(self.font)

        if item then
            local display_item = "???"

            Draw.setColor(COLORS.white)

            if item:isSellable() then
                display_item = string.format(self.currency_text, item:getSellPrice()) .. " - " .. (Mod.libs["magical-glass"].serious_mode and item:getSeriousName() or item:getShortName())
                if item:getSellPrice() < 10 then
                    display_item = "  " .. display_item
                end
                if item:getSellPrice() < 100 then
                    display_item = "  " .. display_item
                end
            else
                display_item = "  NO! - " .. (Mod.libs["magical-glass"].serious_mode and item:getSeriousName() or item:getShortName())
            end

            i = i - current_page
            love.graphics.print(display_item, 60 + ((i % 2) == 0 and 282 or 0), 240 + ((i - ((i - 1) % 2)) * 20), math.rad(self.selling_item_rotation))
        end
    end

    -- Show the sold text in a reversed grid
    if self.sell_page >= self:getSellMaxPage() then
        for i = 8, 9 - self.sold_items, -1 do
            Draw.setColor(COLORS.gray)
            love.graphics.print(self.sold_text, 60 + ((i % 2) == 0 and 282 or 0), 240 + ((i - ((i - 1) % 2)) * 20))
        end
    end

    Draw.setColor(COLORS.white)

    love.graphics.print("Exit", 60, 420)

    if self:getSellMaxPage() > 1 then
        love.graphics.print("PAGE " .. self.sell_page, 285, 420)
    end
end

function LightShop:drawSellConfirm()
    local inventory = Game.inventory:getStorage(self.selected_storage)

    if inventory == nil then
        return
    end

    -- Draw the soul
    Draw.setColor(Game:getSoulColor())
    Draw.draw(self.heart_sprite, -90 + (self.current_selecting_choice * 220), 360 + 10, 0, 2)

    Draw.setColor(COLORS.white)

    love.graphics.print(
        string.format(
            self.sell_confirmation_text,
            Mod.libs["magical-glass"].serious_mode and inventory[self:getSellMenuIndex()]:getSeriousName() or inventory[self:getSellMenuIndex()]:getShortName(),
                string.format(self.currency_text,
                inventory[self:getSellMenuIndex()]:getSellPrice()
            )
        ), 60 + 50, 300
    )

    love.graphics.print(self.sell_confirmation_yes_text, 60 + 100, 360)
    love.graphics.print(self.sell_confirmation_no_text,  60 + 100 + 220, 360)
end

function LightShop:drawTalkMenu()
    Draw.setColor(Game:getSoulColor())
    Draw.draw(self.heart_sprite, 30, 228 + (self.current_selected_item * 40), 0, 2)
    Draw.setColor(COLORS.white)
    love.graphics.setFont(self.font)
    for i = 1, math.max(4, #self.talks) do
        local v = self.talks[i]
        if v then
            Draw.setColor(v[2].color)
            love.graphics.print(v[1], 60, 220 + (i * 40))
        else
            Draw.setColor(COLORS.dkgray)
            love.graphics.print("--------", 60, 220 + (i * 40))
        end
    end
    Draw.setColor(COLORS.white)
    love.graphics.print("Exit", 60, 220 + ((math.max(4, #self.talks) + 1) * 40))
end

function LightShop:drawMoney(selling)
    if selling then
        Draw.setColor(COLORS.yellow)
        love.graphics.setFont(self.font)
        love.graphics.print(string.format(self.sell_currency_text, self:getMoney()), 400, 420)
    else
        Draw.setColor(COLORS.white)
        love.graphics.setFont(self.font)
        love.graphics.print(string.format(self.currency_text, self:getMoney()), 460, 420)
    end
end

function LightShop:drawStates()
    love.graphics.setFont(self.font)
    if self.state == "MAINMENU" then
        self:drawMainMenu()

        if not self.hide_storage_text then
            self:drawStorageDisplay()
        end
        if not self:shouldHideMainMenuCurrency() then
            self:drawMoney(false)
        end
    elseif self.state == "BUYMENU" then
        self:drawBuyItems(true)
        self:drawItemDisplay()

        if not self.hide_storage_text then
            self:drawStorageDisplay()
        end
        self:drawMoney(false)
    elseif self.state == "BUYCONFIRM" then
        self:drawBuyItems(false)
        self:drawBuyConfirm()
        self:drawItemDisplay()

        if not self.hide_storage_text then
            self:drawStorageDisplay()
        end
        self:drawMoney(false)
    elseif self.state == "SELLMENU" then
        self:drawSellMenu()

        if not self.hide_storage_text then
            self:drawStorageDisplay()
        end
        self:drawMoney(false)
    elseif self.state == "SELLING" then
        self:drawSellItems()
        self:drawMoney(true)
    elseif self.state == "SELLCONFIRM" then
        self:drawSellConfirm()
        self:drawMoney(true)
    elseif self.state == "TALKMENU" then
        self:drawTalkMenu()
        self:drawMoney(false)

        if not self.hide_storage_text then
            self:drawStorageDisplay()
        end
    end
end

function LightShop:drawFade()
    Draw.setColor(0, 0, 0, self.fade_alpha)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
end

function LightShop:draw()
    self:drawBackground()

    super.draw(self)

    if self.draw_divider then
        self:drawDivider()
    end

    self:drawStates()

    self:drawFade()
end

function LightShop:drawDivider()
    Draw.setColor(COLORS.white)
    love.graphics.setLineWidth(8)
    love.graphics.line((self.main_box.width / 2) + 127, self.main_box.y + 50, (self.main_box.width / 2) + 127, self.main_box.height + 50)
end

function LightShop:drawBackground()
    if self:isWorldHidden() then
        -- Draw a black backdrop
        Draw.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    end
end

function LightShop:isWorldHidden()
    return self.hide_world
end

function LightShop:shouldHideMainMenuCurrency()
    return self.hide_main_menu_currency
end

function LightShop:isValidMenuLocation()
    if self:getSellMenuIndex() > #Game.inventory:getStorage(self.selected_storage) then
        return false
    end
    if self.current_selected_selling_item_y > 4 or self.current_selected_selling_item_y < 1 then
        return false
    end
    if self.current_selected_selling_item_x > 2 or self.current_selected_selling_item_x < 1 then
        return false
    end
    return true
end

function LightShop:getSellMaxPage()
    return math.ceil(#Game.inventory:getStorage(self.selected_storage) / 8)
end

function LightShop:getSellMenuIndex()
    local page = math.ceil(self.current_selected_selling_item_x / 2) - 1
    return (2 * (self.current_selected_selling_item_y - 1) + (self.current_selected_selling_item_x + (page * 2))) + (self.sell_page - 1) * 8
end

function LightShop:enterSellMenu(storage)
    if not storage then
        self:setRightText(self.sell_no_storage_text)
    elseif not Game.inventory:getStorage(storage) then
        self:setRightText(self.sell_no_storage_text)
    elseif Game.inventory:getItemCount(storage, false) == 0 then
        self:setRightText(self.sell_no_storage_text)
    else
        self.selected_storage = storage
        self:setState("SELLING")
    end
end

-- Checks that the player meets the conditions to purchase an item, and then purchases it
function LightShop:buyItem(current_item)
    if (not self.free_items and current_item.options["price"] or 0) > self:getMoney() then
        -- Too expensive!
        self:setRightText(self.buy_too_expensive_text)
    else

        -- Add the item to the inventory
        local new_item = Registry.createItem(current_item.item.id)
        new_item:load(current_item.item:save())
        local main_storage_full = Game.inventory:isFull(Game.inventory:getDefaultStorage(new_item)["id"], false)
        if Game.inventory:addItem(new_item) then
            -- Successfully added the item, so...

            -- Decrement the stock
            if current_item.options["stock"] then
                current_item.options["stock"] = current_item.options["stock"] - 1
                self:setFlag(current_item.options["flag"], current_item.options["stock"])
            end

            -- Remove the money
            self:removeMoney(not self.free_items and current_item.options["price"] or 0)

            -- Play the buy sound
            Assets.playSound("buyitem")

            -- Write the side text
            if main_storage_full then
                self:setRightText(self.buy_storage_text)
            else
                self:setRightText(self.buy_text)
            end
        else
            -- Not enough space, oops
            self:setRightText(self.buy_no_space_text)
        end
    end
end

function LightShop:setFlag(name, value)
    Game:setFlag("lightshop#" .. self.id .. ":" .. name, value)
end

function LightShop:getFlag(name, default)
    return Game:getFlag("lightshop#" .. self.id .. ":" .. name, default)
end

function LightShop:sellItem(current_item)
    self:addMoney(current_item:getSellPrice())
    Game.inventory:removeItem(current_item)

    Assets.playSound("buyitem")
end

function LightShop:getMoney()
    return Game.lw_money
end

function LightShop:setMoney(amount)
    Game.lw_money = amount
end

function LightShop:addMoney(amount)
    self:setMoney(self:getMoney() + amount)
end

function LightShop:removeMoney(amount)
    self:setMoney(self:getMoney() - amount)
end

return LightShop