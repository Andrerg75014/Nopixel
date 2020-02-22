
local isCop = false
local isDoc = false
local isMedic = false
local cidDoctorsCopAccess = {
    1741, -- torah
}

function DrawText3DTest(x,y,z, text)

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

RegisterNetEvent("np-jobmanager:playerBecameJob")
AddEventHandler("np-jobmanager:playerBecameJob", function(job, name, notify)
    if isMedic and job ~= "ems" then isMedic = false isInService = false end
    if isCop and job ~= "police" then isCop = false isInService = false end
    if isDoc and job ~= "doctor" then isDoc = false isInService = false end
    if job == "police" then isCop = true isInService = true end
    if job == "ems" then isMedic = true isInService = true end
    if job == "doctor" then isDoc = true isInService = true end

    if isMedic == true or isDoc == true then
        local cid = exports["isPed"]:isPed("cid")
        for i=1, #cidDoctorsCopAccess do
            if cid == cidDoctorsCopAccess[i] then
                isCop = true
            end
        end
    end
end)


RegisterNetEvent( 'cell:doors' )
AddEventHandler( 'cell:doors', function(num)
    TriggerEvent("dooranim")
    TriggerServerEvent("np-doors:alterlockstate",tonumber(num))
end)


RegisterNetEvent( 'dooranim' )
AddEventHandler( 'dooranim', function()
    
    ClearPedSecondaryTask(PlayerPedId())
    loadAnimDict( "anim@heists@keycard@" ) 
    TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(850)
    ClearPedTasks(PlayerPedId())

end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

function cZ(num1,num2)
    local answer = false
    if (num1 - num2) > -1.2 and (num1 - num2) < 1.0 then
        answer = true
    end
    return answer
end
hasSteamIdKeys = false
isJudge = false
RegisterNetEvent("isJudge")
AddEventHandler("isJudge", function()
    isJudge = true
end)

RegisterNetEvent("isJudgeOff")
AddEventHandler("isJudgeOff", function()
    isJudge = false
end)

RegisterNetEvent("doors:HasKeys")
AddEventHandler("doors:HasKeys", function(boolRe)
    hasSteamIdKeys = boolRe
end)


    curClosestObj = 999.9
    curClosestNum = 0

local playerped = PlayerPedId()
local plyCoords = GetEntityCoords(playerped)
local closeDoors = {}
local distanceCheck = 100;

Controlkey = {["generalUse"] = {38,"E"}} 
RegisterNetEvent('event:control:update')
AddEventHandler('event:control:update', function(table)
  Controlkey["generalUse"] = table["generalUse"]
end)

Citizen.CreateThread(function()
    while true do
        playerped = PlayerPedId()
        plyCoords = GetEntityCoords(playerped)
        Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        for i = 1, #pointCoords do
            local distance = #(plyCoords - vector3(pointCoords[i]["x"], pointCoords[i]["y"], pointCoords[i]["z"]))
            if distance < distanceCheck then
                closeDoors[i] = pointCoords[i]
            else
                if(closeDoors[i] ~= nil) then
                    closeDoors[i] = nil
                end
            end
        end
        Wait(1000)
    end
end)
RegisterNetEvent("doors:resetTimer")
AddEventHandler("doors:resetTimer", function()
  closestTimer = 0
end)

local closestTimer = 999999
Citizen.CreateThread(function()

    while true do
        

        local drawdist = 12.0
        if ( #(plyCoords - vector3(1842.1411132813,2614.8305664063,44.628032684326)) > 250.0 and #(plyCoords - vector3(465.51, -3119.87, 6.08)) > 300.0 )  then
            distvariable = 20.0
            drawdist = 2.0
        else
            distvariable = 50.0
            drawdist = 20.0
        end

        Citizen.Wait(5)

        local curClosestNum = 0
        local closestdistance = 999.9
        local closestString = "None"
        local daclosmodeelslz = 0
        local doorCoords = { ["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0 }
        local doorCoordsOffset = { ["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0 }

        for i, door in pairs(closeDoors) do
            local distance = #(plyCoords - vector3(door["x"], door["y"], door["z"]))
            
            local newaddition = distance
            if newaddition < closestTimer then
                closestTimer = math.floor(newaddition)
            end

            if distance < distvariable and distance < closestdistance then    
                closestTimer = 0
                if (type(doorTypes[i]["doorType"]) == "number") then
                    objFound = GetClosestObjectOfType(door["x"], door["y"], door["z"], distvariable, doorTypes[i]["doorType"], 0, 0, 0)
                else
                    objFound = GetClosestObjectOfType(door["x"], door["y"], door["z"], distvariable, GetHashKey(doorTypes[i]["doorType"]), 0, 0, 0)
                end

                objCoords = GetEntityCoords(objFound)
                local distance2 = #(vector3(objCoords["x"], objCoords["y"], objCoords["z"]) - vector3(door["x"], door["y"], door["z"]))

                if distance2 < closestdistance and cZ(objCoords["z"],door["z"]) then
                    closestdistance = distance
                    curClosestNum = i 
                    daclosmodeelslz = objFound  
                    doorCoords = objCoords  

                    if (type(doorTypes[i]["doorType"]) ~= "number") then
                        if GetHashKey(doorTypes[i]["doorType"]) == -2023754432 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.05, 0.0, 0.0)  
                        elseif GetHashKey(doorTypes[i]["doorType"]) == -1156020871 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.55, 0.0, -0.1)  
                        elseif GetHashKey(doorTypes[i]["doorType"]) == -222270721 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.2, 0.0, 0.0)     
                        elseif GetHashKey(doorTypes[i]["doorType"]) == 746855201 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.19, 0.0, 0.08)    
                        elseif GetHashKey(doorTypes[i]["doorType"]) == 1309269072 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.45, 0.0, 0.02)        
                        elseif GetHashKey(doorTypes[i]["doorType"]) == -1023447729 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.45, 0.0, 0.02)  
                        elseif GetHashKey(doorTypes[i]["doorType"]) == `v_ilev_fingate` then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.37, 0.0, 0.05)
                        elseif GetHashKey(doorTypes[i]["doorType"]) == `prop_fnclink_02gate7` then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.37, 0.0, 0.05)
                        else
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.2, 0.0, -0.1)  
                        end
                    else

                        if doorTypes[i]["doorType"] == -495720969 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.25, 0.0, 0.02)
                        elseif doorTypes[i]["doorType"] == 464151082 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.3)  
                        elseif doorTypes[i]["doorType"] == -543497392 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 1770281453 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 1173348778 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 479144380 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 1242124150 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 2088680867 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == -320876379 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 631614199 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == -1320876379 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)  
                        elseif doorTypes[i]["doorType"] == -1437850419  then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)  
                        elseif doorTypes[i]["doorType"] == -681066206 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 245182344 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] ==  -1167410167 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 1.2)                              
                        elseif doorTypes[i]["doorType"] == -642608865 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.32, 0.0, -0.23)
                        elseif doorTypes[i]["doorType"] == 749848321 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.08, 0.0, 0.2)
                        elseif doorTypes[i]["doorType"] == 933053701 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.08, 0.0, 0.2)
                        elseif doorTypes[i]["doorType"] == 185711165 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.08, 0.0, 0.2)
                        elseif doorTypes[i]["doorType"] == -1726331785 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.08, 0.0, 0.2)                                                                                    
                        elseif doorTypes[i]["doorType"] == 551491569 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.2, 0.0, -0.23)  
                        elseif doorTypes[i]["doorType"] == -710818483 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.3, 0.0, -0.23)  
                        elseif doorTypes[i]["doorType"] == -543490328 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.0, 0.0, 0.0)  
                        elseif doorTypes[i]["doorType"] == -1417290930 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.0, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == -574290911 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 1773345779 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 1971752884 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.14, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 1641293839 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.07, 0.0, 0.0)
                        elseif doorTypes[i]["doorType"] == 1507503102 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.10, 0.0, 0.0)

                        
                        

                        elseif doorTypes[i]["doorType"] == 1888438146 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 0.9, 0.0, 0.0)  
                        elseif doorTypes[i]["doorType"] == 272205552 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.1, 0.0, 0.0)

                        elseif doorTypes[i]["doorType"] == 9467943 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.2, 0.0, 0.1)
                        elseif doorTypes[i]["doorType"] == 534758478 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -1.2, 0.0, 0.1)

                        elseif doorTypes[i]["doorType"] == 988364535 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 0.4, 0.0, 0.1)
                        elseif doorTypes[i]["doorType"] == -1141522158 then
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, -0.4, 0.0, 0.1)


                        else
                            doorCoordsOffset = GetOffsetFromEntityInWorldCoords(objFound, 1.2, 0.0, 0.1) 
                        end

                    end
                                    
                end

                if door["lock"] ~= nil then
                    if door["lock"] == 1 then 
                        FreezeEntityPosition(objFound, true)                         
                    else 
                        FreezeEntityPosition(objFound, false)
                    end
                end

            elseif distance < distvariable then
                if (type(doorTypes[i]["doorType"]) == "number") then
                    objFound = GetClosestObjectOfType(door["x"], door["y"], door["z"], 1.0, doorTypes[i]["doorType"], 0, 0, 0)
                else
                    objFound = GetClosestObjectOfType(door["x"], door["y"], door["z"], 1.0, GetHashKey(doorTypes[i]["doorType"]), 0, 0, 0)
                end
                daclosmodeelslz = objFound    
                if door["lock"] ~= nil then
                    if door["lock"] == 1 then 
                        FreezeEntityPosition(objFound, true)                         
                    else 
                        FreezeEntityPosition(objFound, false)
                    end
                end


            end

        end

        if closestTimer > 50 and closestTimer ~= 999999 then
            Citizen.Wait(math.ceil(closestTimer * 25))
        end

        if curClosestNum ~= 0 then
            local distcheck = #(plyCoords - vector3(closeDoors[curClosestNum]["x"], closeDoors[curClosestNum]["y"], closeDoors[curClosestNum]["z"]))

            if (type(doorTypes[curClosestNum]["doorType"]) == "number") then
                locked, heading = GetStateOfClosestDoorOfType(doorTypes[curClosestNum]["doorType"], doorCoords["x"], doorCoords["y"], doorCoords["z"])
            else
                locked, heading = GetStateOfClosestDoorOfType(GetHashKey(doorTypes[curClosestNum]["doorType"]), doorCoords["x"], doorCoords["y"], doorCoords["z"])
            end          

            heading = math.ceil(heading * 100) 
            if closeDoors[curClosestNum]["lock"] == 1 then
                if (curClosestNum > 199 and curClosestNum < 219) or (curClosestNum > 20 and curClosestNum < 57) or (curClosestNum > 9 and curClosestNum < 13) then
                    closestString = "Locked (" .. curClosestNum .. ")"
                else
                    closestString = "Locked" 
                end
            else 
                if (curClosestNum > 199 and curClosestNum < 219) or (curClosestNum > 20 and curClosestNum < 57) or (curClosestNum > 9 and curClosestNum < 13) then
                    closestString = "Unlocked (" .. curClosestNum .. ")"
                else
                    closestString = "Unlocked"
                end
                
            end

            if distcheck < drawdist then
                if IsExplosionInSphere(2,closeDoors[curClosestNum]["x"], closeDoors[curClosestNum]["y"], closeDoors[curClosestNum]["z"],5.0) then 
                    TriggerServerEvent("np-doors:ForceLockState",i,0) 
                end

                if isKeyDoor(curClosestNum) then
                    DrawText3DTest(doorCoordsOffset["x"], doorCoordsOffset["y"], doorCoordsOffset["z"], "["..Controlkey["generalUse"][2].."] - " .. closestString .. "" )
                else
                    DrawText3DTest(closeDoors[curClosestNum]["x"], closeDoors[curClosestNum]["y"], closeDoors[curClosestNum]["z"], "[E] - " .. closestString .. "" )
                end
            end


            if  IsControlJustReleased(1,  Controlkey["generalUse"][1]) and OpenCheck(curClosestNum) then

                local shortcheck = #(vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]) - vector3(doorCoordsOffset["x"], doorCoordsOffset["y"], doorCoordsOffset["z"]))

                if shortcheck > 1.7 and isKeyDoor(curClosestNum) then
                    -- dont work til close enough
                else

                    TriggerEvent("dooranim")

                    if isKeyDoor(curClosestNum) then
                        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'keydoors', 0.4)
                    end
                    
                    if closeDoors[curClosestNum]["lock"] == 0 then

                        local active = true
                        local swingcount = 0
                        while active do
                            Citizen.Wait(1)

                            locked, heading = GetStateOfClosestDoorOfType(GetHashKey(doorTypes[curClosestNum]["doorType"]), doorCoords["x"], doorCoords["y"], doorCoords["z"]) 
                            heading = math.ceil(heading * 100) 
                            DrawText3DTest(doorCoordsOffset["x"], doorCoordsOffset["y"], doorCoordsOffset["z"], "Locking" )
                            
                            local dist = #(plyCoords - vector3(closeDoors[curClosestNum]["x"], closeDoors[curClosestNum]["y"], closeDoors[curClosestNum]["z"]))
                            local dst2 = #(plyCoords - vector3(1830.45, 2607.56, 45.59))

                            if heading < 1.5 and heading > -1.5 then
                                swingcount = swingcount + 1
                            end             
                            if dist > 150.0 or swingcount > 100 or dst2 < 200.0 then
                                active = false
                            end
                        end

                    else

                        local active = true
                        local swingcount = 0
                        while active do
                            Citizen.Wait(1)
                            DrawText3DTest(doorCoordsOffset["x"], doorCoordsOffset["y"], doorCoordsOffset["z"], "Unlocking" )
                            swingcount = swingcount + 1
                            if swingcount > 100 then
                                active = false
                            end
                        end

                    end

                    if ( curClosestNum == 114 and not isJudge ) or ( curClosestNum == 115 and not isJudge ) or ( curClosestNum == 116 and not isJudge ) then
                        TriggerServerEvent("server:pass:sdoor",curClosestNum)
                    else
                        TriggerServerEvent("np-doors:alterlockstate",curClosestNum)
                    end

                end

              --  TriggerServerEvent("saveObjects","koil",curClosestNum,GetEntityModel(daclosmodeelslz))
              --  SetEntityCoords(PlayerPedId(),pointCoords[curClosestNum+1]["x"],pointCoords[curClosestNum+1]["y"],pointCoords[curClosestNum+1]["z"])
           
            end      
         end
    end

