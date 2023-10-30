LinkLuaModifier("mortgage_modifier", "modifiers/mortgage_modifier.lua", LUA_MODIFIER_MOTION_NONE)

Mortgage = class({})

function Mortgage:OnSpellStart()
    local caster = self:GetCaster()
    local pID = caster:GetPlayerID()
    local teamID = PlayerResource:GetTeam(pID)
    local target = self:GetCursorTarget()
    local sectorIndex = 0
    local cost = 0
    local TurnsAmount = 15
    local Rent0 = 25
    local Rent1 = 50
	local Rent2 = 100
	local Rent3 = 200
    if target ~= nil then 
        local targetName = target:GetName()
        local targetNameLength = string.len(targetName)
        if targetNameLength <= 9 then
            sectorIndex = tonumber(string.match(targetName, "%d+"))
        else
            if targetName == "sector_station_1" then
                sectorIndex = 3
            elseif targetName == "sector_utility_1" then
                sectorIndex = 8
            elseif targetName == "sector_station_2" then
                sectorIndex = 11
            elseif targetName == "sector_station_3" then
                sectorIndex = 18
            elseif targetName == "sector_utility_2" then
                sectorIndex = 21
            elseif targetName == "sector_station_4" then
                sectorIndex = 26
            end
        end
        if Dmono:GetMortgageFlagTable(sectorIndex) then 
            return nil
        else
            if Dmono:GetFromSectorStatusBought(sectorIndex) == teamID and Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) == "NoUpgrade" and Dmono:GetFromSectorUpgradePriceTable(sectorIndex) ~= 0 then
                cost = Dmono:GetFromSectorMortgageTable(sectorIndex)
                Dmono:UpdateMortgageTurnTable(sectorIndex, 15)
                Dmono:UpdateMortgageFlagTable(sectorIndex, true)
                target:AddNewModifier(nil, nil, "modifier_winter_wyvern_cold_embrace", { duration = -1 })
                Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetMortgageTurnTable(sectorIndex))
                --print(cost)
                caster:ModifyGold(cost , false, 0)
            elseif Dmono:GetFromSectorStatusBought(sectorIndex) == teamID and Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) ~= "NoUpgrade" then
                if Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) == "Upgrade1" then
                    Dmono:UpdateFromSectorStatusUpgradeTable(sectorIndex, "NoUpgrade")
                    Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetFromSectorBaseRentTable(sectorIndex))
                elseif Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) == "Upgrade2" then
                    Dmono:UpdateFromSectorStatusUpgradeTable(sectorIndex, "Upgrade1")
                    Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetFromUpgrade1RentCost(sectorIndex))
                elseif Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) == "Upgrade3" then
                    Dmono:UpdateFromSectorStatusUpgradeTable(sectorIndex, "Upgrade2")
                    Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetFromUpgrade2RentCost(sectorIndex))
                elseif Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) == "Upgrade4" then
                    Dmono:UpdateFromSectorStatusUpgradeTable(sectorIndex, "Upgrade3")
                    Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetFromUpgrade3RentCost(sectorIndex))
                elseif Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) == "Upgrade5" then
                    Dmono:UpdateFromSectorStatusUpgradeTable(sectorIndex, "Upgrade4")
                    Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetFromUpgrade4RentCost(sectorIndex))
                else
                    return nil
                end

                if Dmono:GetFromSectorStatusUpgradeTable(sectorIndex) ~= "NoUpgrade" then
                    Dmono:UpdateFromSectorUpgradePriceTable(sectorIndex,(Dmono:GetFromSectorUpgradePriceTable(sectorIndex) - Dmono:GetFromBaseUpgrade(sectorIndex)))
                else
                    Dmono:UpdateFromSectorUpgradePriceTable(sectorIndex,(Dmono:GetFromBaseUpgrade(sectorIndex)))
                end
                caster:ModifyGold((Dmono:GetFromSectorUpgradePriceTable(sectorIndex) * 0.5) , false, 0)
    	    	target:RemoveModifierByName("upgrade_modifier")
            elseif Dmono:GetFromSectorStatusBought(sectorIndex) == teamID and Dmono:GetFromSectorUpgradePriceTable(sectorIndex) == 0 then 
                cost = Dmono:GetFromSectorMortgageTable(sectorIndex)
                target:AddNewModifier(nil, nil, "modifier_winter_wyvern_cold_embrace", { duration = -1 })
                Dmono:UpdateMortgageTurnTable(sectorIndex, 15)
                Dmono:UpdateMortgageFlagTable(sectorIndex, true)
                if sectorIndex == 8 or sectorIndex == 21 then
                    Dmono:DecrementUtilityTable(pID)
                else
                    Dmono:DecrementStationTable(pID)
                    if Dmono:GetStationTable(pID) == 1 then

                        CheckSector(teamID, Rent0)
                    elseif Dmono:GetStationTable(pID) == 2 then
                        CheckSector(teamID, Rent1)
                    elseif Dmono:GetStationTable(pID) == 3 then
                        CheckSector(teamID, Rent2)
                    elseif Dmono:GetStationTable(pID) == 4 then 
                        CheckSector(teamID, Rent3)
                    end
                end
                Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetMortgageTurnTable(sectorIndex))
                --print(cost)
                caster:ModifyGold(cost , false, 0)
            else
                return nil
            end
        end
    end
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