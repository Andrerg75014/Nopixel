local fixingvehicle = false
local justUsed = false
local retardCounter = 0




Citizen.CreateThread(function()

    
    TriggerServerEvent("inv:playerSpawned");
end)

RegisterNetEvent('inventory-jail')
AddEventHandler('inventory-jail', function(startPosition, cid, name)
    print("hey")
    if (hasEnoughOfItem("okaylockpick",1,false)) then

        TriggerServerEvent("server-inventory-open", startPosition, cid, "1", name);
    end
end)


RegisterNetEvent('RunUseItem')
AddEventHandler('RunUseItem', function(itemid, slot, inventoryName, isWeapon)

    if justUsed then
        retardCounter = retardCounter + 1
        if retardCounter > 10 then
            TriggerServerEvent("exploiter", "Tried using " .. retardCounter .. " items in < 500ms ")
        end
        return
    end

    justUsed = true

    if (not hasEnoughOfItem(itemid,1,false)) then
        TriggerEvent("DoLongHudText","You dont appear to have this item on you?",2) 
        justUsed = false
        retardCounter = 0
        return
    end

    if (itemid == nil) then
        justUsed = false
        retardCounter = 0
        return
    end

    TriggerEvent("hud-display-item",itemid,"Used")
    if (isWeapon) then
        Wait(200)
        local ItemInfo = GetItemInfo(slot)
        local jsonInformation = json.decode(ItemInfo.information)
        if jsonInformation.quality ~= "Broken" then
            TriggerEvent("equipWeaponID",itemid,ItemInfo.information,ItemInfo.id)
        else
            TriggerEvent("DoLongHudText","Weapon is Broken",2) 
            TriggerEvent("brokenWeapon")
        end

        justUsed = false
        retardCounter = 0
        return
    end

    Wait(800)


    if (not IsPedInAnyVehicle(PlayerPedId())) then
        if (itemid == "Suitcase") then
            TriggerEvent('attach:suitcase')
        end

        if (itemid == "Boombox") then
                TriggerEvent('attach:boombox')
        end
        if (itemid == "Box") then
                TriggerEvent('attach:box')
        end
        if (itemid == "DuffelBag") then
                TriggerEvent('attach:blackDuffelBag')
        end
        if (itemid == "MedicalBag") then
                TriggerEvent('attach:medicalBag')
        end
        if (itemid == "SecurityCase") then
                TriggerEvent('attach:securityCase')
        end
        if (itemid == "Toolbox") then
                TriggerEvent('attach:toolbox')
        end
    end



    local remove = false
    local drugitem = false
    local fooditem = false
    local drinkitem = false
    local healitem = false

    if (itemid == "joint" or itemid == "weed5oz" or itemid == "weedq" or itemid == "weed12oz" or itemid == "beer" or itemid == "vodka" or itemid == "whiskey") then
        drugitem = true
    end

    if (itemid == "fakeplate") then
      TriggerEvent("fakeplate:change")
    end

    if (itemid == "tuner") then

      local finished = exports["np-taskbar"]:taskBar(2000,"Connecting Tuner Laptop")
      if (finished == 100) then
        TriggerEvent("tuner:open")
      end
    end

    if (itemid == "electronickit" or itemid == "lockpick") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
      
    end
    if (itemid == "locksystem") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "thermite") then
      TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if(itemid == "evidencebag") then
        
        TriggerEvent("evidence:startCollect", itemid, slot)
        local itemInfo = GetItemInfo(slot)
        local data = itemInfo.information
        if data == '{}' then
            TriggerEvent("DoLongHudText","Start collecting evidence!",1) 
            TriggerEvent("inventory:updateItem", itemid, slot, '{"used": "true"}')
            --
        else
            local dataDecoded = json.decode(data)
            if(dataDecoded.used) then
                print('YOURE ALREADY COLLECTING EVIDENCE YOU STUPID FUCK')
            end
        end
    end


    if (itemid == "decryptersess" or itemid == "decrypterfv2" or itemid == "decrypterenzo") then
      if (#(GetEntityCoords(PlayerPedId()) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data")
          if (finished == 100) then
            TriggerEvent("pixerium:check",3,"robbery:decrypt",true)
          end
      end

      if #(GetEntityCoords(PlayerPedId()) - vector3( 2328.94, 2571.4, 46.71)) < 3.0 then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data")
          if finished == 100 then
            TriggerEvent("pixerium:check",3,"robbery:decrypt2",true)
          end
      end

      if #(GetEntityCoords(PlayerPedId()) - vector3( 1208.73,-3115.29, 5.55)) < 3.0 then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data")
          if finished == 100 then
            TriggerEvent("pixerium:check",3,"robbery:decrypt3",true)
          end
      end
      
    end

    if (itemid == "pix1") then
      if (#(GetEntityCoords(PlayerPedId()) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data")
          if (finished == 100) then
            TriggerEvent("Crypto:GivePixerium",math.random(1,2))
            remove = true
          end
      end
    end  

    if (itemid == "pix2") then
      if (#(GetEntityCoords(PlayerPedId()) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
          local finished = exports["np-taskbar"]:taskBar(25000,"Decrypting Data")
          if (finished == 100) then
            TriggerEvent("Crypto:GivePixerium",math.random(5,12))
            remove = true
          end
      end
    end


    if (itemid == "femaleseed") then
       TriggerEvent("Evidence:StateSet",4,1600)
       TriggerEvent("weed:startcropInsideCheck","female")
       
    end

    if (itemid == "maleseed") then
        TriggerEvent("Evidence:StateSet",4,1600)
        TriggerEvent("weed:startcropInsideCheck","male")
        
    end

    if (itemid == "weedoz") then
 
      local finished = exports["np-taskbar"]:taskBar(5000,"Packing Q Bags")
        if (finished == 100) then
            CreateCraftOption("weedq", 40, true)
        end
        
    end

    if (itemid == "weedq") then
        local finished = exports["np-taskbar"]:taskBar(1000,"Rolling Joints")
        if (finished == 100) then
            CreateCraftOption("joint", 80, true)    
        end
        
    end

    if (itemid == "lighter") then
        TriggerEvent("animation:PlayAnimation","lighter")
          local finished = exports["np-taskbar"]:taskBar(2000,"Starting Fire")
        if (finished == 100) then
            
        end
        
    end

    if (itemid == "joint") then
        local finished = exports["np-taskbar"]:taskBar(2000,"Smoking Joint")
        if (finished == 100) then
            Wait(200)
            TriggerEvent("animation:PlayAnimation","weed")
            TriggerEvent("Evidence:StateSet",3,600)
            TriggerEvent("Evidence:StateSet",4,600)        
            TriggerEvent("stress:timed",1000,"WORLD_HUMAN_SMOKING_POT")
            remove = true
        end
    end

    if (itemid == "vodka" or itemid == "beer" or itemid == "whiskey") then
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"Drink","changethirst",true,itemid)
        TriggerEvent("Evidence:StateSet",8, 600)
    end

    if (itemid == "coffee") then
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"Drink","coffee:drink",true,itemid)
    end

    if (itemid == "fishtaco") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:FishTaco",true,itemid)
    end

    if (itemid == "taco" or itemid == "burrito") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:Taco",true,itemid)
    end

    if (itemid == "churro" or itemid == "hotdog") then
        TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:Condiment",true,itemid)
    end

    if (itemid == "greencow") then
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"Drink","food:Condiment",true,itemid)
    end

    if (itemid == "donut" or itemid == "eggsbacon") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:Condiment",true,itemid)
    end

    if (itemid == "icecream" or itemid == "mshake") then
        TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","food:IceCream",true,itemid)
    end



    if (itemid == "advlockpick") then
             
        local myJob = exports["isPed"]:isPed("myJob")
        if myJob ~= "news" then
            TriggerEvent('inv:advancedLockpick',inventoryName,slot)
        else
            TriggerEvent("DoLongHudText","Nice news reporting, you shit lord idiot.")
        end   

    end


    if (itemid == "Gruppe6Card") then

        local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
        local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 100.0, 0.0)
        local targetVehicle = getVehicleInDirection(coordA, coordB)
        if targetVehicle ~= 0 and GetHashKey("stockade") == GetEntityModel(targetVehicle) then
            local entityCreatePoint = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0, -4.0, 0.0)
            local coords = GetEntityCoords(GetPlayerPed(-1))
            local aDist = GetDistanceBetweenCoords(coords["x"], coords["y"],coords["z"], entityCreatePoint["x"], entityCreatePoint["y"],entityCreatePoint["z"])
            if aDist < 2.0 then
                TriggerEvent("civilian:alertPolice",35.0,"robbery",0)
                local finished = exports["np-taskbar"]:taskBar(45000,"Unlocking Vehicle")
                if finished == 100 then
                    TriggerEvent("sec:AttemptHeist", targetVehicle)
                else
                    TriggerEvent("evidence:bleeding")
                end
                remove = true
            else
                TriggerEvent("DoLongHudText","You need to do this from behind the vehicle.")
            end
        end

    end


    if (itemid == "usbdevice") then
        local finished = exports["np-taskbar"]:taskBar(15000,"Scanning For Networks")
        if (finished == 100) then
            TriggerEvent("hacking:attemptHack")
        end
        
    end

    if (itemid == "weed12oz") then
        TriggerEvent("inv:weedPacking")
        remove = true
    end

    if (itemid == "heavyammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading")
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1788949567,50,true)
            remove = true
        end
    end

    if (itemid == "pistolammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading")
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1950175060,50,true)
            remove = true
        end
    end

    if (itemid == "rifleammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading")
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",218444191,50,true)
            remove = true
        end
    end

    if (itemid == "shotgunammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading")
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",-1878508229,50,true)
            remove = true
        end
    end

    if (itemid == "subammo") then
        local finished = exports["np-taskbar"]:taskBar(5000,"Reloading")
        if (finished == 100) then
            TriggerEvent("actionbar:ammo",1820140472,50,true)
            remove = true
        end
    end


    if (itemid == "armor") then
        local finished = exports["np-taskbar"]:taskBar(10000,"Armor",true)
        if (finished == 100) then
            SetPlayerMaxArmour(PlayerId(), 60 )
            SetPedArmour( PlayerPedId(), 60 )
            TriggerEvent("UseBodyArmor")
            remove = true
        end
    end

    if (itemid == "binoculars") then 
        TriggerEvent("binoculars:Activate")
        
    end

    if (itemid == "camera") then
        TriggerEvent("camera:Activate")
    end

    if (itemid == "nitrous") then
        local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if (GetVehicleMod(currentVehicle,11) == -1) then
            TriggerEvent("DoLongHudText","You need a Turbo to use NOS!",2) 
        end  
        local finished = exports["np-taskbar"]:taskBar(20000,"Nitrous")
        if (finished == 100) then
            TriggerEvent("NosStatus")
            remove = true
        end
    end

    if (itemid == "lockpick") then

        local myJob = exports["isPed"]:isPed("myJob")
        print(myJob)
        if myJob ~= "news" then
            TriggerEvent("inv:lockPick",false,inventoryName,slot)

        else
            TriggerEvent("DoLongHudText","Nice news reporting, you shit lord idiot.")
        end       
        
    end

    if (itemid == "umbrella") then
        TriggerEvent("animation:PlayAnimation","umbrella")
        
    end

    if (itemid == "repairkit") then
      TriggerEvent('veh:repairing',inventoryName,slot,itemid)
           
    end

    if (itemid =="advrepairkit") then
      TriggerEvent('veh:repairing',inventoryName,slot,itemid)
           
    end
    if (itemid == "securityblue" or itemid == "securityblack" or itemid == "securitygreen" or itemid == "securitygold" or itemid == "securityred")  then
        TriggerEvent("robbery:scanLock",false,itemid)       
    end

    if (itemid == "Gruppe6Card2")  then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "Gruppe6Card22")  then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end    

    if (itemid == "ciggy") then
        local finished = exports["np-taskbar"]:taskBar(1000,"Lighting Up")
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","smoke")
            remove = true
        end
    end

    if (itemid == "cigar") then
        local finished = exports["np-taskbar"]:taskBar(1000,"Lighting Up")
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","cigar")
            remove = true
        end
    end

    if (itemid == "oxygentank") then
        local finished = exports["np-taskbar"]:taskBar(30000,"Oxygen Tank",true)
        if (finished == 100) then        
            TriggerEvent("UseOxygenTank")
            remove = true
        end
    end

    if (itemid == "bandage") then
        TaskItem("amb@world_human_clipboard@male@idle_a", "idle_c", 49,10000,"Healing","healed:minors",true,itemid)
    end

    if (itemid == "coke50g") then
        CreateCraftOption("coke5g", 80, true)
        
    end

    if (itemid == "bakingsoda") then 
        CreateCraftOption("1gcrack", 80, true)
    end

    if (itemid == "glucose") then 
        CreateCraftOption("1gcocaine", 80, true)
        
    end

    if (itemid == "idcard") then 
        local ItemInfo = GetItemInfo(slot)
        TriggerServerEvent("police:showID",ItemInfo.information)   
    end

    if (itemid == "drivingtest") then 
        local ItemInfo = GetItemInfo(slot)
        if (ItemInfo.information ~= "No information stored") then
            local data = json.decode(ItemInfo.information)
            TriggerServerEvent("driving:getResults", data.ID)
        end
    end

    if (itemid == "1gcocaine") then
        TriggerEvent("attachItemObjectnoanim","drugpackage01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("anim@amb@nightclub@peds@", "missfbi3_party_snort_coke_b_male3", 49, 5000, "Coke Gaming", "hadcocaine", true,itemid)
    end

    if (itemid == "1gcrack") then 
        TriggerEvent("attachItemObjectnoanim","crackpipe01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 5000, "Smoking Quack", "hadcrack", true,itemid)
    end

    if (itemid == "treat") then
        local model = GetEntityModel(PlayerPedId())
        if model == GetHashKey("a_c_chop") then
            TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 1200, "Treat Num's", "hadtreat", true,itemid)
        end
    end

    if (itemid == "IFAK") then
        TaskItem("amb@world_human_clipboard@male@idle_a", "idle_c", 49,10000,"Applying IFAK","healed:useOxy",true,itemid)
        remove = true
    end


    if (itemid == "oxy") then
        TriggerEvent("animation:PlayAnimation","pill")
        TriggerEvent("useOxy")
        TriggerEvent("healed:useOxy")
        remove = true
    end

    if (itemid == "sandwich" or itemid == "hamburger") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","changehunger",true,itemid)
    end

    if (itemid == "cola" or itemid == "water") then
        --attachPropsToAnimation(itemid, 6000)
        --TaskItem("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"Drink","changethirst",true,itemid)
        AttachPropAndPlayAnimation("amb@world_human_drinking@coffee@male@idle_a", "idle_c", 49,6000,"Drink","changethirst",true,itemid)
    end


    if (itemid == "slushy" or itemid == "jailfood" or itemid == "bleederburger" or itemid == "heartstopper" or itemid == "torpedo" or itemid == "meatfree" or itemid == "moneyshot" or itemid == "fries") then
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49,6000,"Eating","inv:wellfed",true,itemid)
        --attachPropsToAnimation(itemid, 6000)
        --TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 6000, "Eating", "inv:wellfed", true,itemid)
    end

    if (itemid == "methbag") then
        TriggerEvent("attachItemObjectnoanim","crackpipe01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 5000, "💩 Smoking Ass Meth 💩", "hadcocaine", true, itemid)
        remove = true
    end
    if itemid == "slushy" then
        --attachPropsToAnimation(itemid, 6000)
        TriggerEvent("healed:useOxy")
        --TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 6000, "Eating", "inv:wellfed", true,itemid)
        AttachPropAndPlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 6000, "Eating", "inv:wellfed", true,itemid)

    end

    if (itemid == "shitlockpick") then
        lockpicking = true
        TriggerEvent("animation:lockpickinvtestoutside") 
        local finished = exports["np-taskbar"]:taskBar(15000,"Doing the unimaginable",true)
        if (finished == 100) then    
            TriggerEvent("police:uncuffMenu")
        end
        lockpicking = false
        remove = true
    end

    if (itemid == "watch") then
        TriggerEvent("carHud:compass")
    end

    if remove then
        TriggerEvent("inventory:removeItem",itemid, 1)
    end

    Wait(500)
    retardCounter = 0
    justUsed = false


