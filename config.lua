--
-- Basic configuration
--
-- This should be the same for all my apps. Secrets are stored in secrets.lua
--
local module = {}

-- identify NodeMCU by chipid
local nodenames = {}
nodenames[16230360] = "balcony"
nodenames[16230361] = "nodedev"
nodenames[16230884] = "bedsensor"
nodenames[7536954] = "irrigation"
module.SELF = nodenames[node.chipid()]
if module.SELF == nil then
  module.SELF = node.chipid()
  print("FAILED TO IDENTIFY NODEMCU CHIP")
end

-- configure wifi
module.WIFI = {}
module.WIFI.ssid = "NETGEAR93"
module.WIFI.pwd = G.secrets.WIFIPASS

-- configure MQTT
module.MQTT = {}
module.MQTT.host = "192.168.0.20"
module.MQTT.port = 1883
module.MQTT.user = "mqtt"
module.MQTT.pass = G.secrets.MQTTPASS
module.MQTT.endpoint = "/home-assistant/" .. module.SELF .. "/"

return module
