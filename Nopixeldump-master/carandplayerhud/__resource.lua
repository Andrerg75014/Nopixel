resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'


client_script "@np-errorlog/client/cl_errorlog.lua"

client_script 'carhud.lua'
server_script 'carhud_server.lua'
client_script 'cl_autoKick.lua'
server_script 'sr_autoKick.lua'
client_script 'newsStands.lua'

exports {
	"playerLocation",
	"playerZone"
}
