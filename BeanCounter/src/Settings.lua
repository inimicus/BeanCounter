-- -----------------------------------------------------------------------------
-- Settings.lua
-- -----------------------------------------------------------------------------

local BeanCounter = BeanCounter

--- @type table Settings table
local M = {
    --- @type string Name of saved variables
    savedVariables = "BeanCounterData",
    --- @type integer Version of saved variables
    dbVersion = 1,
}

--- @alias DisplayPosition { top: integer, left: integer }
--- @alias Beans table<integer, integer>
--- @alias AccountWideSettings { position: DisplayPosition, locked: boolean }
--- @alias SessionSettings { beans: Beans, startTime: nil|integer }
--- @alias CharacterSettings { session: SessionSettings, beans: Beans }

--- @type DisplayPosition Default display position
local defaultPosition = {
    top = 0,
    left = 0,
};

--- @type AccountWideSettings Default account-wide settings
local accountWideDefaults = {
    position = defaultPosition,
    locked = false,
}

--- @type SessionSettings Default session settings
local sessionDefaults = {
    beans = {},
    startTime = nil,
}

--- @type CharacterSettings Default character settings
local characterDefaults = {
    beans = {},
    session = sessionDefaults,
}

--- @type table Default settings table
M.defaults = {
    --- @type AccountWideSettings Default account-wide settings
    accountWide = accountWideDefaults,
    --- @type CharacterSettings Default character-specific settings
    character = characterDefaults,
}

--- Apply settings
function M:ApplySettings()
    if not BeanCounter.display then return end

    local top = self.accountWide.position.top
    local left = self.accountWide.position.left
    local locked = self.accountWide.locked

    BeanCounter.display:SetPosition(top, left)
    BeanCounter.display.locked = locked
end

--- Initialize settings
function M:Init()
    self.accountWide = ZO_SavedVars:NewAccountWide(self.savedVariables, self.dbVersion, nil, self.defaults.accountWide)
    self.character = ZO_SavedVars:NewCharacterIdSettings(self.savedVariables, self.dbVersion, nil,
        self.defaults.character)

    self:ApplySettings()
end

BeanCounter.settings = M
