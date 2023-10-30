Jail_Roll = class({}) 

function Jail_Roll:OnSpellStart()
	local caster = self:GetCaster()
	local pID = caster:GetPlayerID()
	local rand1 = RandomInt(1, 6)
	local rand2 = RandomInt(1, 6)
    Say(caster,"Dice: " .. rand1 .. " and " .. rand2, false)
    if rand1 == rand2 then
        Say(caster,"Released from jail", false)
        Dmono:SetFakePos(pID, Vector(-1732.92, 1629.54, 128))
        caster:RemoveAbility("Jail_Roll")
	    caster:RemoveAbility("Pay_Jail")
        caster:AddAbility("Roll"):SetLevel(1)
        caster:AddNewModifier(nil, nil, "modifier_muted", {duration = -1})
        Dmono:InsertJail(pID, nil)
    else
        Say(caster,"Unlucky, stay in jail", false)
        Dmono:DecrementJailCount(pID)
        Dmono:SetNewTurn()
    end
end