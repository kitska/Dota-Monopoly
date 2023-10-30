mortgage_modifier = class({})

function mortgage_modifier:OnCreated()
    if not IsServer() then return end
  
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    
    self.chance = self.ability:GetSpecialValueFor("chance")
    self.gold = self.ability:GetSpecialValueFor("gold")
    self.damage = self.ability:GetSpecialValueFor("damage")
end