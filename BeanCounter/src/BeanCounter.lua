-- -----------------------------------------------------------------------------
-- BeanCounter.lua
-- -----------------------------------------------------------------------------

local BeanCounter = BeanCounter

function BeanCounter_Initialized(control)
    BeanCounter.display = control

    function control:SetPosition(top, left)
        self:ClearAnchors()
        self:SetAnchor(CENTER, GuiRoot, CENTER, left, top)
    end

    if control.fragment ~= nil then return end

    control.fragment = ZO_SimpleSceneFragment:New(control)

    HUD_UI_SCENE:AddFragment(control.fragment)
    HUD_SCENE:AddFragment(control.fragment)
end

function BeanCounter_ItemAbilitySlot_OnMouseEnter(control)
    ClearTooltip(BeanCounter_StatsTooltip)

    local parent = control:GetParent() or nil
    if parent and parent.abilityId then
        InitializeTooltip(BeanCounter_StatsTooltip, control, BOTTOM, 0, -5, TOP)
        ZO_Tooltips_SetupDynamicTooltipAnchors(BeanCounter_StatsTooltip, control)

        BeanCounter_StatsTooltip:SetAbilityId(parent.abilityId)
    end
end

function BeanCounter_ItemAbilitySlot_OnMouseExit()
    ClearTooltip(BeanCounter_StatsTooltip)
end

function BeanCounter_OnMoveStop(control)
    local centerX, centerY = control:GetCenter()
    local parentCenterX, parentCenterY = control:GetParent():GetCenter()
    local top, left = centerY - parentCenterY, centerX - parentCenterX
    BeanCounter.settings.accountWide.position = {
        top  = top,
        left = left,
    }
end
