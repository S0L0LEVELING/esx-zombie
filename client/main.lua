local CreatedZombies = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function()
	Wait(10000 * 60)
	CreateThread(function()
		while true do
			local Sleep = 5000
			if #CreatedZombies < Config.MaxZombies then
				CreateZombies()
			end
			Wait(Sleep)
		end
	end)
end)

CreateThread(function()
  while true do
    local Sleep = 10

		for i=1, #CreatedZombies do
			local Zombie = CreatedZombies[i]

			if not IsPedDeadOrDying(Zombie) then 
				SetPedAsNoLongerNeeded(Zombie)
				DeleteEntity(Zombie)
				table.remove(CreatedZombies, i)
			end
		end
    Wait(Sleep)
  end
end)

function CreateZombies()
	local Ped = PlayerPedId()
	local PedCoords = GetEntityCoords(Ped)

	local SpawnDistance = math.random(Config.MinSpawnDistance, Config.MaxSpawnDistance)

	local SpawnCoords = GetOffsetFromEntityInWorldCoords(Ped, 0.0, SpawnDistance, 0.0)
	local ZombieModel = Config.ZombieModels[math.random(#Config.ZombieModels)]
	local Zombie = CreatePed(4, GetHashKey(ZombieModel.model), SpawnCoords, GetEntityHeading(Ped))
	SetPedCombatAttributes(Zombie, 36, true)
	SetPedCombatAttributes(Zombie, 5, true)
	SetPedCombatAbility(Zombie, math.random(0, 2))
						
	RequestAnimSet(ZombieModel.walk)
	while not HasAnimSetLoaded(ZombieModel.walk) do
		Citizen.Wait(1)
	end
	
	--TaskGoToEntity(entity, GetPlayerPed(-1), -1, 0.0, 1.0, 1073741824, 0)
	SetPedMovementClipset(Zombie, ZombieModel.walk, 1.0)
	TaskWanderInArea(Zombie, SpawnCoords, SpawnDistance + 40, 10, 10)
	SetCanAttackFriendly(Zombie, true, true)
	SetPedCanEvasiveDive(Zombie, false)
	SetPedRelationshipGroupHash(Zombie, GetHashKey("zombie"))
	SetPedCombatMovement(Zombie, 3)
	SetPedAlertness(Zombie,3)
	SetPedPathAvoidFire(Zombie, false)
	SetPedPathCanUseLadders(Zombie, true)
	SetPedPathCanDropFromHeight(Zombie, true)
	SetPedPathPreferToAvoidWater(Zombie, false)
	SetPedCombatRange(Zombie, 0)
	SetPedConfigFlag(Zombie,100,1)
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