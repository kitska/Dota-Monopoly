require('utilities')
Roll = class({})   

function Roll:OnSpellStart()
	local caster = self:GetCaster()
	local pID = caster:GetPlayerID()
	local rand1 = RandomInt(1, 6)
	local rand2 = RandomInt(1, 6)
	local teamID = PlayerResource:GetTeam(pID)
	local overallrand = 1--rand1 + rand2
	local casterPos = caster:GetOrigin()
	local fakePos = Dmono:GetFakePos(pID)

	Dmono:SetRandForUtility(rand1, rand2)
	Say(caster, "Dice " .. rand1 .. " and ".. rand2 .. " Overall: ".. overallrand, false)
	for i = 1, 40 do
		
		if casterPos == Vector(-1856, -1421.731445, 128) or casterPos == Vector(-1664, -1408, 128) or casterPos == Vector(-1664, -1719.28, 128) or casterPos == Vector(-1856, -1728, 128) then
			casterPos = caster:GetOrigin()
		elseif casterPos ~= fakePos then
			casterPos = fakePos
		end

		if casterPos == Dmono:GetSectorPos(i) and (overallrand + i) > 40 then
			FindClearSpaceForUnit(caster, Dmono:GetSectorPos(overallrand + i - 40), true)
			Dmono:SetFakePos(pID, Dmono:GetSectorPos(overallrand + i - 40))
			if Dmono:GetSectorPos(overallrand + i - 40) == Dmono:GetSectorPos(1) then
				return
			else
				caster:ModifyGold(200, false, 0)
			end
			return
		end
		
		if casterPos == Dmono:GetSectorPos(i) then
			FindClearSpaceForUnit(caster, Dmono:GetSectorPos(overallrand+i), true)
			Dmono:SetFakePos(pID, Dmono:GetSectorPos(overallrand+i))
			return
		elseif casterPos == Vector(-1856, -1421.731445, 128) or casterPos == Vector(-1664, -1408, 128) or casterPos == Vector(-1664, -1719.28, 128) or casterPos == Vector(-1856, -1728, 128) then
			FindClearSpaceForUnit(caster, Dmono:GetSectorPos(overallrand+1), true)
			Dmono:SetFakePos(pID, Dmono:GetSectorPos(overallrand+1))
			return
		end
	end
end

