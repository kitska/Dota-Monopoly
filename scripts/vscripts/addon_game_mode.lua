---------------------------------------------------------------------------
-- Dmono class
---------------------------------------------------------------------------
if Dmono == nil then
	_G.Dmono = class({}) -- put Dmono in the global scope
end

---------------------------------------------------------------------------
-- Required .lua files
---------------------------------------------------------------------------
require("utilities")
require('libraries/timers')
---------------------------------------------------------------------------
-- Precache
---------------------------------------------------------------------------
function Precache(context)
    PrecacheResource("file", "panorama/layouts/custom_game/timer.xml", context)
	PrecacheResource("file", "panorama/layouts/custom_game/my_panel.xml", context)
end

function Activate()
    GameRules.Dmono = Dmono()
    GameRules.Dmono:InitGameMode()
end
---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------

function Dmono:InitGameMode()
	print( "Load complete" )

	Dmono.RollCount = 0

	Dmono.Flag = 0
	Dmono.tfl = true

	Dmono.ChestFlag = false
	Dmono.ChanceFlag = false
	
	Dmono.BougntSectors = 0
	Dmono.FakePos = {}

	Dmono.currentTurnTimerHandle = nil

	Dmono.pIDs = {}
	Dmono.TurnsQueue = {}
	Dmono.PlayerNPCs = {}
	Dmono.CurrentPlayerIndex = 1
	Dmono.TurnFlag = false
	Dmono.SkipFlagTable = {}
	Dmono.RootModifierFlagTable = {}
	Dmono.DeathFlagTable = {}

	Dmono.JailTable = {}
	Dmono.JailDiceCounter = 0

	Dmono.SectorStatusBought = {}
	Dmono.SectorRentTable = {}
	Dmono.SectorBaseRentTable = {}
	Dmono.SectorStatusUpgradeTable = {}
	Dmono.SectorUpgradePriceTable = {}
	Dmono.PriceSectorIndex = {}
	Dmono.SectorMortgageTable = {}
	Dmono.BaseUpgrade = {}
	Dmono.MortgageTurnTable = {}
	Dmono.MortgageFlagTable = {}

	Dmono.Upgrade1RentCost = {}
	Dmono.Upgrade2RentCost = {}
	Dmono.Upgrade3RentCost = {}
	Dmono.Upgrade4RentCost = {}
	Dmono.UpgradeFinaleRentCost = {}

	Dmono.StationTable = {}
	Dmono.UtilityTable = {}

	Dmono.Rand1ForUtility = 0
	Dmono.Rand2ForUtility = 0

	Dmono.StreetTable = {}

	Dmono.DeficitMoneyPlayer = {}

	Dmono.ChestSectorScriptTable = {}
	self.ChestSectorScriptTable[1] = function(player)
		if player ~= nil then
			player:ModifyGold(200, false, 0)
			Say(player, "Banking error in your favor. Get 200 gold", false)
		end
	end
	self.ChestSectorScriptTable[2] = function(player)
		if player ~= nil then
			player:ModifyGold(25, false, 0)
			Say(player, "Favorable sale of shares. Get 25 gold", false)
		end
	end
	self.ChestSectorScriptTable[3] = function(player)
		--освобождение от тюрьмы
		if player ~= nil then
			player:AddItemByName("item_release_from_prison")
			Say(player, "Release from prison. The card can be used later or sold", false)
		end
	end
	self.ChestSectorScriptTable[4] = function(player)
		if player ~= nil then
			player:ModifyGold(25, false, 0)
			Say(player, "Favorable sale of shares. Get 25 gold", false)
		end
	end
	self.ChestSectorScriptTable[5] = function(player)
		if player ~= nil then
			player:ModifyGold(100, false, 0)
			Say(player, "You have received an inheritance. Get 100 gold", false)
		end
	end
	self.ChestSectorScriptTable[6] = function(player)
		if player ~= nil then
			player:ModifyGold(25, false, 0)
			Say(player, "Tax refund. Get 25 gold", false)
		end
	end
	self.ChestSectorScriptTable[7] = function(player)
		-- в тюрьму
		if player ~= nil then 
			Dmono:SetChestFlag(true)
			FindClearSpaceForUnit(player, Vector(1732.92, -1565.54, 128), true)
			Say(player, "You have been arrested. Go to jail", false)
		end
	end
	self.ChestSectorScriptTable[8] = function(player)
		if player ~= nil then
			Dmono:SetChestFlag(true)
			local pID = player:GetPlayerID()
			local gold = 50
			if not Dmono:GetDeficitMoneyPlayer(pID) then
				Say(player, "Insurance payment. Pay 50 gold", false)
			end
			if player:GetGold() < gold then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, gold)
			end, "CheckPlayerGold", 0.03)
		end
	end
	self.ChestSectorScriptTable[9] = function(player)
		if player ~= nil then
			player:ModifyGold(10, false, 0)
			Say(player, "You won second place in a beauty pageant. Get 10 gold", false)
		end
	end
	self.ChestSectorScriptTable[10] = function(player)
		if player ~= nil then
			player:ModifyGold(50, false, 0)
			Say(player, "Favorable sale of bonds. Get 50 gold", false)
		end
	end
	self.ChestSectorScriptTable[11] = function(player)
		if player ~= nil then
			Dmono:SetChestFlag(true)
			local pID = player:GetPlayerID()
			local gold = 50
			if not Dmono:GetDeficitMoneyPlayer(pID) then
				Say(player, "Payment for treatment. Pay 50 gold", false)
			end
			if player:GetGold() < gold then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, gold)
			end, "CheckPlayerGold", 0.03)
		end
	end
	self.ChestSectorScriptTable[12] = function(player)
		-- телепорт на кобольда 1
		if player ~= nil then 
			Dmono:SetChestFlag(true)
			local pID = player:GetPlayerID()
			FindClearSpaceForUnit(player, Vector(-1575.39, -1129.84, 128), true)
			Dmono:SetFakePos(pID, Vector(-1575.39, -1129.84, 128))
			Say(player, "Return to the small kobold", false)
		end
	end
	self.ChestSectorScriptTable[13] = function(player)
		if player ~= nil then
			player:ModifyGold(100, false, 0)
			Say(player, "Collection of rent. Get 100 gold", false)
		end
	end
	self.ChestSectorScriptTable[14] = function(player)
		-- день рождения
		if player ~= nil then 
			for i = 0, self.PlayerCount - 1 do 
				if Dmono:GetValueFromNPC(i):GetGold() > 10 and  Dmono:GetValueFromNPC(i) ~= player then
					Dmono:GetValueFromNPC(i):ModifyGold(10 * -1, false, 0)
				else
					player:ModifyGold((10 * (self.PlayerCount - 1)), false, 0)
				end
			end
			Say(player, "Happy Birthday. Get 10 gold from each player", false)
		end
	end
	self.ChestSectorScriptTable[15] = function(player)
		-- штраф или карта шанс
		if player ~= nil then 
			Dmono:SetChestFlag(true)
			Say(player, "Pay a fine of 10 gold or take a 'Chance'", false)
			player:RemoveAbility("Roll")
			player:RemoveAbility("Upgrade")
			player:RemoveAbility("Mortgage")
			player:RemoveAbility("Buy_back")
			player:AddAbility("Chest_Sector_Card"):SetLevel(1)
			player:AddAbility("Pay_Chest_Sector"):SetLevel(1)
		end
	end
	self.ChestSectorScriptTable[16] = function(player)
		if player ~= nil then
			Dmono:SetChestFlag(true)
			local pID = player:GetPlayerID()
			local gold = 50
			if not Dmono:GetDeficitMoneyPlayer(pID) then
				Say(player, "Payment for doctor's services. Pay 50 gold", false)
			end
			if player:GetGold() < gold then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, gold)
			end, "CheckPlayerGold", 0.03)
		end
	end

	Dmono.ChanceSectorScriptTable = {}
	self.ChanceSectorScriptTable[1] = function(player)
		-- тп к имбалансному большому
		if player ~= nil then 
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			FindClearSpaceForUnit(player, Vector(-1260.31, -1420.31, 128), true)
			Dmono:SetFakePos(pID, Vector(-1260.31, -1420.31, 128))
			Say(player, "Go to Imbalansniy", false)
		end
	end
	self.ChanceSectorScriptTable[2] = function(player)
		-- на старт тп
		if player ~= nil then 
			local pID = player:GetPlayerID()
			FindClearSpaceForUnit(player, Vector(-1732.92, -1565.54, 128), true)
			Dmono:SetFakePos(pID, Vector(-1732.92, -1565.54, 128))
			Say(player, "Go to start", false)
		end
	end
	self.ChanceSectorScriptTable[3] = function(player)
		-- освобождение из тюрьмы
		if player ~= nil then
			player:AddItemByName("item_release_from_prison")
			Say(player, "Release from prison. The card can be used later or sold", false)
		end
	end
	self.ChanceSectorScriptTable[4] = function(player)
		-- сбор на ремонт улицы
		if player ~= nil then
			Dmono:SetChanceFlag(true)
			local overallsumm = 0
			local forOneUpgrade = 40
			local forOneFinaleUpgrade = 115
			local upgadeCounter = 0
			local FinaleUpgadeCounter = 0
			local upgradeNum = 0
			for i = 1, 28 do 
				if Dmono:GetFromSectorStatusUpgradeTable(i) ~= "NoUpgrade" and Dmono:GetFromSectorStatusUpgradeTable(i) ~= "Upgrade5" then
					upgradeNum = tonumber(string.match(Dmono:GetFromSectorStatusUpgradeTable(i), "%d+"))
					upgadeCounter = upgradeNum + upgadeCounter
				end
				if Dmono:GetFromSectorStatusUpgradeTable(i) == "Upgrade5" then
					FinaleUpgadeCounter = FinaleUpgadeCounter + 1
				end
			end
			overallsumm = (forOneUpgrade * upgadeCounter) + (forOneFinaleUpgrade * FinaleUpgadeCounter)
			Say(player,"Collection for street repairs. For each upgrade 40 gold for each final upgrade 115", false)
			Say(player,"You have ".. upgadeCounter.." upgrades. And you have "..FinaleUpgadeCounter.." final upgrades. Pay "..overallsumm, false)
			if player:GetGold() < overallsumm then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, overallsumm)
			end, "CheckPlayerGold", 0.03)
		end
	end
	self.ChanceSectorScriptTable[5] = function(player)
		-- тп на трента если через старт то + 200
		if player ~= nil then 
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			local playerPos = Dmono:GetFakePos(pID)
			local sectorToTeleport = Vector(1575.38, 322.462, 128)
			if Dmono:GetSectorIndexPos(playerPos) > Dmono:GetSectorIndexPos(sectorToTeleport) then
				FindClearSpaceForUnit(player, sectorToTeleport, true)
				player:ModifyGold(200, false, 0)
				Say(player,"Go to Forest Protector and get 200 gold", false)
			else
				FindClearSpaceForUnit(player, sectorToTeleport, true)
				Say(player,"Go to Forest Protector", false)
			end
			Dmono:SetFakePos(pID, sectorToTeleport)
		end
	end
	self.ChanceSectorScriptTable[6] = function(player)
		if player ~= nil then
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			local gold = 15
			if not Dmono:GetDeficitMoneyPlayer(pID) then
				Say(player, "Speeding fine. Pay 15 gold", false)
			end
			if player:GetGold() < gold then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, gold)
			end, "CheckPlayerGold", 0.03)
		end
	end
	self.ChanceSectorScriptTable[7] = function(player)
		if player ~= nil then
			player:ModifyGold(150, false, 0)
			Say(player, "Loan return. Get 150 gold", false)
		end
	end
	self.ChanceSectorScriptTable[8] = function(player)
		-- в тюрьму
		if player ~= nil then 
			Dmono:SetChanceFlag(true)
			FindClearSpaceForUnit(player, Vector(1732.92, -1565.54, 128), true)
			Say(player, "You have been arrested. Go to jail", false)
		end
	end
	self.ChanceSectorScriptTable[9] = function(player)
		-- капитальный ремонт
		if player ~= nil then
			Dmono:SetChanceFlag(true)
			local overallsumm = 0
			local forOneUpgrade = 25
			local forOneFinaleUpgrade = 100
			local upgadeCounter = 0
			local FinaleUpgadeCounter = 0
			local upgradeNum = 0
			for i = 1, 28 do 
				if Dmono:GetFromSectorStatusUpgradeTable(i) ~= "NoUpgrade" and Dmono:GetFromSectorStatusUpgradeTable(i) ~= "Upgrade5" then
					upgradeNum = tonumber(string.match(Dmono:GetFromSectorStatusUpgradeTable(i), "%d+"))
					upgadeCounter = upgradeNum + upgadeCounter
				end
				if Dmono:GetFromSectorStatusUpgradeTable(i) == "Upgrade5" then
					FinaleUpgadeCounter = FinaleUpgadeCounter + 1
				end
			end
			overallsumm = (forOneUpgrade * upgadeCounter) + (forOneFinaleUpgrade * FinaleUpgadeCounter)
			Say(player,"Capital repairs. For each upgrade 25 gold for each last upgrade 100", false)
			Say(player,"You have ".. upgadeCounter.." upgrades. And you have "..FinaleUpgadeCounter.." final upgrades. Pay "..overallsumm, false)
			if player:GetGold() < overallsumm then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, overallsumm)
			end, "CheckPlayerGold", 0.03)
		end
	end
	self.ChanceSectorScriptTable[10] = function(player)
		-- тп на катапульту верхнюю если через старт то + 200
		if player ~= nil then 
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			local playerPos = Dmono:GetFakePos(pID)
			local sectorToTeleport = Vector(-0.000305176, 1484.31, 128)
			if Dmono:GetSectorIndexPos(playerPos) > Dmono:GetSectorIndexPos(sectorToTeleport) then
				FindClearSpaceForUnit(player, sectorToTeleport, true)
				player:ModifyGold(200, false, 0)
				Say(player,"Go to Dire Cata and get 200 gold", false)
			else
				FindClearSpaceForUnit(player, sectorToTeleport, true)
				Say(player,"Go to Dire Cata", false)
			end
			Dmono:SetFakePos(pID, sectorToTeleport)
		end
	end
	self.ChanceSectorScriptTable[11] = function(player)
		if player ~= nil then
			player:ModifyGold(50, false, 0)
			Say(player, "Bank dividends. Get 150 gold", false)
		end
	end
	self.ChanceSectorScriptTable[12] = function(player)
		if player ~= nil then
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			local gold = 20
			if not Dmono:GetDeficitMoneyPlayer(pID) then
				Say(player, "Drunk driving. 20 gold penalty", false)
			end
			if player:GetGold() < gold then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, gold)
			end, "CheckPlayerGold", 0.03)
		end
	end
	self.ChanceSectorScriptTable[13] = function(player)
		if player ~= nil then
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			local gold = 150
			if not Dmono:GetDeficitMoneyPlayer(pID) then
				Say(player, "Payment for driver training. Pay 150 gold", false)
			end
			if player:GetGold() < gold then
				Say(player, "You don`t have enough gold", false)
				local roll = player:FindAbilityByName("Roll")
				roll:SetHidden(true)
			end
			GameRules:GetGameModeEntity():SetThink(function()
				return Dmono:CheckPlayerGold(player, gold)
			end, "CheckPlayerGold", 0.03)
		end
	end
	self.ChanceSectorScriptTable[14] = function(player)
		if player ~= nil then
			player:ModifyGold(100, false, 0)
			Say(player, "You have won the chess championship. Get 100 gold", false)
		end
	end
	self.ChanceSectorScriptTable[15] = function(player)
		-- тп на маленькую гарпию если через старт то + 200
		if player ~= nil then 
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			local playerPos = Dmono:GetFakePos(pID)
			local sectorToTeleport = Vector(-1575.39, 322.462, 128)
			if Dmono:GetSectorIndexPos(playerPos) > Dmono:GetSectorIndexPos(sectorToTeleport) then
				FindClearSpaceForUnit(player, sectorToTeleport, true)
				player:ModifyGold(200, false, 0)
				Say(player,"Go to Small Harpy and get 200 gold", false)
			else
				FindClearSpaceForUnit(player, sectorToTeleport, true)
				Say(player,"Go to Small Harpy", false)
			end
			Dmono:SetFakePos(pID, sectorToTeleport)
		end
	end
	self.ChanceSectorScriptTable[16] = function(player)
		-- на три клетки назад
		if player ~= nil then
			Dmono:SetChanceFlag(true)
			local pID = player:GetPlayerID()
			local playerPos = Dmono:GetFakePos(pID)
			FindClearSpaceForUnit(player, Dmono:GetSectorPos(Dmono:GetSectorIndexPos(playerPos) - 3), true)
			Say(player, "Go back three sectors", false)
			Dmono:SetFakePos(pID, Dmono:GetSectorPos(Dmono:GetSectorIndexPos(playerPos) - 3))
		end
	end

	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }		--		Yellow
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	
	Dmono.JailCoords = Vector(-2048, 1856, 128)

	Dmono.places = {
		Vector(-1732.92, -1565.54, 128),
		Vector(-1575.39, -1129.84, 128),
		Vector(-1575.39, -839.384, 128),
		Vector(-1575.39, -548.923, 128),
		Vector(-1575.39, -258.462, 128),
		Vector(-1575.39, 32.0001, 128),
		Vector(-1575.39, 322.462, 128),
		Vector(-1575.39, 612.923, 128),
		Vector(-1575.39, 903.385, 128),
		Vector(-1575.39, 1193.85, 128),
		Vector(-1732.92, 1629.54, 128),
		Vector(-1260.31, 1484.31, 128),
		Vector(-945.231, 1484.31, 128),
		Vector(-630.154, 1484.31, 128),
		Vector(-315.077, 1484.31, 128),
		Vector(-0.000305176, 1484.31, 128),
		Vector(315.077, 1484.31, 128),
		Vector(630.154, 1484.31, 128),
		Vector(945.231, 1484.31, 128),
		Vector(1260.31, 1484.31, 128),
		Vector(1732.92, 1629.54, 128),
		Vector(1575.38, 1193.85, 128),
		Vector(1575.38, 903.385, 128),
		Vector(1575.38, 612.923, 128),
		Vector(1575.38, 322.462, 128),
		Vector(1575.38, 32.0001, 128),
		Vector(1575.38, -258.462, 128),
		Vector(1575.38, -548.923, 128),
		Vector(1575.38, -839.384, 128),
		Vector(1575.38, -1129.85, 128),
		Vector(1732.92, -1565.54, 128),
		Vector(1260.31, -1420.31, 128),
		Vector(945.231, -1420.31, 128),
		Vector(630.154, -1420.31, 128),
		Vector(315.077, -1420.31, 128),
		Vector(-0.000305176, -1420.31, 128),
		Vector(-315.077, -1420.31, 128),
		Vector(-630.154, -1420.31, 128),
		Vector(-945.231, -1420.31, 128),
		Vector(-1260.31, -1420.31, 128)
	}

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	GameRules:SetGoldPerTick(0)
	GameRules:SetGoldTickTime(0)
	GameRules:SetPreGameTime(10)
	GameRules:SetPostGameTime(10)
	GameRules:SetStartingGold(1500)
	GameRules:SetTreeRegrowTime(1)

	GameRules:SetShowcaseTime(0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1,1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2,1)
	GameRules:EnableCustomGameSetupAutoLaunch(true)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:LockCustomGameSetupTeamAssignment(false)
	GameRules:SetHeroSelectionTime(999)
	GameRules:SetPreGameTime(10)
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
	GameRules:SetUseUniversalShopMode(true)
	--GameRules:GetGameModeEntity():SetCameraDistanceOverride( 3000 )
	
	GameMode = GameRules:GetGameModeEntity()
	GameMode:SetRecommendedItemsDisabled(true)
	GameMode:SetStashPurchasingDisabled(true)
	GameMode:SetAlwaysShowPlayerInventory(false)
	GameMode:SetTopBarTeamValuesOverride(true)
	GameMode:SetTopBarTeamValuesVisible(false)
	GameMode:SetRecommendedItemsDisabled(true)
	GameMode:SetStashPurchasingDisabled(true)
	GameMode:SetBuybackEnabled(false)
	GameMode:SetDaynightCycleDisabled(false)
	GameMode:SetThink("OnThink", self, "GlobalThink", 2)
	GameMode:SetHUDVisible(DOTA_DEFAULT_UI_AGHANIMS_STATUS, false)
	GameMode:SetHUDVisible(DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS , false)
	GameMode:SetHUDVisible(DOTA_DEFAULT_UI_SHOP_COMMONITEMS  , false)
	 
	ListenToGameEvent("npc_spawned", OnNPCSpawned, nil)
	ListenToGameEvent('player_disconnect', OnPlayerDisconnect, nil)
	ListenToGameEvent('entity_killed', OnHeroDeath, nil)
	ListenToGameEvent("dota_item_purchased", OnItemPurchased, nil)

	

	local paytax1 = Entities:FindByName(nil,("pay_tax_entity_1"))
	local paytax2 = Entities:FindByName(nil,("pay_tax_entity_4"))
	DressPayTaxer(paytax1)
	DressPayTaxer(paytax2)
	local furion = Entities:FindByName(nil,("sector_16"))
	local trent = Entities:FindByName(nil,("sector_17"))
	DressFurionSector(furion)
	DressTrentSector(trent)
	local morphling = Entities:FindByName(nil,("sector_utility_2"))
	DressMorphSector(morphling)

	self:LoadAllKV()
	self:FromKVToTables()
