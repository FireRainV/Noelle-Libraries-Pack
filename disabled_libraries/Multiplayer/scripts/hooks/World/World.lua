local World, super = HookSystem.hookScript(World)

function World:init(map)
    super.init(self, map)

    self.other_players = {}
    self.other_souls = {}
end

function World:onKeyPressed(key)
    super.onKeyPressed(self, key)

    -- Each player can interact on their own
    if self.state == "GAMEPLAY" then
        for _, player in ipairs(self.other_players) do
            if Input.is("p" .. player.index + 1 .. "_confirm", key) and not self:hasCutscene() then
                if player:interact() then
                    Input.clear("confirm")
                end
            end
        end
    end
end

-- Spawn the party and the players
-- Each player will be assigned to the party member in order
-- If there're more party members than players, then the rest of the party will follow Player 1
function World:spawnParty(marker, party, extra, facing)
    party = party or Game.party or { "kris" }
    for _, player in pairs(self.other_players) do
        self:removeChild(player)
    end
    self.other_players = {}

    if #party > 0 then
        for i, chara in ipairs(party) do
            if type(chara) == "string" then
                party[i] = Game:getPartyMember(chara)
            end
        end

        if type(marker) == "table" then
            self:spawnPlayer(marker[1], marker[2], party[1]:getActor(), party[1].id)
            for i = 2, Mod.libs["multiplayer"].max_players do
                if party[i] then
                    self:spawnOtherPlayer(i - 1, marker[1], marker[2], party[i]:getActor(), party[i].id)
                end
            end
        else
            self:spawnPlayer(marker or "spawn", party[1]:getActor(), party[1].id)
            for i = 2, math.min(Mod.libs["multiplayer"].max_players, #party) do
                self:spawnOtherPlayer(i - 1, marker or "spawn", party[i]:getActor(), party[i].id)
            end
        end

        if facing then
            self.player:setFacing(facing)
            for _, player in ipairs(self.other_players) do
                player:setFacing(facing)
            end
        end

        for i = 2 + #self.other_players, #party do
            local follower = self:spawnFollower(party[i]:getActor(), { party = party[i].id })
            follower:setFacing(facing or self.player.facing)
        end

        for _, actor in ipairs(extra or Game.temp_followers or {}) do
            if type(actor) == "table" then
                local follower = self:spawnFollower(actor[1], { index = actor[2] })
                follower:setFacing(facing or self.player.facing)
            else
                local follower = self:spawnFollower(actor)
                follower:setFacing(facing or self.player.facing)
            end
        end
        self:spawnSoul()
    end
end

-- Spawn the other players' character
function World:spawnOtherPlayer(player, ...)
    local args = { ... }

    local x, y = 0, 0
    local chara = self.other_players[player] and self.other_players[player].actor
    local party

    if #args > 0 then
        if type(args[1]) == "number" then
            x, y = args[1], args[2]
            chara = args[3] or chara
            party = args[4]
        elseif type(args[1]) == "string" then
            x, y = self.map:getMarker(args[1])
            chara = args[2] or chara
            party = args[3]
        end
    end

    if type(chara) == "string" then
        chara = Registry.createActor(chara)
    end

    local facing = "down"

    if Game.world.player then
        facing = Game.world.player.facing
    end

    if Mod.libs["magical-glass"] and Game.party[player + 1]:getUndertaleMovement() then
        self.other_players[player] = OtherUnderPlayer(chara, x, y, player)
    else
        self.other_players[player] = OtherPlayer(chara, x, y, player)
    end
    self.other_players[player].layer = self.map.object_layer
    self.other_players[player]:setFacing(facing)
    self:addChild(self.other_players[player])

    if party then
        self.other_players[player].party = party
    end
end

-- Spawn an overworld soul for each player and color it depending on the player's party member main color
-- If the player's party member has a soul priority below 2, turn it into a monster soul (by rotating it upside-down)
function World:spawnSoul(x, y)
    super.spawnSoul(self, x, y)

    if Game.party[1] then
        self.soul:setColor(Game.party[1]:getColor())
        if Game.party[1].soul_priority < 2 then
            self.soul.rotation = math.pi
        end
    end

    for _, soul in pairs(self.other_souls) do
        self:removeChild(soul)
    end
    self.other_souls = {}

    for player = 1, #self.other_players do
        self.other_souls[player] = OverworldSoul(x, y)
        self.other_souls[player].index = player
        self.other_souls[player]:setColor(Game:getSoulColor())
        if Game.party[player + 1] then
            self.other_souls[player]:setColor(Game.party[player + 1]:getColor())
            if Game.party[player + 1].soul_priority < 2 then
                self.other_souls[player].rotation = math.pi
            end
        end
        self:addChild(self.other_souls[player])
    end
end

-- The function will now also get the other players' character
function World:getPartyCharacterInParty(party)
    if type(party) == "string" then
        party = Game:getPartyMember(party)
    end

    if self.player and Game:hasPartyMember(self.player:getPartyMember()) and party == self.player:getPartyMember() then
        return self.player
    else
        for _, player in ipairs(self.other_players) do
            if Game:hasPartyMember(player:getPartyMember()) and party == player:getPartyMember() then
                return player
            end
        end

        for _, follower in ipairs(self.followers) do
            if Game:hasPartyMember(follower:getPartyMember()) and party == follower:getPartyMember() then
                return follower
            end
        end
    end
end

-- Get all players' character (including Player 1's character)
function World:getPlayers()
    local characters = TableUtils.copy(self.other_players)
    if self.player then
        table.insert(characters, 1, self.player)
    end
    return characters
end

-- Check if any player has enter a battle area to apply the visual effects for all players
function World:inBattle()
    for _, player in ipairs(self:getPlayers()) do
        for _, area in ipairs(self.map.battle_areas) do
            if area:collidesWith(player.collider) then
                if not self.in_battle_area then
                    self.in_battle_area = true
                end
                break
            end
        end
        if self.in_battle_area then
            break
        end
    end

    return super.inBattle(self)
end

return World