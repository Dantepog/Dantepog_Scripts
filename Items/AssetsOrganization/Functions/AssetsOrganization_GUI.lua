-- @noindex
-- Global Variables
function GuitInit()
    -- ReaImGui Context
    ctx = reaper.ImGui_CreateContext('Assets Organization')
    WindowName = ScriptName .. ' ' .. ScriptVersion
    -- Size WindowsGui
    Gui_W = 350
    Gui_H = 500
    -- Size ChildGui
    Childgui_W = 300
    Childgui_H = 350
    -- Size ChildGuiSuccess
    SuccessGui_W = 300
    SuccessGui_H = 32
    -- Size ButtonGui
    ButtonGuiW = 145
    -- inputTextGUI
    InputTexSize = 190
    -- Size ColorButtonGui
    ColorSize = 22
    -- PosXWindow
    PosXWindow = 162


    --FontSize
    FontSize = 15

    -- Boolean variables
    Pin = true
    fontChange = true
    organizeSuccess = false -- Initialize organizeSuccess to false
end

-- Function to adjust the size of the UI and the font
function adjustScale(scale, scaleInputText, scaleSuccess, scaleFont)
    Gui_W = 350 * scale
    Gui_H = 500 * scale
    Childgui_W = 300 * scale
    Childgui_H = 350 * scale
    ButtonGuiW = 145 * scale
    ColorSize = 22 * scale
    PosXWindow = 162 * scale
    InputTexSize = 190 - scaleInputText
    SuccessGui_W = 300 * scale
    SuccessGui_H = 40 - scaleSuccess
    FontSize = 15 - scaleFont
    -- Mark that the font needs to be updated
    fontChange = true
end

-- Function to update the font if necessary
function updateFont()
    if fontChange then
        Font = reaper.ImGui_CreateFont('sans-serif', FontSize)
        reaper.ImGui_Attach(ctx, Font)
        fontChange = false
    end
end

-- Function to get item colors for a specific track
function getItemColorsForTrack(track)
    local colors = {}
    local itemCount = reaper.CountTrackMediaItems(track)
    for i = 0, itemCount - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        local color = reaper.GetMediaItemInfo_Value(item, "I_CUSTOMCOLOR")
        if color ~= 0 then
            colors[color] = true
        end
    end
    return colors
end

-- Function to convert a REAPER color to ImGui
function convertColor(reaperColor)
    local r = (reaperColor & 0xFF) / 255
    local g = ((reaperColor >> 8) & 0xFF) / 255
    local b = ((reaperColor >> 16) & 0xFF) / 255
    local a = ((reaperColor >> 24) & 0xFF) / 255
    return r, g, b, a
end

-- Function to update colors and trackNames for the selected track
function updateColorsAndNames()
    local selectedTrack = reaper.GetSelectedTrack(0, 0)
    if selectedTrack then
        colors_ID = getItemColorsForTrack(selectedTrack)
    else
        colors_ID = {}
    end
    lastSelectedTrack = selectedTrack
end

