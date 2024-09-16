-- @description Dantepog_AssetsOrganization
-- @author Dantepog
-- @version 1.02
-- @about
--    ## Assets Organization
--    AssetsOrganization is a script designed to optimize the workflow and organization of assets within our project.
--    - This scripts use "ReaImGui - ReaScript Binding for Dear ImGui" and "js_ReaScript API" to work. Install them on your Reaper using Reapack with the "ReaTeam Extension" Repository -
--
--
--    Thank fo using this Script. Dantepog
-- @provides
--    [nomain] Functions/*.lua



-- Load functions from the functions script
dofile(reaper.GetResourcePath().."/Scripts/Dantepog Scripts/Items/AssetsOrganization/Functions/AssetsOrganization_Functions.lua")

-- Load the graphical interface from the interface script
dofile(reaper.GetResourcePath().."/Scripts/Dantepog Scripts/Items/AssetsOrganization/Functions/AssetsOrganization_GUI.lua")


-- Variables globales
ScriptVersion = "1.01"
ScriptName = 'Assets Organization'
local storageFile = reaper.GetResourcePath().."/Scripts/Dantepog Scripts/Items/AssetsOrganization/Functions/AssetsOrganization_Storage.lua"

-- Tabla para almacenar los nombres de los tracks por color
trackNames = {}
colors_ID = {}
lastSelectedTrack = nil
organizeSuccess = false  -- Variable para almacenar el estado de la organización

-- Función para cargar los nombres desde el archivo
function loadTrackNames()
    local file = io.open(storageFile, "r")
    if file then
      local content = file:read("*a")
      file:close()
      local chunk = load(content)
      if chunk then
        trackNames = chunk() or {}
      else
        trackNames = {}
      end
    else
      trackNames = {}
    end
  end
  
-- Función para guardar los nombres en el archivo
function saveTrackNames()
    local file = io.open(storageFile, "w")
    if file then
      file:write("return " .. table.tostring(trackNames))
      file:close()
    end
  end

  -- Función para convertir una tabla a una cadena (para guardar en archivo)
function table.tostring(tbl)
    local result, done = {}, {}
    for k, v in pairs(tbl) do
      table.insert(result, string.format("[%q]=%q", k, v))
    end
    return "{" .. table.concat(result, ",") .. "}"
  end
  -- Función para restablecer los valores por defecto
function resetTrackNames(colorString)
    if colorString then
      trackNames[colorString] = nil
    else
      trackNames = {}
    end
    saveTrackNames()
  end
  
  organizeSuccess = false  -- Variable para almacenar el estado de la organización
-- Inicialización
loadTrackNames()
GuitInit()
updateColorsAndNames()
reaper.defer(loop)