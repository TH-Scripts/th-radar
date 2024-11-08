local thread = false
local lastDisplayState = false
local frozenSpeed = 0
local frozenPlate = ""
local isFrozen = false
local permission = false

--vehicle stats
local speed
local plate = ""

local display = false

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

    for _,v in pairs(Config.Jobs) do
        if v == ESX.PlayerData.job.name then
            permission = true
        else
            permission = false
        end
    end
end)



RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    for k, v in pairs(Config.Jobs) do
        if job.name == v then
            permission = true
        else
            permission = false
        end
    end
end)


RegisterCommand('tooglefroze', function()
    ToggleFreezeState()
end)

RegisterCommand('radar', function()
    local playerPed = PlayerPedId()
    if permission then
        if IsPedInAnyVehicle(playerPed, false) then
            if not display then
                thread = true
                display = true
                SendNUIMessage({
                    display = true,
                    frozen = isFrozen  
                })

                if Config.Help then
                    lib.notify({
                        title = 'Tryk ESC',
                        type = 'info'
                    })  
                end

                ESX.SetTimeout(200, function()
                    SetNuiFocus(true, true)
                end)
            else
                StopUI()
            end
        else
            lib.notify({
                title = 'Køretøj',
                description = 'Du er ikke i noget køretøj',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Politi',
            description = 'Du er ikke politi',
            type = 'error'
        })
    end
end)

RegisterNUICallback('key', function()
    SetNuiFocus(false, false)
end)

function StopUI()
    display = false
    thread = false
    SendNUIMessage({
        display = false,
    })

    SetNuiFocus(false, false)
end

RegisterNUICallback('exit', function()
    StopUI()
end)


function ToggleFreezeState()
    if permission then
        isFrozen = not isFrozen

        SendNUIMessage({
            display = true,
            frozen = isFrozen 
        })
    else
        lib.notify({
            title = 'Politi',
            description = 'Du er ikke politi',
            type = 'error'
        })
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300)

        if thread then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if IsPedInAnyVehicle(playerPed, false) then
                if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
                    local vehicleAhead, plate = GetVehicleInFront(playerPed)

                    if DoesEntityExist(vehicleAhead) and not IsEntityDead(vehicleAhead) then
                        local speed = GetEntitySpeed(vehicleAhead) * 3.6

                        if isFrozen then
                            if frozenSpeed == 0 then
                                frozenSpeed = ESX.Math.Round(speed)
                            end

                            if frozenPlate == "" then
                                frozenPlate = plate
                            end
                        else
                            frozenSpeed = ESX.Math.Round(speed)
                            frozenPlate = plate
                        end
                    end

                    SendNUIMessage({
                        plate = frozenPlate,
                        speed = frozenSpeed,
                        display = true,
                        frozen = isFrozen 
                    })
                else
                    frozenSpeed = 0
                    frozenPlate = ""
                    SendNUIMessage({
                        display = true,
                        frozen = isFrozen
                    })
                end
            else
                StopUI()
                thread = false
            end
        end
    end
end)




function GetVehicleInFront(entity)
    local playerPos = GetEntityCoords(entity)
    local forwardVector = GetEntityForwardVector(entity)
    local rayHandle = StartShapeTestRay(playerPos.x, playerPos.y, playerPos.z, playerPos.x + forwardVector.x * 100.0, playerPos.y + forwardVector.y * 100.0, playerPos.z + forwardVector.z * 100.0, 10, entity, 0)
    
    local _, hit, endCoords, surfaceNormal, vehicle = GetShapeTestResult(rayHandle)
    
    local plate = ""

    if hit then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    
    return vehicle, plate
end


-- keymapping
RegisterKeyMapping('radar', Config.RadarDesc, 'keyboard', Config.RadarHotkey)
RegisterKeyMapping('tooglefroze', Config.FreezeDesc, 'keyboard', Config.FreezeHotkey)
