WIFI_SSID = "Network ESSID"
WIFI_KEY = "Network password"
DOMOTICZ_PORT = 8080
DOMOTICZ_HOST = "192.168.X.Y"

-- PINS
DHT22_PIN = 4 -- data pin, GPIO2

reportInterval = 300 -- esp deepsleep time in seconds

------------------------------------------------
wifimanager = require("wifimanager")
domoticz = require("domoticz")
canSleep = false
prepareToSleep = false
reportStarted = false
warmupCounter = 3
function report()
    wifimanager.connect(WIFI_SSID, WIFI_KEY)
    tmr.alarm(1, 100, 1, function()
        if reportStarted == true then
            if wifimanager.isConnected() == true and canSleep == false then
                domoticz.init(DOMOTICZ_HOST, DOMOTICZ_PORT)

                status, temp, humi, temp_dec, humi_dec = dht.readxx(DHT22_PIN)                
                if status == dht.OK then
                    domoticz.sendData(1, {temp, humi})
                end

                canSleep = true
            end

            if canSleep == true and domoticz ~= nil and domoticz.getQueueSize() == 0 then
                print("Going sleep")
                tmr.stop(1)
                node.dsleep(1000000 * reportInterval, 0)
            end
        end
    end)
end

uart.write(0, "Starting in ")
tmr.alarm(0, 1000, 1, function() 
    if (warmupCounter > 0) then 
        uart.write(0, warmupCounter .. "... ")
        warmupCounter = warmupCounter - 1
    else 
        print("0")
        reportStarted = true
        tmr.stop(0)
        report()
    end
end)

