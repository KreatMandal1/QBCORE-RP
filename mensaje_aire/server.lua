-- Archivo: server.lua

-- Evento del servidor para transmitir el mensaje a todos los jugadores
RegisterServerEvent("transmitirMensaje")
AddEventHandler("transmitirMensaje", function(mensaje, x, y, z, tiempoLimite)
    -- Transmitir el mensaje a todos los jugadores
    TriggerClientEvent("transmitirMensaje", -1, mensaje, x, y, z, tiempoLimite)
end)
