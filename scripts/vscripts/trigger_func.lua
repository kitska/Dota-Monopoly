require('libraries/timers')
function angleChangeForFirst( event )
	player = event.activator
	player:SetAngles(0,90,0)
end

function angleChangeForSecond( event )
	player = event.activator
	player:SetAngles(0,0,0)
end

function angleChangeForThird( event )
	player = event.activator
	player:SetAngles(0,270,0)
end

function angleChangeForFours( event )
	player = event.activator
	player:SetAngles(0,180,0)
end

function angleChangeForJail( event )
	player = event.activator
	player:SetAngles(0,330,0)
end

function startTrigger( event )
	player = event.activator
	player:ModifyGold(200, false, 0)
	Dmono:SetNewTurn()
end

function changeAbility( event )
	player = event.activator
	local pID = player:GetPlayerID()
	local pos = player:GetOrigin()
	local fakePos = Dmono:GetFakePos(pID)
	local cost = 0
	local index = 0

	if pos == Vector(-1856, -1421.731445, 128) or pos == Vector(-1664, -1408, 128) or pos == Vector(-1664, -1719.28, 128) or pos == Vector(-1856, -1728, 128) then
		pos = caster:GetOrigin()
	elseif pos ~= fakePos then
		pos = fakePos
		print(pos)
	end

	index = Dmono:GetPosForSector(pos)
	cost = Dmono:GetFromSectorRentTable(index)

	local pID = player:GetPlayerID()
	local teamID = PlayerResource:GetTeam(pID)
	local checkSector = Dmono:GetFromSectorStatusBought(index)
	local ownerPID = Dmono:GetPlayerIDInTeam(teamID)

	print(cost.." rent")
	if checkSector == teamID then
		print("on own sector")
		Dmono:SetNewTurn()
		return
	elseif checkSector == 0 then
		player:RemoveAbility("Roll")
		player:RemoveAbility("Upgrade")
		player:RemoveAbility("Mortgage")
		player:RemoveAbility("Buy_back")
		player:AddAbility("None"):SetLevel(1)
		player:AddAbility("Buy"):SetLevel(1)
	elseif checkSector ~= teamID then
		if index ~= 8 or index ~= 21 then
			if not Dmono:GetMortgageFlagTable(index) then
				Say(player, "You got into property. You paid ".. cost .." to the owner", false)
				GameRules:GetGameModeEntity():SetThink(function()
					return Dmono:SendMoneyToOwner(player, checkSector, cost)
				end, "SendMoneyToOwner", 0.03)
			end
		else
			local rand1 = Dmono:GetRand1ForUtility()
			local rand2 = Dmono:GetRand1ForUtility()
			if not Dmono:GetMortgageFlagTable(index) then
				local multiplyer = 0
				if Dmono:GetUtilityTable(ownerPID) == 1 then
					multiplyer = 4
				elseif Dmono:GetUtilityTable(ownerPID) == 2 then
					multiplyer = 10
				end
				cost = (rand1 + rand2) * multiplyer
				Say(player, "You got into property. You paid ".. cost .." to the owner", false)
				GameRules:GetGameModeEntity():SetThink(function()
					return Dmono:SendMoneyToOwner(player, checkSector, cost)
				end, "SendMoneyToOwner", 0.03)
			end
		end
	end
end

function OnFirstSpawn( event )
	player = event.activator
	local pID = player:GetPlayerID()
	player:SetAbilityPoints(0)
	Dmono:SetStationTable(pID, 0)
	Dmono:SetUtilityTable(pID, 0)
	player:RemoveAbility("None")
	player:RemoveAbility("Roll")
	player:RemoveAbility("Buy")
	player:RemoveAbility("Mortgage")
	player:RemoveAbility("Buy_back")
	player:RemoveAbility("Upgrade")
	player:AddAbility("Roll"):SetLevel(1)
	player:AddAbility("Upgrade"):SetLevel(1)
	player:AddAbility("Mortgage"):SetLevel(1)
	player:AddAbility("Buy_back"):SetLevel(1)
