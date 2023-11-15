-- Archivo: mensaje_en_el_aire.lua

local mensajeFlotante = {
    activo = false,
    texto = "",
    tiempoDeUso = 0
}

-- Comando para mostrar o eliminar un mensaje en el aire
RegisterCommand("msj", function(source, args, rawCommand)
    local currentTime = GetGameTimer()

    -- Verifica si el mensaje está activo
    if mensajeFlotante.activo then
        -- Eliminamos el mensaje
        DesactivarMensajeFlotante()
    elseif currentTime > mensajeFlotante.tiempoDeUso then
        -- Obtenemos las coordenadas del jugador que ejecuta el comando
        local player = GetPlayerPed(-1)
        local x, y, z = table.unpack(GetEntityCoords(player))

        -- Creamos el texto del mensaje
        mensajeFlotante.texto = table.concat(args, " ") -- Concatenamos los argumentos del comando
        mensajeFlotante.tiempoDeUso = currentTime + 30 * 1000 -- Establece el tiempo de uso en 30 segundos

        -- Activamos el mensaje y lo transmitimos a todos los jugadores
        ActivarMensajeFlotante(x, y, z, mensajeFlotante.texto)
        TriggerServerEvent("transmitirMensaje", mensajeFlotante.texto, x, y, z, mensajeFlotante.tiempoDeUso)
    else
        -- Mensaje de espera, puedes personalizarlo según tus necesidades
        TriggerEvent("chatMessage", "Sistema", {255, 0, 0}, "Debes esperar 30 segundos antes de mostrar otro mensaje.")
    end
end, false)

-- Función para activar el mensaje flotante
function ActivarMensajeFlotante(x, y, z, mensaje)
    mensajeFlotante.activo = true
    mensajeFlotante.texto = mensaje

    Citizen.CreateThread(function()
        while mensajeFlotante.activo do
            local player = GetPlayerPed(-1)
            local px, py, pz = table.unpack(GetEntityCoords(player))

            local distance = GetDistanceBetweenCoords(px, py, pz, x, y, z, true)

            -- Dibuja el texto solo si está a 16 metros de distancia o menos (ajustado según la necesidad)
            if distance <= 16.0 then
                DrawText3D(mensajeFlotante.texto, x, y, z)
            end

            Citizen.Wait(0)
        end
    end)
end

-- Función para eliminar el mensaje flotante
function DesactivarMensajeFlotante()
    mensajeFlotante.activo = false
    mensajeFlotante.texto = ""
    mensajeFlotante.tiempoDeUso = GetGameTimer() + 30 * 1000 -- Establece el tiempo de espera de 30 segundos

    -- Transmitimos la desactivación del mensaje a todos los jugadores
    TriggerServerEvent("transmitirMensaje", "", 0, 0, 0, mensajeFlotante.tiempoDeUso)
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

-- Función para calcular la distancia entre dos puntos en 3D
function GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2, useZ)
    useZ = useZ or false
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = useZ and (z1 - z2) or 0.0
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end


