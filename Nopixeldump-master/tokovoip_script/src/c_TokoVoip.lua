------------------------------------------------------------
------------------------------------------------------------
---- Author: Dylan 'Itokoyamato' Thuillier              ----
----                                                    ----
---- Email: itokoyamato@hotmail.fr                      ----
----                                                    ----
---- Resource: tokovoip_script                          ----
----                                                    ----
---- File: c_TokoVoip.lua                               ----\
------------------------------------------------------------
------------------------------------------------------------

--------------------------------------------------------------------------------
--	Client: TokoVoip functions
--------------------------------------------------------------------------------

TokoVoip = {};
TokoVoip.__index = TokoVoip;
local lastTalkState = false
local lastTalking = 0

function TokoVoip.init(self, config)
	local self = setmetatable(config, TokoVoip);
	self.config = json.decode(json.encode(config));
	self.lastNetworkUpdate = 0;
	self.lastPlayerListUpdate = self.playerListRefreshRate;
	self.playerList = {};
	return (self);
end

function TokoVoip.loop(self)
	Citizen.CreateThread(function()
		while (true) do
			Citizen.Wait(self.refreshRate);
			self:processFunction();
			self:sendDataToTS3();

			self.lastNetworkUpdate = self.lastNetworkUpdate + self.refreshRate;
			self.lastPlayerListUpdate = self.lastPlayerListUpdate + self.refreshRate;
			if (self.lastNetworkUpdate >= self.networkRefreshRate) then
				self.lastNetworkUpdate = 0;
				self:updateTokoVoipInfo();
			end
			if (self.lastPlayerListUpdate >= self.playerListRefreshRate) then
				self.playerList = getPlayers();
				self.lastPlayerListUpdate = 0;
			end
		end
	end);
end

function TokoVoip.sendDataToTS3(self) -- Send usersdata to the Javascript Websocket
	self:updatePlugin("updateTokoVoip", self.plugin_data);
end

function getRadioDisplay(self) -- Display all radio channels in a list with the current "talking" channel marked so people understand they might be listening to multiple
	local channels = self.myChannels
	local curChannel = self.plugin_data.radioChannel
	local display = "No Channel"

	for channelId, channel in pairs(channels) do
		if curChannel == channelId then
			display = "<br>" .. channel.name .. " 🎧  🎤<br>"
		end
	end
	
	return display
end

function TokoVoip.updateTokoVoipInfo(self, forceUpdate) -- Update the top-left info
	local info = "";
	if (self.mode == 1) then
		info = "Normal";
	elseif (self.mode == 2) then
		info = "Whispering";
	elseif (self.mode == 3) then
		info = "Shouting";
	end

	if (self.plugin_data.radioTalking) then
		info = info .. " on radio ";
	end
	if (self.talking == 1 or self.plugin_data.radioTalking) then
		info = "<font class='talking'>" .. info .. "</font>";
	end
	if (self.plugin_data.radioChannel ~= -1 and self.myChannels[self.plugin_data.radioChannel]) then
	    if (string.find(self.myChannels[self.plugin_data.radioChannel].name, "Call")) then
			if self.loudSpeaker then
				info = info .. "<br>[Phone] " .. self.myChannels[self.plugin_data.radioChannel].name .. " 🎧  🎤 🔊<br>"
			else
				info = info .. "<br>[Phone] " .. self.myChannels[self.plugin_data.radioChannel].name .. " 🎧  🎤<br>"
			end

	    else
				info = info .. getRadioDisplay(self);
	    end
	end
	if (info == self.screenInfo and not forceUpdate) then return end
	self.screenInfo = info;
	self:updatePlugin("updateTokovoipInfo", "" .. info);
end

function TokoVoip.updatePlugin(self, event, payload)
	exports.tokovoip_script:doSendNuiMessage(event, payload);
end

function TokoVoip.updateConfig(self)
	local data = self.config;
	data.plugin_data = self.plugin_data;
	data.pluginVersion = self.pluginVersion;
	data.pluginStatus = self.pluginStatus;
	data.pluginUUID = self.pluginUUID;
	self:updatePlugin("updateConfig", data);
