Pay_tax = class({})

LinkLuaModifier("pay_modifier", "modifiers/pay_modifier.lua", LUA_MODIFIER_MOTION_NONE)

function Pay_tax:GetIntrinsicModifierName()
  return "pay_modifier"
end

