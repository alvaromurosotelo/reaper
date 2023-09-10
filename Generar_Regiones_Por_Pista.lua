-- Obtener el número de pistas en el proyecto
local numTracks = reaper.CountTracks(0)

-- Crear una tabla para almacenar las regiones
local regions = {}

-- Inicializar la variable para rastrear el punto de inicio de la siguiente región
local nextRegionStart = 0

-- Iterar a través de todas las pistas
for i = 0, numTracks - 1 do
    local track = reaper.GetTrack(0, i) -- Obtener la pista actual
    local _, trackName = reaper.GetTrackName(track, "") -- Obtener el nombre de la pista actual
    
    local itemCount = reaper.CountTrackMediaItems(track) -- Obtener el número de ítems en la pista
    
    -- Iterar a través de los ítems en la pista actual
    for j = 0, itemCount - 1 do
        local item = reaper.GetTrackMediaItem(track, j) -- Obtener el ítem actual
        local startTime = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local endTime = startTime + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        local regionName = trackName -- Usar el nombre de la pista como nombre de la región
        
        -- Verificar si ya existe una región con el mismo nombre y rango de tiempo
        local regionExists = false
        for _, existingRegion in ipairs(regions) do
            if existingRegion.name == regionName and existingRegion.start_time <= startTime and existingRegion.end_time >= endTime then
                regionExists = true
                break
            end
        end
        
        -- Si no existe una región con el mismo nombre y rango, crear una nueva región
        if not regionExists then
            -- Asegurarse de que el punto de inicio de la región sea igual al punto de finalización del item anterior
            if startTime > nextRegionStart then
                nextRegionStart = startTime
            end
            
            reaper.AddProjectMarker2(0, true, nextRegionStart, endTime, regionName, -1, 0)
            
            -- Actualizar el punto de inicio de la siguiente región
            nextRegionStart = endTime
            
            table.insert(regions, {
                name = regionName,
                start_time = nextRegionStart,
                end_time = endTime
            })
        end
    end
end

reaper.UpdateArrange()