end

function OnPayTaxSector(event)
    local player = event.activator
    local pID = player:GetPlayerID()
    local index = 0
    local pos = player:GetOrigin()
    local fakePos = Dmono:GetFakePos(pID)
    local cost

    if pos == Vector(-1856, -1421.731445, 128) or pos == Vector(-1664, -1408, 128) or pos == Vector(-1664, -1719.28, 128) or pos == Vector(-1856, -1728, 128) then
        pos = caster:GetOrigin()
    elseif pos ~= fakePos then
        pos = fakePos
        print(pos)
    end

    if pos == Dmono:GetSectorPos(5) then
        index = 1
        cost = 200
    elseif pos == Dmono:GetSectorPos(39) then
        index = 4
        cost = 100
    end
	local roll = player:FindAbilityByName("Roll")
    if player:GetGold() < cost then
        Say(player, "You don`t have enough gold", false)
        roll:SetHidden(true)
    end

    local paytaxer = Entities:FindByName(nil, ("pay_tax_entity_" .. index))
    if paytaxer then
        local goldCheckTimer = Timers:CreateTimer("wait_for_gold_timer", {
            endTime = 0.1,
            callback = function()
                if player:GetGold() >= cost then
                    paytaxer:FindAbilityByName("pay_tax"):SetActivated(true)
                    paytaxer:MoveToTargetToAttack(player)
                    Timers:CreateTimer("paytax_timer", {
                        endTime = 1,
                        callback = function()
                            paytaxer:Stop()
                            paytaxer:FindAbilityByName("pay_tax"):SetActivated(false)
                        end
                    })
					Dmono:UpdateDeficitMoneyPlayer(pID, false)
					roll:SetHidden(false)
                    Dmono:SetNewTurn()
                    return nil -- Остановить циклический таймер
                else
					Dmono:UpdateDeficitMoneyPlayer(pID, true)
                    return 0.1 -- Повторить проверку через 0.1 секунды
                end
            end
        })
    end
end

function OnChestSector( event )
	player = event.activator
	local randForChest = RandomInt(1, 16) 
	Dmono:GetFromChestTable(randForChest, player)
	if Dmono:GetChestFlag() then
		Dmono:SetChestFlag(false)
		return
	else
		Dmono:SetNewTurn()
	end
end

function OnChanceSector( event )
	player = event.activator
	local randForChance = RandomInt(1, 16)
	Dmono:GetFromChanceTable(randForChance, player)
	if Dmono:GetChanceFlag() then
		Dmono:SetChanceFlag(false)
		return
	else
		Dmono:SetNewTurn()
	end
end

function OnVisitJailSector( event )
	player = event.activator
	Dmono:SetNewTurn()
end

function JailTrigger( event )
	player = event.activator
	playerID = player:GetPlayerID()
	Dmono:InsertJail(playerID, 3)
	local JailCoords = Dmono:GetJailCoords()
	FindClearSpaceForUnit(player, JailCoords, true)
	Dmono:SetNewTurn()
end

function InJailTrigger( event )
	player = event.activator
	player:RemoveModifierByName("modifier_muted")
	player:RemoveAbility("Roll")
	player:RemoveAbility("Upgrade")
	player:RemoveAbility("Mortgage")
	player:RemoveAbility("Buy_back")
	player:AddAbility("Jail_Roll"):SetLevel(1)
	player:AddAbility("Pay_Jail"):SetLevel(1)
end

function SkipTurnTrigger( event )
	player = event.activator
	local pID = player:GetPlayerID()
	Dmono:SkipTurn(pID)
	local modifier = player:AddNewModifier(nil, nil, "modifier_winter_wyvern_cold_embrace", {duration = -1})
	Dmono:SetNewTurn()
end