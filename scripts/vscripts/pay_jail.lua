Pay_Jail = class({}) 

function Pay_Jail:OnSpellStart()
    local caster = self:GetCaster()
	local pID = caster:GetPlayerID()
    local cost = 50
    if caster:GetGold() < 50 then
        Say(caster, "Dont have enough money",false)
    else
        caster:ModifyGold(cost * -1, false, 0)
        Say(caster,"Released from jail", false)
        Dmono:SetFakePos(pID, Vector(-1732.92, 1629.54, 128))
        if caster:HasAbility("Jail_Roll") then
            caster:RemoveAbility("Jail_Roll")
            caster:RemoveAbility("Pay_Jail")
            caster:AddAbility("Roll"):SetLevel(1)
        else
	        caster:RemoveAbility("Pay_Jail")
            caster:AddAbility("Roll"):SetLevel(1)
        end
        Dmono:InsertJail(pID, nil)
    end
    caster:AddNewModifier(nil, nil, "modifier_muted", {duration = -1})
end