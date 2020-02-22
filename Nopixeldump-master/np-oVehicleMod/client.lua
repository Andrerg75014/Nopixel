local copCars = {
    "police2", -- police / sheriff charger
    "police3", -- police SUV
    "policeb", -- police bike
    "sheriff", -- sheriff cvsi
    "sheriff2", -- sheriff SUV
    "hwaycar2", -- trooper cvpi
    "hwaycar", -- trooper suv
    "hwaycar3", -- trooper charger
    "2015polstang", -- mustang pursuit
    "police", -- K9 Vehicle
    "police4", -- uc cv
    "fbi", -- uc charger
    "fbi2", -- uc cadi
    "pbus", -- prison bus
    "polmav", -- chopper
    "polaventa", --Aventador
    "pol718", -- porsche
    "polf430", -- ferrarri
    "romero", -- lmfao
    "predator"
}

local offroadVehicles = {
    "bifta",
    "blazer",
    "brawler",
    "dubsta3",
    "dune",
    "rebel2",
    "sandking",
    "trophytruck",
    "sanchez",
    "sanchez2",
    "blazer",
    "enduro",
    "pol9",
    "police3", -- police SUV
    "sheriff2", -- sheriff SUV
    "hwaycar", -- trooper suv   
    "fbi2",
    "bf400" 
}

local offroadbikes = {
    "ENDURO",
    "sanchez",
    "sanchez2"
}




local carsEnabled = {}
local airtime = 0
local offroadTimer = 0
local airtimeCoords = GetEntityCoords(PlayerPedId())
local heightPeak = 0
local lasthighPeak = 0
local highestPoint = 0
local zDownForce = 0
local veloc = GetEntityVelocity(veh)
local offroadVehicle = false



local NosVehicles = {}
local nosForce = 0.0
RegisterNetEvent('NosStatus')
AddEventHandler('NosStatus', function()
    local playerPed = PlayerPedId()
    
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
    local driverPed = GetPedInVehicleSeat(currentVehicle, -1)
    if GetVehicleMod(currentVehicle,11) == -1 and GetVehicleMod(currentVehicle,18) == -1 then
        TriggerEvent("DoLongHudText","Need Engine/Turbo upgraded!",2) 
        return 
    end

    if currentVehicle ~= nil and currentVehicle ~= false and currentVehicle ~= 0 then
        if driverPed == PlayerPedId() then
            NosVehicles[currentVehicle] = 100

        end
    end
end)

local handbrake = 0
local nitroTimer = false

RegisterNetEvent('resethandbrake')
AddEventHandler('resethandbrake', function()
    while handbrake > 0 do
        handbrake = handbrake - 1
        Citizen.Wait(30)
    end
end)
RegisterNetEvent('NetworkNos')
AddEventHandler('NetworkNos', function(plt)

    if plt == GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)) then
        startNos()
    end

end)


RegisterNetEvent('NetworkNosOff')
AddEventHandler('NetworkNosOff', function(plt)

    if plt == GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)) then
        endNos()
    end

end)


RegisterNetEvent('NosBro')
AddEventHandler('NosBro', function(currentVehicle)

    if not nitroTimer then
        TriggerServerEvent("NetworkNos",GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)))
    end     

    local passedCurrentVehicle = currentVehicle
    if not IsVehicleOnAllWheels(passedCurrentVehicle) or not IsVehicleEngineOn(passedCurrentVehicle) then return end
    local curSpeed = GetEntitySpeed(passedCurrentVehicle)
    local modifier = (1.0 / (curSpeed / 5)) * 0.81
    SetVehicleForwardSpeed(passedCurrentVehicle, curSpeed + modifier) --Forward Speed

    if nosForce == 0.0 then
        local fInitialDriveForce = GetVehicleHandlingFloat(passedCurrentVehicle, 'CHandlingData', 'fInitialDriveForce')
        nosForce = fInitialDriveForce
    end
    local burst = math.ceil( (nosForce + nosForce * 1.15) * 100000 ) / 100000
    if GetEntitySpeed(passedCurrentVehicle) > 70 then
        burst = math.ceil( (nosForce + nosForce * 0.85) * 100000 ) / 100000
    end
    

    if burst > 0 then
        SetVehicleHandlingField(passedCurrentVehicle, 'CHandlingData', 'fInitialDriveForce', burst)
    end