end

function Dmono:GetPlayerIDInTeam(teamID)

    local heroes = HeroList:GetAllHeroes()

    for _, hero in pairs(heroes) do
		local pID = hero:GetPlayerID()
        if PlayerResource:GetTeam(pID) == teamID then
            return hero:GetPlayerID()
        end
    end

    return nil
end

function Dmono:CheckPlayerGold(player, gold)
	local pID = player:GetPlayerID()
	if player:GetGold() >= gold then
        player:ModifyGold(gold * -1, false, 0)
		local roll = player:FindAbilityByName("Roll")
		roll:SetHidden(false)
		Dmono:UpdateDeficitMoneyPlayer(pID, false)
		Dmono:SetNewTurn()
        return nil
    else
        Dmono:UpdateDeficitMoneyPlayer(pID, true)
    end
    return 0.03
end

function Dmono:GetDeficitMoneyPlayer(playerID)
	return self.DeficitMoneyPlayer[playerID]
end

function Dmono:UpdateDeficitMoneyPlayer(playerID, value)
	self.DeficitMoneyPlayer[playerID] = value
end

function OnItemPurchased(event)
	local playerID = event.PlayerID
	local itemCost = event.itemcost
	local itemName = event.itemname

	-- Получаем героя игрока
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

	-- Удаляем предмет из инвентаря героя
	for itemSlot = 0, 9 do
		local item = hero:GetItemInSlot(itemSlot)
		if item and item:GetAbilityName() == itemName then
			hero:RemoveItem(item)
			break
		end
	end

	-- Возвращаем сумму денег, потраченную на предмет
	PlayerResource:ModifyGold(playerID, itemCost, false, DOTA_ModifyGold_Unspecified)
