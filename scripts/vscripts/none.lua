require('libraries/timers')
None = class({}) 

function None:OnSpellStart()
	local caster = self:GetCaster()
	local pID = caster:GetPlayerID()
	caster:RemoveAbility("Buy")
	caster:RemoveAbility("None")
	caster:AddAbility("Roll"):SetLevel(1)
	caster:AddAbility("Upgrade"):SetLevel(1)
	caster:AddAbility("Mortgage"):SetLevel(1)
	caster:AddAbility("Buy_back"):SetLevel(1)
	Dmono:SetNewTurn()
end