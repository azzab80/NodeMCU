local THRESHOLD = 500 

-- get bed occupancy
local function get_bed_occupancy()
    CURR_PRES = adc.read(0)
    if CURR_PRES > 200 then
        INBED = "true"
    else
        INBED = "false"
    return INBED 
  end
end


tmr.alarm(2, 10000, tmr.ALARM_AUTO, function()
  get_bed_occupancy()
  print("Current Pressure " .. INBED)
end)