end)

function AttachPropAndPlayAnimation(dictionary,animation,typeAnim,timer,message,func,remove,itemid)
    if itemid == "hamburger" or itemid == "heartstopper" or itemid == "bleederburger" then
        TriggerEvent("attachItem", "hamburger")
    elseif itemid == "sandwich" then
        TriggerEvent("attachItem", "sandwich")
    elseif itemid == "donut" then
        TriggerEvent("attachItem", "donut")
    elseif itemid == "water" or itemid == "cola" or itemid == "vodka" or itemid == "whiskey" or itemid == "beer" or itemid == "coffee" then
        TriggerEvent("attachItem", itemid)
    elseif itemid == "fishtaco" or itemid == "taco" then
        TriggerEvent("attachItem", "taco")
    elseif itemid == "greencow" then
        TriggerEvent("attachItem", "energydrink")
    end
    TaskItem(dictionary, animation, typeAnim, timer, message, func, remove, itemid)
    TriggerEvent("destroyProp")
end

RegisterNetEvent('randPickupAnim')
AddEventHandler('randPickupAnim', function()
    loadAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low',5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end)



local clientInventory = {};
RegisterNetEvent('current-items')
AddEventHandler('current-items', function(inv)
    clientInventory = inv
end)



RegisterNetEvent('SniffRequestCID')
AddEventHandler('SniffRequestCID', function(src)
    local cid = exports["isPed"]:isPed("cid")
    TriggerServerEvent("SniffCID",cid,src)
end)



function GetItemInfo(checkslot)
    for i,v in pairs(clientInventory) do
        if (tonumber(v.slot) == tonumber(checkslot)) then
            local info = {["information"] = v.information,["id"] = v.id }
            return info
        end
    end
    return "No information stored";
end

-- item id, amount allowed, crafting.
function CreateCraftOption(id, add, craft)
    TriggerEvent("CreateCraftOption", id, add, craft)
end

-- Animations
function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

function TaskItem(dictionary,animation,typeAnim,timer,message,func,remove,itemid)
    loadAnimDict( dictionary ) 
    TaskPlayAnim( PlayerPedId(), dictionary, animation, 8.0, 1.0, -1, typeAnim, 0, 0, 0, 0 )
    local timer = tonumber(timer)
    if timer > 0 then
        local finished = exports["np-taskbar"]:taskBar(timer,message,true)
        if finished == 100 or timer == 0 then
            TriggerEvent(func)
        end
    else
        TriggerEvent(func)
    end

    if remove then
        TriggerEvent("inventory:removeItem",itemid, 1)
    end
end



function GetCurrentWeapons()
    local returnTable = {}
    for i,v in pairs(clientInventory) do
        if (tonumber(v.item_id)) then
            local t = { ["hash"] = v.item_id, ["id"] = v.id, ["information"] = v.information, ["name"] = v.item_id, ["slot"] = v.slot }
            returnTable[#returnTable+1]=t
        end
    end   
    if returnTable == nil then 
        return {}
    end
    return returnTable
end

function getQuantity(itemid)
    local amount = 0
    for i,v in pairs(clientInventory) do
        if (v.item_id == itemid) then
            amount = amount + v.amount
        end
    end
    return amount
end

function hasEnoughOfItem(itemid,amount,shouldReturnText)
    if shouldReturnText == nil then shouldReturnText = true end
    if itemid == nil or itemid == 0 or amount == nil or amount == 0 then if shouldReturnText then TriggerEvent("DoLongHudText","I dont seem to have " .. itemid .. " in my pockets.",2) end return false end
    amount = tonumber(amount)
    local slot = 0
    local found = false

    if getQuantity(itemid) >= amount then
        return true
    end
    if (shouldReturnText) then
        TriggerEvent("DoLongHudText","I dont have enough of that item...",2) 
    end    
    return false
end































-- DNA



RegisterNetEvent('evidence:addDnaSwab')
AddEventHandler('evidence:addDnaSwab', function(dna)
    TriggerEvent("DoLongHudText", "DNA Result: " .. dna,1)    
end)

RegisterNetEvent('CheckDNA')
AddEventHandler('CheckDNA', function()
    TriggerServerEvent("Evidence:checkDna")
end)

RegisterNetEvent('evidence:dnaSwab')
AddEventHandler('evidence:dnaSwab', function()
    t, distance = GetClosestPlayer()
    if(distance ~= -1 and distance < 5) then
        TriggerServerEvent("police:dnaAsk", GetPlayerServerId(t))
    end
end)

RegisterNetEvent('evidence:swabNotify')
AddEventHandler('evidence:swabNotify', function()
    TriggerEvent("DoLongHudText", "DNA swab taken.",1)
end)


function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end


-- DNA AND EVIDENCE END
























-- this is the upside down world, be careful.


function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)   
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    
    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end
function DrawText3Ds(x,y,z, text)
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

local burgies = 0
RegisterNetEvent('inv:wellfed')
AddEventHandler('inv:wellfed', function()
    TriggerEvent("Evidence:StateSet",25,3600)
    TriggerEvent("changehunger")
    TriggerEvent("changehunger")
    TriggerEvent("client:newStress",false,10)
    TriggerEvent("changehunger")
    TriggerEvent("changethirst")
    burgies = 0
end)


RegisterNetEvent('animation:lockpickinvtestoutside')
AddEventHandler('animation:lockpickinvtestoutside', function()
    local lPed = PlayerPedId()
    RequestAnimDict("veh@break_in@0h@p_m_one@")
    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
        Citizen.Wait(0)
    end
    
    while lockpicking do
        
        Citizen.Wait(2500)
        TaskPlayAnim(lPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 16, 0.0, 0, 0, 0)
    end
    ClearPedTasks(lPed)
end)

RegisterNetEvent('animation:lockpickinvtest')
AddEventHandler('animation:lockpickinvtest', function(disable)
    local lPed = PlayerPedId()
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end
    if disable ~= nil then
        if not disable then
            lockpicking = false
            return
        else
            lockpicking = true
        end
    end
    while lockpicking do

        if not IsEntityPlayingAnim(lPed, "mini@repair", "fixing_a_player", 3) then
            ClearPedSecondaryTask(lPed)
            TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    ClearPedTasks(lPed)
end)



RegisterNetEvent('inv:lockPick')
AddEventHandler('inv:lockPick', function(isForced,inventoryName,slot)
    TriggerEvent("robbery:scanLock",true)
    if lockpicking then return end

    lockpicking = true
    playerped = PlayerPedId()
    targetVehicle = GetVehiclePedIsUsing(playerped)
    local itemid = 21

    if targetVehicle == 0 then
        coordA = GetEntityCoords(playerped, 1)
        coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
        targetVehicle = getVehicleInDirection(coordA, coordB)
        local driverPed = GetPedInVehicleSeat(targetVehicle, -1)
        if targetVehicle == 0 then
            lockpicking = false
            TriggerEvent("robbery:lockpickhouse",isForced)
            return
        end

        if driverPed ~= 0 then
            lockpicking = false
            return
        end
            local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
            local leftfront = GetOffsetFromEntityInWorldCoords(targetVehicle, d1["x"]-0.25,0.25,0.0)

            local count = 5000
            local dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
            while dist > 2.0 and count > 0 do
                dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
                Citizen.Wait(1)
                count = count - 1
                DrawText3Ds(leftfront["x"],leftfront["y"],leftfront["z"],"Move here to lockpick.")
            end

            if dist > 2.0 then
                lockpicking = false
                return
            end


            TaskTurnPedToFaceEntity(PlayerPedId(), targetVehicle, 1.0)
            Citizen.Wait(1000)
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)
            local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
            if triggerAlarm then
                SetVehicleAlarm(targetVehicle, true)
                StartVehicleAlarm(targetVehicle)
            end


            TriggerEvent("civilian:alertPolice",20.0,"lockpick",targetVehicle)
           
            TriggerEvent("animation:lockpickinvtestoutside")
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)

           
            local carTimer = GetVehicleHandlingFloat(targetVehicle, 'CHandlingData', 'nMonetaryValue')

            if carTimer == nil then
                carTimer = math.random(25000,180000)
            end

            if carTimer < 25000 then
                carTimer = 25000
            end

            if carTimer > 180000 then
                carTimer = 180000
            end

            carTimer = math.ceil(carTimer / 3)

            local finished = exports["np-taskbar"]:taskBar(carTimer,"Lockpicking")

            if finished ~= 100 then
                 lockpicking = false
                return
            end

            if finished == 100 then
                if triggerAlarm then
                    SetVehicleAlarm(targetVehicle, false)
                end
                local chance = math.random(50)
                if #(GetEntityCoords(targetVehicle) - GetEntityCoords(PlayerPedId())) < 10.0 and targetVehicle ~= 0 and GetEntitySpeed(targetVehicle) < 5.0 then
                    if chance > 8 then
                        SetVehicleDoorsLocked(targetVehicle, 1)
                        TriggerEvent("DoLongHudText", "Vehicle Unlocked.",1)
                        TriggerEvent('InteractSound_CL:PlayOnOne', 'unlock', 0.1)
                    else
                        TriggerEvent("DoLongHudText", "Failed.",2)
                    end

                    if not isForced and math.random(12) < 3 then
                        TriggerEvent("DoLongHudText", "The lockpick bent out of shape.",2)
                        TriggerEvent("inventory:removeItem","lockpick", 1)
                    end

                end
            end
        lockpicking = false
    else
        if targetVehicle ~= 0 and not isForced then

            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)
            local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
            if triggerAlarm then
                SetVehicleAlarm(targetVehicle, true)
                StartVehicleAlarm(targetVehicle)
            end

            SetVehicleHasBeenOwnedByPlayer(targetVehicle,true)
            TriggerEvent("civilian:alertPolice",12.0,"lockpick",targetVehicle)
           
            TriggerEvent("animation:lockpickinvtest")
            TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)

           
            local carTimer = GetVehicleHandlingFloat(targetVehicle, 'CHandlingData', 'nMonetaryValue')
            if carTimer == nil then
                carTimer = math.random(25000,180000)
            end
            if carTimer < 25000 then
                carTimer = 25000
            end

            if carTimer > 180000 then
                carTimer = 180000
            end
            
            carTimer = math.ceil(carTimer / 3)


            local myJob = exports["isPed"]:isPed("myJob")
            if myjob == "towtruck" then
                carTimer = 4000
            end

            local finished = exports["np-taskbar"]:taskBar(carTimer,"Modifying Ignition Stage 1",false,false,targetVehicle)
            if finished ~= 100 then
                 lockpicking = false
                return
            end

            Citizen.Wait(500)
            TriggerEvent("civilian:alertPolice",12.0,"lockpick",targetVehicle)

            local finished = exports["np-taskbar"]:taskBar(carTimer,"Modifying Ignition Stage 2",false,false,targetVehicle)
            if finished ~= 100 then
                 lockpicking = false
                return
            end

            Citizen.Wait(500)
            TriggerEvent("civilian:alertPolice",12.0,"lockpick",targetVehicle)
            local finished = exports["np-taskbar"]:taskBar(carTimer,"Modifying Ignition Stage 3",false,false,targetVehicle)
            if finished ~= 100 then
                 lockpicking = false
                return
            end     


            Citizen.Wait(500)
            if finished == 100 then
                if triggerAlarm then
                    SetVehicleAlarm(targetVehicle, false)
                end
                local chance = math.random(50)
                if #(GetEntityCoords(targetVehicle) - GetEntityCoords(PlayerPedId())) < 10.0 and targetVehicle ~= 0 and GetEntitySpeed(targetVehicle) < 5.0 then

                    local plate = GetVehicleNumberPlateText(targetVehicle)
                    SetVehicleDoorsLocked(targetVehicle, 1)
                    TriggerEvent("keys:addNew",targetVehicle,plate)
                    TriggerEvent("DoLongHudText", "Ignition Working.",1)
                    SetEntityAsMissionEntity(targetVehicle,false,true)
                    SetVehicleHasBeenOwnedByPlayer(targetVehicle,true)
                    TriggerEvent("chop:plateoff",plate)


                    if not isForced and math.random(12) < 3 and myjob == "towtruck" then
                        TriggerEvent("DoLongHudText", "The lockpick bent out of shape.",2)
                        TriggerEvent("inventory:removeItem","lockpick", 1)
                    end
                    
                end
                lockpicking = false
            end
        end
    end
    lockpicking = false