end

function Dmono:DeathTurn(playerID)
	self.DeathFlagTable[playerID] = true
end

function Dmono:CheckDeathTurn(playerID)
	return self.DeathFlagTable[playerID]
end

function OnHeroDeath(event)
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	local pID = killedUnit:GetPlayerID()
	local teamID = PlayerResource:GetTeam(pID)
	Dmono:SetStationTable(pID, 0)
	Dmono:SetUtilityTable(pID, 0)
	for i = 1, 28 do
		if i == 3 then
			sectorUnit = Entities:FindByName(nil,("sector_station_1"))
		elseif i == 8 then
			sectorUnit = Entities:FindByName(nil,("sector_utility_1"))
		elseif i == 11 then
			sectorUnit = Entities:FindByName(nil,("sector_station_2"))
		elseif i == 18 then
			sectorUnit = Entities:FindByName(nil,("sector_station_3"))
		elseif i == 21 then
			sectorUnit = Entities:FindByName(nil,("sector_utility_2"))
		elseif i == 26 then
			sectorUnit = Entities:FindByName(nil,("sector_station_4"))
		else
			sectorUnit = Entities:FindByName(nil,("sector_"..i))
		end
		local visible_sectors = Entities:FindByName(nil, ("sec_"..i.."_visible"))
		if Dmono:GetFromSectorStatusBought(i) == teamID then
			if Dmono:GetFromSectorStatusUpgradeTable(i) ~= "NoUpgrade" then
				Dmono:UpdateFromSectorStatusUpgradeTable(i, "NoUpgrade")
				Dmono:UpdateFromSectorUpgradePriceTable(i, Dmono:GetFromBaseUpgrade(i))
			end
			local modifierCold = sectorUnit:FindAllModifiersByName("modifier_winter_wyvern_cold_embrace")
    		for _, modifier in pairs(modifierCold) do
    		    sectorUnit:RemoveModifierByName(modifier:GetName())
    		end
			local modifierUp = sectorUnit:FindAllModifiersByName("upgrade_modifier")
    		for _, modifier in pairs(modifierUp) do
    		    sectorUnit:RemoveModifierByName(modifier:GetName())
    		end
			Dmono:UpdateMortgageTurnTable(i, 0)
            Dmono:UpdateMortgageFlagTable(i, false)
			Dmono:UpdateFromSectorRentTable(i, Dmono:GetFromSectorBaseRentTable(i))
			Dmono:UpdateFromSectorStatusBought(i, 0)
			visible_sectors:SetRenderColor(255, 255, 255)
		end
	end
	local QueueTurns = Dmono.TurnsQueue[Dmono.CurrentPlayerIndex]
	local playerHero = Dmono:GetValueFromNPC(QueueTurns)
	if playerHero == killedUnit then
		Dmono:DeathTurn(pID)
		Dmono:SkipTurn(pID)
		Dmono:SetNewTurn()
	else
		return
	end

	local players = HeroList:GetAllHeroes()
    local alivePlayers = 0
    local lastAlive = nil

    for _, player in pairs(players) do
		local playerID = player:GetPlayerID()
        if player:IsRealHero() and player:IsAlive() then
            alivePlayers = alivePlayers + 1
			lastAlive = player
        end
    end
	lastAlivepID = lastAlive:GetPlayerID()
	if alivePlayers == 1 and lastAlive:IsAlive() then
		local teamID = PlayerResource:GetTeam(lastAlivepID)
		Dmono:MakeTeamWin(teamID)
	else
		return
	end
