local mensajeSobreJugador = {
    activo = false,
    mensaje = "",
    tiempoLimite = 0
}

local cooldown = 30 * 1000  -- Tiempo de espera en milisegundos (30 segundos)

-- Comando para activar o desactivar el mensaje en el aire
RegisterCommand("doo", function(source, args, rawCommand)
    local playerId = source
    local currentTime = GetGameTimer()

    if not mensajeSobreJugador.activo and currentTime > mensajeSobreJugador.tiempoLimite then
        -- Obtenemos las coordenadas del jugador que ejecuta el comando
        local player = GetPlayerPed(-1)

        -- Creamos el texto del mensaje
        mensajeSobreJugador.mensaje = table.concat(args, " ") -- Concatenamos los argumentos del comando
        mensajeSobreJugador.tiempoLimite = currentTime + cooldown -- Establece el límite de tiempo

        -- Activamos el mensaje y transmitimos al servidor
        ActivarMensajeSobreJugador(playerId, player, mensajeSobreJugador.mensaje, mensajeSobreJugador.tiempoLimite)
    elseif mensajeSobreJugador.activo then
        -- Desactivamos el mensaje y transmitimos al servidor
        DesactivarMensajeSobreJugador(playerId)
    else
        -- Muestra un mensaje de espera en el chat
        TriggerEvent("chatMessage", "Sistema", {255, 0, 0}, "Debes esperar 30 segundos antes de mostrar otro mensaje.")
    end
end, false)

-- Función para activar el mensaje sobre el jugador y transmitir al servidor
function ActivarMensajeSobreJugador(playerId, player, mensaje, tiempoLimite)
    mensajeSobreJugador.activo = true

    Citizen.CreateThread(function()
        while mensajeSobreJugador.activo do
            local x, y, z = table.unpack(GetEntityCoords(player))

            -- Dibuja el texto siempre sobre el jugador
            DrawText3D(mensajeSobreJugador.mensaje, x, y, z + 1.5)

            -- Verifica si ha pasado el tiempo límite
            local currentTime = GetGameTimer()
            if currentTime > mensajeSobreJugador.tiempoLimite then
                DesactivarMensajeSobreJugador(playerId)
            end

            Citizen.Wait(0)
        end
    end)

    -- Transmitir al servidor
    TriggerServerEvent("transmitirMensaje", playerId, true, mensajeSobreJugador.mensaje, mensajeSobreJugador.tiempoLimite)
end

-- Función para desactivar el mensaje sobre el jugador y transmitir al servidor
function DesactivarMensajeSobreJugador(playerId)
    mensajeSobreJugador.activo = false
    mensajeSobreJugador.mensaje = ""

    -- Actualizar tiempo límite con cooldown
    mensajeSobreJugador.tiempoLimite = GetGameTimer() + cooldown

    -- Transmitir al servidor
    TriggerServerEvent("transmitirMensaje", playerId, false, "", mensajeSobreJugador.tiempoLimite)
end

-- Función para dibujar texto en el mundo 3D
function DrawText3D(text, x, y, z)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)

    AddTextComponentString(text)
    DrawText(_x, _y)
end
