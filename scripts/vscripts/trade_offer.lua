Trade_Offer = class({})

function Trade_Offer:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target ~= nil then
        CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "show_trade_window", {targetID = target:GetPlayerID()})
    end
end