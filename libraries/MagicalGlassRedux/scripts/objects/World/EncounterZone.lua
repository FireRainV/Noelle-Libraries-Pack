local EncounterZone, super = Class(Event)

function EncounterZone:init(data)
    super.init(self, data)

    self.debug_select = false

    self.random_encounter = Mod.libs["magical-glass"]:createRandomEncounter(data.properties["randomencounter"])

    if Mod.libs["magical-glass"].steps_until_encounter == nil or Mod.libs["magical-glass"].steps_until_encounter and Mod.libs["magical-glass"].steps_until_encounter < 0 then
        self.random_encounter:resetSteps(true)
    end

    if TableUtils.contains({ "rectangle", "circle", "ellipse", "polygon", "polyline" }, data.shape) then
        self.type = "zone"
        self.collider = TiledUtils.colliderFromShape(self, data)
    else
        self.type = "map"
    end

    self.accepting = false
    Mod.libs["magical-glass"].in_encounter_zone = false
end

function EncounterZone:update()
    super.update(self)

    self.accepting = false

    -- Check if the player is currently in an encounter zone
    if Game.world.player and Game.state == "OVERWORLD" then
        for _, player in ipairs(Game.stage:getObjects(Player)) do
            if self.collider:collidesWith(player) or self.type == "map" then
                self.accepting = true
                break
            end
        end
    end
    Mod.libs["magical-glass"].in_encounter_zone = self.accepting

    -- Start the random encounter and reset the movement steps value
    if Mod.libs["magical-glass"].steps_until_encounter and Mod.libs["magical-glass"].steps_until_encounter <= 0 and self.accepting then
        self.random_encounter:resetSteps(false)
        self.random_encounter:start()
    end
end

function EncounterZone:onAddToStage(parent)
    if Mod then
        Mod.libs["magical-glass"].encounters_enabled = true
    end

    super.onAdd(self, parent)
end

function EncounterZone:onRemoveFromStage(stage)
    if Mod then
        Mod.libs["magical-glass"].encounters_enabled = false
    end

    super.onRemove(self, stage)
end

-- Print debug info at the top-left of the screen when inside an encounter zone
function EncounterZone:draw()
    super.draw(self)

    if DEBUG_RENDER and self.collider and self.accepting then
        love.graphics.push()
        love.graphics.origin()

        love.graphics.setFont(Assets.getFont("main"))
        love.graphics.print({ { 1, 0, 0 }, "Encounter Zone!", { 1, 1, 0 }, "\nSteps Until Encounter: ", { 1, 1, 1 }, not Mod.libs["magical-glass"].initiating_random_encounter and (Mod.libs["magical-glass"].steps_until_encounter or "N\\A") or 0 }, 8, 0, 0, 1.25)

        love.graphics.pop()
    end
end

function EncounterZone:getDebugInfo()
    local info = super.getDebugInfo(self)
    table.insert(info, "Active: " .. (self.accepting and "True" or "False"))

    return info
end

return EncounterZone