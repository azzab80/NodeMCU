--
-- Plant watering mechanism on the balcony
--
-- Controls the pump and reads the water level sensor
--
local module = {}

local dataInt = 60

-- local PIN_LEVEL = 1 -- GPIO5
-- local PIN_PUMP  = 2 -- GPIO4
time_between_sensor_readings = 30000

-- speed is 0 - 100
function motor(pin_speed, pin_dir, dir, speed)
  gpio.write(pin_dir,dir)
  pwm.setduty(pin_speed, (speed * duty) / 100)
end

function motor_a(dir, speed)
  motor(pin_a_speed, pin_a_dir, dir, speed)
end

function module.gotosleep()
  print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds")
  node.dsleep(time_between_sensor_readings*1000)   
end
  -- start the pump
--
-- checks the current water level and does nothing if it's too low
--
function module.start_pump()
  print "pump requested"
  -- if(get_current_level() == 1) then
  print "PUMP STARTED"
  motor_a(FWD, 100)
  G.mqtt.publish("sensor/pump", "1", 1)
    -- safety: shut down after 90s
  tmr.create():alarm(90 * 1000, tmr.ALARM_SINGLE, module.stop_pump)
  -- tmr.create():alarm(95 * 1000, tmr.ALARM_SINGLE, module.gotosleep)
end

-- stop the pump
function module.stop_pump()
  print "PUMP STOPPED"
  motor_a(FWD, 0)
  G.mqtt.publish("sensor/pump", "0", 1)
end

function module.read_sensors()
  local moisture = adc.read(0)/10
  print("Publishing to sensor/moisture" .. ": " .. moisture)	-- print a status message
  G.mqtt.publish("sensor/moisture", moisture, 1, 1)
end

-- configure everything
local function setup()
  -- publish current level after startup
  G.mqtt.waitThen(function()
    -- local level = get_current_level()
    -- G.mqtt.publish("sensor/waterlevel", level, 1, 1)
  end)

  -- start wifi and mqtt
  G.wifi.waitThen(G.mqtt.start)

  -- water level monitoring by interrupt
  -- gpio.mode(PIN_LEVEL, gpio.INT, gpio.PULLUP)
  -- gpio.trig(PIN_LEVEL, "down", on_level_change)

  -- setup pump
  pin_a_speed = 2
  pin_a_dir = 3
  
  FWD = gpio.HIGH
  REV = gpio.LOW
  
  duty = 1023
  
  --initiate motor A
  gpio.mode(pin_a_speed,gpio.OUTPUT)
  gpio.write(pin_a_speed,gpio.LOW)
  pwm.setup(pin_a_speed,1000,duty) --PWM 1KHz, Duty 1023
  pwm.start(pin_a_speed)
  pwm.setduty(pin_a_speed,0)
  gpio.mode(pin_a_dir,gpio.OUTPUT)


  -- register for pump commands
  G.mqtt.subscribe("switch/pump", function(data)
    if(data == "1") then
      module.start_pump()
    else
      module.stop_pump()
      --module.gotosleep()
    end
  end)
  -- turn off the pump on startup
  module.stop_pump()

  -- Start moisture reads
  tmr.alarm(0, (dataInt * 1000), 1, module.read_sensors)
end

-- run the application
function module.start()
  setup()
end

return module
