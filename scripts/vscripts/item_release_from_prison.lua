item_release_from_prison = class({})

function item_release_from_prison:OnSpellStart()
    local caster = self:GetCaster()
    local pID = caster:GetPlayerID()
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
    local item = caster:FindItemInInventory("item_release_from_prison")
    caster:RemoveItem(item)
    caster:AddNewModifier(nil, nil, "modifier_muted", {duration = -1})
end