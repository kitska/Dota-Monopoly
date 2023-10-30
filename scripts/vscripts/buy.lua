require('utilities')
require('libraries/timers')
Buy = class({})

function Buy:OnSpellStart()
	local caster = self:GetCaster()
	local pID = caster:GetPlayerID()
	local index = 0
	local playerName = PlayerResource:GetPlayerName(pID)
	local pos = caster:GetOrigin()
	local cost = 0
	local fakePos = Dmono:GetFakePos(pID)
	local sectorsbought = Dmono:GetBoughtSectors()

	if pos == Vector(-1856, -1421.731445, 128) or pos == Vector(-1664, -1408, 128) or pos == Vector(-1664, -1719.28, 128) or pos == Vector(-1856, -1728, 128) then
		pos = caster:GetOrigin()
	elseif pos ~= fakePos then
		pos = fakePos
	end

	index = Dmono:GetPosForSector(pos)

	cost = Dmono:GetFromPriceSectorIndex(index)

	local sectors = Entities:FindByName(nil, ("sector_trigger_"..index))
	local visible_sectors = Entities:FindByName(nil, ("sec_"..index.."_visible"))
	local teamID = PlayerResource:GetTeam(pID)
	if caster:GetGold() < cost then
		Say(caster, "Can't afford to buy this sector #" .. index .. ". Sector costs " .. cost .. ". " .. "You have " .. caster:GetGold() .. " gold " , false)
		caster:RemoveAbility("Buy")
		caster:RemoveAbility("None")
		caster:AddAbility("Roll"):SetLevel(1)
		caster:AddAbility("Upgrade"):SetLevel(1)
		caster:AddAbility("Mortgage"):SetLevel(1)
		caster:AddAbility("Buy_back"):SetLevel(1)
		Dmono:SetNewTurn()
		return nil
	else

		if index == 3 then
			Dmono:IncrementStationTable(pID)
		elseif index == 8 then
			Dmono:IncrementUtilityTable(pID)
		elseif index == 11 then
			Dmono:IncrementStationTable(pID)
		elseif index == 18 then
			Dmono:IncrementStationTable(pID)
		elseif index == 21 then
			Dmono:IncrementUtilityTable(pID)
		elseif index == 26 then
			Dmono:IncrementStationTable(pID)
		end
		
		-- print(index.. " index")
		-- print(Dmono:GetFromSectorRentTable(index).. " rent")
		-- print(Dmono:GetStationTable(pID).. " count")

		local Rent1 = 50
		local Rent2 = 100
		local Rent3 = 200

		if Dmono:GetStationTable(pID) == 2 then
			Dmono:UpdateFromSectorRentTable(index, Rent1)
			CheckSector(teamID, Rent1)
		elseif Dmono:GetStationTable(pID) == 3 then
			Dmono:UpdateFromSectorRentTable(index, Rent2)
			CheckSector(teamID, Rent2)
		elseif Dmono:GetStationTable(pID) == 4 then 
			Dmono:UpdateFromSectorRentTable(index, Rent3)
			CheckSector(teamID, Rent3)
		end

		caster:ModifyGold(cost * -1, false, 0)
		Dmono:UpdateFromSectorStatusBought(index, teamID)
	end
	if teamID == 2 then
		visible_sectors:SetRenderColor(61, 210, 150)
	elseif teamID == 3 then
		visible_sectors:SetRenderColor(243, 201, 9)
	elseif teamID == 6 then
		visible_sectors:SetRenderColor(197, 77, 168)
	elseif teamID == 7 then
		visible_sectors:SetRenderColor(255, 108, 0)
	end

	Say(caster, "Bought sector #" .. index .. " for ".. cost .. " gold", false)
	caster:RemoveAbility("Buy")
	caster:RemoveAbility("None")
	caster:AddAbility("Roll"):SetLevel(1)
	caster:AddAbility("Upgrade"):SetLevel(1)
	caster:AddAbility("Mortgage"):SetLevel(1)
	caster:AddAbility("Buy_back"):SetLevel(1)
	Dmono:SetNewTurn()
end

function CheckSector(teamID, rent)
	for i = 1, 28 do
		if i == 3 and Dmono:GetFromSectorStatusBought(i) == teamID then
			Dmono:UpdateFromSectorRentTable(i, rent)
		elseif i == 11 and Dmono:GetFromSectorStatusBought(i) == teamID then
			Dmono:UpdateFromSectorRentTable(i, rent)
		elseif i == 18 and Dmono:GetFromSectorStatusBought(i) == teamID then
			Dmono:UpdateFromSectorRentTable(i, rent)
		elseif i == 26 and Dmono:GetFromSectorStatusBought(i) == teamID then
			Dmono:UpdateFromSectorRentTable(i, rent)
		end
	end
end