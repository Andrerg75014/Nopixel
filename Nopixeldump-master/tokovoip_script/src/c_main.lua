------------------------------------------------------------
------------------------------------------------------------
---- Author: Dylan 'Itokoyamato' Thuillier              ----
----                                                    ----
---- Email: itokoyamato@hotmail.fr                      ----
----                                                    ----
---- Resource: tokovoip_script                          ----
----                                                    ----
---- File: c_main.lua                                   ----
------------------------------------------------------------
------------------------------------------------------------

--------------------------------------------------------------------------------
--	Client: Voip data processed before sending it to TS3Plugin
--------------------------------------------------------------------------------
local isLoggedIn = false;
local targetPed;
local useLocalPed = true;
local isRunning = false;
local isInTruckerRadio = false
local isInEmergencyRadio = false
local lastEmergencyChannel = 0
local radioVolume = -6;
local stereoVolume = -4;
local HeadBone = 0x796e;
local animStates = {}
local defaultVolume = 0
ValidCast = {}

--------------------------------------------------------------------------------
--	Plugin functions
--------------------------------------------------------------------------------

-- Handles the talking state of other players to apply talking animation to them
local function setPlayerTalkingState(player, playerServerId)
	local talking = tonumber(getPlayerData(playerServerId, "voip:talking"));
	if (animStates[playerServerId] == 0 and talking == 1) then
		PlayFacialAnim(GetPlayerPed(player), "mic_chatter", "mp_facial");
	elseif (animStates[playerServerId] == 1 and talking == 0) then
		PlayFacialAnim(GetPlayerPed(player), "mood_normal_1", "facials@gen_male@base");
	end
	animStates[playerServerId] = talking;
end

RegisterNUICallback("updatePluginData", function(data)
	local payload = data.payload;
	if (voip[payload.key] == payload.data) then return end
	voip[payload.key] = payload.data;
	if payload.key == "pluginUUID" then
		serverRefresh()
	else
		setPlayerData(voip.serverId, "voip:" .. payload.key, voip[payload.key], false);
	end
	
	voip:updateConfig();
	voip:updateTokoVoipInfo(true);
	
end);

-- Receives data from the TS plugin on microphone toggle
RegisterNUICallback("setPlayerTalking", function(data)
	voip.talking = tonumber(data.state);
	if (voip.talking == 1) then
		setPlayerData(voip.serverId, "voip:talking", 1, true);
		PlayFacialAnim(GetPlayerPed(PlayerId()), "mic_chatter", "mp_facial");
	else
		setPlayerData(voip.serverId, "voip:talking", 0, true);
		PlayFacialAnim(PlayerPedId(), "mood_normal_1", "facials@gen_male@base");
	end
end)