end

function OnPlayerDisconnect(event)
	local playerID = event.PlayerID

	local reason = event.reason
    local playerName = event.name
    local networkID = event.networkid
    local xuid = event.xuid


    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hero and hero:IsAlive() then
        hero:Kill(nil, hero)
    end

	-- Utilities:RemoveElementFromTable(Dmono.TurnsQueue, playerID)
	-- Utilities:RemoveElementFromTable(Dmono.PlayerNPCs, hero)
	-- Dmono.CurrentPlayerIndex = Dmono.CurrentPlayerIndex - 1
	-- Dmono.PlayerCount = Dmono.PlayerCount - 1
end

function Dmono:SetChestFlag(value)
	self.ChestFlag = value
end

function Dmono:SetChanceFlag(value)
	self.ChanceFlag = value
end

function Dmono:GetChestFlag()
	return self.ChestFlag
end

function Dmono:GetChanceFlag()
	return self.ChanceFlag
end

function Dmono:GetFromChanceTable(rand, player)
	Dmono.ChanceSectorScriptTable[rand](player)
end

function Dmono:GetFromChestTable(rand, player)
	Dmono.ChestSectorScriptTable[rand](player)
end

function Dmono:CheckStreetCondition(teamID)
	if Dmono:GetFromSectorStatusBought(1) == teamID and Dmono:GetFromSectorStatusBought(2) == teamID then 
		self.StreetTable[1] = teamID
		return true
	elseif Dmono:GetFromSectorStatusBought(4) == teamID and Dmono:GetFromSectorStatusBought(5) == teamID and Dmono:GetFromSectorStatusBought(6) == teamID then
		self.StreetTable[2] = teamID
		return true
	elseif Dmono:GetFromSectorStatusBought(7) == teamID and Dmono:GetFromSectorStatusBought(9) == teamID and Dmono:GetFromSectorStatusBought(10) == teamID then
		self.StreetTable[3] = teamID
		return true
	elseif Dmono:GetFromSectorStatusBought(12) == teamID and Dmono:GetFromSectorStatusBought(13) == teamID and Dmono:GetFromSectorStatusBought(14) == teamID then
		self.StreetTable[4] = teamID
		return true
	elseif Dmono:GetFromSectorStatusBought(15) == teamID and Dmono:GetFromSectorStatusBought(16) == teamID and Dmono:GetFromSectorStatusBought(17) == teamID then
		self.StreetTable[5] = teamID
		return true
	elseif Dmono:GetFromSectorStatusBought(19) == teamID and Dmono:GetFromSectorStatusBought(20) == teamID and Dmono:GetFromSectorStatusBought(22) == teamID then
		self.StreetTable[6] = teamID
		return true
	elseif Dmono:GetFromSectorStatusBought(23) == teamID and Dmono:GetFromSectorStatusBought(24) == teamID and Dmono:GetFromSectorStatusBought(25) == teamID then
		self.StreetTable[7] = teamID
		return true
	elseif Dmono:GetFromSectorStatusBought(27) == teamID and Dmono:GetFromSectorStatusBought(28) == teamID then
		self.StreetTable[8] = teamID
		return true
	end
end

function Dmono:SetRandForUtility(rand1, rand2)
	Dmono.Rand1ForUtility = rand1
	Dmono.Rand2ForUtility = rand2
end

function Dmono:GetRand1ForUtility()
	return Dmono.Rand1ForUtility
end

function Dmono:GetRand2ForUtility()
	return Dmono.Rand2ForUtility
end

function Dmono:GetFromBaseUpgrade(index)
	return self.BaseUpgrade[index]
end

function Dmono:GetStationTable(playerID)
	return self.StationTable[playerID]
end

function Dmono:SetStationTable(playerID, count)
	self.StationTable[playerID] = count
end

function Dmono:IncrementStationTable(playerID)
	self.StationTable[playerID] = self.StationTable[playerID] + 1
end

function Dmono:DecrementStationTable(playerID)
	self.StationTable[playerID] = self.StationTable[playerID] - 1
end

function Dmono:GetUtilityTable(playerID)
	return self.UtilityTable[playerID]
end

function Dmono:SetUtilityTable(playerID, count)
	self.UtilityTable[playerID] = count
end

function Dmono:IncrementUtilityTable(playerID)
	self.UtilityTable[playerID] = self.UtilityTable[playerID] + 1
end

function Dmono:DecrementUtilityTable(playerID)
	self.UtilityTable[playerID] = self.UtilityTable[playerID] - 1
end

function Dmono:GetFromSectorStatusBought(index)
	return self.SectorStatusBought[index]
end

function Dmono:GetFromSectorRentTable(index)
	return self.SectorRentTable[index]
end

function Dmono:GetFromSectorStatusUpgradeTable(index)
	return self.SectorStatusUpgradeTable[index]
end

function Dmono:GetFromSectorUpgradePriceTable(index)
	return self.SectorUpgradePriceTable[index]
end

function Dmono:GetFromPriceSectorIndex(index)
	return self.PriceSectorIndex[index]
end

function Dmono:GetFromSectorMortgageTable(index)
	return self.SectorMortgageTable[index]
end

function Dmono:GetFromSectorBaseRentTable(index)
	return self.SectorBaseRentTable[index]
end

function Dmono:UpdateFromSectorStatusBought(index, value)
	self.SectorStatusBought[index] = value
end

function Dmono:UpdateFromSectorRentTable(index, value)
	self.SectorRentTable[index] = value
end

function Dmono:UpdateFromSectorStatusUpgradeTable(index, value)
	self.SectorStatusUpgradeTable[index] = value
end

function Dmono:UpdateFromSectorUpgradePriceTable(index, value)
	self.SectorUpgradePriceTable[index] = value
end

function Dmono:UpdateFromPriceSectorIndex(index, value)
	self.PriceSectorIndex[index] = value
end

function Dmono:UpdateFromSectorMortgageTable(index, value)
	self.SectorMortgageTable[index] = value
end

function Dmono:GetFromUpgrade1RentCost(index)
	return self.Upgrade1RentCost[index]
end

function Dmono:GetFromUpgrade2RentCost(index)
	return self.Upgrade2RentCost[index]
end

function Dmono:GetFromUpgrade3RentCost(index)
	return self.Upgrade3RentCost[index]
end

function Dmono:GetFromUpgrade4RentCost(index)
	return self.Upgrade4RentCost[index]
end

function Dmono:GetFromUpgradeFinaleRentCost(index)
	return self.UpgradeFinaleRentCost[index]
end

function Dmono:GetMortgageTurnTable(index)
	return self.MortgageTurnTable[index]
end

function Dmono:UpdateMortgageTurnTable(index, value)
	self.MortgageTurnTable[index] = value
end

function Dmono:GetMortgageFlagTable(index)
	return self.MortgageFlagTable[index]
end

function Dmono:UpdateMortgageFlagTable(index, value)
	self.MortgageFlagTable[index] = value
end

function Dmono:LoadAllKV()
	print("Loading all KVs")
	GameRules.kvSector = LoadKeyValues("scripts/KV/sectors.kv")
end

