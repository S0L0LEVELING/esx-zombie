local CreatedZombies = {}


CreateThread(function()
	AddRelationshipGroup("zombie")
	SetRelationshipBetweenGroups(5, GetHashKey("zombie"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("zombie"))
	SetAiMeleeWeaponDamageModifier(1.5)

	if Config.SafeZone.Enabled then
		local SafeZone = Config.SafeZone.Center
		local SafeZoneRadius = Config.SafeZone.radius
		local SafeRadius = AddBlipForRadius(SafeZone, SafeZoneRadius)
		local SafeIcon = AddBlipForCoord(SafeZone)
		SetBlipColour (SafeRadius, 2)
		SetBlipAlpha (SafeRadius, 200)
		SetBlipSprite (SafeIcon, 685)
		SetBlipScale  (SafeIcon, 0.8)
		SetBlipColour (SafeIcon, 2)
		SetBlipAsShortRange(SafeIcon, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName("Safe Zone")
		EndTextCommandSetBlipName(blip)
		
	end
		while true do
		local Sleep = 2000
		if ESX.IsPlayerLoaded() then 
			if #CreatedZombies < Config.MaxZombies then
				CreateZombies()
			end
			Wait(Sleep)
		end
	end
end)



if Config.NoPeds then
	CreateThread(function()
		while true do
			Wait(1)
			local playerPed = PlayerPedId()
			local pos = GetEntityCoords(playerPed) 
			RemoveVehiclesFromGeneratorsInArea(pos['x'] - 500.0, pos['y'] - 500.0, pos['z'] - 500.0, pos['x'] + 500.0, pos['y'] + 500.0, pos['z'] + 500.0);
			SetRandomBoats(0)
			
			--[[ PED POPULATION OFF ]]
			SetPedPopulationBudget(0)
			SetPedDensityMultiplierThisFrame(0)
			SetScenarioPedDensityMultiplierThisFrame(0, 0)

			--[[ VEHICLE POPULATION OFF ]]
			SetPedPopulationBudget(0)
			SetVehicleDensityMultiplierThisFrame(0)
			SetRandomVehicleDensityMultiplierThisFrame(0)
			SetParkedVehicleDensityMultiplierThisFrame(0)

			--[[ POLICE IGNORE PLAYER ]]
			SetPoliceIgnorePlayer(playerPed, true)
			SetDispatchCopsForPlayer(playerPed, false)
		end
	end)
end


CreateThread(function()
  while true do
    local Sleep = 1

		for i=1, #CreatedZombies do
			local Zombie = CreatedZombies[i]
			local Coords = GetEntityCoords(PlayerPedId())
			local ZombieCoords = GetEntityCoords(Zombie)

			if GetEntityHealth(Zombie) <= 2 or #(Coords - ZombieCoords ) > 90 or #(Config.SafeZone.Center - ZombieCoords) <= Config.SafeZone.radius then 
				SetPedAsNoLongerNeeded(Zombie)
				DeleteEntity(Zombie)
				table.remove(CreatedZombies, i)
			end
		end
    Wait(Sleep)
  end
end)

function CreateZombies()
	print("Spawing")
	local Ped = PlayerPedId()
	local PedCoords = GetEntityCoords(Ped)

	local SpawnDistanceX = math.random(Config.MinSpawnDistance, Config.MaxSpawnDistance)
	local SpawnDistanceY = math.random(Config.MinSpawnDistance, Config.MaxSpawnDistance)

	local SpawnCoords = vector3(PedCoords.x + SpawnDistanceX, PedCoords.y + SpawnDistanceY, PedCoords.z)
	local ZombieModel = Config.ZombieModels[math.random(#Config.ZombieModels)]
	RequestModel(ZombieModel.model)
	while not HasModelLoaded(ZombieModel.model) do
		Wait(1)
	end
	local Zombie = CreatePed(4, GetHashKey(ZombieModel.model), SpawnCoords, GetEntityHeading(Ped))
	SetPedCombatAttributes(Zombie, 16, 1)
	SetPedCombatAttributes(ped, 17, 0)
	SetPedCombatAttributes(Zombie, 46, 1)
	SetPedCombatAttributes(Zombie, 1424, 0)
	SetPedCombatAttributes(Zombie, 5, 1)
	SetPedCombatAbility(Zombie, math.random(0, 2))
	SetPedArmour(Zombie, 100)
	SetPedAccuracy(Zombie, 25)
	SetPedSeeingRange(Zombie, 10.0)
	SetPedHearingRange(Zombie, 1000.0)

	RequestAnimSet(ZombieModel.walk)
	while not HasAnimSetLoaded(ZombieModel.walk) do
		Wait(1)
	end
	
	--TaskGoToEntity(entity, GetPlayerPed(-1), -1, 0.0, 1.0, 1073741824, 0)
	SetPedMovementClipset(Zombie, ZombieModel.walk, 1.0)
	TaskWanderStandard(Zombie, 1.0, 10)
	SetEntityMaxSpeed(Zombie, 5.0 * ZombieModel.Speed)
	SetCanAttackFriendly(Zombie, true, true)
	SetPedCanEvasiveDive(Zombie, false)
	SetPedRelationshipGroupHash(Zombie, GetHashKey("zombie"))
	SetPedCombatMovement(Zombie, 3)
	SetPedAlertness(Zombie,3)
	SetPedDiesWhenInjured(Zombie, false)
	SetPedPathAvoidFire(Zombie, false)
	SetPedPathCanUseLadders(Zombie, true)
	SetPedPathCanDropFromHeight(Zombie, true)
	SetPedPathPreferToAvoidWater(Zombie, false)
	SetPedAllowVehiclesOverride(Zombie, true)
	SetPedCombatRange(Zombie, 0)
	SetPedConfigFlag(Zombie,100,1)
	SetPedFleeAttributes(Zombie, 0, 0)
	SetPedSuffersCriticalHits(Zombie, false)
	SetPedAsEnemy(Zombie, true)
	ApplyPedDamagePack(Zombie,"BigHitByVehicle", 0.0, 9.0)
	ApplyPedDamagePack(Zombie,"SCR_Dumpster", 0.0, 9.0)
	ApplyPedDamagePack(Zombie,"SCR_Torture", 0.0, 9.0)
	StopPedSpeaking(Zombie,true)
	SetEntityAsMissionEntity(Zombie, true, true)
	
	CreatedZombies[#CreatedZombies + 1] = Zombie
end

if Config.Blackout then
	SetArtificialLightsState(true)
end

if Config.DisableAmbience then
	StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
end

AddEventHandler("onResourceStop", function(ResourceName)
	if ResourceName == GetCurrentResourceName() then 
		for i=1, #CreatedZombies do
			local Zombie = CreatedZombies[i]
			SetPedAsNoLongerNeeded(Zombie)
			DeleteEntity(Zombie)
		end
		CreatedZombies = {}
	end
end)