end)


function OpenCheck(curClosestNum)
    local gangType = exports["isPed"]:isPed("gang")
    local passes = exports["isPed"]:isPed("passes")


    if (isCop or isJudge or exports["np-base"]:getModule("LocalPlayer"):getVar("job") == "district attorney" or hasSteamIdKeys) and (curClosestNum == 146 or curClosestNum == 147) then
        return false
    end

    if curClosestNum ~= 0 and (isCop or isJudge or exports["np-base"]:getModule("LocalPlayer"):getVar("job") == "district attorney" or hasSteamIdKeys) then
        return true
    end

    if ( IsControlJustReleased(1,  Controlkey["generalUse"][1]) and (curClosestNum == 116 or curClosestNum == 115 or curClosestNum == 114) ) then
        return true
    end

    if (curClosestNum == 146 or curClosestNum == 147 or curClosestNum == 157 or curClosestNum == 158) and gangType == 1 then
        return true
    end

    local rank = exports["isPed"]:GroupRank("parts_shop")
    --opens the quick fix
    if rank > 0 and (curClosestNum == 156) then
        return true
    end
    
    local rank = exports["isPed"]:GroupRank("lost_mc")
    --opens the biker club
    if rank > 0 and (curClosestNum == 187 or curClosestNum == 188 or curClosestNum == 189) then
        return true
    end

    local rank = exports["isPed"]:GroupRank("carpet_factory")
    --opens the biker club
    if rank > 0 and (curClosestNum == 160 or curClosestNum == 161 ) then
        return true
    end

    local rank = exports["isPed"]:GroupRank("illegal_carshop")
    --opens the biker club
    if rank > 3 and (curClosestNum == 162 or curClosestNum == 163 ) then
        return true
    end

    local rank = exports["isPed"]:GroupRank("tuner_carshop")
    if rank > 1 and (curClosestNum == 192 or curClosestNum == 193 ) then
        return true
    end


    local rank = exports["isPed"]:GroupRank("weed_factory")
    local rank2 = exports["isPed"]:GroupRank("winery_factory")
    --opens the biker club
    if (rank > 1 or rank2 > 2) and (curClosestNum == 164) then
        return true
    end

    if (rank2 > 3) and (curClosestNum > 222 and curClosestNum < 230) then
        return true
    end



    local cid = exports["isPed"]:isPed("cid")
    if (cid == 41) and (curClosestNum == 190 or curClosestNum == 191) then
        return true
    end

    local rank = exports["isPed"]:GroupRank("rooster_academy")
    if rank >= 3 and ((curClosestNum >= 219 and curClosestNum <= 223 ) or (curClosestNum >= 230 and curClosestNum <= 239 )) then
        return true
    end

    local rank = exports["isPed"]:GroupRank("drift_school")
    if (isCop or isJudge or isMedic or rank >= 1) and ((curClosestNum >= 240 and curClosestNum <= 243 )) then
        return true
    end
    if rank >= 3 and curClosestNum == 244 then
        return true
    end

    return false