end)

local reapiring = false
RegisterNetEvent('veh:repairing')
AddEventHandler('veh:repairing', function(inventoryName,slot,itemid)
    local playerped = PlayerPedId()
    local coordA = GetEntityCoords(playerped, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
    local targetVehicle = getVehicleInDirection(coordA, coordB)

    local advanced = false
    if itemid == "advrepairkit" then
        advanced = true
    end

    if targetVehicle ~= 0 then

        local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
        local moveto = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0,d2["y"]+0.5,0.0)
        local dist = #(vector3(moveto["x"],moveto["y"],moveto["z"]) - GetEntityCoords(PlayerPedId()))
        local count = 1000

        while dist > 1.0 and count > 0 do
            dist = #(vector3(moveto["x"],moveto["y"],moveto["z"]) - GetEntityCoords(PlayerPedId()))
            Citizen.Wait(1)
            count = count - 1
            DrawText3Ds(moveto["x"],moveto["y"],moveto["z"],"Move here to repair.")
        end

        if reapiring then return end
        reapiring = true
        
        local timeout = 20

        NetworkRequestControlOfEntity(targetVehicle)

        while not NetworkHasControlOfEntity(targetVehicle) and timeout > 0 do 
            NetworkRequestControlOfEntity(targetVehicle)
            Citizen.Wait(100)
            timeout = timeout -1
        end


        if dist < 1.0 then
            TriggerEvent("animation:repair",targetVehicle)
            fixingvehicle = true

            local repairlength = 1000

            if advanced then
                repairlength = ((3500 - (GetVehicleEngineHealth(targetVehicle) * 3) - (GetVehicleBodyHealth(targetVehicle)) / 2) * 5) + 2000
            else
                repairlength = ((3500 - (GetVehicleEngineHealth(targetVehicle) * 3) - (GetVehicleBodyHealth(targetVehicle)) / 2) * 3) + 2000
            end

            local finished = exports["np-taskbar"]:taskBar(repairlength,"Repairing")
            if finished == 100 then
                
                local myJob = exports["isPed"]:isPed("myJob")
                if myjob == "towtruck" then
                    SetVehicleEngineHealth(targetVehicle, 1000.0)
                    SetVehicleBodyHealth(targetVehicle, 1000.0)

                    if math.random(100) > 95 then
                        TriggerEvent("inventory:removeItem","repairtoolkit",1)
                    end

                else

                    TriggerEvent('veh.randomDegredation',30,targetVehicle,3)

                    if advanced then
                        TriggerEvent("inventory:removeItem","advrepairkit", 1)
                        TriggerEvent('veh.randomDegredation',30,targetVehicle,3)
                        if GetVehicleEngineHealth(targetVehicle) < 900.0 then
                            SetVehicleEngineHealth(targetVehicle, 900.0)
                        end
                        if GetVehicleBodyHealth(targetVehicle) < 945.0 then
                            SetVehicleBodyHealth(targetVehicle, 945.0)
                        end

                    else
                        if math.random(100) > 95 then
                            TriggerEvent("inventory:removeItem","repairtoolkit",1)
                        end

                        if GetVehicleEngineHealth(targetVehicle) < 200.0 then
                            SetVehicleEngineHealth(targetVehicle, 200.0)
                        end
                        if GetVehicleBodyHealth(targetVehicle) < 945.0 then
                            SetVehicleBodyHealth(targetVehicle, 945.0)
                        end
                        if GetEntityModel(targetVehicle) == `BLAZER` then
                            SetVehicleEngineHealth(targetVehicle, 600.0)
                            SetVehicleBodyHealth(targetVehicle, 800.0)
                        end
                    end                    
                end

                for i = 0, 5 do
                    SetVehicleTyreFixed(targetVehicle, i) 
                end
            end
            ClearPedTasks(playerped)
        end
        fixingvehicle = false
    end
    reapiring = false
end)

-- Animations
RegisterNetEvent('animation:load')
AddEventHandler('animation:load', function(dict)
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end)

RegisterNetEvent('animation:repair')
AddEventHandler('animation:repair', function(veh)
    SetVehicleDoorOpen(veh, 4, 0, 0)
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), veh, 1.0)
    Citizen.Wait(1000)

    while fixingvehicle do
        local anim3 = IsEntityPlayingAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 3)
        if not anim3 then
            TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    SetVehicleDoorShut(veh, 4, 1, 1)
end)