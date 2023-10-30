
upgrade_modifier = class({})

function upgrade_modifier:IsDebuff() return true end
function upgrade_modifier:IsHidden() return false end
function upgrade_modifier:IsPurgable() return true end
function upgrade_modifier:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function upgrade_modifier:ShouldUseOverheadOffset()
	return true
end

function upgrade_modifier:GetEffectName()
	return "particles/econ/items/warlock/warlock_ti10_head/warlock_ti_10_fatal_bonds_icon_skull.vpcf"
end

function upgrade_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function upgrade_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end

function upgrade_modifier:OnCreated(keys)
	if IsServer() then
	end
end

function upgrade_modifier:OnIntervalThink()
	if IsServer() then
		if not parent:IsAlive() then
			self:Destroy()
		end
	end
end