function Dmono:FromKVToTables()
	local sectorKV = GameRules.kvSector
	local numCounter = 1

	repeat
		for k,v in pairs(sectorKV) do
			local sector = sectorKV[k]
			if tonumber(sector.Number) == numCounter then
				Dmono:FillSectorsTables(Dmono.SectorStatusBought, 0)
				Dmono:FillSectorsTables(Dmono.SectorRentTable, sector.Rent)
				Dmono:FillSectorsTables(Dmono.SectorBaseRentTable, sector.Rent)
				Dmono:FillSectorsTables(Dmono.SectorStatusUpgradeTable, "NoUpgrade")
				Dmono:FillSectorsTables(Dmono.SectorUpgradePriceTable, sector.UpgradeCost)
				Dmono:FillSectorsTables(Dmono.PriceSectorIndex, sector.Price)
				Dmono:FillSectorsTables(Dmono.SectorMortgageTable, sector.Mortgage)
				Dmono:FillSectorsTables(Dmono.MortgageTurnTable, 0)
				Dmono:FillSectorsTables(Dmono.MortgageFlagTable, false)
				if sector.Upgrade1 == nil or sector.Upgrade2 == nil or sector.Upgrade3 == nil or sector.Upgrade4 == nil or sector.Upgrade5 == nil then
					Dmono:FillSectorsTables(Dmono.Upgrade1RentCost, 0)
					Dmono:FillSectorsTables(Dmono.Upgrade2RentCost, 0)
					Dmono:FillSectorsTables(Dmono.Upgrade3RentCost, 0)
					Dmono:FillSectorsTables(Dmono.Upgrade4RentCost, 0)
					Dmono:FillSectorsTables(Dmono.UpgradeFinaleRentCost, 0)
				else
					Dmono:FillSectorsTables(Dmono.Upgrade1RentCost, sector.Upgrade1)
					Dmono:FillSectorsTables(Dmono.Upgrade2RentCost, sector.Upgrade2)
					Dmono:FillSectorsTables(Dmono.Upgrade3RentCost, sector.Upgrade3)
					Dmono:FillSectorsTables(Dmono.Upgrade4RentCost, sector.Upgrade4)
					Dmono:FillSectorsTables(Dmono.UpgradeFinaleRentCost, sector.Upgrade5)
				end
				numCounter = numCounter + 1
			end
		end
	until numCounter > 28
	for i = 1, 28 do
		self.BaseUpgrade[i] = self.SectorUpgradePriceTable[i]
	end
end

function OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
    if npc:IsRealHero() then
      local modifier = npc:AddNewModifier(nil, nil, "modifier_stunned", {duration = -1})
	  local modifier2 = npc:AddNewModifier(nil, nil, "modifier_silence", {duration = -1})
	  local modifier3 = npc:AddNewModifier(nil, nil, "modifier_muted", {duration = -1})
    end
	local pID = npc:GetPlayerID()

	table.insert(Dmono.pIDs, pID)
	Dmono:InsertNPC(npc)
end

function Dmono:SendMoneyToOwner(player, teamID, gold)
	local pID = player:GetPlayerID()
	if player:GetGold() >= gold then
        player:ModifyGold(gold * -1, false, 0)
		local roll = player:FindAbilityByName("Roll")
		roll:SetHidden(false)
		Dmono:UpdateDeficitMoneyPlayer(pID, false)
		local playerCount = PlayerResource:GetPlayerCount()
		for i = 0, playerCount - 1 do
			local player = PlayerResource:GetPlayer(i)
			if player and player:GetTeam() == teamID then
				if player:GetAssignedHero() then
					player:GetAssignedHero():ModifyGold(gold, false, 0)
				end
			end
		end
		Dmono:SetNewTurn()
        return nil
    else
        Dmono:UpdateDeficitMoneyPlayer(pID, true)
    end
    return 0.03
end

function Dmono:GetPosForSector(pos)
	local index = 0
	if pos == Dmono:GetSectorPos(2) then
		index = 1
	elseif pos == Dmono:GetSectorPos(4) then
		index = 2
	elseif pos == Dmono:GetSectorPos(6) then
		index = 3
	elseif pos == Dmono:GetSectorPos(7) then
		index = 4
	elseif pos == Dmono:GetSectorPos(9) then
		index = 5
	elseif pos == Dmono:GetSectorPos(10) then
		index = 6
	elseif pos == Dmono:GetSectorPos(12) then
		index = 7
	elseif pos == Dmono:GetSectorPos(13) then
		index = 8
	elseif pos == Dmono:GetSectorPos(14) then
		index = 9
	elseif pos == Dmono:GetSectorPos(15) then
		index = 10
	elseif pos == Dmono:GetSectorPos(16) then
		index = 11
	elseif pos == Dmono:GetSectorPos(17) then
		index = 12
	elseif pos == Dmono:GetSectorPos(19) then
		index = 13
	elseif pos == Dmono:GetSectorPos(20) then
		index = 14
	elseif pos == Dmono:GetSectorPos(22) then
		index = 15
	elseif pos == Dmono:GetSectorPos(24) then
		index = 16
	elseif pos == Dmono:GetSectorPos(25) then
		index = 17
	elseif pos == Dmono:GetSectorPos(26) then
		index = 18
	elseif pos == Dmono:GetSectorPos(27) then
		index = 19
	elseif pos == Dmono:GetSectorPos(28) then
		index = 20
	elseif pos == Dmono:GetSectorPos(29) then
		index = 21
	elseif pos == Dmono:GetSectorPos(30) then
		index = 22
	elseif pos == Dmono:GetSectorPos(32) then
		index = 23
	elseif pos == Dmono:GetSectorPos(33) then
		index = 24
	elseif pos == Dmono:GetSectorPos(35) then
		index = 25
	elseif pos == Dmono:GetSectorPos(36) then
		index = 26
	elseif pos == Dmono:GetSectorPos(38) then
		index = 27
	elseif pos == Dmono:GetSectorPos(40) then
		index = 28
	end
	return index
end

function DressPayTaxer( unit )
	local weaponModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/bounty_hunter/gold_ripperbounty_hunter_weapon/gold_ripperbounty_hunter_weapon.vmdl",
		origin = unit:GetAbsOrigin(),
		scale = 1.0, 
	})
	weaponModel:SetParent(unit, "attach_attack1") 
	weaponModel:FollowEntity(unit, true) 

	local offhandModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/bounty_hunter/gold_ripperbounty_hunter_off_hand/gold_ripperbounty_hunter_off_hand.vmdl",
		origin = unit:GetAbsOrigin(),
		scale = 1.0, 
	})
	offhandModel:SetParent(unit, "attach_attack2") 
	offhandModel:FollowEntity(unit, true) 
	

	local headModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/bounty_hunter/hunternoname_head/hunternoname_head.vmdl",
		origin = unit:GetAbsOrigin(),
		scale = 1.0, 
	})
	headModel:SetParent(unit, "attach_head") 
	headModel:FollowEntity(unit, true) 


	local chestModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/bounty_hunter/old_man_gondar_armor/old_man_gondar_armor.vmdl",
		origin = unit:GetAbsOrigin(),
		scale = 1.0, 
	})
	chestModel:SetParent(unit, "attach_hitloc")
	chestModel:FollowEntity(unit, true)


	local backModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/bounty_hunter/old_man_gondar_back/old_man_gondar_back.vmdl",
		origin = unit:GetAbsOrigin(),
		scale = 1.0, 
	})
	backModel:SetParent(unit, "attach_hitloc")
	backModel:FollowEntity(unit, true)
	
end

function DressFurionSector( furion )
	local weaponModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/items/furion/allfather_of_nature_weapon/allfather_of_nature_weapon.vmdl",
        origin = furion:GetAbsOrigin(),
        scale = 1.0,
    })
    weaponModel:SetParent(furion, "attach_attack1")
    weaponModel:FollowEntity(furion, true)

    local shoulderModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/items/furion/allfather_of_nature_shoulder/allfather_of_nature_shoulder.vmdl",
        origin = furion:GetAbsOrigin(),
        scale = 1.0,
    })
    shoulderModel:SetParent(furion, "attach_shoulder")
    shoulderModel:FollowEntity(furion, true)

    local neckModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/items/furion/allfather_of_nature_neck/allfather_of_nature_neck.vmdl",
        origin = furion:GetAbsOrigin(),
        scale = 1.0,
    })
    neckModel:SetParent(furion, "attach_neck")
    neckModel:FollowEntity(furion, true)

    local headModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/items/furion/allfather_of_nature_head/allfather_of_nature_head.vmdl",
        origin = furion:GetAbsOrigin(),
        scale = 1.0,
    })
    headModel:SetParent(furion, "attach_head")
    headModel:FollowEntity(furion, true)

    local backModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/items/furion/allfather_of_nature_back/allfather_of_nature_back.vmdl",
        origin = furion:GetAbsOrigin(),
        scale = 1.0,
    })
    backModel:SetParent(furion, "attach_back")
    backModel:FollowEntity(furion, true)

    local armsModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
        model = "models/items/furion/allfather_of_nature_arms/allfather_of_nature_arms.vmdl",
        origin = furion:GetAbsOrigin(),
        scale = 1.0,
    })
    armsModel:SetParent(furion, "attach_armsgloves")
    armsModel:FollowEntity(furion, true)
end