local function clientProcessing()
	local playerList = voip.playerList;
	local usersdata = {};
	local inEavesDroppingDist = {}
	local inPassThroughDist = {}
	local localHeading;
	local ped = PlayerPedId()
	-- TODO: FIXME: This broke with a recent FiveM Update
	if (voip.headingType == 1) then
	 	localHeading = math.rad(GetEntityHeading(ped));
	else
	 	localHeading = math.rad(GetGameplayCamRot().z % 360);
	end
	--localHeading = math.rad(GetEntityHeading(ped));
	-- TODO: FIXME: This broke with a recent FiveM Update

	local localPos;
	

	if useLocalPed then
		localPos = GetPedBoneCoords(ped, HeadBone);
	else
		localPos = GetPedBoneCoords(targetPed, HeadBone);
	end

	for i=1,#playerList do
		local player = playerList[i]
		local playerServerId = GetPlayerServerId(player);
		if (GetPlayerPed(player) and voip.serverId ~= playerServerId) then
			local playerPos = GetPedBoneCoords(GetPlayerPed(player), HeadBone);
			local dist = #(localPos - playerPos);

			if (not getPlayerData(playerServerId, "voip:mode")) then
				setPlayerData(playerServerId, "voip:mode", 1);
			end

			local mode = tonumber(getPlayerData(playerServerId, "voip:mode"));
			
			-- Set player's default data
			local tbl = {
				uuid = getPlayerData(playerServerId, "voip:pluginUUID"),
				volume = -voip.minVolume,
				muted = 1,
				radioEffect = false,
				posX = 0.0,
				posY = 0.0,
				posZ = voip.plugin_data.enableStereoAudio and playerPos.z or 0,
			};
			--

			local remotePlayerUsingRadio = getPlayerData(playerServerId, "radio:talking");
			local remotePlayerChannel = tonumber(getPlayerData(playerServerId, "radio:channel"));

			-- Process proximity
			if (dist >= voip.distance[mode]) then
				tbl.muted = 1;
			else

				-- Process angle to target
				local angleToTarget = localHeading - math.atan(playerPos.y - localPos.y, playerPos.x - localPos.x);
				tbl.posX = voip.plugin_data.enableStereoAudio and math.cos(angleToTarget) * dist or 0
				tbl.posY = voip.plugin_data.enableStereoAudio and math.sin(angleToTarget) * dist or 0
				tbl.posZ = voip.plugin_data.enableStereoAudio and playerPos.z or 0


				--	Process the volume for proximity voip
				
				if (not mode or (mode ~= 1 and mode ~= 2 and mode ~= 3)) then mode = 1 end;
				local volume = -voip.minVolume + (voip.minVolume - dist / voip.distance[mode] * voip.minVolume);
				if (volume >= 0) then
					volume = 0;
				end
				--

				tbl.volume = volume;
				tbl.muted = 0;

				-- process eavesdropping 
				if (dist <= voip.distance[2]) then
					if(remotePlayerChannel ~= 0 and remotePlayerChannel ~= nil) then
						local canListen = true
						local loudSpeaker = getPlayerData(playerServerId, "voip:loudSpeaker");

						if(remotePlayerChannel >= 100 and remotePlayerChannel <= 999 and not loudSpeaker and remotePlayerChannel ~= voip.listenBroadcast ) then canListen = false end

						if(voip.plugin_data.radioChannel ~= remotePlayerChannel and canListen and voip.myChannels[remotePlayerChannel]) then

							for k,v in pairs(voip.myChannels[remotePlayerChannel].subscribers) do
								if (k ~= voip.serverId and k ~= playerServerId and inEavesDroppingDist[k] == nil) then
									local targetPos = GetPedBoneCoords(GetPlayerPed(GetPlayerFromServerId(k)), HeadBone);
									local dist2 = #(playerPos - targetPos);
									if (dist2 >= voip.distance[2]) then
										local targetUsingRadio = getPlayerData(v, "radio:talking");
										local targetChannel = getPlayerData(v, "radio:channel");
										if targetUsingRadio and targetChannel == remotePlayerChannel then
											local effect = true
											if (remotePlayerChannel >= 100 and remotePlayerChannel <= 999) then effect = false end
											local reduction = voip.minVolume/3
											inEavesDroppingDist[k] = {
												[1] = getPlayerData(v, "voip:pluginUUID"),
												[2] = voip.plugin_data.enableStereoAudio and math.cos(angleToTarget) * dist or 0,
												[3] = voip.plugin_data.enableStereoAudio and math.sin(angleToTarget) * dist or 0,
												[4] = (-reduction + (reduction - dist / 0.35 * reduction)),
												[5] = effect,
											}
										end
									end
								end
							end
						end
					end
				end
				--
			end
			--
			
			if remotePlayerChannel == voip.listenBroadcast then
				if(getPlayerData(playerServerId, "voip:broadcasting") and remotePlayerUsingRadio) then
					if(IsPedInAnyVehicle(PlayerPedId(),false)) then	
						local vehPos = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(PlayerPedId(),false), 0.0, -1.5, 0.0)
						local angleToVehicle = localHeading - math.atan(vehPos.y - localPos.y, vehPos.x - localPos.x);

						tbl.volume = stereoVolume;
						tbl.muted = 0;
						tbl.posX = voip.plugin_data.enableStereoAudio and math.cos(angleToVehicle) * 0.0 or 0;
						tbl.posY = voip.plugin_data.enableStereoAudio and math.sin(angleToVehicle) * 16.4 or 0;
						tbl.posZ = voip.plugin_data.enableStereoAudio and localPos.z or 0;

					end
				end
			end

			-- Process channels
			local channel = voip.myChannels[remotePlayerChannel]
			
			if channel then
				if (channel.subscribers[voip.serverId] and channel.subscribers[playerServerId] and voip.myChannels[remotePlayerChannel] and remotePlayerUsingRadio and remotePlayerChannel ~= voip.listenBroadcast) then
					if (remotePlayerChannel <= 100 or (remotePlayerChannel >= 1000 and remotePlayerChannel <= 9999)) then 
						tbl.radioEffect = true;
					end
					tbl.volume = radioVolume;
					tbl.muted = 0;
					tbl.posX = 0;
					tbl.posY = 0;
					tbl.posZ = voip.plugin_data.enableStereoAudio and localPos.z or 0;
				end

				if (channel.subscribers[voip.serverId] and channel.subscribers[playerServerId] and voip.myChannels[remotePlayerChannel] and remotePlayerChannel ~= voip.listenBroadcast) then
					if(remotePlayerChannel > 100 and remotePlayerChannel <= 999) then
						for l=1,#playerList do
							local playerTarget = playerList[l]
							local playerServerIdTarget = GetPlayerServerId(playerTarget);
							if (GetPlayerPed(playerTarget) and voip.serverId ~= playerServerId and playerServerId ~= playerServerIdTarget) then
								local targetPos = GetPedBoneCoords(GetPlayerPed(playerTarget), HeadBone);
								local distPTTarget = #(targetPos - playerPos); -- distance to phone holder
								local distPTPlayer = #(targetPos - localPos); -- distnace to player doing check

								if (distPTPlayer > voip.distance[3] and distPTTarget <= voip.distance[2] and inPassThroughDist[l] == nil) then
									local angleToTT = localHeading - math.atan(playerPos.y - localPos.y, playerPos.x - localPos.x);
									local reduction = voip.minVolume/4
									inPassThroughDist[l] = {
										[1] = getPlayerData(playerServerIdTarget, "voip:pluginUUID"),
										[2] = voip.plugin_data.enableStereoAudio and math.cos(angleToTT) * distPTTarget or 0,
										[3] = voip.plugin_data.enableStereoAudio and math.sin(angleToTT) * distPTTarget or 0,
										[4] = (-reduction + (reduction - distPTTarget / 0.35 * reduction)),
									}
								end
							end
						end
					end
				end
			end


			
			--
			usersdata[#usersdata + 1] = tbl
			setPlayerTalkingState(player, playerServerId);
		end
	end

	local eavesdropping = false

	for k,v in pairs(inEavesDroppingDist) do
		for _,o in pairs(usersdata) do
			if o.uuid == v[1] then
				o.muted = 0;
				o.posX = v[2];
				o.posY = v[3];
				o.volume = v[4];
				o.radioEffect = v[5];
				if o.radioEffect then
					eavesdropping = true
				end
			end
		end
		voip.plugin_data.localRadioClicks = false;
		voip.plugin_data.remote_click_off = false;
	end

	for k,v in pairs(inPassThroughDist) do
		for _,o in pairs(usersdata) do
			if o.uuid == v[1] then
				o.muted = 0;
				o.posX = v[2];
				o.posY = v[3];
				o.volume = v[4];
				o.radioEffect = false;
			end
		end
		voip.plugin_data.localRadioClicks = false;
		voip.plugin_data.remote_click_off = false;
	end

	if eavesdropping then
		voip.plugin_data.ClickVolume = ""..math.abs(20)*-1 
	else
		voip.plugin_data.ClickVolume = voip.plugin_data.default_ClickVolume
	end

	voip.plugin_data.Users = usersdata; -- Update TokoVoip's data
	voip.plugin_data.posX = 0;
	voip.plugin_data.posY = 0;
	voip.plugin_data.posZ = voip.plugin_data.enableStereoAudio and localPos.z or 0;
end


function initializeVoip()
	if (isRunning) then return end
	isRunning = true;

	voip = TokoVoip:init(TokoVoipConfig); -- Initialize TokoVoip and set default settings

	-- Variables used script-side
	voip.plugin_data.Users = {};
	voip.plugin_data.radioTalking = false;
	voip.plugin_data.radioChannel = -1;
	voip.plugin_data.localRadioClicks = false;
	voip.mode = 1;
	voip.loudSpeaker = false;
	voip.talking = false;
	voip.pluginStatus = -1;
	voip.pluginVersion = "0";
	voip.serverId = GetPlayerServerId(PlayerId());
	voip.listenBroadcast = 19829;
	voip.broadcasting = false;
	voip.toggleRadio = false
	voip.blockRadio = false
	defaultVolume = voip.minVolume
	-- Radio channels
	voip.myChannels = {};

	-- Player data shared on the network
	setPlayerData(voip.serverId, "voip:mode", voip.mode, true);
	setPlayerData(voip.serverId, "voip:talking", voip.talking, true);
	setPlayerData(voip.serverId, "radio:channel", voip.plugin_data.radioChannel, true);
	setPlayerData(voip.serverId, "radio:talking", voip.plugin_data.radioTalking, true);
	setPlayerData(voip.serverId, "voip:pluginStatus", voip.pluginStatus, false);
	setPlayerData(voip.serverId, "voip:pluginVersion", voip.pluginVersion, false);
	setPlayerData(voip.serverId, "voip:loudSpeaker", voip.loudSpeaker, true);
	setPlayerData(voip.serverId, "voip:listenBroadcast", voip.listenBroadcast, false);
	setPlayerData(voip.serverId, "voip:broadcasting", voip.broadcasting, true);
	setPlayerData(voip.serverId, "voip:toggleRadio", voip.toggleRadio, false);
	setPlayerData(voip.serverId, "voip:blockRadio", voip.blockRadio, false);
	refreshAllPlayerData();

	-- Set targetped (used for spectator mod for admins)
	targetPed = PlayerPedId();

	--isLoggedIn = true
	while not isLoggedIn do
		Wait(50);
	end

	-- Load custom VoIP settings
	--TriggerServerEvent("TokoVoip:clientHasSelecterCharecter")
	
	voip.processFunction = clientProcessing; -- Link the processing function that will be looped
	voip:initialize(); -- Initialize the websocket and controls
	voip:loop(); -- Start TokoVoip's loop

	-- Request this stuff here only one time
	RequestAnimDict("mp_facial");
	RequestAnimDict("facials@gen_male@base");


	refreshAllPlayerData();
	tokoUpdateControls();
	-- Debug data stuff
	local debugData = false;
	if debugData then
		Citizen.CreateThread(function()
			while true do
				Wait(5)

				if (IsControlPressed(0, Keys["LEFTSHIFT"])) then
					if (IsControlJustPressed(1, Keys["9"]) or IsDisabledControlJustPressed(1, Keys["9"])) then
						debugData = not debugData;
					end
				end

				if (debugData) then
					local pos_y;
					local pos_x;
					local players = getPlayers();

					for i = 1, #players do
						local player = players[i];
						local playerServerId = GetPlayerServerId(players[i]);

						pos_y = 1.1 + (math.ceil(i/12) * 0.1);
						pos_x = 0.60 + ((i - (12 * math.floor(i/12)))/15);

						drawTxt(pos_x, pos_y, 1.0, 1.0, 0.2, "[" .. playerServerId .. "] " .. GetPlayerName(player) .. "\nMode: " .. tostring(getPlayerData(playerServerId, "voip:mode")) .. "\nChannel: " .. tostring(getPlayerData(playerServerId, "radio:channel")) .. "\nRadioTalking: " .. tostring(getPlayerData(playerServerId, "radio:talking")) .. "\npluginStatus: " .. tostring(getPlayerData(playerServerId, "voip:pluginStatus")) .. "\npluginVersion: " .. tostring(getPlayerData(playerServerId, "voip:pluginVersion")) .. "\nTalking: " .. tostring(getPlayerData(playerServerId, "voip:talking")), 255, 255, 255, 255);
					end
					local i = 0;
					for channelIndex, channel in pairs(voip.myChannels) do
						i = i + 1;
						drawTxt(0.8 + i/12, 0.5, 1.0, 1.0, 0.2, channel.name .. "(" .. channelIndex .. ")", 255, 255, 255, 255);
						local j = 0;
						for _, player in pairs(channel.subscribers) do
							j = j + 1;
							drawTxt(0.8 + i/12, 0.5 + j/60, 1.0, 1.0, 0.2, player, 255, 255, 255, 255);
						end
					end
				end
			end
		end);
	end
end
RegisterNetEvent("initializeVoip");
AddEventHandler("initializeVoip", initializeVoip);

--------------------------------------------------------------------------------
--	Radio Settings functions
--------------------------------------------------------------------------------
function toBoolean(value)
  return value == 1 or tostring(value) == "true";
end

Controlkey = {["tokoptt"] = {137,"CAPS"},["loudSpeaker"] = {84,"-"},["distanceChange"] = {47,"G"},["tokoToggle"] = {36,"LEFTCTRL"}} 
RegisterNetEvent('event:control:update')
AddEventHandler('event:control:update', function(table)
	Controlkey["tokoptt"] = table["tokoptt"]
	Controlkey["distanceChange"] = table["distanceChange"]
	Controlkey["loudSpeaker"] = table["loudSpeaker"]
	Controlkey["tokoToggle"] = table["tokoToggle"]

	if isLoggedIn then
		tokoUpdateControls()
	end
end)

Settings = {["stereoAudio"] = false,["localClickOn"] = true,["localClickOff"] = true, ["remoteClickOn"] = true, ["remoteClickOff"] = true, ["mainVolume"] = 6.0, ["clickVolume"] = 10.0,["radioVolume"] = 5.0}
RegisterNetEvent('event:settings:update')
AddEventHandler('event:settings:update', function(table)
	while not voip do
		Wait(200)
	end

	Settings = table["tokovoip"]
	tokoUpdateSettings()
end)

function tokoUpdateControls()
	voip.radioKey = Controlkey["tokoptt"][1]
	voip.keyProximity = Controlkey["distanceChange"][1]
	voip.keyToggleLoudSpeaker = Controlkey["loudSpeaker"][1]
	voip.keySecondaryRadioToggle = Controlkey["tokoToggle"][1]
end

function tokoUpdateSettings()
	voip.minVolume = tonumber(Settings["mainVolume"])
	radioVolume = math.abs(tonumber( Settings["radioVolume"]))*-1 
	voip.plugin_data.ClickVolume = ""..math.abs(tonumber( Settings["clickVolume"]))*-1 
	voip.plugin_data.default_ClickVolume = ""..math.abs(tonumber( Settings["clickVolume"]))*-1 

	voip.plugin_data.default_local_click_on = Settings["localClickOn"]
	voip.plugin_data.local_click_off = Settings["localClickOff"]
	--voip.plugin_data.remote_click_on = Settings["remoteClickOn"]
	--voip.plugin_data.remote_click_off = Settings["remoteClickOff"]
	voip.plugin_data.enableStereoAudio = Settings["stereoAudio"]
	if voip then
		voip:updateConfig();
		voip:updateTokoVoipInfo(true);
	end
	TriggerEvent("TokoVoip:setRadioVolume",radioVolume,true)
end

RegisterNetEvent("TokoVoip:updateSettings");
AddEventHandler("TokoVoip:updateSettings", tokoUpdateSettings);

function setRadioVolume(volume,isSettingsUpdate)
	local vol = math.ceil(volume) or 0;
	if vol > 0 then vol = 0 end; 
	radioVolume = vol;
	if not isSettingsUpdate then
		exports["np-base"]:getModule("SettingsData"):setVarible("tokovoip","radioVolume",math.abs(vol))
	end
end
RegisterNetEvent("TokoVoip:setRadioVolume");
AddEventHandler("TokoVoip:setRadioVolume", setRadioVolume);
exports("setRadioVolume", setRadioVolume);

function setVolumeDown()
	if radioVolume <= -20 then
		radioVolume = -20
	else
		radioVolume = radioVolume - 1
	end
	TriggerEvent("TokoVoip:setRadioVolume",radioVolume)
	TriggerEvent("DoShortHudText","Volume: " .. radioVolume)
end
RegisterNetEvent("TokoVoip:DownVolume");
AddEventHandler("TokoVoip:DownVolume", setVolumeDown);
exports("setRadioVolumeDown", setVolumeDown);

function setVolumeUp()
	if radioVolume >= 0 then
		radioVolume = 0
	else
		radioVolume = radioVolume + 1
	end
	TriggerEvent("TokoVoip:setRadioVolume",radioVolume)
	TriggerEvent("DoShortHudText","Volume: " .. radioVolume)
end
RegisterNetEvent("TokoVoip:UpVolume");
AddEventHandler("TokoVoip:UpVolume", setVolumeUp);
exports("setRadioVolumeUp", setVolumeUp);


RegisterNetEvent('event:control:tokoChangeEmergency')
AddEventHandler('event:control:tokoChangeEmergency', function(useID)
	local job = exports["isPed"]:isPed("myjob")
  	local Emergency = false
  	if job == "police" then
    	Emergency = true
  	elseif job == "ems" then
    	Emergency = true
  	elseif job == "doctor" then
    	Emergency = true
  	end


  	if Emergency then
  		if voip.plugin_data.radioChannel == 1 then
  				TriggerServerEvent("TokoVoip:addPlayerToRadio", 5, GetPlayerServerId(PlayerId()))
    		TriggerEvent("ChannelSet",5)
  		elseif voip.plugin_data.radioChannel == 5 then
  				TriggerServerEvent("TokoVoip:addPlayerToRadio", 1, GetPlayerServerId(PlayerId()))
  			TriggerEvent("ChannelSet",1)
  		end
  	end

end)




--------------------------------------------------------------------------------
--	Broadcast Settings functions
--------------------------------------------------------------------------------

function broadcastListening(channel)
	voip.listenBroadcast = channel
	setPlayerData(voip.serverId, "voip:listenBroadcast", voip.listenBroadcast, false);
end
RegisterNetEvent("TokoVoip:broadcastListening");
AddEventHandler("TokoVoip:broadcastListening", broadcastListening);

function setVolumeDownBroadcast()
	if stereoVolume <= -voip.minVolume then
		stereoVolume = -voip.minVolume
	else
		stereoVolume = stereoVolume - 1
	end
	TriggerEvent("DoShortHudText","Stereo Volume: " .. stereoVolume)
end
RegisterNetEvent("TokoVoip:DownVolumeBroadcast");
AddEventHandler("TokoVoip:DownVolumeBroadcast", setVolumeDownBroadcast);


function setVolumeUpBroadcast()
	if stereoVolume >= -4 then
		stereoVolume = -4
	else
		stereoVolume = stereoVolume + 1
	end
	TriggerEvent("DoShortHudText","Stereo Volume: " .. stereoVolume)
end
RegisterNetEvent("TokoVoip:UpVolumeBroadcast");
AddEventHandler("TokoVoip:UpVolumeBroadcast", setVolumeUpBroadcast);


--------------------------------------------------------------------------------
--	Radio functions
--------------------------------------------------------------------------------

local currentRadioCH = 0;
function ResetRadioChannel()
  Wait(1000)
  local job = exports["isPed"]:isPed("myjob")
  local channel = 0
  if job == "police" then
    channel = 1
  elseif job == "ems" then
    channel = 1
  elseif job == "towtruck" then
    channel = 3
  elseif job == "trucker" then
    channel = 4
  end
  if channel ~= 0 then
    TriggerServerEvent("TokoVoip:addPlayerToRadio", channel, GetPlayerServerId(PlayerId()))
  else
  	if currentRadioCH ~= 0 then
  		TriggerServerEvent("TokoVoip:addPlayerToRadio", currentRadioCH, GetPlayerServerId(PlayerId()))
  		currentRadioCH = 0;
  	else
  		TriggerEvent("radio:resetNuiCommand")
  	end
  end
end
RegisterNetEvent("ResetRadioChannel");
AddEventHandler("ResetRadioChannel", ResetRadioChannel);

function addPlayerToRadio(channel)
	TriggerServerEvent("TokoVoip:addPlayerToRadio", channel, voip.serverId);
end
RegisterNetEvent("TokoVoip:addPlayerToRadio");
AddEventHandler("TokoVoip:addPlayerToRadio", addPlayerToRadio);
exports("addPlayerToRadio", addPlayerToRadio);

function removePlayerFromRadio(channel,refresh)
	TriggerServerEvent("TokoVoip:removePlayerFromRadio", channel, voip.serverId);
	if refresh ~= nil then
		TriggerEvent("ResetRadioChannel")
	end
end
RegisterNetEvent("TokoVoip:removePlayerFromRadio");
AddEventHandler("TokoVoip:removePlayerFromRadio", removePlayerFromRadio);
exports("removePlayerFromRadio", removePlayerFromRadio);

RegisterNetEvent("TokoVoip:onPlayerLeaveChannel");
AddEventHandler("TokoVoip:onPlayerLeaveChannel", function(channelId, playerServerId,isDeleted)
	-- Local player left channel
	if not isDeleted then
		if (playerServerId == voip.serverId and voip.myChannels[channelId]) then
			local currentChannel = voip.plugin_data.radioChannel;
			voip.myChannels[channelId].subscribers[playerServerId] = nil;

			voip.plugin_data.radioChannel = -1; -- Always set to -1 since we are removed from all channels

			if (currentChannel ~= voip.plugin_data.radioChannel) then -- Update network data only if we actually changed radio channel
				if ValidCast[currentChannel] then 
					voip.broadcasting = false
					setPlayerData(voip.serverId, "voip:broadcasting", voip.broadcasting, true);
				end

				setPlayerData(voip.serverId, "radio:channel", voip.plugin_data.radioChannel, true);
			end

		-- Remote player left channel we are subscribed to
		elseif(voip.myChannels[channelId]) then
			voip.myChannels[channelId].subscribers[playerServerId] = nil;
		end
	else
		voip.myChannels[channelId] = nil
	end
end)


RegisterNetEvent("TokoVoip:onPlayerJoinChannel");
AddEventHandler("TokoVoip:onPlayerJoinChannel", function(channelId, playerServerId, channelData)
	-- Local player joined channel
	if (playerServerId == voip.serverId and channelData) then
		local currentChannel = voip.plugin_data.radioChannel;

		if channelId > 99 and channelId < 999 then -- we are switching to a call here
			if (currentChannel < 99 or currentChannel > 999) then
				currentRadioCH = currentChannel; -- we are on a radio freq before entering call ? 
			end
		end

		voip.plugin_data.radioChannel = channelData.id;
		voip.myChannels[channelData.id] = channelData;

		if (currentChannel ~= voip.plugin_data.radioChannel) then -- Update network data only if we actually changed radio channel
			if ValidCast[voip.plugin_data.radioChannel] then 
				voip.broadcasting = true
				setPlayerData(voip.serverId, "voip:broadcasting", voip.broadcasting, true);
			end
			setPlayerData(voip.serverId, "radio:channel", voip.plugin_data.radioChannel, true);
		end
	end

	if (voip.myChannels[channelId] == nil and channelData ~= nil) then voip.myChannels[channelId] = channelData end
	if voip.myChannels and voip.myChannels[channelId] then
		voip.myChannels[channelId].subscribers[playerServerId] = playerServerId;
	end

end)

RegisterNetEvent("TokoVoip:setChannels");
AddEventHandler("TokoVoip:setChannels", function(channelData,ValidCastData)
	voip.myChannels = channelData
	ValidCast = ValidCastData
end)


function isPlayerInChannel(channel)
	if (voip.myChannels[channel]) then
		return true;
	else
		return false;
	end
end
exports("isPlayerInChannel", isPlayerInChannel)

--------------------------------------------------------------------------------
--	Specific utils
--------------------------------------------------------------------------------

function serverRefresh()
	Citizen.CreateThread(function()
		while true do
			setPlayerData(voip.serverId, "voip:pluginUUID", voip.pluginUUID, true);
			Wait(voip.serverRefreshRate)
		end
	end);
end


function playerLoggedIn(toggle)
	if (toggle) then
		isLoggedIn = true;
	end
end
RegisterNetEvent("tokovoip:onPlayerLoggedIn");
AddEventHandler("tokovoip:onPlayerLoggedIn", playerLoggedIn);

function changeName(name)
	if name == nil or name == "" then return end
	voip.plugin_data.localName = escape2(name)
end
RegisterNetEvent("TokoVoip:changeName");
AddEventHandler("TokoVoip:changeName", changeName);


-- Toggle the blocking screen with usage explanation
local displayingPluginScreen = false;
function displayPluginScreen(toggle)
	if (displayingPluginScreen ~= toggle) then
		SendNUIMessage(
			{
				type = "displayPluginScreen",
				data = toggle
			}
		);
		displayingPluginScreen = toggle;
	end
end

-- Used for admin spectator feature
function updateVoipTargetPed(newTargetPed, useLocal)
	targetPed = newTargetPed
	useLocalPed = useLocal
end
AddEventHandler("updateVoipTargetPed", updateVoipTargetPed)


-- volume should be higher then the already set voip.minVolume
-- spike point based on the difference between the end goal and default , example default 20 , target 60 , diff is 40 , counting up .. spikepoint 15 , meaning when past 15 all the way to target it halfs wait
function volumeDropSpike(volume,time,holdTime,spikePoint)
	voip.blockRadio = true
	setPlayerData(voip.serverId, "voip:blockRadio", voip.blockRadio, false);
	-- Intital quite down 	
	for i=defaultVolume,volume do
		voip.minVolume = voip.minVolume + 1
		Wait(3)
	end
	Wait(holdTime)

	local diff = volume - defaultVolume

	-- returning back to normal
	for i=1,diff do
		voip.minVolume = voip.minVolume - 1
		if i > spikePoint then
			Wait((time/2))
		else
			Wait(time)
		end
	end

	-- reset back to normal
	voip.minVolume = defaultVolume 
	voip.blockRadio = false
	setPlayerData(voip.serverId, "voip:blockRadio", voip.blockRadio, false);
end
RegisterNetEvent("TokoVoip:volumeDropSpike");
AddEventHandler("TokoVoip:volumeDropSpike", volumeDropSpike);