end)

RegisterNetEvent('nos:help')
AddEventHandler('nos:help', function()
    
    local playerPed = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)  

    if NosVehicles[currentVehicle] == nil then
        NosVehicles[currentVehicle] = 0
    end

    TriggerEvent("chatMessage", "NOS: ", {255, 255, 255}, "You have %" .. math.floor(NosVehicles[currentVehicle]) .. " left")

end)


local disablenos = false
function startNos()
    disablenos = true
    nitroTimer = true
    local playerPed = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)      
    SetVehicleBoostActive(currentVehicle, 1) --Boost Sound
    StartScreenEffect("RaceTurbo", 30.0, 0)
    StartScreenEffect("ExplosionJosh3", 30.0, 0)    
    Citizen.Wait(200)
    StartScreenEffect("RaceTurbo", 0, 0)
    StartScreenEffect("ExplosionJosh3", 0, 0)
    SetVehicleBoostActive(currentVehicle, 0)
end

function endNos()
    local playerPed = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)  
    if nosForce ~= 0.0 then
        SetVehicleHandlingField(currentVehicle, 'CHandlingData', 'fInitialDriveForce', nosForce)
    end
    nosForce = 0.0
    nitroTimer = false
    Citizen.Wait(1000)
    disablenos = false
end


--if not IsVehicleTyreBurst(currentVehicle, tireToBurst) then
--  SetVehicleTyreBurst(currentVehicle, tireToBurst, true, 1000)
--  SetVehicleEngineHealth(currentVehicle, 0)

-- SetVehicleEngineOn(currentVehicle, false, true, true)



local seatbelt = false


function downgrade(veh,power,offroad)
    if carsEnabled["" .. veh .. ""] == nil then 
        return 
    end     
    if offroad then 
        power = power + 0.5
        if IsThisModelABike(GetEntityModel(veh)) then
            power = power + 0.3
        else
            power = power + 0.3
        end

    end
    power = math.ceil(power * 10)

    local factor = math.random( 3+power ) / 10


    if factor > 0.7 then
        if IsThisModelABike(GetEntityModel(veh)) then
            if not offroad then
                factor = 0.7
            end
        else
            if not offroad then
                factor = 0.7
            else
                factor = 0.8
            end
            
        end
    end

    if factor < 0.4 then
        if not offroad then
            factor = 0.25
        else
            factor = 0.4
        end
    end

    if carsEnabled["" .. veh .. ""] == nil then return end
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel', carsEnabled["" .. veh .. ""]["fInitialDriveMaxFlatVel"] * factor)
    --SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock', carsEnabled["" .. veh .. ""]["fSteeringLock"] * factor)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionLossMult', carsEnabled["" .. veh .. ""]["fTractionLossMult"] * factor)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult', carsEnabled["" .. veh .. ""]["fLowSpeedTractionLossMult"] * factor)
    SetVehicleEnginePowerMultiplier(veh,factor)
    SetVehicleEngineTorqueMultiplier(veh,factor)

end
function resetdowngrade(veh)
    if carsEnabled["" .. veh .. ""] == nil then 
        return 
    end

    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel', carsEnabled["" .. veh .. ""]["fInitialDriveMaxFlatVel"])
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock', carsEnabled["" .. veh .. ""]["fSteeringLock"])
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionLossMult', carsEnabled["" .. veh .. ""]["fTractionLossMult"])
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult', carsEnabled["" .. veh .. ""]["fLowSpeedTractionLossMult"])
    SetVehicleEnginePowerMultiplier(veh,0.7)
    SetVehicleEngineTorqueMultiplier(veh,0.7)

end

local upgrdnames = {
    [1] = "Extractors", -- increase speed 5%
    [2] = "Air Filter", -- increase speed 2%
    [3] = "Racing Suspension", -- increase handling 3%
    [4] = "Racing Rollbars", -- increase handling 3%
    [5] = "Bored Cyclinders", -- increase speed 5%
    [6] = "Carbon Fiber", -- reduce weight and increase downforce
}




