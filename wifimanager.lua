
local moduleName = ... 
local M = {}
_G[moduleName] = M

local connected
local counter
local connectionTime
local cannotConnect

function M.connect(SSID, KEY)
    connected = false
    cannotConnect = false
    connectionTime = 0
    starttimer = tmr.now()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID, KEY)
    wifi.sta.connect()
    realtype = wifi.sleeptype(wifi.LIGHT_SLEEP)

    counter = 0
    tmr.alarm(2, 1000, 1, function()
        if wifi.sta.getip() == nil then
            if counter == 0 then
                uart.write(0, "Connecting to " .. SSID)
            else 
                uart.write(0, ".")
            end
            counter = counter + 1
            if (counter > 20) then
                print(" Connection to " .. SSID .. " failed")
                connected = false
                cannotConnect = true
                tmr.stop(2)
            end
        else
            tmr.stop(2)
            connected = true
            connectionTime = tmr.now() - starttimer
        
            print(" Connected to " .. SSID)
            print("ESP8266 mode is: " .. wifi.getmode())
            print("The module MAC address is: " .. wifi.ap.getmac())
            print("Config done, IP is " .. wifi.sta.getip())
            -- wifi.sleeptype(wifi.LIGHT_SLEEP)
        end
    end)
end

function M.cannotConnect()
    return cannotConnect
end 

function M.getConnectionTime()
    return connectionTime
end

function M.isConnected()
    return connected
end

function M.disconnect()
    wifi.sta.disconnect()
end

return M
