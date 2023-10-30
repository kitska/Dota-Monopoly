pay_modifier = class({})

function pay_modifier:OnCreated()
  if not IsServer() then return end

  self.caster = self:GetCaster()
  self.ability = self:GetAbility()
  self.parent = self:GetParent()
  
  self.chance = self.ability:GetSpecialValueFor("chance")
  self.gold = self.ability:GetSpecialValueFor("gold")
  self.damage = self.ability:GetSpecialValueFor("damage")
  
end

function pay_modifier:OnRefresh()
  if not IsServer() then return end
  
  self.chance = self.ability:GetSpecialValueFor("chance")
  self.gold = self.ability:GetSpecialValueFor("gold")
  self.damage = self.ability:GetSpecialValueFor("damage")
end

function pay_modifier:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED
  }
  return funcs
end

function pay_modifier:OnAttackLanded(params)
  if not IsServer() then return end

  local caster = params.attacker
  local target = params.target
  local pID = target:GetPlayerID()
  local ability = self:GetAbility()
  local cost = 0
  local pos = target:GetAbsOrigin()
  local fakePos = Dmono:GetFakePos(pID)

  if pos == Vector(-1856, -1421.731445, 186) or pos == Vector(-1664, -1408, 186) or pos == Vector(-1664, -1719.28, 186) or pos == Vector(-1856, -1728, 186) then
		pos = target:GetAbsOrigin()
	elseif pos ~= fakePos then
		pos = fakePos
		print(pos)
	end

  if pos == Dmono:GetSectorPos(5) then
		cost = 200
	elseif pos == Dmono:GetSectorPos(39) then
		cost = 100
	end

  local digitsCount = string.len(tostring(cost))

  if caster == self:GetCaster() then
    target:ModifyGold(cost * -1, false, 0)
    self.particle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_ti9_immortal/bh_ti9_immortal_jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    self:AddParticle(self.particle, false, false, -1, false, false)
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    local particleGold = ParticleManager:CreateParticle("particles/msg_fx/msg_goldbounty.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
		ParticleManager:SetParticleControl(particleGold, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particleGold, 1, Vector(0, cost, 0))
		ParticleManager:SetParticleControl(particleGold, 2, Vector(2.0, digitsCount, 0))
		ParticleManager:SetParticleControl(particleGold, 3, Vector(255, 200, 33))
    ParticleManager:DestroyParticle(particleGold, false)
		ParticleManager:ReleaseParticleIndex(particleGold)
  end
end

function pay_modifier:OnDestroy()
  if not IsServer() then return end
end

function pay_modifier:IsPurgeException()
  return false
end

function pay_modifier:IsPurgable()
  return false
end

function pay_modifier:IsHidden()
  return true
end