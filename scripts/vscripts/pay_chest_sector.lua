Pay_Chest_Sector = class({})

function Pay_Chest_Sector:OnSpellStart()
    local caster = self:GetCaster()
	local pID = caster:GetPlayerID()
    if caster:GetGold() > 10 then
        caster:ModifyGold(10 * -1, false, 0)
        caster:RemoveAbility("Chest_Sector_Card")
        caster:RemoveAbility("Pay_Chest_Sector")
        caster:AddAbility("Roll"):SetLevel(1)
	    caster:AddAbility("Upgrade"):SetLevel(1)
	    caster:AddAbility("Mortgage"):SetLevel(1)
	    caster:AddAbility("Buy_back"):SetLevel(1)
        Dmono:SetNewTurn()
    end
end