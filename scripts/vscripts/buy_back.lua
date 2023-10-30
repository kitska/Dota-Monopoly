Buy_back = class({})

function Buy_back:OnSpellStart()
    local caster = self:GetCaster()
    local pID = caster:GetPlayerID()
    local teamID = PlayerResource:GetTeam(pID)
    local target = self:GetCursorTarget()
    local sectorIndex = 0
    local cost
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
        if Dmono:GetFromSectorStatusBought(sectorIndex) == teamID and Dmono:GetMortgageFlagTable(sectorIndex) then
            if target:FindModifierByName("modifier_winter_wyvern_cold_embrace") ~= nil then
                cost = Dmono:GetFromSectorMortgageTable(sectorIndex) * 1.1
				target:RemoveModifierByName("modifier_winter_wyvern_cold_embrace")
                Dmono:UpdateFromSectorRentTable(sectorIndex, Dmono:GetFromSectorBaseRentTable(sectorIndex))
				Dmono:UpdateFromSectorStatusBought(sectorIndex, teamID)
                Dmono:UpdateMortgageFlagTable(sectorIndex, false)
				Dmono:UpdateMortgageTurnTable(sectorIndex, 0)
                if caster:GetGold() > cost then
                    caster:ModifyGold(cost * -1, false, 0)
                else
                    return nil
                end
			end
        else
            return nil
        end
    end
end