-- -----------------------------------------------------------------------------
-- Main.lua
-- -----------------------------------------------------------------------------

--- @alias Control any # Give the GuiXml control a "proper" type

--- @type table Main addon table
BeanCounter = {
    --- @type string Addon name
    name = "BeanCounter",
    --- @type Control Display control element
    display = nil,
}

--- Unregister the addon
--- @see EVENT_ADD_ON_LOADED
local function unregister()
    EVENT_MANAGER:UnregisterForEvent(BeanCounter.name, EVENT_ADD_ON_LOADED)
end

function BeanCounter:Init()
    self.settings:Init()
    self.overrides:Init()
    self.tracking:Init()
end

--- Initialize the addon
--- @param addonName string Name of the addon loaded
--- @return nil
local function init(_, addonName)
    -- Skip addons that aren't this one
    if addonName ~= BeanCounter.name then return end

    -- Ready to go
    unregister()
    BeanCounter:Init()
end

-- Make the magic happen
EVENT_MANAGER:RegisterForEvent(BeanCounter.name, EVENT_ADD_ON_LOADED, init)