end


RegisterNetEvent("np-doors:alterlockstateclient")
AddEventHandler("np-doors:alterlockstateclient", function(pointCoordsSent)
    pointCoords = pointCoordsSent
end)




-- add any doors that arent opened by the player being really close here, for example, gates and shit... could be done on table but /care - prefer function name
function isKeyDoor(num)
    if num == 0 then
        return false
    end
    if doorTypes[num]["doorType"] == "prop_gate_prison_01" then
        return false
    end
    if doorTypes[num]["doorType"] == 1286392437 then
        return false
    end
    if doorTypes[num]["doorType"] == "v_ilev_fin_vaultdoor" then
        return false
    end
    if doorTypes[num]["doorType"] == "hei_prop_station_gate" then
        return false
    end
    return true
end


-- request hashkey of closest object in that location
-- give exact location of object
-- do distance of player to coords
-- group coords pending on location and only search if in specific areas.

-- area sections to check locks
-- 1, 10, 13, 19, 21(bigcheck), 39
-- police HQ


doorTypes = {
    
    [1] = { ["doorType"] = 'v_ilev_rc_door2' },
    [2] = { ["doorType"] = 'v_ilev_rc_door2' },
    [3] = { ["doorType"] = 'v_ilev_ph_gendoor005' },
    [4] = { ["doorType"] = 'v_ilev_ph_gendoor005' },
    [5] = { ["doorType"] = 'v_ilev_ph_gendoor004' },
    [6] = { ["doorType"] = 'v_ilev_ph_cellgate' },
    [7] = { ["doorType"] = 'v_ilev_ph_cellgate' },
    [8] = { ["doorType"] = 'v_ilev_ph_cellgate' },
    [9] = { ["doorType"] = 'v_ilev_ph_cellgate' },
    [10] = { ["doorType"] = 'prop_gate_prison_01' },
    [11] = { ["doorType"] = 'prop_gate_prison_01' },
    [12] = { ["doorType"] = 'prop_gate_prison_01' },
    [13] = { ["doorType"] = 'v_ilev_shrfdoor' },
    [14] = { ["doorType"] = 'prop_ld_jail_door' },
    [15] = { ["doorType"] = 'prop_ld_jail_door' },
    [16] = { ["doorType"] = 'prop_ld_jail_door' },
    [17] = { ["doorType"] = 'v_ilev_ph_cellgate02' },
    [18] = { ["doorType"] = 'v_ilev_ph_cellgate02' },
    [19] = { ["doorType"] = 'v_ilev_shrf2door' },
    [20] = { ["doorType"] = 'v_ilev_shrf2door' },
    [21] = { ["doorType"] = 'prop_gate_prison_01' },
    [22] = { ["doorType"] = 'prop_gate_prison_01' },
    [23] = { ["doorType"] = 'prop_gate_prison_01' },
    [24] = { ["doorType"] = 'prop_gate_prison_01' },
    [25] = { ["doorType"] = 'prop_gate_prison_01' },
    [26] = { ["doorType"] = 'prop_gate_prison_01' },
    [26] = { ["doorType"] = 'prop_gate_prison_01' },
    [26] = { ["doorType"] = 'prop_gate_prison_01' },
    [26] = { ["doorType"] = 'prop_gate_prison_01' },
    [26] = { ["doorType"] = 'prop_gate_prison_01' },
    [27] = { ["doorType"] = 'prop_gate_prison_01' },
    [28] = { ["doorType"] = 'prop_gate_prison_01' },
    [29] = { ["doorType"] = 'prop_gate_prison_01' },
    [30] = { ["doorType"] = 'prop_gate_prison_01' },
    [31] = { ["doorType"] = 'prop_gate_prison_01' },
    [32] = { ["doorType"] = 'prop_gate_prison_01' },
    [33] = { ["doorType"] = 'prop_gate_prison_01' },
    [34] = { ["doorType"] = 'prop_gate_prison_01' },
    [35] = { ["doorType"] = 'prop_gate_prison_01' },
    [36] = { ["doorType"] = 'prop_gate_prison_01' },
    [37] = { ["doorType"] = 'prop_gate_prison_01' },
    [38] = { ["doorType"] = 'prop_gate_prison_01' },

    [39] = { ["doorType"] = -1167410167 },
    [40] = { ["doorType"] = -1167410167 },
    [41] = { ["doorType"] = -1167410167 },
    [42] = { ["doorType"] = -1167410167 },
    [43] = { ["doorType"] = -1167410167 },
    [44] = { ["doorType"] = -1167410167 },
    [45] = { ["doorType"] = -1167410167 },
    [46] = { ["doorType"] = -1167410167 },
    [47] = { ["doorType"] = -1167410167 },
    [48] = { ["doorType"] = -1167410167 },
    [49] = { ["doorType"] = -1167410167 },
    [50] = { ["doorType"] = -1167410167 },
    [51] = { ["doorType"] = -1167410167 },
    [52] = { ["doorType"] = -1167410167 },
    [53] = { ["doorType"] = -1167410167 },
    [54] = { ["doorType"] = -1167410167 },
    [55] = { ["doorType"] = -1167410167 },
    [56] = { ["doorType"] = -1167410167 },




    [57] = { ["doorType"] = 'prop_fnclink_03gate5' },
    [58] = { ["doorType"] = 'prop_ld_jail_door' },
    [59] = { ["doorType"] = 'prop_ld_jail_door' },
    [60] = { ["doorType"] = 'prop_ld_jail_door' },
    [61] = { ["doorType"] = 'prop_ld_jail_door' },
    [62] = { ["doorType"] = 'prop_ld_jail_door' },
    [63] = { ["doorType"] = 'prop_ld_jail_door' },
    [64] = { ["doorType"] = 'prop_ld_jail_door' },
    [65] = { ["doorType"] = 'prop_ld_jail_door' },
    [66] = { ["doorType"] = 'prop_ld_jail_door' },
    [67] = { ["doorType"] = 'prop_ld_jail_door' },
    [68] = { ["doorType"] = 'v_ilev_arm_secdoor' },
    [69] = { ["doorType"] = 'v_ilev_ph_gendoor002' },
    [70] = { ["doorType"] = 'hei_prop_station_gate' },
    [71] = { ["doorType"] = 'hei_prop_station_gate' },
    [72] = { ["doorType"] = 'v_ilev_cbankvaulgate02' },
    [73] = { ["doorType"] = 'v_ilev_cbankvaulgate02' },
    [74] = { ["doorType"] = 'hei_v_ilev_bk_gate_pris' },
    [75] = { ["doorType"] = 'v_ilev_bk_door' },
    [76] = { ["doorType"] = 'hei_v_ilev_bk_gate2_pris' },
    [77] = { ["doorType"] = 'hei_v_ilev_bk_safegate_pris' },
    [78] = { ["doorType"] = 'hei_v_ilev_bk_safegate_pris' },
    [79] = { ["doorType"] = 'prop_damdoor_01' },

    [80] = { ["doorType"] = 'v_ilev_fingate' },
    [81] = { ["doorType"] = 'v_ilev_fingate' },
    [82] = { ["doorType"] = 'v_ilev_fingate' },
    [83] = { ["doorType"] = 'v_ilev_fingate' },
    [84] = { ["doorType"] = 'v_ilev_fingate' },
    [85] = { ["doorType"] = 'v_ilev_fingate' },
    [86] = { ["doorType"] = 'v_ilev_fingate' },
    [87] = { ["doorType"] = 'v_ilev_fingate' },
    [88] = { ["doorType"] = 'v_ilev_fingate' },
    [89] = { ["doorType"] = 'v_ilev_fingate' },

    [90] = { ["doorType"] = 'v_ilev_fin_vaultdoor' },

    -- new sandy shores pd
    [91] = { ["doorType"] = 'prop_ld_jail_door' },
    [92] = { ["doorType"] = 'prop_ld_jail_door' },
    [93] = { ["doorType"] = 'prop_ld_jail_door' },

    [94] = { ["doorType"] = 'v_ilev_shrf2door' },
    [95] = { ["doorType"] = 'v_ilev_shrf2door' },

    [96] = { ["doorType"] = -341973294 },
    [97] = { ["doorType"] = -341973294 },
    [98] = { ["doorType"] = -341973294 },
    [99] = { ["doorType"] = -341973294 },

    [100] = { ["doorType"] = -341973294 },
    [101] = { ["doorType"] = -341973294 },

    [102] = { ["doorType"] = -147325430 },
    [103] = { ["doorType"] = -147325430 },
    [104] = { ["doorType"] = -147325430 },
    [105] = { ["doorType"] = -147325430 },
    [106] = { ["doorType"] = -147325430 },
    [107] = { ["doorType"] = -147325430 },
    [108] = { ["doorType"] = -147325430 },
    [109] = { ["doorType"] = -147325430 },
    [110] = { ["doorType"] = -147325430 },
    [111] = { ["doorType"] = -147325430 },
    [112] = { ["doorType"] = -147325430 },
    [113] = { ["doorType"] = -147325430 },

    [114] = { ["doorType"] = -1116041313 },
    [115] = { ["doorType"] = 668467214 },

    [116] = { ["doorType"] = -495720969 },
    [117] = { ["doorType"] = -519068795 },
    [118] = { ["doorType"] = -519068795 },

    [119] = { ["doorType"] = 749848321 },
    [120] = { ["doorType"] = 749848321 },
    [121] = { ["doorType"] = 749848321 },
    [122] = { ["doorType"] = 749848321 },
    [123] = { ["doorType"] = 749848321 },
    [124] = { ["doorType"] = 749848321 },

    --  -642608865
    [125] = { ["doorType"] = -642608865 },
    [126] = { ["doorType"] = -642608865 },
    [127] = { ["doorType"] = -642608865 },
    [128] = { ["doorType"] = -642608865 },
    [129] = { ["doorType"] = -642608865 },
    [130] = { ["doorType"] = -642608865 },
    [131] = { ["doorType"] = -642608865 },
    [132] = { ["doorType"] = -642608865 },
    [133] = { ["doorType"] = -642608865 },
    [134] = { ["doorType"] = -642608865 },
    [135] = { ["doorType"] = -642608865 },
    [136] = { ["doorType"] = -642608865 },
    [137] = { ["doorType"] = -642608865 },
    [138] = { ["doorType"] = -642608865 },
    [139] = { ["doorType"] = -642608865 },
    [140] = { ["doorType"] = -642608865 },
    [141] = { ["doorType"] = -642608865 },
    [142] = { ["doorType"] = -642608865 },
    [143] = { ["doorType"] = -642608865 },
    [144] = { ["doorType"] = -642608865 },
    [145] = { ["doorType"] = -642608865 },

    -- 125 to 145 are cell block doors
    [146] = { ["doorType"] = -681066206 },
    [147] = { ["doorType"] = 245182344 },

    -- new pd 933053701
    [148] = { ["doorType"] = "v_ilev_ph_cellgate" },
    [149] = { ["doorType"] = "v_ilev_ph_cellgate" },

    [150] = { ["doorType"] = -1320876379},
    [151] = { ["doorType"] = -543497392},
    [152] = { ["doorType"] = -543497392},
    [153] = { ["doorType"] = 464151082},    
    [154] = { ["doorType"] = 245182344}, 
    [155] = { ["doorType"] = 1770281453}, 



    [156] = { ["doorType"] = 190770132 },
    [157] = { ["doorType"] = 551491569 }, 
    [158] = { ["doorType"] = 933053701 },
    [159] = { ["doorType"] = -1591004109},

    [160] = { ["doorType"] = 1286392437 },
    [161] = { ["doorType"] = 1286392437 },

    [162] = { ["doorType"] = -710818483 },
    [163] = { ["doorType"] = -710818483 },

    [164] = { ["doorType"] = -2113580896 },

    [165] = { ["doorType"] = 'prop_fnclink_02gate7' },


    [166] = { ["doorType"] = 631614199 },
    [167] = { ["doorType"] = 631614199 },
    [168] = { ["doorType"] = 631614199 },
    [169] = { ["doorType"] = 631614199 },

    [170] = { ["doorType"] = 631614199 },

    [171] = { ["doorType"] = 933053701 },
    [172] = { ["doorType"] = -1320876379},
    [173] = { ["doorType"] = 1173348778},
    [174] = { ["doorType"] = 479144380},
    [175] = { ["doorType"] = 1242124150},
    [176] = { ["doorType"] = 1242124150},
    [177] = { ["doorType"] = 2088680867},
    [178] = { ["doorType"] = 933053701},

    [179] = { ["doorType"] = 'v_ilev_ph_cellgate'},
    [180] = { ["doorType"] = 'v_ilev_ph_cellgate'},
    [181] = { ["doorType"] = 'v_ilev_ph_cellgate'},
    [182] = { ["doorType"] = 'v_ilev_ph_cellgate'},
    [183] = { ["doorType"] = 'v_ilev_ph_cellgate'},
    [184] = { ["doorType"] = 'v_ilev_ph_cellgate'},
    [185] = { ["doorType"] = 'v_ilev_ph_cellgate'},

    [186] = { ["doorType"] = 749848321},
    [187] = { ["doorType"] = -543490328}, -- Lost MC Int Doors
    [188] = { ["doorType"] = -543490328}, -- Lost MC Int Doors
    [189] = { ["doorType"] = 190770132}, -- Lost MC Front Door

    [190] = { ["doorType"] = 1888438146}, -- dojo
    [191] = { ["doorType"] = 272205552}, --  dojo

    [192] = { ["doorType"] = 1289778077 }, --Tuner Office Front
    [193] = { ["doorType"] = -626684119 }, --Tuner Office Back


    [194] = { ["doorType"] = -1320876379}, --visitor Office
    [195] = { ["doorType"] = -1437850419}, --airlock
    [196] = { ["doorType"] = -1437850419}, --airlock
    [197] = { ["doorType"] = -1033001619}, --back door

    [198] = { ["doorType"] = 1425919976}, --back door
    [199] = { ["doorType"] = 9467943}, --back door

    [200] = { ["doorType"] = -1167410167 },
    [201] = { ["doorType"] = -1167410167 },
    [202] = { ["doorType"] = -1167410167 },
    [203] = { ["doorType"] = -1167410167 },
    [204] = { ["doorType"] = -1167410167 },
    [205] = { ["doorType"] = -1167410167 },
    [206] = { ["doorType"] = -1167410167 },
    [207] = { ["doorType"] = -1167410167 },
    [208] = { ["doorType"] = -1167410167 },
    [209] = { ["doorType"] = -1167410167 },
    [210] = { ["doorType"] = -1167410167 },
    [211] = { ["doorType"] = -1167410167 },
    [212] = { ["doorType"] = -1167410167 },

    [213] = { ["doorType"] = -1033001619},
    [214] = { ["doorType"] = 1373390714},

    [215] = { ["doorType"] = -2109504629},
    [216] = { ["doorType"] = -2109504629},

    [217] = { ["doorType"] = 1373390714},
    [218] = { ["doorType"] = -1033001619},

    [219] = { ["doorType"] = -574290911},
    [220] = { ["doorType"] = 1773345779},
    [221] = { ["doorType"] = 1971752884},
    [222] = { ["doorType"] = 1971752884},

    [223] = { ["doorType"] = 534758478},
    [224] = { ["doorType"] = 534758478},
    [225] = { ["doorType"] = 534758478},

    [226] = { ["doorType"] = -1033001619},
    [227] = { ["doorType"] = -1033001619},

    [228] = { ["doorType"] = 988364535},
    [229] = { ["doorType"] = -1141522158},

    [230] = { ["doorType"] = 1641293839},
    [231] = { ["doorType"] = 1507503102},
    [232] = { ["doorType"] = 1971752884},
    [233] = { ["doorType"] = 1971752884},
    [234] = { ["doorType"] = 1971752884},
    [235] = { ["doorType"] = 1971752884},
    [236] = { ["doorType"] = 1971752884},
    [237] = { ["doorType"] = 1971752884},
    [238] = { ["doorType"] = 1971752884},
    [239] = { ["doorType"] = 1971752884},

    -- Drift School Doors / Gates
    [240] = { ["doorType"] = 1286392437},
    [241] = { ["doorType"] = 1286392437},
    [242] = { ["doorType"] = 1286392437},
    [243] = { ["doorType"] = 1286392437},
    [244] = { ["doorType"] = 3610585061},
}


