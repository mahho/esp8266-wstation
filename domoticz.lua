
local moduleName = ... 
local M = {}
_G[moduleName] = M

local conn
local myHost 
local myPort 
local queue

function M.init(host, port)
    myHost = host
    myPort = port
    queue = {}

    conn = net.createConnection(net.TCP, 0)
    conn:connect(port, host)

    tmr.alarm(3, 500, 1, function()
        processQueue()
    end)
end

function processQueue()
    if table.getn(queue) > 0 then
        print ("Sending to domoticz device " .. queue[1]["idx"] .. " values " .. queue[1]["values"])

        conn:send("GET /json.htm?type=command&param=udevice&idx=" .. queue[1]["idx"] .. "&nvalue=0&svalue=" .. queue[1]["values"] .. " HTTP/1.1\r\nHost: pi\r\n"
         .."Connection: keep-alive\r\nAccept: */*\r\n\r\n", function(send)
            print("sending")
        end)
        conn:on("sent", function(conn, payload) 
            table.remove(queue, 1)
        end)        
    end
end

function M.sendData(idx, data)
    values = table.concat(data, ";") --> "a,b,c"
    queueData = {}
    queueData["idx"] = idx
    queueData["values"] = values
    table.insert(queue, queueData)
end

function M.getQueueSize()
    return table.getn(queue)
end

return M
