local preview = {}

function preview:init(mod, button)
    self.mod = mod

    self.hide_background = true

    button:setColor(1, 1, 0)
    button:setFavoritedColor(0, 1, 0)

    if not mod.PREVIEW_STAGE then
        mod.PREVIEW_STAGE = Stage()
    end
end

function preview:update()
    self.mod.PREVIEW_STAGE:update()

    if (MainMenu.state == "MODSELECT" or TARGET_MOD) and MainMenu.mod_list:getSelectedMod() and MainMenu.mod_list:getSelectedMod().id == self.mod.id then
        if not self.mod.PREVIEW_VIDEO then
            Assets.data.videos[self.mod.id .. "/preview"] = self.mod.path .. "/preview.ogv"
            self.mod.PREVIEW_VIDEO = Video(self.mod.id .. "/preview", true, 0, 0, 640, 480)
            self.mod.PREVIEW_VIDEO.parallax_x, self.mod.PREVIEW_VIDEO.parallax_y = 0, 0
            self.mod.PREVIEW_VIDEO:setLooping(true)
            self.mod.PREVIEW_VIDEO:play()
            self.mod.PREVIEW_STAGE:addChild(self.mod.PREVIEW_VIDEO)
        end
    elseif self.mod.PREVIEW_VIDEO and (MainMenu.state == "TITLE" or not MainMenu.mod_list:getSelectedMod() or MainMenu.mod_list:getSelectedMod().id ~= self.mod.id) then
        self.mod.PREVIEW_VIDEO:remove()
        self.mod.PREVIEW_VIDEO = nil
        Assets.data.videos[self.mod.id .. "/preview"] = nil
    end
end

function preview:draw()
    self.mod.PREVIEW_STAGE:draw()
end

return preview