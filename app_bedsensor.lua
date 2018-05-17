-- Bed Occupancy Sensor via MQTT

local module = {}

-- Set bed sensor threshold
local THRESHOLD = 20 
local BEDCOUNT = 0

-- get bed occupancy
local function get_bed_occupancy()
    CURR_PRES = adc.read(0)
    print(CURR_PRES)
    if CURR_PRES > 850 then
        INBED = "1"
    else
        INBED = "0"
    return INBED 
  end
end


local function setup()
-- publish sensor after startup
    -- G.mqtt.waitThen(function()
    --     local level = get_bed_occupancy()
    --     G.mqtt.publish("sensor/inbed", level, 1, 1)
    -- end)

-- start wifi and mqtt
G.wifi.waitThen(G.mqtt.start)

tmr.alarm(2, 10000, tmr.ALARM_AUTO, function()
    get_bed_occupancy()
    print("Current Pressure " .. INBED)
    if INBED == "1" then
        G.mqtt.publish("sensor/inbed", "1", 1, 1)
        BEDCOUNT = 0
    else
        BEDCOUNT = BEDCOUNT +1
        if BEDCOUNT == 2 then
            G.mqtt.publish("sensor/inbed", "0", 1, 1)
            print("Out Of Bed Count " .. BEDCOUNT)
            BEDCOUNT = 0
        end
    end
end)
end



-- run the application
function module.start()
    setup()
  end
  
  return module