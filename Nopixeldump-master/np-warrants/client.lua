local guiEnabled = false

-- Open Gui and Focus NUI
function openGui()
  local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
  if not isInVeh then
    SetPlayerControl(PlayerId(), 0, 0)
  end
  guiEnabled = true
  SetNuiFocus(true,true)
  SendNUIMessage({openWarrants = true})
   TriggerEvent('animation:tablet',true)
end

function openGuiDoctor()
  local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
  if not isInVeh then
    SetPlayerControl(PlayerId(), 0, 0)
  end
  guiEnabled = true
  SetNuiFocus(true,true)
  SendNUIMessage({openDoctors = true})
   TriggerEvent('animation:tablet',true)
end

function openpr()
  SetPlayerControl(PlayerId(), 0, 0)
  guiEnabled = true
    SetNuiFocus(true,true)
    SendNUIMessage({
      openSection = "publicrecords"
    })
   TriggerEvent('animation:tablet',true)
end

-- Close Gui and disable NUI
function closeGui()
  SetNuiFocus(false,false)
  guiEnabled = false
  TriggerEvent('animation:tablet',false)
  Wait(250)
  ClearPedTasks(PlayerPedId())
  SetPlayerControl(PlayerId(), 1, 0)
end

RegisterNetEvent("phone:publicrecords")
AddEventHandler("phone:publicrecords", function()
    openpr()
end)

-- Opens our warrants
RegisterNetEvent('warrantsGui')
AddEventHandler('warrantsGui', function()
  openGui()
  guiEnabled = true
end)

RegisterNetEvent('doctorGui')
AddEventHandler('doctorGui', function()
  openGuiDoctor()
  guiEnabled = true
end)

-- NUI Callback Methods
RegisterNUICallback('close', function(data, cb)
  closeGui()
  cb('ok')
end)