-- Function to start the graphical interface
function loop()
    updateFont()
    updateColorsAndNames()
    PushTheme() -- Apply UI styles

    -- Apply the menu bar and window size
    local window_flags = reaper.ImGui_WindowFlags_NoDocking() | reaper.ImGui_WindowFlags_AlwaysAutoResize() | reaper.ImGui_WindowFlags_MenuBar()
    if Pin then
        window_flags = window_flags | reaper.ImGui_WindowFlags_TopMost()
    end
    reaper.ImGui_SetNextWindowSize(ctx, Gui_W, Gui_H, reaper.ImGui_Cond_Once())
    reaper.ImGui_PushFont(ctx, Font)

    -- Initialize the script's visual
    local visible, open = reaper.ImGui_Begin(ctx, WindowName, true, window_flags)
    if visible then
        -- Menu with tabs to organize properties
        if reaper.ImGui_BeginMenuBar(ctx) then
            if reaper.ImGui_BeginMenu(ctx, 'Settings') then
                if reaper.ImGui_BeginMenu(ctx, 'scale') then
                    reaper.ImGui_SetItemTooltip(ctx, "Adjust the window scale") -- Tooltip explaining the function
                    if reaper.ImGui_MenuItem(ctx, '75%') then
                    adjustScale(0.75, 65, 10, 3) -- Adjust window size to 75% (scale, scaleInputText, scaleSuccess, scaleFont)
                    end
                    if reaper.ImGui_MenuItem(ctx, '100%') then
                    adjustScale(1, 0, 0, 0) -- Reset window size to default (scale, scaleInputText, scaleSuccess, scaleFont)
                    end
                reaper.ImGui_EndMenu(ctx)
                end
                reaper.ImGui_EndMenu(ctx)
            end
            if reaper.ImGui_BeginMenu(ctx, 'About') then
                --Donate
                if reaper.ImGui_BeginMenu(ctx, 'Donate') then
                    if reaper.ImGui_MenuItem(ctx, 'Paypal') then
                        reaper.CF_ShellExecute('https://www.paypal.com/paypalme/dantepog')
                    end
                    if reaper.ImGui_MenuItem(ctx, 'Mp Arg') then
                        reaper.CF_ShellExecute('https://link.mercadopago.com.ar/dantepog')
                    end
                reaper.ImGui_EndMenu(ctx)
                end
                --Documentation
                if reaper.ImGui_BeginMenu(ctx, 'Documentation') then

                    if reaper.ImGui_MenuItem(ctx, 'English') then
                        reaper.CF_ShellExecute('https://docs.google.com/document/d/1hFJVco7cOTCLycMk1RJ3eOepeKDoi2i585jOsIEaqxc/edit?usp=sharing')
                    end
                    if reaper.ImGui_MenuItem(ctx, 'Spanish') then
                        reaper.CF_ShellExecute('https://docs.google.com/document/d/1w05GoRe3G82fMZ5T_d7gjJGId3c17wrj0ymQbdQ2F-8/edit?usp=sharing')
                    end
                reaper.ImGui_EndMenu(ctx)
                end                
                 -- Website
                if reaper.ImGui_MenuItem(ctx, 'Website') then
                    reaper.CF_ShellExecute('https://dantepog.carrd.co/')
                end
                --Video
                if reaper.ImGui_MenuItem(ctx, 'Video') then
                    reaper.CF_ShellExecute('https://youtu.be/9rEwwqmUUu8?si=F-X3QeMXLEY0W1xe')
                end
                reaper.ImGui_EndMenu(ctx)
            end
            retval, Pin = reaper.ImGui_MenuItem(ctx, 'Pin', nil, Pin) -- Pin Window
            reaper.ImGui_EndMenuBar(ctx)
        end

        -- Region of text boxes by color
        local child_flags = reaper.ImGui_ChildFlags_Border() -- Flags for the text box
        reaper.ImGui_BeginChild(ctx, 'TrackNames', Childgui_W, Childgui_H, child_flags)

        -- Show track names according to color
        if lastSelectedTrack == nil or next(colors_ID) == nil then
            reaper.ImGui_Text(ctx, 'Select a track with colored Items')
        else
            for color, _ in pairs(colors_ID) do
                local colorString = string.format("%06X", color & 0xFFFFFF)
                local nameKey = "color" ..colorString
                local name = trackNames[colorString] or ""
                local r, g, b, a = convertColor(color)

                --InputText
                reaper.ImGui_SeparatorText(ctx, "Track name")
                reaper.ImGui_SetNextItemWidth(ctx, InputTexSize)
                local changed, newName = reaper.ImGui_InputText(ctx, "##" .. colorString, name, 256)
                if changed then
                    trackNames[colorString] = newName
                    saveTrackNames()
                end
                -- ColorButtonGui
                reaper.ImGui_SameLine(ctx)
                local colorflags =   reaper.ImGui_ColorEditFlags_NoInputs()
                reaper.ImGui_ColorButton(ctx, nameKey, reaper.ImGui_ColorConvertDouble4ToU32(r, g, b, a), colorflags, ColorSize, ColorSize)
                reaper.ImGui_SameLine(ctx, PosCleanButtonY)
                if reaper.ImGui_Button(ctx, "Clean##" .. colorString) then
                    resetTrackNames(colorString)
                end
            end
        end
        reaper.ImGui_EndChild(ctx)

        --Organice Assets button
        if next(colors_ID) ~= nil then
            if reaper.ImGui_Button(ctx, 'Organize Assets', ButtonGuiW) then
                local success = organize_items_by_color(trackNames)
                if success then
                    organizeSuccess = true
                end
            end
            -- Show the "Clean all trackNames" button only when there are items
            reaper.ImGui_SameLine(ctx)
            if reaper.ImGui_Button(ctx, 'Clean all track names', ButtonGuiW) then
                resetTrackNames()
            end
        end

        -- Show success message within the interface
        if organizeSuccess then
           if reaper.ImGui_SmallButton(ctx, "X") then
            organizeSuccess = false
        end
            reaper.ImGui_SameLine(ctx)
            reaper.ImGui_Text(ctx, "Organize Success")
        end
        reaper.ImGui_End(ctx)
    end

    PopTheme()
    reaper.ImGui_PopFont(ctx)

    if open then
        reaper.defer(loop)
    end
end

function PushTheme()
      -- Style
      reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 12)
      reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ChildRounding(),  5)
      reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_PopupRounding(),  0)
      reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(),  4)
      reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_GrabRounding(),   3)

      -- Color
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(),            0x3F297A8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(),     0x6D37FF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(),      0x8355FF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive(),      0x3A25718A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_CheckMark(),          0x7F50FF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SliderGrab(),         0x6138CF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SliderGrabActive(),   0x7542FF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),             0xE3780FF4)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),      0xFA9742FF)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),       0xFA9B0FFF)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(),             0x7748F78A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(),      0x6C36FF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(),       0x7B4FF58A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Separator(),          0x0ABD0280)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SeparatorHovered(),   0x1CBF1AC7)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SeparatorActive(),    0x1ABF2EFF)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ResizeGrip(),         0x7E4FFF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ResizeGripHovered(),  0x7C4FF48A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ResizeGripActive(),   0x7748F98A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Tab(),                0x442C848A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabHovered(),         0x7A4AFC8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabActive(),          0x50349B8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabUnfocused(),       0x1E18308A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TabUnfocusedActive(), 0x3021598A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_DockingPreview(),     0x7444F98A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TextSelectedBg(),     0x6D37FF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_NavHighlight(),       0x6C36FF8A)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Border(),             0x442C848A)
end

function PopTheme()
      reaper.ImGui_PopStyleVar(ctx, 5)
      reaper.ImGui_PopStyleColor(ctx, 28)
end