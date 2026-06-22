local SchoolDoor, super = Class(Map)

function SchoolDoor:load()
    super.load(self)

    if Game:getPartyMember("ralsei") then
        Game:removePartyMember("ralsei")
    end
end

return SchoolDoor