end

function TokoVoip.initialize(self)
	self:updateConfig();
	self:updatePlugin("initializeSocket", nil);
	Citizen.CreateThread(function()
		while (true) do
			Citizen.Wait(5);

			if (IsControlJustPressed(0, self.keyProximity)) then -- Switch proximity modes (normal / whisper / shout)
				if (not self.mode) then
					self.mode = 1;
				end
				self.mode = self.mode + 1;
				if (self.mode > 3) then
					self.mode = 1;
				end
				TriggerEvent("voip:settizng",self.mode)
				setPlayerData(self.serverId, "voip:mode", self.mode, true);
				self:updateTokoVoipInfo();
			elseif (IsControlJustPressed(0, self.keyToggleLoudSpeaker)) then
				self.loudSpeaker = not self.loudSpeaker 
				setPlayerData(self.serverId, "voip:loudSpeaker", self.loudSpeaker, true);
			elseif (IsControlJustPressed(0, self.keySecondaryRadioToggle) and IsControlPressed(0, self.radioKey) and self.broadcasting) then
				self.toggleRadio = not self.toggleRadio 
				setPlayerData(self.serverId, "voip:toggleRadio", self.toggleRadio, false);
			end

			if ((self.broadcasting and self.toggleRadio) or (IsControlPressed(0, self.radioKey)) and self.plugin_data.radioChannel ~= -1 and not exports["isPed"]:isPed("dead")) and not self.blockRadio then-- Talk on radio
				self.plugin_data.radioTalking = true;
				self.plugin_data.localRadioClicks = true;
				if self.plugin_data.default_local_click_on == nil then self.plugin_data.default_local_click_on = false end

				if (self.plugin_data.radioChannel > 100 and self.plugin_data.radioChannel < 999 or self.plugin_data.radioChannel == self.listenBroadcast or ValidCast[self.plugin_data.radioChannel]) then -- Phone range
					self.plugin_data.localRadioClicks = false;
					self.plugin_data.remote_click_off = false;
				elseif (self.plugin_data.radioChannel >= 1000 and self.plugin_data.radioChannel <= 9999)then -- Radio range
					self.plugin_data.local_click_on = self.plugin_data.default_local_click_on;
					self.plugin_data.remote_click_off = true;
				else -- Should only be emergency channels 
					self.plugin_data.local_click_on = self.plugin_data.default_local_click_on;
					self.plugin_data.remote_click_off = true;
				end

				if (not getPlayerData(self.serverId, "radio:talking")) then
					setPlayerData(self.serverId, "radio:talking", true, true);
					self:updateTokoVoipInfo();
				end
				
				
				if (lastTalkState == false and self.myChannels[self.plugin_data.radioChannel]) then
					if (not string.match(self.myChannels[self.plugin_data.radioChannel].name, "Call") and not IsPedSittingInAnyVehicle(PlayerPedId())) and self.plugin_data.radioChannel ~= self.listenBroadcast then
						RequestAnimDict("random@arrests");
						while not HasAnimDictLoaded("random@arrests") do
							Wait(5);
						end
						TaskPlayAnim(PlayerPedId(),"random@arrests","generic_radio_chatter", 8.0, 0.0, -1, 49, 0, 0, 0, 0);
					end
					lastTalkState = true
				end
			else
				if self.talking ~= lastTalking or self.plugin_data.radioTalking == true then
					if self.plugin_data.radioTalking == true then
						self.plugin_data.radioTalking = false;
						if (getPlayerData(self.serverId, "radio:talking")) then
							setPlayerData(self.serverId, "radio:talking", false, true);
						end
					end
					if self.talking ~= lastTalking then
						lastTalking = self.talking
					end
					self:updateTokoVoipInfo();
				end

				if lastTalkState == true then
					lastTalkState = false
					StopAnimTask(PlayerPedId(), "random@arrests","generic_radio_chatter", -4.0);
				end
			end
		end
	end);
end

function TokoVoip.disconnect(self)
	self:updatePlugin("disconnect");
end
