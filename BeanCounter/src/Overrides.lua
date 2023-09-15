-- -----------------------------------------------------------------------------
-- Overrides.lua
-- -----------------------------------------------------------------------------

-- HACK: These are volatile and subject to breakage
--       with API changes or other addons attempting
--       similar overrides!

local BeanCounter = BeanCounter

local M = {}

--- Reimplement esoui/ingame/actionbar/abilityslot.lua TryShowActionMenu()
--- @param abilitySlot integer Ability slot to show the action menu for
--- @return boolean|nil
local function tryShowActionMenu(abilitySlot)
    if abilitySlot.hotbarCategory ~= HOTBAR_CATEGORY_COMPANION then
        local button = ZO_ActionBar_GetButton(abilitySlot.slotNum, abilitySlot.hotbarCategory)
        if button then
            local slotNum = button:GetSlot()
            if IsSlotUsed(slotNum, abilitySlot.hotbarCategory) and not IsActionSlotRestricted(slotNum, abilitySlot.hotbarCategory) then
                ClearMenu()
                AddMenuItem(GetString(SI_ABILITY_ACTION_CLEAR_SLOT), function()
                    ClearAbilitySlot(slotNum, abilitySlot.hotbarCategory)
                end)
                AddMenuItem("Add to Bean Counter", function()
                    d(zo_strformat(
                        "Added to Bean Counter - abilityId: <<1>>",
                        GetSlotBoundId(slotNum, abilitySlot.hotbarCategory)
                    ))
                end)
                ShowMenu(abilitySlot)

                return true
            end
        end
    end
end

function M:Init()
    -- Backup existing RunClickHandlers
    local Original_RunClickHandlers = RunClickHandlers

    --- Redefine RunClickHandlers to intercept and modify right clicks on slots
    --- in the ability bar.
    ---
    --- This method is used in 4 functions:
    --- * ZO_AbilitySlot_OnSlotClicked
    --- * ZO_AbilitySlot_OnSlotDoubleClicked
    --- * ZO_AbilitySlot_OnSlotMouseUp
    --- * ZO_AbilitySlot_OnSlotMouseDown
    ---
    --- Only in ZO_AbilitySlot_OnSlotClicked does `handlerTable` contain:
    --- handlerTable[ABILITY_SLOT_TYPE_ACTIONBAR][MOUSE_BUTTON_INDEX_RIGHT]
    ---
    --- We can leverage this fact to override action bar right clicks
    --- and reimplement our own right click menu.
    ---
    --- NOTE: This will conflict with any addon that also attempts to modify the ability bar right click menu
    function RunClickHandlers(handlerTable, slot, buttonId, ...)
        if handlerTable and handlerTable[ABILITY_SLOT_TYPE_ACTIONBAR] and handlerTable[ABILITY_SLOT_TYPE_ACTIONBAR][MOUSE_BUTTON_INDEX_RIGHT] then
            handlerTable[ABILITY_SLOT_TYPE_ACTIONBAR][MOUSE_BUTTON_INDEX_RIGHT] = { tryShowActionMenu }
        end
        Original_RunClickHandlers(handlerTable, slot, buttonId, ...)
    end

    --- OVERRIDE: Redefine ZO method to add menu item
    --- @diagnostic disable-next-line:duplicate-set-field
    function ZO_KeyboardAssignableActionBarButton:ShowActionMenu()
        if not self.hotbar:AreHotbarEditsEnabled() then
            return
        end

        local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
        local slotData = hotbarData:GetSlotData(self.slotId)

        if slotData and not slotData:IsEmpty() and not IsActionSlotRestricted(self.slotId, hotbarData:GetHotbarCategory()) then
            ClearMenu()
            AddMenuItem(GetString(SI_ABILITY_ACTION_CLEAR_SLOT), function()
                if hotbarData:ClearSlot(self.slotId) then
                    PlaySound(SOUNDS.ABILITY_SLOT_CLEARED)
                end
            end)
            AddMenuItem("Add to Bean Counter", function()
                d(zo_strformat(
                    "Added to Bean Counter - abilityId: <<1>>",
                    GetSlotBoundId(self.slotId, hotbarData:GetHotbarCategory())
                ))
            end)
            ShowMenu(self.button)
        end
    end

end

BeanCounter.overrides = M
