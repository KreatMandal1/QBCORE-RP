RegisterServerEvent("transmitirMensaje")
AddEventHandler("transmitirMensaje", function(playerId, activo, x, y, z, mensaje, tiempoLimite)
    TriggerClientEvent("recibirMensajeSobreJugador", playerId, activo, x, y, z, mensaje, tiempoLimite)
end)