function DressTrentSector( trent )
	local armsModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/treant/halloweentree_arms/halloweentree_arms.vmdl",
		origin = trent:GetAbsOrigin(),
		scale = 1.0,
	})
	armsModel:SetParent(trent, "attach_attack1")
	armsModel:FollowEntity(trent, true)
	
	local headModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/treant/halloweentree_head/halloweentree_head.vmdl",
		origin = trent:GetAbsOrigin(),
		scale = 1.0,
	})
	headModel:SetParent(trent, "attach_head")
	headModel:FollowEntity(trent, true)
	
	local legsModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/treant/halloweentree_legs/halloweentree_legs.vmdl",
		origin = trent:GetAbsOrigin(),
		scale = 1.0,
	})
	legsModel:SetParent(trent, "attach_feet")
	legsModel:FollowEntity(trent, true)
	
	local shoulderModel = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/treant/halloweentree_shoulder/halloweentree_shoulder.vmdl",
		origin = trent:GetAbsOrigin(),
		scale = 1.0,
	})
	shoulderModel:SetParent(trent, "attach_attack2")
	shoulderModel:FollowEntity(trent, true)
end

function Dmono:FillSectorsTables(tbl, value)
	table.insert(tbl, value)
end

function DressMorphSector( morphling )
	local armsProp = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/morphling/abyss_overlord_arms/abyss_overlord_arms.vmdl",
		origin = morphling:GetAbsOrigin(),
		scale = 1.0,
	})
	armsProp:SetParent(morphling, "attach_attack1")
	armsProp:FollowEntity(morphling, true)
	
	local backProp = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/morphling/abyss_overlord_back/abyss_overlord_back.vmdl",
		origin = morphling:GetAbsOrigin(),
		scale = 1.0,
	})
	backProp:SetParent(morphling, "attach_back")
	backProp:FollowEntity(morphling, true)
	
	local headProp = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/morphling/abyss_overlord_head/abyss_overlord_head.vmdl",
		origin = morphling:GetAbsOrigin(),
		scale = 1.0,
	})
	headProp:SetParent(morphling, "attach_head")
	headProp:FollowEntity(morphling, true)
	
	local miscProp = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/morphling/abyss_overlord_misc/abyss_overlord_misc.vmdl",
		origin = morphling:GetAbsOrigin(),
		scale = 1.0,
	})
	miscProp:SetParent(morphling, "attach_misc")
	miscProp:FollowEntity(morphling, true)
	
	local shoulderProp = SpawnEntityFromTableSynchronous("prop_dynamic", {
		model = "models/items/morphling/abyss_overlord_shoulder/abyss_overlord_shoulder.vmdl",
		origin = morphling:GetAbsOrigin(),
		scale = 1.0,
	})
	shoulderProp:SetParent(morphling, "attach_shoulder")
	shoulderProp:FollowEntity(morphling, true)
end

function Dmono:OnPlaeyrChat(keys)
	return false
end	

function Dmono:InsertNPC( npc )
	table.insert(self.PlayerNPCs, npc)
end

function Dmono:SetPlayerCount( value )
	self.PlayerCount = value
end

function Dmono:GetCountPlayers()
	return self.PlayerCount
end

function Dmono:PrintNPC()
	for i = 1, Utilities:TableSize(self.PlayerNPCs) do
		print(self.PlayerNPCs[i]:GetName() .. ", ")
	end
end

function Dmono:GetValueFromNPC(playerIdFromQueue)
	for _, npc in pairs(self.PlayerNPCs) do
		local pID = npc:GetPlayerID()
		if pID == playerIdFromQueue then
			return npc
		end
	end
end

function Dmono:OnThink()
	Dmono:ParticleToSectors()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and self.Flag == 0 then
		Dmono.playerCountTeam1 = PlayerResource:GetPlayerCountForTeam(2)
		Dmono.playerCountTeam2 = PlayerResource:GetPlayerCountForTeam(3)
		Dmono.playerCountTeam3 = PlayerResource:GetPlayerCountForTeam(6)
		Dmono.playerCountTeam4 = PlayerResource:GetPlayerCountForTeam(7)
		Dmono.PlayerCount = Dmono.playerCountTeam1 + Dmono.playerCountTeam2 + Dmono.playerCountTeam3 + Dmono.playerCountTeam4

		table.sort(Dmono.pIDs)

		if Dmono.PlayerCount > 1 then
			Dmono:ShuffleQueue(Dmono.pIDs)
		else
			Dmono.TurnsQueue = {0}
		end

		for i = 0, Dmono.PlayerCount - 1 do 
			Dmono.SkipFlagTable[i] = false
			Dmono.DeathFlagTable[i] = false
			Dmono.RootModifierFlagTable[i] = false
			Dmono.DeficitMoneyPlayer[i] = false
		end
		Dmono:HandleTurn()
		self.Flag = self.Flag + 1
	end
	local playerCount = PlayerResource:GetPlayerCount()
	local hero = nil
	local pID = nil

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		for playerID = 0, playerCount - 1 do
			local player = PlayerResource:GetPlayer(playerID)
			local hero = player:GetAssignedHero()
			if hero ~= nil then
				local mango = hero:FindItemInInventory("item_enchanted_mango")
				if mango then
					hero:RemoveItem(mango)
				end

				local faerieFire = hero:FindItemInInventory("item_faerie_fire")
				if faerieFire then
					hero:RemoveItem(faerieFire)
				end
			end
		end
    end
		
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		for i = 0, playerCount - 1 do
			local player = PlayerResource:GetPlayer(i)
			if player then
				if player:GetAssignedHero() then
					hero = player:GetAssignedHero()
					pID = hero:GetPlayerID()
					CustomNetTables:SetTableValue(
						"networth_players",
						tostring(pID),
						{
							net = hero:GetGold(),
						}
					)			
				end
			end
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		for i = 0, playerCount - 1 do
			local player = PlayerResource:GetPlayer(i)
			if player then
				if player:GetAssignedHero() then
					hero = player:GetAssignedHero()
					pID = hero:GetPlayerID()
					CustomNetTables:SetTableValue(
						"networth_players",
						tostring(pID),
						{
							net = hero:GetGold(),
						}
					)
				end
			end
		end
	end
	return 1
end

function Dmono:ParticleToSectors()
	local sectorUnit
	local digitsCount
	local color = Vector(0,0,0)
	for i = 1, 28 do
		if Dmono:GetMortgageFlagTable(i) then
			color = Vector(212, 34, 34)
		else
			color = Vector(255, 215, 0)
		end
		if i == 3 then
			sectorUnit = Entities:FindByName(nil,("sector_station_1"))
		elseif i == 8 then
			sectorUnit = Entities:FindByName(nil,("sector_utility_1"))
			if sectorUnit:GetAbsOrigin() ~= Vector(-965.343, 1818.71, 320) then
				sectorUnit:SetAbsOrigin(Vector(-965.343, 1818.71, 320))
			end
			local particleShine = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_cast_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, sectorUnit )
			ParticleManager:DestroyParticle(particleShine, false)
			ParticleManager:ReleaseParticleIndex(particleShine)
		elseif i == 11 then
			sectorUnit = Entities:FindByName(nil,("sector_station_2"))
		elseif i == 18 then
			sectorUnit = Entities:FindByName(nil,("sector_station_3"))
		elseif i == 21 then
			sectorUnit = Entities:FindByName(nil,("sector_utility_2"))
		elseif i == 26 then
			sectorUnit = Entities:FindByName(nil,("sector_station_4"))
		else
			sectorUnit = Entities:FindByName(nil,("sector_"..i))
		end

		local particle = ParticleManager:CreateParticle("particles/msg_fx/msg_goldbounty.vpcf", PATTACH_OVERHEAD_FOLLOW, sectorUnit )
		if Dmono:GetFromSectorStatusBought(i) > 0 then
			if i ~= 8 or i ~= 21 then
				digitsCount = string.len(tostring(Dmono.SectorRentTable[i]))
				ParticleManager:SetParticleControl(particle, 0, sectorUnit:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, Vector(0, Dmono.SectorRentTable[i], 0))
				ParticleManager:SetParticleControl(particle, 2, Vector(2.0, digitsCount, 0))
				ParticleManager:SetParticleControl(particle, 3, color)
				ParticleManager:DestroyParticle(particle, false)
				ParticleManager:ReleaseParticleIndex(particle)
			end
		else
			digitsCount = string.len(tostring(Dmono.PriceSectorIndex[i]))
			ParticleManager:SetParticleControl(particle, 0, sectorUnit:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(0, Dmono.PriceSectorIndex[i], 0))
			ParticleManager:SetParticleControl(particle, 2, Vector(2.0, digitsCount, 0))
			ParticleManager:SetParticleControl(particle, 3, color)
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end
	
end

