TokoVoipConfig = {
	refreshRate = 400, -- Rate at which the data is sent to the TSPlugin
	serverRefreshRate = 20000, -- rate at wich the client updates the server with its current information
	networkRefreshRate = 3000, -- Rate at which the network data is updated/reset on the local ped
	playerListRefreshRate = 15000, -- Rate at which the playerList is updated
	minVersion = "1.2.4", -- Version of the TS plugin required to play on the server

	distance = {
		12, -- Normal speech distance in gta distance units
		4, -- Whisper speech distance in gta distance units
		34, -- Shout speech distance in gta distance units
	},
	headingType = 0, -- headingType 0 uses GetGameplayCamRot, basing heading on the camera's heading, to match how other GTA sounds work. headingType 1 uses GetEntityHeading which is based on the character's direction
	radioKey = Keys["CAPS"], -- Keybind used to talk on the radio
	keySwitchChannels = Keys["="], -- Keybind used to switch the radio channels
	keySwitchChannelsSecondary = Keys["="], -- If set, both the keySwitchChannels and keySwitchChannelsSecondary keybinds must be pressed to switch the radio channels
	keyToggleLoudSpeaker = Keys["-"],
	keySecondaryRadioToggle = Keys["LEFTCTRL"],
	keyProximity = Keys["G"], -- Keybind used to switch the proximity mode
	minVolume = 20, -- The lowest volume heared at the furthest point for proximity volume, larger number means quieter
	
	plugin_data = {
		-- TeamSpeak channel name used by the voip
		-- If the TSChannelWait is enabled, players who are currently in TSChannelWait will be automatically moved
		-- to the TSChannel once everything is running
		TSChannel = "TokoVoipCourt",
		TSPassword = "153yh143y5680124yt314y", -- TeamSpeak channel password (can be empty)

		-- Optional: TeamSpeak waiting channel name, players wait in this channel and will be moved to the TSChannel automatically
		-- If the TSChannel is public and people can join directly, you can leave this empty and not use the auto-move
		TSChannelWait = "AFK",
		
		-- Blocking screen informations
		TSServer = "ts.nopixel.net", -- TeamSpeak server address to be displayed on blocking screen
		TSChannelSupport = "Support", -- TeamSpeak support channel name displayed on blocking screen
		TSDownload = "https://www.nopixel.net", -- Download link displayed on blocking screen
		TSChannelWhitelist = { -- Black screen will not be displayed when users are in those TS channels
			"Support 2",
		},

		-- The following is purely TS client settings, to match tastes
		local_click_on = true, -- Is local click on sound active
		local_click_off = true, -- Is local click off sound active
		remote_click_on = true, -- Is remote click on sound active
		remote_click_off = true, -- Is remote click off sound active
		enableStereoAudio = true, -- If set to true, positional audio will be stereo (you can hear people more on the left or the right around you)
		ClickVolume = "15",
		localName = "", -- If set, this name will be used as the user's teamspeak display name
		localNamePrefix = "", -- If set, this prefix will be added to the user's teamspeak display name

		default_local_click_on = local_click_on,
		default_ClickVolume = ClickVolume,
	}
};

AddEventHandler("onClientResourceStart", function(resource)
	if (resource == GetCurrentResourceName()) then	--	Initialize the script when this resource is started
		TokoVoipConfig.plugin_data.localName = escape(GetPlayerName(PlayerId())); -- Set the local name
		TriggerEvent("initializeVoip"); -- Trigger this event whenever you want to start the voip
	end
end)

