-- -----------------------------------------------------------------------------
-- Tracking.lua
-- -----------------------------------------------------------------------------

local BeanCounter                                          = BeanCounter

--- @type integer The currently active hotbar
local g_activeHotbar                                       = HOTBAR_CATEGORY_PRIMARY
--- @type integer, integer Slot indices
local SKILL_BAR_START_SLOT_INDEX, SKILL_BAR_END_SLOT_INDEX = GetAssignableAbilityBarStartAndEndSlots() --[[ @as integer, integer ]]

local M                                                    = {}


--- Increment the bean for the provided ability ID
--- @param beans Beans
--- @param abilityId integer
local function increment(beans, abilityId)
    local currentCount = beans[abilityId] or 0

    beans[abilityId] = currentCount + 1;
end

--- Recalculate the top beans
function M:RecalculateTop5()
    local top5         = {}

    -- Adjust to bean display mode, session or character
    -- local characterBeans = self.settings.character.beans
    local sessionBeans = BeanCounter.settings.character.session.beans

    local abilityIds   = {}
    for key in pairs(sessionBeans) do
        table.insert(abilityIds, key)
    end

    table.sort(abilityIds, function(a, b)
        return sessionBeans[a] > sessionBeans[b]
    end)

    for i = 1, 5, 1 do
        top5[i] = abilityIds[i]
    end

    for rank, ability in ipairs(top5) do
        if BeanCounter_DisplayList then
            local item = BeanCounter_DisplayList:GetNamedChild("Item" .. rank)
            if item then
                item.abilityId = ability
                item:GetNamedChild("AbilitySlotIcon"):SetTexture(GetAbilityIcon(ability))
                item:GetNamedChild("Count"):SetText(self:GetBeanCount(ability))
            end
        end
    end
end

--- Add a bean to the current session counts
--- @param abilityId integer
function M:AddBeanToSession(abilityId)
    local beans = BeanCounter.settings.character.session.beans

    increment(beans, abilityId)
end

--- Add a bean to the current character counts
--- @param abilityId integer
function M:AddBeanToCharacter(abilityId)
    local beans = BeanCounter.settings.character.beans

    increment(beans, abilityId)
end

--- Add a bean to the current counts
--- @param abilityId integer
function M:AddBean(abilityId)
    self:AddBeanToCharacter(abilityId)
    self:AddBeanToSession(abilityId)
end

function M:GetBeanCount(abilityId)
    -- local characterBeans = self.settings.character.beans
    local sessionBeans = BeanCounter.settings.character.session.beans

    return sessionBeans[abilityId] or 0
end

--- Initialize tracking
function M:Init()
    EVENT_MANAGER:RegisterForEvent(BeanCounter.name .. "_SlotAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED,
        function(_, actionSlotIndex)
            -- Skip non-skill bar slots, e.g. light/heavy attacks
            if not (actionSlotIndex >= SKILL_BAR_START_SLOT_INDEX and actionSlotIndex <= SKILL_BAR_END_SLOT_INDEX) then
                return
            end

            if GetSlotType(actionSlotIndex, g_activeHotbar) ~= ACTION_TYPE_NOTHING then
                local abilityId = GetSlotBoundId(actionSlotIndex, GetActiveHotbarCategory()) --[[ @as integer ]]

                if not abilityId then
                    return
                end

                self:AddBean(abilityId)
                self:RecalculateTop5()
            end
        end)

    EVENT_MANAGER:RegisterForEvent(BeanCounter.name .. "_ActiveHotbarUpdated", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED,
        function(_, didActiveHotbarChange, _, activeHotbarCategory)
            if not didActiveHotbarChange then return end

            g_activeHotbar = activeHotbarCategory
        end)

    self:RecalculateTop5()
end

BeanCounter.tracking = M