function ejectionLUL()
    local veh = GetVehiclePedIsIn(PlayerPedId(),false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
    

    SetEntityCoords(PlayerPedId(),coords)
    Citizen.Wait(1)

    SetPedToRagdoll(PlayerPedId(), 5511, 5511, 0, 0, 0, 0)

    SetEntityVelocity(PlayerPedId(), veloc.x*4,veloc.y*4,veloc.z*4)

    local ejectspeed = math.ceil(GetEntitySpeed(PlayerPedId()) * 8)

    SetEntityHealth( PlayerPedId(), (GetEntityHealth(PlayerPedId()) - ejectspeed) )

   -- TriggerEvent("randomBoneDamage")

end

RegisterNetEvent("carhud:ejection:client")
AddEventHandler("carhud:ejection:client",function(plate)
    local curplate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
    if curplate == plate and not seatbelt then
        if math.random(10) > 7 then
            ejectionLUL()
        end
    end
end)


RegisterNetEvent('event:control:vehicleMod')
AddEventHandler('event:control:vehicleMod', function(useID)
    if IsPedInAnyVehicle(PlayerPedId()) and not IsThisModelABike(GetEntityModel(veh)) then
        if seatbelt == false then
            TriggerEvent("seatbelt",true)
            TriggerEvent("InteractSound_CL:PlayOnOne","seatbelt",0.1)
            TriggerEvent("DoShortHudText",'Seat Belt Enabled',4)
        else
            TriggerEvent("seatbelt",false)
            TriggerEvent("InteractSound_CL:PlayOnOne","seatbeltoff",0.7)
            TriggerEvent("DoShortHudText",'Seat Belt Disabled',4)
        end
        seatbelt = not seatbelt
    end
end)


Citizen.CreateThread(function()
    local firstDrop = GetEntityVelocity(PlayerPedId())
    local lastentSpeed = 0
    while true do

        Citizen.Wait(1)

        if (IsPedInAnyVehicle(PlayerPedId(), false)) then

            local veh = GetVehiclePedIsIn(PlayerPedId(),false)
            if not invehicle and not IsThisModelABike(GetEntityModel(veh)) then
                invehicle = true
                TriggerEvent("InteractSound_CL:PlayOnOne","beltalarm",0.35)
            end
            
            local bicycle = IsThisModelABicycle( GetEntityModel(veh) )

            if carsEnabled["" .. veh .. ""] == nil and not bicycle then

                local fSteeringLock = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock')

                fSteeringLock = math.ceil((fSteeringLock * 0.6)) + 0.1
                SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)
                SetVehicleHandlingField(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)

                local fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel')
                if IsThisModelABike(GetEntityModel(veh)) then

                    local fTractionCurveMin = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin')

                    fTractionCurveMin = fTractionCurveMin * 0.6
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin', fTractionCurveMin)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fTractionCurveMin', fTractionCurveMin)   

                    local fTractionCurveMax = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax')

                    fTractionCurveMax = fTractionCurveMax * 0.6
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax', fTractionCurveMax)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fTractionCurveMax', fTractionCurveMax)



                    local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
                    fInitialDriveForce = fInitialDriveForce * 2.2
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)

                    local fBrakeForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce')
                    fBrakeForce = fBrakeForce * 1.4
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', fBrakeForce)
                    
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSuspensionReboundDamp', 5.000000)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fSuspensionReboundDamp', 5.000000)

                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSuspensionCompDamp', 5.000000)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fSuspensionCompDamp', 5.000000)

                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fSuspensionForce', 22.000000)
                    SetVehicleHandlingField(veh, 'CHandlingData', 'fSuspensionForce', 22.000000)

                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fCollisionDamageMult', 2.500000)
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fEngineDamageMult', 0.120000)
                else

                    local fBrakeForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce')
                    fBrakeForce = fBrakeForce * 0.5
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', fBrakeForce)

                    local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
                    print(fInitialDriveForce)
                    if fInitialDriveForce < 0.289 then
                        print("buff shit vh")
                        fInitialDriveForce = fInitialDriveForce * 1.05
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)
                    else
                        print("nerf good vh")
                        fInitialDriveForce = fInitialDriveForce * 0.8
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)
                    end
                                


                    print(fInitialDriveForce .. " " .. GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce'))

                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fEngineDamageMult', 0.100000)
                    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fCollisionDamageMult', 2.900000)

                end
            
                SetVehicleHandlingFloat(veh, 'CHandlingData', 'fDeformationDamageMult', 1.000000)

                SetVehicleHasBeenOwnedByPlayer(veh,true)
                carsEnabled["" .. veh .. ""] = { 
                    ["fInitialDriveMaxFlatVel"] = fInitialDriveMaxFlatVel, 
                    ["fSteeringLock"] = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock'), 
                    ["fTractionLossMult"] = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionLossMult'), 
                    ["fLowSpeedTractionLossMult"] = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fLowSpeedTractionLossMult') 
                }
                local plt = GetVehicleNumberPlateText(veh)
                TriggerServerEvent("request:illegal:upgrades",plt)
            else
                Wait(1000)
            end


            if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then

                local coords = GetEntityCoords(PlayerPedId())
                local roadtest2 = IsPointOnRoad(coords.x, coords.y, coords.z, veh)
              --  roadtest, endResult, outHeading = GetClosestVehicleNode(coords.x, coords.y, coords.z,  1, 0, -1)
             --   endDistance = #(vector3(endResult.x, endResult.y, endResult.z) - GetEntityCoords(PlayerPedId()))   
                local myspeed = GetEntitySpeed(veh) * 3.6
                local xRot = GetEntityUprightValue(veh)
                if not roadtest2 then
                    if (xRot < 0.90) then
                        offroadTimer = offroadTimer + (1 - xRot)
                    elseif xRot > 0.90 then
                        if offroadTimer < 1 then
                            offroadTimer = 0
                        else
                            offroadTimer = offroadTimer - xRot
                            resetdowngrade(veh)
                        end                         
                    end
                elseif offroadTimer > 0 or offroadTimer == 0 then
                    offroadTimer = 0
                    offroadVehicle = false 
                    resetdowngrade(veh)
                end

                if offroadTimer > 5 and not IsPedInAnyHeli(PlayerPedId()) and not IsPedInAnyBoat(PlayerPedId()) then  
           
                    for i = 1, #offroadVehicles do
                        if IsVehicleModel( GetVehiclePedIsUsing(PlayerPedId()), GetHashKey(offroadVehicles[i]) ) then
                            offroadVehicle = true

                        end
                    end

                    if not offroadVehicle then
                        if IsThisModelABike(GetEntityModel(veh)) then
                            downgrade(veh,0.12 - xRot / 10,offroadVehicle)  
                        else
                            downgrade(veh,0.20 - xRot / 10,offroadVehicle)
                        end
                    
                    else
                        downgrade(veh,0.35 - xRot / 10,offroadVehicle)
                    end
                end

                if IsEntityInAir(veh) then
                    firstDrop = GetEntityVelocity(veh)
                    lastentSpeed = math.ceil(GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())))
                    if airtime == 1 then
                        heightPeak = 0
                        lasthighPeak = 0                        
                        airtimeCoords = GetEntityCoords(veh)
                        lasthighPeak = airtimeCoords.z
                    else
                        local AirCurCoords = GetEntityCoords(veh)
                        heightPeak = AirCurCoords.z
                        if tonumber(heightPeak) > tonumber(lasthighPeak) and airtime ~= 0 then
                            lasthighPeak = heightPeak
                            highestPoint = heightPeak - airtimeCoords.z
                        end
                    end
                    airtime = airtime + 1
                elseif airtime > 0 then
                    
                    if airtime > 110 then
                        Citizen.Wait(333)
                        local landingCoords = GetEntityCoords(veh)  
                        local landingfactor = landingCoords.z - airtimeCoords.z     
                        local momentum = GetEntityVelocity(veh)
                        highestPoint = highestPoint - landingfactor

                        highestPoint = highestPoint * 0.55

                        airtime = math.ceil(airtime * highestPoint)

                        local xdf = 0
                        local ydf = 0
                        if momentum.x < 0 then
                            xdf = momentum.x
                            xdf = math.ceil(xdf - (xdf * 2))
                        else
                            xdf = momentum.x
                        end

                        if momentum.y < 0 then
                            ydf = momentum.y
                            ydf = math.ceil(ydf - (ydf * 2))
                        else
                            ydf = momentum.y
                        end



                        zdf = momentum.z 
                        lastzvel = firstDrop.z
                        print("IMPACT Z" .. zdf)
                        print("LAST DROP Z" .. lastzvel)


                        zdf = zdf - lastzvel
                        local dirtBike = false
                        for i = 1, #offroadbikes do
                            if IsVehicleModel(GetVehiclePedIsUsing(PlayerPedId()), GetHashKey(offroadbikes[i], _r)) then
                                dirtBike = true
                            end
                        end
                        if dirtBike then
                            airtime = airtime - 200
                        end

                        if IsThisModelABicycle(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))) then
                            print(airtime .. " what " .. zdf)
                            local ohshit = math.ceil((zdf * 200))
                            local entSpeed = math.ceil( GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())) * 1.35 )
                            print("speed - " .. entSpeed)

                            if airtime > 550 then
                                if airtime > 550 and ohshit > airtime and ( entSpeed < lastentSpeed or entSpeed < 2.0 ) then
                                    ejectionLUL()
                                    --TriggerEvent("DoLongHudText","eject : " .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                elseif airtime > 1500 and entSpeed < lastentSpeed then
                                    ejectionLUL()
                                    --TriggerEvent("DoLongHudText","eject 2 : " .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                else
                                --  TriggerEvent("DoLongHudText","Good Landing" .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                end
                            end

                        elseif airtime > 950 and IsThisModelABike(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))) then
                            print(airtime .. " what " .. zdf)
                            local ohshit = math.ceil((zdf * 200))
                            local entSpeed = math.ceil( GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())) * 1.15 )
                            print("speed - " .. entSpeed)

                            if airtime > 950 then
                                if airtime > 950 and ohshit > airtime and ( entSpeed < lastentSpeed or entSpeed < 2.0 ) then
                                    ejectionLUL()
                                    --TriggerEvent("DoLongHudText","eject : " .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                elseif airtime > 2500 and entSpeed < lastentSpeed then
                                    ejectionLUL()
                                    --TriggerEvent("DoLongHudText","eject 2 : " .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                else
                                    --TriggerEvent("DoLongHudText","Good Landing" .. ohshit .. " vs " .. airtime .. " " .. entSpeed .. " vs " .. lastentSpeed)
                                end
                            end
                                 
                        end
                    end
                    airtimeCoords = GetEntityCoords(PlayerPedId())
                    heightPeak = 0
                    airtime = 0
                    lasthighPeak = 0
                    zDownForce = 0
                end

                --GetVehicleClass(vehicle)
                local ped = PlayerPedId()
                local roll = GetEntityRoll(veh)

                if IsEntityInAir(veh) and not IsThisModelABike(GetEntityModel(veh)) then
                    DisableControlAction(0, 59)
                    DisableControlAction(0, 60)
                end
                if ((roll > 75.0 or roll < -75.0) or not IsVehicleEngineOn(veh)) and not IsThisModelABike(GetEntityModel(veh)) then         
                    DisableControlAction(2,59,true)
                    DisableControlAction(2,60,true)
                end
            else
                Wait(1000)
            end
        else
            if invehicle or seatbelt then
                if seatbelt then
                    TriggerEvent("InteractSound_CL:PlayOnOne","seatbeltoff",0.7)
                end
                invehicle = false
                seatbelt = false
                TriggerEvent("seatbelt",false)
            end
            Citizen.Wait(1500)
        end
    end
end)




Citizen.CreateThread(function()
    Citizen.Wait(1000)
    local newvehicleBodyHealth = 0
    local newvehicleEngineHealth = 0
    local currentvehicleEngineHealth = 0
    local currentvehicleBodyHealth = 0
    local frameBodyChange = 0
    local frameEngineChange = 0
    local lastFrameVehiclespeed = 0
    local lastFrameVehiclespeed2 = 0
    local thisFrameVehicleSpeed = 0
    local tick = 0
    local damagedone = false

    local modifierDensity = true
    while true do
        Citizen.Wait(5)
        local playerPed = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)

        local driverPed = GetPedInVehicleSeat(currentVehicle, -1)

        if currentVehicle ~= nil and currentVehicle ~= false and currentVehicle ~= 0 then

            SetPedHelmet(playerPed, false)

            lastVehicle = GetVehiclePedIsIn(playerPed, false)

            if driverPed == PlayerPedId() then
                if GetVehicleEngineHealth(currentVehicle) < 0.0 then
                    SetVehicleEngineHealth(currentVehicle,0.0)
                end

                if (GetVehicleHandbrake(currentVehicle) or (GetVehicleSteeringAngle(currentVehicle)) > 25.0 or (GetVehicleSteeringAngle(currentVehicle)) < -25.0) then
                    if handbrake == 0 then
                        handbrake = 100
                        TriggerEvent("resethandbrake")
                    else
                        handbrake = 100
                    end
                end

                if NosVehicles[currentVehicle] == nil then
                    NosVehicles[currentVehicle] = 0
                end

                thisFrameVehicleSpeed = GetEntitySpeed(currentVehicle) * 3.6

                if (IsControlJustReleased(1,21) or NosVehicles[currentVehicle] < 10) and nitroTimer then
                    endNos()
                end

                if IsControlPressed(1,21) and not disablenos and handbrake < 5 and thisFrameVehicleSpeed > 45.0 and not IsThisModelAHeli(GetEntityModel(currentVehicle)) and not IsThisModelABoat(GetEntityModel(currentVehicle)) and not IsThisModelABike(GetEntityModel(currentVehicle)) and NosVehicles[currentVehicle] ~= nil then
                    if NosVehicles[currentVehicle] > 1 then
                        TriggerEvent("NosBro",currentVehicle)
                        NosVehicles[currentVehicle] = NosVehicles[currentVehicle] - 1
                    end
                end

                currentvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)

                if currentvehicleBodyHealth == 1000 and frameBodyChange ~= 0 then
                    frameBodyChange = 0
                end

                if frameBodyChange ~= 0 then
                    if lastFrameVehiclespeed > 110 and thisFrameVehicleSpeed < (lastFrameVehiclespeed * 0.75) and not damagedone then
                        if frameBodyChange > 18.0 then
                            if not IsThisModelABike(currentVehicle) then
                                TriggerServerEvent("carhud:ejection:server",GetVehicleNumberPlateText(currentVehicle))
                            end

                            if not seatbelt and not IsThisModelABike(currentVehicle) then
                                if math.random(math.ceil(lastFrameVehiclespeed)) > 110 then
                                    ejectionLUL()
                                end
                            elseif seatbelt and not IsThisModelABike(currentVehicle) then
                                if lastFrameVehiclespeed > 150 then
                                    if math.random(math.ceil(lastFrameVehiclespeed)) > 99 then
                                        ejectionLUL()
                                    end
                                end
                            end
                        else
                            if not IsThisModelABike(currentVehicle) then
                                TriggerServerEvent("carhud:ejection:server",GetVehicleNumberPlateText(currentVehicle))
                            end

                            if not seatbelt and not IsThisModelABike(currentVehicle) then
                                if math.random(math.ceil(lastFrameVehiclespeed)) > 60 then
                                    ejectionLUL()
                                end
                            elseif seatbelt and not IsThisModelABike(currentVehicle) then
                                if lastFrameVehiclespeed > 120 then
                                    if math.random(math.ceil(lastFrameVehiclespeed)) > 99 then
                                        ejectionLUL()
                                    end
                                end
                            end
                        end
                        damagedone = true
                        local wheels = {0,1,4,5}
                        for i=1, math.random(4) do
                            local wheel = math.random(#wheels)
                            SetVehicleTyreBurst(currentVehicle, wheels[wheel], true, 1000)
                            table.remove(wheels, wheel)
                        end

                        SetVehicleEngineHealth(currentVehicle, 0)
                        SetVehicleEngineOn(currentVehicle, false, true, true)
                        Citizen.Wait(1000)
                        TriggerEvent("civilian:alertPolice",50.0,"carcrash",0)
                    end

                    if currentvehicleBodyHealth < 350.0 and not damagedone then
                        damagedone = true
                        local wheels = {0,1,4,5}
                        for i=1, math.random(4) do
                            local wheel = math.random(#wheels)
                            SetVehicleTyreBurst(currentVehicle, wheels[wheel], true, 1000)
                            table.remove(wheels, wheel)
                        end
                        SetVehicleBodyHealth(targetVehicle, 945.0)
                        SetVehicleEngineHealth(currentVehicle, 0)
                        SetVehicleEngineOn(currentVehicle, false, true, true)
                        Citizen.Wait(1000)
                    end
                end

                if lastFrameVehiclespeed < 110 then
                    Wait(100)
                    tick = 0
                end

                frameBodyChange = newvehicleBodyHealth - currentvehicleBodyHealth
                if tick > 0 then
                    tick = tick - 1
                    if tick == 1 then
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                    end
                else
                    lastFrameVehiclespeed2 = lastFrameVehiclespeed
                    if damagedone then
                        damagedone = false
                        frameBodyChange = 0
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                    end

                    if thisFrameVehicleSpeed > lastFrameVehiclespeed2 then
                        lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                    end

                    if thisFrameVehicleSpeed < lastFrameVehiclespeed2 then
                        tick = 25
                    end
                end

                vels = GetEntityVelocity(currentVehicle)

                if tick < 0 then
                    tick = 0
                end

                newvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                if not modifierDensity then
                    modifierDensity = true
                    TriggerEvent("DensityModifierEnable",modifierDensity)
                end
            else

                vels = GetEntityVelocity(currentVehicle)
                if modifierDensity then
                    modifierDensity = false
                    TriggerEvent("DensityModifierEnable",modifierDensity)
                end
                Wait(1000)
            end

            veloc = GetEntityVelocity(currentVehicle)

        else

            if lastVehicle ~= nil then
                SetPedHelmet(playerPed, true)
                Citizen.Wait(200)
                newvehicleBodyHealth = GetVehicleBodyHealth(lastVehicle)

                if not damagedone and newvehicleBodyHealth < currentvehicleBodyHealth then
                    damagedone = true                   
                    SetVehicleTyreBurst(lastVehicle, tireToBurst, true, 1000) 
                    SetVehicleEngineHealth(lastVehicle, 0)
                    SetVehicleEngineOn(lastVehicle, false, true, true)
                    Citizen.Wait(1000)
                end

                lastVehicle = nil
                TriggerEvent("DensityModifierEnable",true)
            end
            lastFrameVehiclespeed = 0
            lastFrameVehiclespeed2 = 0
            newvehicleBodyHealth = 0
            currentvehicleBodyHealth = 0
            frameBodyChange = 0
            Citizen.Wait(2000)
        end
    end
end)




RegisterNetEvent("client:illegal:upgrades")
AddEventHandler("client:illegal:upgrades",function(Extractors,Filter,Suspension,Rollbars,Bored,Carbon)

    if (IsPedInAnyVehicle(PlayerPedId(), false)) then
        local veh = GetVehiclePedIsIn(PlayerPedId(),false)
        if Extractors == 1 then

            local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
            fInitialDriveForce = fInitialDriveForce + fInitialDriveForce * 0.1
            SetVehicleHandlingField(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)
        end


        if Filter == 1 then

            local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
            fInitialDriveForce = fInitialDriveForce + fInitialDriveForce * 0.1
            SetVehicleHandlingField(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)
        end

        if Suspension == 1 then

            local fBrakeForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce')
            fBrakeForce = fBrakeForce + fBrakeForce * 0.3   
            SetVehicleHandlingField(veh, 'CHandlingData', 'fBrakeForce', fBrakeForce)

            local fSteeringLock = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock')
            fSteeringLock = fSteeringLock + fSteeringLock * 0.2
            SetVehicleHandlingField(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)

        end

        if Rollbars == 1 then

            local fBrakeForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce')
            fBrakeForce = fBrakeForce + fBrakeForce * 0.1
            SetVehicleHandlingField(veh, 'CHandlingData', 'fBrakeForce', fBrakeForce)

            local fSteeringLock = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fSteeringLock')
            fSteeringLock = fSteeringLock + fSteeringLock * 0.2
            SetVehicleHandlingField(veh, 'CHandlingData', 'fSteeringLock', fSteeringLock)

        end

        if Bored == 1 then

            local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
            fInitialDriveForce = fInitialDriveForce + fInitialDriveForce * 0.05
            SetVehicleHandlingField(veh, 'CHandlingData', 'fInitialDriveForce', fInitialDriveForce)
        end

        if Carbon == 1 then


            local fMass = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fMass')
            fMass = fMass - fMass * 0.3
            SetVehicleHandlingField(veh, 'CHandlingData', 'fMass', fMass)

            local fInitialDriveForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
            fInitialDriveForce = fInitialDriveForce + fInitialDriveForce * 0.1

        end
    end
end)