--1011692606,v_ilev_fingate


pointCoords = {
    -- LS PD
    [1] = { ["x"] = 467.96185302734, ["y"] = -1014.669128418, ["z"] = 26.3863906860 , ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [2] = { ["x"] = 469.26318359375, ["y"] = -1014.472900390, ["z"] = 26.3863906860 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [3] = { ["x"] = 445.36053466797, ["y"] = -989.44879150, ["z"] = 30.689603805 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [4] = { ["x"] = 444.14099121094, ["y"] = -989.46069335, ["z"] = 30.6896038055 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [5] = { ["x"] = 449.90518188477, ["y"] = -986.48205566, ["z"] = 30.689603805 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [6] = { ["x"] = 463.84945678711, ["y"] = -992.779174804, ["z"] = 24.91487503 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [7] = { ["x"] = 461.95840454102, ["y"] = -993.647827148, ["z"] = 24.914875030 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [8] = { ["x"] = 461.90615844727, ["y"] = -998.29254150, ["z"] = 24.91487503 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [9] = { ["x"] = 461.7724609375, ["y"] = -1001.99768066, ["z"] = 24.9148750305 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    --jail doors
    [10] = { ["x"] = 1844.7203369141, ["y"] = 2608.3020019531, ["z"] = 45.588035583496 , ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [11] = { ["x"] = 1818.572265625, ["y"] = 2608.2299804688, ["z"] = 45.592163085938 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [12] = { ["x"] = 1795.8159179688, ["y"] = 2617.5134277344, ["z"] = 45.56498336792 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    -- sandy
    [13] = { ["x"] = 1855.1921386719, ["y"] = 3683.4545898438, ["z"] = 34.26749420166 , ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [14] = { ["x"] = 1846.2023925781, ["y"] = 3662.627929687, ["z"] = -116.78986358643 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [15] = { ["x"] = 1851.9909667969, ["y"] = 3665.7602539063, ["z"] = -116.78012084961 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [16] = { ["x"] = 1857.4644775391, ["y"] = 3669.0063476563, ["z"] = -116.78956604004 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [17] = { ["x"] = 1868.2186279297, ["y"] = 3674.5285644531, ["z"] = -116.7801361084 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [18] = { ["x"] = 1872.2174072266, ["y"] = 3676.7377929688, ["z"] = -116.77998352051 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    -- paleto office
    [19] = { ["x"] = -443.23126220703, ["y"] = 6015.7934570313, ["z"] = 31.716367721558 , ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [20] = { ["x"] = -444.05133056641, ["y"] = 6016.6479492188, ["z"] = 31.716367721558 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    --jail outer doors
    [21] = { ["x"] = 1831.2694091797, ["y"] = 2699.9138183594, ["z"] = 45.428318023682 , ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [22] = { ["x"] = 1812.2027587891, ["y"] = 2486.5739746094, ["z"] = 45.450214385986 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [23] = { ["x"] = 1809.537109375, ["y"] = 2477.837890625, ["z"] = 45.447677612305 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [24] = { ["x"] = 1759.3575439453, ["y"] = 2425.1088867188, ["z"] = 45.420440673828 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [25] = { ["x"] = 1752.7341308594, ["y"] = 2421.80078125, ["z"] = 45.420444488525 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [26] = { ["x"] = 1663.994140625, ["y"] = 2408.1733398438, ["z"] = 45.401222229004 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [27] = { ["x"] = 1657.2958984375, ["y"] = 2409.2045898438, ["z"] = 45.401203155518 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [28] = { ["x"] = 1556.2720947266, ["y"] = 2472.7768554688, ["z"] = 45.387180328369 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [29] = { ["x"] = 1553.3070068359, ["y"] = 2479.3220214844, ["z"] = 45.389339447021 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [30] = { ["x"] = 1547.3625488281, ["y"] = 2579.8903808594, ["z"] = 45.388778686523 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [31] = { ["x"] = 1547.7840576172, ["y"] = 2587.3059082031, ["z"] = 45.388725280762 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [32] = { ["x"] = 1577.9162597656, ["y"] = 2670.2790527344, ["z"] = 45.478248596191 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [33] = { ["x"] = 1582.7955322266, ["y"] = 2675.8718261719, ["z"] = 45.4811668396 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [34] = { ["x"] = 1652.0666503906, ["y"] = 2743.1545410156, ["z"] = 45.440773010254 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [35] = { ["x"] = 1658.6146240234, ["y"] = 2746.5207519531, ["z"] = 45.440727233887 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [36] = { ["x"] = 1765.6442871094, ["y"] = 2751.3068847656, ["z"] = 45.427284240723 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [37] = { ["x"] = 1772.5434570313, ["y"] = 2748.2758789063, ["z"] = 45.427417755127 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [38] = { ["x"] = 1833.8065185547, ["y"] = 2692.9055175781, ["z"] = 45.429954528809 , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    -- jail cells 1
    [39] =  { ['x'] = 1765.09,['y'] = 2497.75,['z'] = 50.43,['h'] = 37.03, ['info'] = ' cell1' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [40] =  { ['x'] = 1762.11,['y'] = 2496.34,['z'] = 50.43,['h'] = 117.34, ['info'] = ' cell2' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [41] =  { ['x'] = 1759.16,['y'] = 2494.27,['z'] = 50.43,['h'] = 98.7, ['info'] = ' cell3' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [42] =  { ['x'] = 1756.1,['y'] = 2492.79,['z'] = 50.43,['h'] = 123.69, ['info'] = ' cell4' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [43] =  { ['x'] = 1752.89,['y'] = 2491.03,['z'] = 50.43,['h'] = 242.9, ['info'] = ' cell5' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [44] =  { ['x'] = 1749.97,['y'] = 2489.42,['z'] = 50.43,['h'] = 196.34, ['info'] = ' cell6' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [45] =  { ['x'] = 1746.98,['y'] = 2487.55,['z'] = 50.43,['h'] = 214.95, ['info'] = ' cell7' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [46] =  { ['x'] = 1744.0,['y'] = 2485.71,['z'] = 50.43,['h'] = 50.17, ['info'] = ' cell8' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [47] =  { ['x'] = 1765.14,['y'] = 2497.76,['z'] = 45.83,['h'] = 356.58, ['info'] = ' cell9' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [48] =  { ['x'] = 1762.09,['y'] = 2495.92,['z'] = 45.83,['h'] = 16.81, ['info'] = ' cell10' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [49] =  { ['x'] = 1755.97,['y'] = 2492.56,['z'] = 45.82,['h'] = 46.32, ['info'] = ' cell11' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [50] =  { ['x'] = 1752.89,['y'] = 2490.99,['z'] = 45.82,['h'] = 213.6, ['info'] = ' cell12' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [51] =  { ['x'] = 1749.94,['y'] = 2489.07,['z'] = 45.82,['h'] = 331.05, ['info'] = ' cell13' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [52] =  { ['x'] = 1746.89,['y'] = 2487.49,['z'] = 45.82,['h'] = 54.1, ['info'] = ' cell14' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [53] =  { ['x'] = 1743.71,['y'] = 2485.66,['z'] = 45.82,['h'] = 211.12, ['info'] = ' cell15' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [54] =  { ['x'] = 1771.65,['y'] = 2484.21,['z'] = 50.43,['h'] = 236.52, ['info'] = ' cell16' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [55] =  { ['x'] = 1768.67,['y'] = 2482.77,['z'] = 50.43,['h'] = 198.08, ['info'] = ' cell17' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [56] =  { ['x'] = 1765.9,['y'] = 2480.46,['z'] = 50.43,['h'] = 30.75, ['info'] = ' cell18' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},

    -- jail connector gate
    [57] = { ["x"] = 1797.0574951172, ["y"] = 2596.65625, ["z"] = 45.674968719482, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    -- paleto cell rooms
    [58] = { ["x"] = 1681.9916992188, ["y"] = 2522.287109375, ["z"] = -120.84986877441, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [59] = { ["x"] = 1685.1719970703, ["y"] = 2522.3488769531, ["z"] = -120.8498916626, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [60] = { ["x"] = 1682.0576171875, ["y"] = 2514.810546875, ["z"] = -120.84047698975, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [61] = { ["x"] = 1688.2840576172, ["y"] = 2522.4572753906, ["z"] = -120.8498840332, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [62] = { ["x"] = 1691.4313964844, ["y"] = 2522.4057617188, ["z"] = -120.8498840332, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [63] = { ["x"] = 1694.453125, ["y"] = 2522.5625, ["z"] = -120.84987640381, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [64] = { ["x"] = 1694.373046875, ["y"] = 2514.8806152344, ["z"] = -120.84986877441, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [65] = { ["x"] = 1691.3768310547, ["y"] = 2514.7338867188, ["z"] = -120.84976196289, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [66] = { ["x"] = 1688.1711425781, ["y"] = 2514.7253417969, ["z"] = -120.8411026001, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [67] = { ["x"] = 1685.0921630859, ["y"] = 2514.8466796875, ["z"] = -120.84799957275, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    --police armory
    [68] = { ["x"] = 452.96487426758, ["y"] = -982.53363037109, ["z"] = 30.689598083496, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "v_ilev_arm_secdoor"},
    [69] = { ["x"] = 447.29840087891, ["y"] = -980.27178955078, ["z"] = 30.689607620239, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "v_ilev_shrf2door" },
    [70] = { ["x"] = 489.32452392578, ["y"] = -1017.5843505859, ["z"] = 28.044719696045, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },
    [71] = { ["x"] = 410.27792358398, ["y"] = -1027.7735595703, ["z"] = 29.39656829834, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    -- paleto Bank
    [72] = { ["x"] = -105.26515197754, ["y"] = 6473.158203125, ["z"] = 31.626722335815, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [73] = { ["x"] = -105.8353729248, ["y"] = 6475.4985351563, ["z"] = 31.626731872559, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    -- main bank
    [74] = { ["x"] = 256.98944091797, ["y"] = 220.38664245605, ["z"] = 106.28520202637, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [75] = { ["x"] = 265.85864257813, ["y"] = 217.75534057617, ["z"] = 110.28289794922, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [76] = { ["x"] = 262.02630615234, ["y"] = 221.7437286377, ["z"] = 106.28517913818, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [77] = { ["x"] = 252.43919372559, ["y"] = 220.7792816162, ["z"] = 101.68327331543, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [78] = { ["x"] = 261.56430053711, ["y"] = 215.07192993164, ["z"] = 101.68328857422, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
       -- Power Station
    [79] = { ["x"] = 735.46380615234, ["y"] = 133.14086914063, ["z"] = 80.747093200684, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [80] = { ["x"] = -6.6697192192078, ["y"] = -679.294921875, ["z"] = 16.130609512329, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [81] = { ["x"] = -3.5632178783417, ["y"] = -677.44299316406, ["z"] = 16.130609512329, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [82] = { ["x"] = 1.5718550682068, ["y"] = -679.27227783203, ["z"] = 16.130609512329, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [83] = { ["x"] = 3.6144170761108, ["y"] = -682.57989501953, ["z"] = 16.130609512329, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [84] = { ["x"] = -1.3165618181229, ["y"] = -671.81481933594, ["z"] = 16.130609512329, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [85] = { ["x"] = -2.6524605751038, ["y"] = -668.06042480469, ["z"] = 16.130611419678, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [86] = { ["x"] = -0.91495686769485, ["y"] = -662.41760253906, ["z"] = 16.130611419678, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [87] = { ["x"] = 9.7716875076294, ["y"] = -666.49841308594, ["z"] = 16.130611419678, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [88] = { ["x"] = 7.3052654266357, ["y"] = -672.68402099609, ["z"] = 16.130611419678, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [89] = { ["x"] = 4.0292530059814, ["y"] = -673.79479980469, ["z"] = 16.130611419678, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [90] = { ["x"] = -3.1030461788177, ["y"] = -684.98815917969, ["z"] = 16.130630493164, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [91] = { ["x"] = 2452.9575195313, ["y"] = -837.133239746099, ["z"] = -37.2665176391, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [92] = { ["x"] = 2453.5952148438, ["y"] = -832.03875732422, ["z"] = -37.26651763916, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [93] = { ["x"] = 2447.46557617197, ["y"] = -837.075866699229, ["z"] = -37.2665176391, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [94] = { ["x"] = 2458.049316406, ["y"] = -832.220092773, ["z"] = -37.26651000976, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [95] = { ["x"] = 2457.08984375, ["y"] = -831.457031259, ["z"] = -37.2665100097, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [96] = { ["x"] = 2046.6600341797, ["y"] = 2969.775390625, ["z"] = -67.301948547363, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [97] = { ["x"] = 2047.5411376953, ["y"] = 2970.952880859, ["z"] = -67.301948547363, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [98] = { ["x"] = 2060.086181640, ["y"] = 2977.69750976, ["z"] = -67.30183410644, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [99] = { ["x"] = 2060.78125, ["y"] = 2978.762207031, ["z"] = -67.301826477051, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [100] = { ["x"] = 2049.1655273430, ["y"] = 2971.9916992186, ["z"] = -61.901763916014, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [101] = { ["x"] = 2048.548339843, ["y"] = 2970.960937, ["z"] = -61.90176391601, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [102] = { ["x"] = 2060.8203125, ["y"] = 2984.1823730469, ["z"] = -67.301322937012, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [103] = { ["x"] = 2061.7375488281, ["y"] = 2983.3891601563, ["z"] = -67.301322937012, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [104] = { ["x"] = 2055.0881347656, ["y"] = 2981.1962890625, ["z"] = -67.301879882813, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [105] = { ["x"] = 2051.4184570313, ["y"] = 2975.39453125, ["z"] = -67.301849365234, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [106] = { ["x"] = 2055.0895996094, ["y"] = 2969.9526367188, ["z"] = -67.30184173584, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [107] = { ["x"] = 2050.9877929688, ["y"] = 2964.1806640625, ["z"] = -67.301849365234, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [108] = { ["x"] = 2051.2609863281, ["y"] = 2975.4206542969, ["z"] = -61.901748657227, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [109] = { ["x"] = 2056.6057128906, ["y"] = 2983.3688964844, ["z"] = -61.901760101318, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [110] = { ["x"] = 2060.779296875, ["y"] = 2984.2619628906, ["z"] = -61.901763916016, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [111] = { ["x"] = 2061.9997558594, ["y"] = 2983.7165527344, ["z"] = -61.901763916016, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [112] = { ["x"] = 2128.4526367188, ["y"] = 2925.5498046875, ["z"] = -61.90193939209, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [113] = { ["x"] = 2123.123535156, ["y"] = 2927.565917968, ["z"] = -61.90193939209, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [114] = { ["x"] = 128.1485748291, ["y"] = -1297.7568359375, ["z"] = 29.269529342651, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [115] = { ["x"] = 96.017646789551, ["y"] = -1285.9528808594, ["z"] = 29.26876258850, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [116] = { ["x"] = 113.38555145264, ["y"] = -1296.6597900394, ["z"] = 29.26876068115, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [117] = { ['x'] = 1703.42,['y'] = 2577.34,['z'] = -69.4, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [118] = { ['x'] = 1709.09,['y'] = 2571.46,['z'] = -69.42, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},

    [119] = { ['x'] = 1744.3,['y'] = 2646.93,['z'] = 48.11, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [120] = { ['x'] = 1744.3,['y'] = 2643.05,['z'] = 48.11, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [121] = { ['x'] = 1744.42,['y'] = 2629.05,['z'] = 48.11, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [122] = { ['x'] = 1740.46,['y'] = 2640.78,['z'] = 48.11, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [123] = { ['x'] = 1740.7,['y'] = 2632.78,['z'] = 48.11, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [124] = { ['x'] = 1740.7,['y'] = 2624.7,['z'] = 48.11, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    [125] = {['x'] = 1727.37,['y'] = 2643.2,['z'] = 45.61,['h'] = 177.75, ["cellnumber"] =  1 , ["lock"] = 0, ["distCheck"] = true, ["doorType"] = ""},
    [126] = {['x'] = 1730.44,['y'] = 2643.16,['z'] = 45.61,['h'] = 181.53, ["cellnumber"] =  2 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [127] = {['x'] = 1733.53,['y'] = 2643.06,['z'] = 45.61,['h'] = 182.5, ["cellnumber"] =  3 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [128] = {['x'] = 1736.69,['y'] = 2643.09,['z'] = 45.61,['h'] = 181.04, ["cellnumber"] =  4 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [129] = {['x'] = 1739.89,['y'] = 2643.06,['z'] = 45.61,['h'] = 175.19, ["cellnumber"] =  5 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [130] = {['x'] = 1742.88,['y'] = 2643.1,['z'] = 45.61,['h'] = 180.11, ["cellnumber"] =  6 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [131] = {['x'] = 1746.05,['y'] = 2642.82,['z'] = 45.61,['h'] = 194.73, ["cellnumber"] =  7 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [132] = {['x'] = 1727.37,['y'] = 2634.97,['z'] = 45.61,['h'] = 182.48, ["cellnumber"] =  8 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [133] = {['x'] = 1730.49,['y'] = 2635.0,['z'] = 45.61,['h'] = 185.23, ["cellnumber"] =  9 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [134] = {['x'] = 1733.69,['y'] = 2634.96,['z'] = 45.61,['h'] = 178.79, ["cellnumber"] =  10 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [135] = {['x'] = 1736.76,['y'] = 2634.74,['z'] = 45.61,['h'] = 200.01, ["cellnumber"] =  11 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [136] = {['x'] = 1739.86,['y'] = 2634.97,['z'] = 45.61,['h'] = 186.28, ["cellnumber"] =  12 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [137] = {['x'] = 1742.93,['y'] = 2634.89,['z'] = 45.61,['h'] = 183.38, ["cellnumber"] =  13 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [138] = {['x'] = 1745.94,['y'] = 2635.01,['z'] = 45.61,['h'] = 187.82, ["cellnumber"] =  14 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [139] = {['x'] = 1727.52,['y'] = 2626.94,['z'] = 45.61,['h'] = 179.67, ["cellnumber"] =  15 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [140] = {['x'] = 1730.63,['y'] = 2626.28,['z'] = 45.61,['h'] = 195.28, ["cellnumber"] =  16 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [141] = {['x'] = 1733.66,['y'] = 2626.89,['z'] = 45.61,['h'] = 184.08, ["cellnumber"] =  17 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [142] = {['x'] = 1736.79,['y'] = 2626.88,['z'] = 45.61,['h'] = 178.34, ["cellnumber"] =  18 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [143] = {['x'] = 1739.9,['y'] = 2627.02,['z'] = 45.61,['h'] = 179.24, ["cellnumber"] =  19 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [144] = {['x'] = 1742.95,['y'] = 2626.83,['z'] = 45.61,['h'] = 195.65, ["cellnumber"] =  20 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [145] = {['x'] = 1746.07,['y'] = 2626.92,['z'] = 45.61,['h'] = 180.52, ["cellnumber"] =  21 , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [146] =  { ['x'] = 718.85,['y'] = -976.14,['z'] = 24.91,['h'] = 354.85, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [147] =  { ['x'] = 717.42,['y'] = -976.1,['z'] = 24.91,['h'] = 355.66, ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },


    -- more PD things
    [148] =  { ['x'] = 462.68,['y'] = -989.16,['z'] = 24.92,['h'] = 11.83, ['info'] = ' Gate 1', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [149] =  { ['x'] = 462.53,['y'] = -989.84,['z'] = 24.92,['h'] = 348.53, ['info'] = ' Gate 2', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },
    [150] =  { ['x'] = 465.63,['y'] = -984.86,['z'] = 24.92,['h'] = 354.13, ['info'] = ' Wood door 1', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [151] =  { ['x'] = 466.97,['y'] = -983.9,['z'] = 24.92,['h'] = 320.9, ['info'] = ' Wood door 2', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },
    [152] =  { ['x'] = 472.69,['y'] = -983.79,['z'] = 24.92,['h'] = 141.27, ['info'] = 'Wood door 3', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },
    [153] =  { ['x'] = 482.9,['y'] = -983.81,['z'] = 24.23,['h'] = 168.71, ['info'] = 'flash interigation', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },
    [154] =  { ['x'] = 485.27,['y'] = -984.02,['z'] = 24.23,['h'] = 7.9, ['info'] = ' viewing', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },
    [155] =  { ['x'] = 489.17,['y'] = -985.5,['z'] = 24.23,['h'] = 98.03, ['info'] = ' woodDoor', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },


    [156] =  { ['x'] = 982.02,['y'] = -103.07,['z'] = 74.85,['h'] = 48.8, ['info'] = ' The Lost', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },

    [157] =  { ['x'] = 710.79,['y'] = -964.11,['z'] = 30.4,['h'] = 98.01, ['info'] = ' Carpet Extra 1', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },

    [158] =  { ['x'] = 710.57,['y'] = -961.39,['z'] = 30.4,['h'] = 80.24, ['info'] = ' Carpet Extra 2', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },
    [159] =  { ['x'] = 149.51,['y'] = -1047.09,['z'] = 29.35,['h'] = 144.22, ['info'] = 'Sqaure gate loc', ["lock"] = 0, ["distCheck"] = false, ["doorType"] = "" },

    [160] =  { ['x'] = 478.97,['y'] = -3116.39,['z'] = 6.08,['h'] = 180.66, ['info'] = ' Door 1', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""  },
    [161] =  { ['x'] = 488.38,['y'] = -3116.3,['z'] = 6.08,['h'] = 273.41, ['info'] = ' Door 2', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""  },

    [162] =  { ['x'] = 1008.14,['y'] = -3166.3,['z'] = -38.86,['h'] = 179.17, ['info'] = ' imports office', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [163] =  { ['x'] = 1004.75,['y'] = -3153.65,['z'] = -38.9,['h'] = 359.43, ['info'] = ' imports metting', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },

    [164] =  { ['x'] = 349.7,['y'] = -1028.7,['z'] = 29.3,['h'] = 359.43, ['info'] = ' The Apartment', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },

    [165] =  { ["x"] = 1839.358, ["y"] = 2559.477, ["z"] = 45.674968719482, ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},

    [166] =  { ['x'] = 1845.62,['y'] = 3683.13,['z'] = 34.28,['h'] = 294.84, ['info'] = ' cell 1' , ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [167] =  { ['x'] = 1842.63,['y'] = 3682.95,['z'] = 34.28,['h'] = 117.38, ['info'] = ' cell 2' , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [168] =  { ['x'] = 1841.14,['y'] = 3685.56,['z'] = 34.28,['h'] = 117.97, ['info'] = ' cell 3' , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [169] =  { ['x'] = 1844.13,['y'] = 3685.8,['z'] = 34.28,['h'] = 298.32, ['info'] = ' cell 4' , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    [170] =  { ['x'] = -434.33,['y'] = 6005.01,['z'] = 31.72,['h'] = 219.24, ['info'] = ' 5' , ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},

    -- even more PD shit
    [171] =  { ['x'] = 490.94,  ['y'] = -982.4,  ['z'] = 24.23,['h'] = 349.44,  ['info'] = ' lineup', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [172] =  { ['x'] = 466.86,  ['y'] = -994.46, ['z'] = 24.92,['h'] = 20.05,   ['info'] = ' officeDoor', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [173] =  { ['x'] = 473.0,   ['y'] = -994.45, ['z'] = 24.27,['h'] = 355.28,  ['info'] = ' connecteddoor', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [174] =  { ['x'] = 489.23,  ['y'] = -1005.31,['z'] = 24.27,['h'] = 93.0,    ['info'] = ' glasswood', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [175] =  { ['x'] = 486.72,  ['y'] = -1006.54,['z'] = 24.27,['h'] = 169.86,  ['info'] = ' interigation1', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [176] =  { ['x'] = 477.71,  ['y'] = -1006.71,['z'] = 24.27,['h'] = 183.86,  ['info'] = ' interigation2', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [177] =  { ['x'] = 481.91,  ['y'] = -1006.72,['z'] = 24.27,['h'] = 105.48,  ['info'] = ' viewing', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [178] =  { ['x'] = 479.54,  ['y'] = -987.33, ['z'] = 24.23,['h'] = 274.76,  ['info'] = ' cross', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},

    [179] =  { ['x'] = 483.22,  ['y'] = -988.76, ['z'] = 24.23,['h'] = 5.63,    ['info'] = ' gate1', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [180] =  { ['x'] = 475.53,  ['y'] = -988.59, ['z'] = 24.23,['h'] = 19.03,   ['info'] = ' gate2', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [181] =  { ['x'] = 482.45,  ['y'] = -997.64, ['z'] = 24.27,['h'] = 226.11,  ['info'] = ' gate3', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [182] =  { ['x'] = 482.61,  ['y'] = -996.58, ['z'] = 24.27,['h'] = 72.1,    ['info'] = ' gate4', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [183] =  { ['x'] = 478.04,  ['y'] = -1000.15,['z'] = 24.27,['h'] = 13.05,   ['info'] = ' gate5', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [184] =  { ['x'] = 472.5,   ['y'] = -1000.01,['z'] = 24.27,['h'] = 121.67,  ['info'] = ' gate6', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [185] =  { ['x'] = 467.26,  ['y'] = -1000.05,['z'] = 24.92,['h'] = 10.31,   ['info'] = ' gate7', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},

    [186] =  { ['x'] = 461.69,  ['y'] = -985.96, ['z'] = 30.69,['h'] = 96.4,    ['info'] = 'PD staircase',  ["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    -- Lost Clubhouse
    [187] =  { ['x'] = 104.22,  ['y'] = 3609.94, ['z'] = 40.35,['h'] = 94.82,   ['info'] = ' LostInsideL',  ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [188] =  { ['x'] = 103.95,  ['y'] = 3611.84, ['z'] = 40.28,['h'] = 80.52,   ['info'] = ' LostInsideR',  ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [189] =  { ['x'] = 90.28,   ['y'] = 3608.0,  ['z'] = 40.74,['h'] = 266.95,  ['info'] = ' LostFront',    ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },

    [190] =  { ['x'] = 300.68,['y'] = 203.17,['z'] = 104.38,['h'] = 341.11, ['info'] = ' ww1',  ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [191] =  { ['x'] = 302.16,['y'] = 202.56,['z'] = 104.37,['h'] = 342.87, ['info'] = ' ww2',    ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },

    [192] =  { ['x'] = 948.9346,  ['y'] = -964.55, ['z'] = 39.51,['h'] = 89.9,   ['info'] = ' TunerOfficeFront',  ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [193] =  { ['x'] = 954.3395,  ['y'] = -972.0, ['z'] = 39.51,['h'] = 198.2,   ['info'] = ' TunerOfficeRear',    ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },

     -- prison visitation
    [194] =  { ['x'] = 1843.68,['y'] = 2579.72,['z'] = 46.02,['h'] = 190.96, ['info'] = ' officedoor',    ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [195] =  { ['x'] = 1841.16,['y'] = 2593.99,['z'] = 46.02,['h'] = 92.65, ['info'] = ' air1',    ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [196] =  { ['x'] = 1833.73,['y'] = 2593.97,['z'] = 46.02,['h'] = 90.11, ['info'] = ' air2',   ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [197] =  { ['x'] = 1828.16,['y'] = 2592.93,['z'] = 46.02,['h'] = 83.47, ['info'] = ' back1',   ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },

    [198] =  { ['x'] = -632.36,['y'] = -236.92,['z'] = 38.05,['h'] = 306.14, ['info'] = ' 1', ["lock"] = 1, ["distCheck"] = true, ["doorType"] = "" },
    [199] =  { ['x'] = -631.06,['y'] = -238.68,['z'] = 38.11,['h'] = 298.21, ['info'] = ' 2', ["lock"] = 1, ["distCheck"] = false, ["doorType"] = "" },

    -- jail cells 2
    [200] =  { ['x'] = 1762.72,['y'] = 2479.1,['z'] = 50.43,['h'] = 212.66, ['info'] = ' cell19' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [201] =  { ['x'] = 1759.59,['y'] = 2477.42,['z'] = 50.42,['h'] = 213.5, ['info'] = ' cell20' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [202] =  { ['x'] = 1756.9,['y'] = 2475.67,['z'] = 50.42,['h'] = 184.0, ['info'] = ' cell21' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [203] =  { ['x'] = 1753.65,['y'] = 2474.0,['z'] = 50.42,['h'] = 209.05, ['info'] = ' cell22' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [204] =  { ['x'] = 1750.66,['y'] = 2472.15,['z'] = 50.42,['h'] = 203.92, ['info'] = ' cell23' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [205] =  { ['x'] = 1771.74,['y'] = 2484.32,['z'] = 45.82,['h'] = 182.57, ['info'] = ' cell24' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [206] =  { ['x'] = 1768.79,['y'] = 2482.63,['z'] = 45.82,['h'] = 186.96, ['info'] = ' cell25' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [207] =  { ['x'] = 1765.71,['y'] = 2480.85,['z'] = 45.82,['h'] = 215.83, ['info'] = ' cell26' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [208] =  { ['x'] = 1762.69,['y'] = 2479.03,['z'] = 45.82,['h'] = 215.3, ['info'] = ' cell27' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [209] =  { ['x'] = 1759.74,['y'] = 2477.4,['z'] = 45.82,['h'] = 209.69, ['info'] = ' cell28' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [210] =  { ['x'] = 1756.74,['y'] = 2475.52,['z'] = 45.82,['h'] = 303.21, ['info'] = ' cell29' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [211] =  { ['x'] = 1753.81,['y'] = 2473.91,['z'] = 45.82,['h'] = 161.48, ['info'] = ' cell30' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [212] =  { ['x'] = 1750.91,['y'] = 2471.91,['z'] = 45.82,['h'] = 208.37, ['info'] = ' cell31' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},

    [213] =  { ['x'] = 1758.87,['y'] = 2493.79,['z'] = 45.82,['h'] = 33.83, ['info'] = ' jailNormalEntry' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [214] =  { ['x'] = 1754.43,['y'] = 2501.34,['z'] = 45.96,['h'] = 32.67, ['info'] = ' jailNormalFront' , ["lock"] = 0, ["distCheck"] = false, ["doorType"] = ""},
    [215] =  { ['x'] = 1771.76,['y'] = 2493.68,['z'] = 50.43,['h'] = 137.2, ['info'] = ' jailGlassDoor1' , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [216] =  { ['x'] = 1772.57,['y'] = 2492.77,['z'] = 50.43,['h'] = 156.89, ['info'] = ' jailGlassDoor2' , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    [217] =  { ['x'] = 1780.89,['y'] = 2510.91,['z'] = 45.81,['h'] = 148.15, ['info'] = ' jailPoliceDoor1' , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [218] =  { ['x'] = 1780.24,['y'] = 2508.09,['z'] = 45.83,['h'] = 191.35, ['info'] = ' jailPoliceDoor2' , ["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    -- crime school
    [219] =  { ['x'] = -151.83,['y'] = 295.01,['z'] = 98.88,['h'] = 189.07, ['info'] = ' schoolmaindoor1' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [220] =  { ['x'] = -151.09,['y'] = 295.15,['z'] = 98.88,['h'] = 177.92, ['info'] = ' schoolmaindoor2' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    [221] =  { ['x'] = -160.29,['y'] = 317.09,['z'] = 98.88,['h'] = 263.01, ['info'] = ' schooldoor1' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [222] =  { ['x'] = -177.73,['y'] = 306.87,['z'] = 101.07,['h'] = 252.85, ['info'] = ' schooldoor2',["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
  

    [223] =  { ['x'] = -1879.45,['y'] = 2057.26,['z'] = 140.99,['h'] = 70.74, ['info'] = ' the cellar' ,["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [224] =  { ['x'] = -1883.62,['y'] = 2059.23,['z'] = 145.58,['h'] = 165.14, ['info'] = ' door 1' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [225] =  { ['x'] = -1885.69,['y'] = 2059.92,['z'] = 145.58,['h'] = 340.36, ['info'] = ' door 2' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [226] =  { ['x'] = 1776.54,['y'] = 2512.86,['z'] = 45.83, ['h'] = 340.36, ['info'] = ' door 2' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [227] =  { ['x'] = 1771.52,['y'] = 2506.6,['z'] = 45.83,['h'] = 31.51, ['info'] = ' inf door',["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},


    [228] =  { ['x'] = -1864.62,['y'] = 2061.15,['z'] = 140.98, ['h'] = 340.36, ['info'] = ' frd' ,["lock"] = 1, ["distCheck"] = true, ["doorType"] = ""},
    [229] =  { ['x'] = -1864.62,['y'] = 2059.94,['z'] = 140.98, ['h'] = 31.51, ['info'] = ' frd2',["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    [230] =  { ['x'] = -178.69,['y'] = 314.68,['z'] = 97.97,['h'] = 289.9, ['info'] = ' backDoorSchool1' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [231] =  { ['x'] = -178.62,['y'] = 313.81,['z'] = 97.98,['h'] = 259.19, ['info'] = ' backDoorSchool2' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [232] =  { ['x'] = -171.85,['y'] = 319.05,['z'] = 93.76,['h'] = 115.77, ['info'] = ' schoolLower1',["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [233] =  { ['x'] = -177.44,['y'] = 306.81,['z'] = 97.41,['h'] = 352.68, ['info'] = ' schoolLower2' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [234] =  { ['x'] = -161.04,['y'] = 328.23,['z'] = 93.77,['h'] = 264.59, ['info'] = ' schoolLower3' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [235] =  { ['x'] = -160.88,['y'] = 334.12,['z'] = 93.77,['h'] = 189.95, ['info'] = ' schoolLower4' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [236] =  { ['x'] = -166.61,['y'] = 327.96,['z'] = 93.76,['h'] = 293.73, ['info'] = ' schoolLower5' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [237] =  { ['x'] = -166.64,['y'] = 334.12,['z'] = 93.77,['h'] = 176.69, ['info'] = ' schoolLower6' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [238] =  { ['x'] = -172.17,['y'] = 334.22,['z'] = 93.76,['h'] = 155.18, ['info'] = ' schoolLower7' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},
    [239] =  { ['x'] = -171.94,['y'] = 328.02,['z'] = 93.76,['h'] = 43.54, ['info'] = ' schoolLower8' ,["lock"] = 1, ["distCheck"] = false, ["doorType"] = ""},

    [240] =  { ['x'] = 17.58,['y'] = -2532.28,['z'] = 6.06,['h'] = 232.63, ['info'] = ' drift gate1', ['lock'] = 1, ['distCheck'] = true, ['doorType'] = ""},
    [241] =  { ['x'] = 12.21,['y'] = -2539.58,['z'] = 6.06,['h'] = 234.27, ['info'] = ' drift gate2', ['lock'] = 1, ['distCheck'] = true, ['doorType'] = ""},
    [242] =  { ['x'] = -190.63,['y'] = -2515.28,['z'] = 6.05,['h'] = 180.93, ['info'] = ' drift gate3', ['lock'] = 1, ['distCheck'] = true, ['doorType'] = ""},
    [243] =  { ['x'] = -199.49,['y'] = -2515.54,['z'] = 6.05,['h'] = 179.09, ['info'] = ' drift gate4', ['lock'] = 1, ['distCheck'] = true, ['doorType'] = ""},
    [244] =  { ['x'] = -62.5,['y'] = -2519.62,['z'] = 7.41,['h'] = 231.25, ['info'] = ' drift officedoor', ['lock'] = 1, ['distCheck'] = false, ['doorType'] = ""},

}
