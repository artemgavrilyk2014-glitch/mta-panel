-- MTA Panel - Lua HTTP Resource
-- Встанови цей ресурс на MTA сервері як "mta_panel"
-- Файл: mta_panel/server.lua

local secret = "your_secret_key_here" -- Змін це на свій секретний ключ

-- Перевірка секретного ключа
local function checkAuth(request)
    local key = request.headers and request.headers["X-Secret-Key"]
    return key == secret
end

-- Список гравців
addHTTPHandler("players", function(request, response)
    if not checkAuth(request) then
        response.statusCode = 403
        response.write('{"error":"Unauthorized"}')
        return
    end
    
    local players = {}
    for _, player in ipairs(getElementsByType("player")) do
        table.insert(players, {
            name = getPlayerName(player),
            ping = getPlayerPing(player),
            serial = getPlayerSerial(player)
        })
    end
    
    response.headers["Content-Type"] = "application/json"
    response.write(toJSON({
        players = players,
        count = #players
    }))
end)

-- Інформація про сервер
addHTTPHandler("info", function(request, response)
    if not checkAuth(request) then
        response.statusCode = 403
        response.write('{"error":"Unauthorized"}')
        return
    end
    
    response.headers["Content-Type"] = "application/json"
    response.write(toJSON({
        playerCount = #getElementsByType("player"),
        maxPlayers = getMaxPlayers(),
        serverName = getServerName(),
        uptime = getTickCount()
    }))
end)

-- Кік гравця
addHTTPHandler("kick", function(request, response)
    if not checkAuth(request) then
        response.statusCode = 403
        response.write('{"error":"Unauthorized"}')
        return
    end
    
    local data = fromJSON(request.body or "{}")
    if not data or not data.name then
        response.statusCode = 400
        response.write('{"error":"Missing name"}')
        return
    end
    
    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerName(player) == data.name then
            kickPlayer(player, data.reason or "Kicked by admin")
            response.write('{"success":true}')
            return
        end
    end
    
    response.statusCode = 404
    response.write('{"error":"Player not found"}')
end)

-- Бан гравця
addHTTPHandler("ban", function(request, response)
    if not checkAuth(request) then
        response.statusCode = 403
        response.write('{"error":"Unauthorized"}')
        return
    end
    
    local data = fromJSON(request.body or "{}")
    if not data or not data.name then
        response.statusCode = 400
        response.write('{"error":"Missing name"}')
        return
    end
    
    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerName(player) == data.name then
            banPlayer(player, false, data.reason or "Banned by admin")
            response.write('{"success":true}')
            return
        end
    end
    
    response.statusCode = 404
    response.write('{"error":"Player not found"}')
end)

outputServerLog("[MTA Panel] HTTP API запущено!")
