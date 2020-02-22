local chatInputActive = false
local chatInputActivating = false

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')

-- internal events
RegisterNetEvent('__cfx_internal:serverPrint')

RegisterNetEvent('_chat:messageEntered')

--deprecated, use chat:addMessage
AddEventHandler('chatMessage', function(author, color, text)
  local hud = exports["isPed"]:isPed("hud")

  if color == 8 then
    TriggerEvent("phone:addnotification",author,text)
    return
  end
  if hud < 3 then
    local args = { text }
    if author ~= "" then
      table.insert(args, 1, author)
    end
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = color,
        multiline = true,
        args = args
      }
    })
  end
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
  print(msg)

  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
      color = { 0, 0, 0 },
      multiline = true,
      args = { msg }
    }
  })
end)



AddEventHandler('chat:addMessage', function(message)
  local hud = exports["isPed"]:isPed("hud")
  if hud then
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = message
    })
  end
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end)

AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:addTemplate', function(id, html)
  SendNUIMessage({
    type = 'ON_TEMPLATE_ADD',
    template = {
      id = id,
      html = html
    }
  })
end)

AddEventHandler('chat:clear', function(name)
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)

  if not data.canceled then
    local id = PlayerId()

    --deprecated
    local r, g, b = 0, 0x99, 255

    TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message)
  end

  cb('ok')
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init');

  cb('ok')
end)



RegisterNetEvent('event:control:chat')
AddEventHandler('event:control:chat', function(useID)
  if not chatInputActive then
    SetNuiFocus(true)
    chatInputActive = true
    chatInputActivating = true
    local hud = exports["isPed"]:isPed("hud")


    SendNUIMessage({
      type = 'HUD_CHANGE',
      hudtype = hud,
    })

    SendNUIMessage({
      type = 'ON_OPEN',
    })
  end
  if chatInputActive then
    SetNuiFocus(false)
    SetNuiFocus(true)

    chatInputActivating = false
  end
end)


Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false)
end)