function Dmono:HandleTurn()
	CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
	local QueueTurns = self.TurnsQueue[self.CurrentPlayerIndex]
	local playerHero = Dmono:GetValueFromNPC(QueueTurns)
	local prevIndex = self.TurnsQueue[self.CurrentPlayerIndex - 1]
	local prevPlayerHero = Dmono:GetValueFromNPC(prevIndex)
	local pID
	if IsValidEntity(playerHero) then
		pID = playerHero:GetPlayerID()
	end
	local teamID = PlayerResource:GetTeam(pID)

	for i=1, 28 do
		if i == 3 then
			sectorUnit = Entities:FindByName(nil,("sector_station_1"))
		elseif i == 8 then
			sectorUnit = Entities:FindByName(nil,("sector_utility_1"))
		elseif i == 11 then
			sectorUnit = Entities:FindByName(nil,("sector_station_2"))
		elseif i == 18 then
			sectorUnit = Entities:FindByName(nil,("sector_station_3"))
		elseif i == 21 then
			sectorUnit = Entities:FindByName(nil,("sector_utility_2"))
		elseif i == 26 then
			sectorUnit = Entities:FindByName(nil,("sector_station_4"))
		else
			sectorUnit = Entities:FindByName(nil,("sector_"..i))
		end
		local visible_sectors = Entities:FindByName(nil, ("sec_"..i.."_visible"))
		if Dmono:GetMortgageTurnTable(i) == 1 then
			if sectorUnit:FindModifierByName("modifier_winter_wyvern_cold_embrace") ~= nil then
				sectorUnit:RemoveModifierByName("modifier_winter_wyvern_cold_embrace")
				Dmono:UpdateFromSectorRentTable(i, Dmono:GetFromSectorBaseRentTable(i))
				Dmono:UpdateFromSectorStatusBought(i, 0)
				visible_sectors:SetRenderColor(255, 255, 255)
				Dmono:UpdateMortgageFlagTable(i, false)
				Dmono:UpdateMortgageTurnTable(i, 0)
			end
		end
		if Dmono:GetMortgageTurnTable(i) > 0 and Dmono:GetFromSectorStatusBought(i) == teamID then
			Dmono:UpdateMortgageTurnTable(i, Dmono:GetMortgageTurnTable(i) - 1)
			Dmono:UpdateFromSectorRentTable(i, Dmono:GetMortgageTurnTable(i))
		end
	end

	if IsValidEntity(playerHero) then
		if playerHero:FindModifierByName("modifier_winter_wyvern_cold_embrace") ~= nil and Dmono.RootModifierFlagTable[pID] then
			playerHero:RemoveModifierByName("modifier_winter_wyvern_cold_embrace")
			Dmono.RootModifierFlagTable[pID] = false
		end
	end

	if self.TurnFlag and prevPlayerHero == nil then
		prevPlayerHero = Dmono:GetValueFromNPC(self.TurnsQueue[self.PlayerCount])
		prevPlayerHero:AddNewModifier(nil, nil, "modifier_stunned", {duration = -1})
		prevPlayerHero:AddNewModifier(nil, nil, "modifier_silence", {duration = -1})
		self.TurnFlag = false
	elseif self.TurnFlag and prevPlayerHero ~= nil then
		prevPlayerHero:AddNewModifier(nil, nil, "modifier_stunned", {duration = -1})
		prevPlayerHero:AddNewModifier(nil, nil, "modifier_silence", {duration = -1})
		self.TurnFlag = false
	end

	if Dmono:GetJailStatus(pID) == 0 then
		playerHero:RemoveAbility("Jail_Roll")
		playerHero:RemoveAbility("Pay_Jail")
		playerHero:AddAbility("Pay_Jail"):SetLevel(1)
	end
	
	if Dmono:CheckSkipTurn(pID) == false then
		if playerHero ~= nil and IsValidEntity(playerHero) then
			local modifierStun = playerHero:FindAllModifiersByName("modifier_stunned")
    		for _, modifier in pairs(modifierStun) do
    		    playerHero:RemoveModifierByName(modifier:GetName())
    		end
			local modifierSilence = playerHero:FindAllModifiersByName("modifier_silence")
    		for _, modifier in pairs(modifierSilence) do
    		    playerHero:RemoveModifierByName(modifier:GetName())
    		end
		else
			print("?")
		end
	end

	local timerHandle = Timers:CreateTimer("turn_timer", {
    	endTime = 90,
    	callback = function()
			-- print("in callback "..playerHero:GetUnitName())
			if Dmono:GetDeficitMoneyPlayer(pID) then
				playerHero:Kill(nil, playerHero)
				return 1
			end
			if IsValidEntity(playerHero) then
				playerHero:AddNewModifier(nil, nil, "modifier_stunned", {duration = -1})
				playerHero:AddNewModifier(nil, nil, "modifier_silence", {duration = -1})
			end
			self.CurrentPlayerIndex = self.CurrentPlayerIndex + 1
			if self.PlayerCount < self.CurrentPlayerIndex then
				self.CurrentPlayerIndex = 1
			end
			self:HandleTurn()
    	end
   	})

	self.currentTurnTimerHandle = timerHandle

	if Dmono:CheckSkipTurn(pID) then 
		if not Dmono:CheckDeathTurn(pID) then
			Dmono:SetSkipFlagTable(pID, false)
		end
		Dmono.RootModifierFlagTable[pID] = true
		if playerHero ~= nil and IsValidEntity(playerHero)  then
			local modifierStun = playerHero:FindAllModifiersByName("modifier_stunned")
    		for _, modifier in pairs(modifierStun) do
    		    playerHero:RemoveModifierByName(modifier:GetName())
    		end
			local modifierSilence = playerHero:FindAllModifiersByName("modifier_silence")
    		for _, modifier in pairs(modifierSilence) do
    		    playerHero:RemoveModifierByName(modifier:GetName())
    		end
		else
			print("skip?")
		end
		Dmono:SetNewTurn()
	end
end

function Dmono:ColorForTeam( teamID )
	local color = self.m_TeamColors[ teamID ]
	if color == nil then
		color = { 255, 255, 255 } 
	end
	return color
end

function Dmono:SkipTurn( playerID )
	self.SkipFlagTable[playerID] = true
end

function Dmono:SetSkipFlagTable(index, value)
	self.SkipFlagTable[index] = value
end	

function Dmono:CheckSkipTurn( playerID )
	return self.SkipFlagTable[playerID]
end

function Dmono:SetNewTurn()
	self.TurnFlag = true
	if self.currentTurnTimerHandle ~= nil then
		Timers:RemoveTimer(self.currentTurnTimerHandle)
	end
	self.CurrentPlayerIndex = self.CurrentPlayerIndex + 1
	if self.PlayerCount < self.CurrentPlayerIndex then
		self.CurrentPlayerIndex = 1
	end
	self:HandleTurn()
end

function Dmono:GetJailCoords()
	return self.JailCoords
end

function Dmono:GetSectorPos( index )
	return self.places[index]
end

function Dmono:GetSectorIndexPos(pos)
	for i=1, 40 do 
		if self.places[i] == pos then
			return i
		end
	end
end

function Dmono:MakeTeamWin(teamID)
	GameRules:SetGameWinner(teamID)
	return
end

function Dmono:MakeTeamLose(teamID)
	GameRules:MakeTeamLose(teamID)
	return
end

function Dmono:GetFakePos(playerID)
	return self.FakePos[playerID]
end

function Dmono:SetFakePos(playerID, pos)
	self.FakePos[playerID] = pos
end

function Dmono:IncrimentOfRolls()
	self.RollCount = self.RollCount + 1
end

function Dmono:IncrimentOfBoughts()
	self.BougntSectors = self.BougntSectors + 1
end

function Dmono:GetRollCount()
	return self.RollCount
end

function Dmono:GetBoughtSectors()
	return self.BougntSectors
end

function Dmono:InsertPlayerID(playerID)
    table.insert(self.pIDs, playerID)
end

function Dmono:InsertJail(playerID, amountOfTurns)
	self.JailTable[playerID] = amountOfTurns
end

function Dmono:GetJailStatus(playerID)
	return self.JailTable[playerID]
end

function Dmono:DecrementJailCount(playerID)
	self.JailTable[playerID] = self.JailTable[playerID] - 1
end

function Dmono:PrintID()
	for i = 1, Utilities:TableSize(self.pIDs) do 
		print(self.pIDs[i])
	end
	print("----------------------------" .. Utilities:TableSize(self.pIDs) .. " " .. Utilities:TableSize(self.TurnsQueue))
	for i = 1, Utilities:TableSize(self.TurnsQueue) do 
		print(self.TurnsQueue[i])
	end
end

