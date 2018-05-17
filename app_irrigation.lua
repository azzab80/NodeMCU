--
-- Plant watering mechanism on the balcony
--
-- Controls the pump and reads the water level sensor
--
local module = {}

-- local PIN_LEVEL = 1 -- GPIO5
local PIN_PUMP  = 0
local PIN_RELAY1 = 1
local PIN_RELAY2 = 2
local PIN_RELAY3 = 6
local PIN_RELAY4 = 7

local PIN_MOISTURE = 0

-- data interval
local dataInt = 60

-- start the pump
function module.start_pump()
  print "pump requested"
  gpio.write(PIN_PUMP,gpio.HIGH)
  print "PUMP STARTED"
  G.mqtt.publish("sensor/pump", "1", 1)
    -- safety: shut down after 180s
  tmr.create():alarm(180 * 1000, tmr.ALARM_SINGLE, module.stop_pump)
end

-- stop the pump
function module.stop_pump()
  print "PUMP STOPPED"
  gpio.write(PIN_PUMP,gpio.LOW)
  G.mqtt.publish("sensor/pump", "0", 1)
end

function module.read_sensors()

  local moisture = adc.read(PIN_MOISTURE)
  print("Publishing to sensor/moisture" .. ": " .. moisture)	-- print a status message
  G.mqtt.publish("sensor/moisture", moisture, 1, 1)

end

function module.check_relays()

  if(gpio.read(PIN_RELAY1) == 1) then
    G.mqtt.publish("sensor/relay1", "1", 1)
  else
    G.mqtt.publish("sensor/relay1", "0", 1)
  end

  if(gpio.read(PIN_RELAY2) == 1) then
    G.mqtt.publish("sensor/relay2", "1", 1)
  else
    G.mqtt.publish("sensor/relay2", "0", 1)
  end

  if(gpio.read(PIN_RELAY3) == 1) then
    G.mqtt.publish("sensor/relay3", "1", 1)
  else
    G.mqtt.publish("sensor/relay3", "0", 1)
  end

  if(gpio.read(PIN_RELAY4) == 1) then
    G.mqtt.publish("sensor/relay4", "1", 1)
  else
    G.mqtt.publish("sensor/relay4", "0", 1)
  end

end

-- configure everything
local function setup()
  -- publish current level after startup
  G.mqtt.waitThen(function()
    local moisture = adc.read(PIN_MOISTURE)
    --local moisture = 2
    G.mqtt.publish("sensor/moisture", moisture, 1, 1)
  end)

  -- start wifi and mqtt
  G.wifi.waitThen(G.mqtt.start)

  --initiate pump
  gpio.mode(PIN_PUMP,gpio.OUTPUT)
  gpio.write(PIN_PUMP,gpio.LOW)

  --initiate relays
  gpio.mode(PIN_RELAY1,gpio.OUTPUT)
  gpio.write(PIN_RELAY1,gpio.LOW)

  gpio.mode(PIN_RELAY2,gpio.OUTPUT)
  gpio.write(PIN_RELAY2,gpio.LOW)

  gpio.mode(PIN_RELAY3,gpio.OUTPUT)
  gpio.write(PIN_RELAY3,gpio.LOW)

  gpio.mode(PIN_RELAY4,gpio.OUTPUT)
  gpio.write(PIN_RELAY4,gpio.LOW)


  -- register for pump commands
  G.mqtt.subscribe("switch/pump", function(data)
    if(data == "1") then
      module.start_pump()
    else
      module.stop_pump()
    end
  end)

  -- register for relay commands
  G.mqtt.subscribe("switch/relay1", function(data)
    if(data == "1") then
      gpio.write(PIN_RELAY1,gpio.HIGH)
      G.mqtt.publish("sensor/relay1", "1", 1)
    else
      gpio.write(PIN_RELAY1,gpio.LOW)
      G.mqtt.publish("sensor/relay1", "0", 1)
    end
  end)

  G.mqtt.subscribe("switch/relay2", function(data)
    if(data == "1") then
      gpio.write(PIN_RELAY2,gpio.HIGH)
      G.mqtt.publish("sensor/relay2", "1", 1)
    else
      gpio.write(PIN_RELAY2,gpio.LOW)
      G.mqtt.publish("sensor/relay2", "0", 1)
    end
  end)

  G.mqtt.subscribe("switch/relay3", function(data)
    if(data == "1") then
      gpio.write(PIN_RELAY3,gpio.HIGH)
      G.mqtt.publish("sensor/relay3", "1", 1)
    else
      gpio.write(PIN_RELAY3,gpio.LOW)
      G.mqtt.publish("sensor/relay3", "0", 1)
    end
  end)

  G.mqtt.subscribe("switch/relay4", function(data)
    if(data == "1") then
      gpio.write(PIN_RELAY4,gpio.HIGH)
      G.mqtt.publish("sensor/relay4", "1", 1)
    else
      gpio.write(PIN_RELAY4,gpio.LOW)
      G.mqtt.publish("sensor/relay4", "0", 1)
    end
  end)

  -- turn off the pump on startup
  module.stop_pump()

  -- Start moisture reads
  tmr.alarm(0, (dataInt * 1000), 1, module.read_sensors)
  
  -- Start relays reads
  tmr.alarm(0, (dataInt * 100), 1, module.check_relays)
  
end

-- run the application
function module.start()
  setup()
end

return module
