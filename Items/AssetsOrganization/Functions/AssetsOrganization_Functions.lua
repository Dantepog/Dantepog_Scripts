-- @noindex
-- Function to get a track by name
function getTrackByName(trackName)
    local trackCount = reaper.CountTracks(0)
    for i = 0, trackCount - 1 do
        local track = reaper.GetTrack(0, i)
        retval, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
        if name == trackName then
            return track
        end
    end
    return nil
end

-- Function to create a new track with a specific name and color
function createTrackWithNameAndColor(trackName, color, trackNames)
    reaper.InsertTrackAtIndex(reaper.CountTracks(0), false)
    local track = reaper.GetTrack(0, reaper.CountTracks(0) - 1)
    local colorString = string.format("%06X", color & 0xFFFFFF)
    local finalTrackName = trackNames[colorString] or ("Color " .. colorString)
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", finalTrackName, true)
    reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", color | 0x1000000) -- Añadir el bit de alpha
    return track
end

-- Function to move items to a specific track and position
function moveItemToTrackAndPosition(item, track, position)
    reaper.MoveMediaItemToTrack(item, track)
    reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
end

-- Function to get the final position of a track
function getFinalPositionOfTrack(track)
    local itemCount = reaper.CountTrackMediaItems(track)
    local finalPosition = 0

    for i = 0, itemCount - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        if item then
            local itemEnd = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            if itemEnd > finalPosition then
                finalPosition = itemEnd
            end
        end
    end

    return finalPosition
end

-- Main function to organize items
function organize_items_by_color(trackNames)
    reaper.Undo_BeginBlock()

    local selectedTrack = reaper.GetSelectedTrack(0, 0)
    if not selectedTrack then
        reaper.ShowMessageBox("Please select a track.", "Error", 0)
        return false
    end

    local itemCount = reaper.CountTrackMediaItems(selectedTrack)
    local colorTrackMap = {}
    local colorItemsMap = {}
    local colorPositionMap = {}

    -- Collect items by color
    for i = 0, itemCount - 1 do
        local item = reaper.GetTrackMediaItem(selectedTrack, i)
        if item then
            local color = reaper.GetMediaItemInfo_Value(item, "I_CUSTOMCOLOR")

            if color ~= 0 then
                local colorString = string.format("%06X", color & 0xFFFFFF)
                if not colorItemsMap[colorString] then
                    colorItemsMap[colorString] = {}
                end
                table.insert(colorItemsMap[colorString], item)
            end
        end
    end

    -- Create tracks by color and move items
    for colorString, items in pairs(colorItemsMap) do
        local color = tonumber(colorString, 16)
        if not colorTrackMap[colorString] then
            local trackName = trackNames[colorString] or "Color " .. colorString
            local track = getTrackByName(trackName)
            if not track then
                track = createTrackWithNameAndColor(trackName, color, trackNames)
            end
            colorTrackMap[colorString] = track
            colorPositionMap[colorString] = getFinalPositionOfTrack(track)
        end

        local track = colorTrackMap[colorString]
        local position = colorPositionMap[colorString]

        for _, item in ipairs(items) do
            moveItemToTrackAndPosition(item, track, position)
            local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            position = position + itemLength
        end

        colorPositionMap[colorString] = position
    end

    reaper.UpdateArrange()
    reaper.Undo_EndBlock("Organize items by color", -1)
    return true
end