function Dmono:ShuffleQueue(pIDTable)
	local shuffled = {}

    for i = 1, Utilities:TableSize(pIDTable)  do shuffled[i] = pIDTable[i] end

    for i = Utilities:TableSize(shuffled), 2, -1 do
        local j = RandomInt(1,i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
	
	for i = 1, Utilities:TableSize(shuffled) do self.TurnsQueue[i] = shuffled[i] end
end

-- ⠄⠂⠄⠐⠄⠄⠄⠄⠄⢀⣠⣶⣶⣿⣿⣿⣷⣶⣶⣤⣀⡀⠄⠄⠄⠄⠄⠄⠂⠄⠐⠄⠄⠂⠄⠐⠄
-- ⠄⠐⠈⠄⠄⠄⠄⣀⣴⣿⣿⣿⣿⣿⢿⣿⢿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠄⠄⠄⠄⠁⢀⠈⠄⠈⠄⡀
-- ⠐⠄⠄⠄⠄⢀⣴⣿⣿⡿⣿⢽⣾⣽⢿⣺⡯⣷⣻⣽⣻⣟⣿⣿⣿⣿⣦⡀⠄⠄⠄⠄⡀⠐⠈⠄⠄
-- ⠄⠄⠄⠄⢀⣾⣿⣿⢿⡽⡯⣿⢾⣟⣿⣳⢿⡽⣾⣺⣳⣻⣺⣽⣻⡿⣿⣿⣦⠄⠄⠄⠄⠄⠄⠄⠂
-- ⠄⠄⠄⠄⣿⣿⣿⣯⢿⣽⣻⣽⣿⣿⣯⣿⣿⣿⣷⣻⢮⣗⡯⣞⡾⡹⡵⣻⣿⣇⠄⠄⠄⠂⠄⠄⠠
-- ⠄⠄⠄⣸⣿⣿⣿⣿⡿⡾⣳⢿⢿⢿⠿⠿⠟⠟⠟⠿⣯⡾⣝⣗⣯⢪⢎⢗⣯⣿⣇⠄⠄⠄⠄⢀⠄
-- ⠄⠄⠄⠋⠉⠁⠑⠁⢉⣁⡁⠁⠁⠄⠄⠄⠄⠄⠄⠄⢉⢻⢽⣞⢾⣕⢕⢝⢎⣿⣿⡀⠄⠄⠄⠄⢀
-- ⠄⠄⠄⡧⠠⡀⠐⠂⣸⣿⢿⢔⢔⢤⢈⠡⡱⣩⢤⢴⣞⣾⣽⢾⣽⣺⡕⡕⡕⡽⣿⣿⠟⢶⠄⠄⠄
-- ⠄⠄⠄⣿⡳⡄⡢⡂⣿⣿⢯⣫⢗⣽⣳⡣⣗⢯⣟⣿⣿⢿⡽⣳⢗⡷⣻⡎⢎⢎⣿⡇⠻⣦⠃⠄⠄
-- ⠄⠄⠄⡿⡝⡜⣜⣬⣿⣿⣿⣷⣯⢺⠻⡻⣜⢔⠡⢓⢝⢕⢏⢗⢏⢯⡳⡝⡸⡸⣸⣧⡀⣹⣠⠄⠄
-- ⠄⠄⠄⣇⢪⢎⡧⡛⠛⠋⠋⠉⠙⣨⣮⣦⢅⡃⠇⡕⡌⡪⡨⢸⢨⢣⠫⡨⢪⢸⠰⣿⣇⣾⡞⠄⠄
-- ⠄⠄⠄⢑⡕⡵⡻⣕⠄⠄⠄⠔⡜⡗⡟⣟⢿⢮⢆⡑⢕⣕⢎⢮⡪⡎⡪⡐⢅⢇⢣⠹⡛⣿⡅⠄⠄
-- ⠄⠄⠄⢸⢎⠪⡊⣄⣰⣰⣵⣕⣮⣢⣳⡸⡨⠪⡨⠂⠄⠑⢏⠗⢍⠪⡢⢣⢃⠪⡂⣹⣽⣿⣷⡄⠄
-- ⠄⠄⠄⡸⠐⠝⠋⠃⠡⡕⠬⠎⠬⠩⠱⢙⣘⣑⣁⡈⠄⠄⡕⢌⢊⢪⠸⡘⡜⢌⠢⣸⣾⢿⣿⣿⡀
-- ⠄⠄⠄⡎⣐⠲⢒⢚⢛⢛⢛⢛⠛⠝⡋⡫⢉⠪⡱⠡⠄⠠⢣⢑⠱⡨⡊⡎⢜⢐⠅⢼⡾⣟⣿⣿⣷
-- ⠄⠄⣠⡃⡢⠨⢀⢂⢐⢐⢄⠑⠌⢌⢂⠢⠡⡑⡘⢌⠠⡘⡌⢎⠜⡌⢎⠜⡌⠢⠨⡸⣿⡽⣿⣿⣿
-- ⢴⠋⠁⡢⡑⡨⢐⢐⢌⠢⣂⢣⠩⡂⡢⡑⡑⡌⢜⠰⡨⢪⢘⠔⡱⢘⠔⡑⠨⢈⠐⢼⡷⣿⣻⢷⢯
-- ⠂⠄⠄⡢⡃⡢⢊⢔⢢⠣⡪⡢⢣⠪⡢⡑⡕⡜⡜⡌⢎⢢⠱⠨⡂⡑⠨⠄⠁⡂⡨⣺⡽⡯⡫⠣⠡
-- ⠄⠄⣰⡸⠐⠌⠆⢇⠎⡎⢎⢎⢎⢎⢎⢎⠎⡎⡪⠘⠌⠂⠁⠁⠄⢀⠄⢄⢢⢚⢮⢏⠞⡨⢂⠕⠉
-- ⡀⢀⡯⡃⡌⠈⠈⠄⠄⠈⠄⠄⠄⠄⠄⠂⠁⠄⠄⠄⠄⠄⠄⢄⢂⢢⢱⢱⢱⠱⢡⢑⠌⢂⠡⠠⠡
-- ⣀⡸⠨⢂⠌⡊⢄⢂⠠⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⠠⢐⢨⣘⢔⢵⠱⡃⡃⡕⡸⠐⡁⠌⡐⡨⠨⢊
-- ⢣⢎⠨⠄⠄⠨⢊⢪⢪⡫⡪⡊⡐⡐⡐⡌⡬⡪⡪⣎⢗⡕⡎⡣⠃⢅⠊⠆⠡⠠⡁⠢⡑⡐⢌⢌⠢
-- ⡎⡎⠄⠈⠄⠡⢂⠂⡕⡕⡕⠕⢌⢌⢢⢱⢸⡸⣪⢮⡣⡓⠌⠠⢑⠡⢈⠌⢌⢂⠪⠨⡂⣊⠢⡢⢣
-- ⢢⢣⠊⢀⠨⠨⢐⠐⡸⡸⡪⡱⡑⡌⡆⡇⡇⣏⢮⢪⢪⠊⠄⢑⢐⠨⡐⢌⠢⡪⡘⢌⠢⡢⢣⠪⠊
-- ⡣⡑⢅⠄⠄⠨⢐⠨⢰⢱⢣⢣⢪⢸⢨⡚⣞⢜⢎⢎⢎⠪⠐⠄⡆⡣⡪⡊⡪⡂⡪⡘⡌⡎⠊⠄⡐
-- ⡣⠊⠄⣷⣄⠄⠄⠌⢸⢸⠱⡱⡡⡣⡣⡳⡕⡇⡇⡇⠥⠑⠄⢡⢑⠕⢔⢑⠔⡌⡆⠇⠁⡀⠄⠁⠄
-- ⡊⠌⠄⣿⣿⣷⣤⣤⣂⣅⣑⠰⠨⠢⢑⣕⣜⣘⣨⣦⣥⣬⠄⢐⢅⢊⢢⢡⠣⠃⠄⡐⠠⠄⡂⠡⢈
-- ⢨⠨⠄⢹⢛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⠟⠄⢰⢰⢱⠑⠁⢀⠐⡀⠂⠄⠡⠐⠐⡀
-- ⡱⢐⠄⢸⡲⡠⠄⠉⠙⠻⠿⣿⠿⠿⢛⠫⡩⡳⣸⠾⠁⢀⢢⠣⠃⠄⠠⠐⡀⠂⠄⠡⠈⠄⡁⠂⠄
-- ⢌⠆⢕⠈⣗⢥⢣⢡⢑⢌⡢⡢⢅⢇⢇⢯⢾⡽⠃⢀⠔⡅⠁⠄⠄⠨⢀⠡⠐⠈⠄⠡⢈⠐⡀⠅⠌
-- ⠢⠭⢆⠦⡿⡷⡷⡵⡷⡷⣵⢽⡮⣷⢽⡽⡓⠤⠤⠕⡁⠠⠄⠅⠄⠅⠄⠂⠌⠠⠡⠈⠄⢂⠐⠠⠨