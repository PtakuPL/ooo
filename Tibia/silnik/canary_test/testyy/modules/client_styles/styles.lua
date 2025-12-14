local resourceLoaders = {
    ["otui"] = g_ui.importStyle,
    ["otfont"] = g_fonts.importFont,
    ["otps"] = g_particles.importParticle,
}

function init()
    local device = g_platform.getDevice()
    importResources("styles", "otui", device)
    importResources("fonts", "otfont", device)
    importResources("particles", "otps", device)

    g_mouse.loadCursors('/cursors/cursors')
    g_gameConfig.loadFonts()
end

function terminate()
end

function importResources(dir, type, device)
    local path = '/' .. dir .. '/'
    local files = g_resources.listDirectoryFiles(path)
    table.sort(files)
    for _, file in ipairs(files) do
        if g_resources.isFileType(file, type) then
            -- Debug: check if TTF files exist
            if file == "mono-12.otfont" then
                local ttfPath = "/fonts/ttf/NotoSansMono-Regular.ttf"
                print("DEBUG TTF mono: " .. ttfPath ..
                    " exists=" .. tostring(g_resources.fileExists(ttfPath)) ..
                    " realPath=" .. tostring(g_resources.getRealPath(ttfPath)))
            elseif file == "noto-12.otfont" then
                local regular = "/fonts/ttf/NotoSans-Regular.ttf"
                local bold = "/fonts/ttf/NotoSans-Bold.ttf"
                print("DEBUG TTF noto regular: " .. regular ..
                    " exists=" .. tostring(g_resources.fileExists(regular)) ..
                    " realPath=" .. tostring(g_resources.getRealPath(regular)))
                print("DEBUG TTF noto bold: " .. bold ..
                    " exists=" .. tostring(g_resources.fileExists(bold)) ..
                    " realPath=" .. tostring(g_resources.getRealPath(bold)))
            end
            
            local ok, resultOrErr = pcall(resourceLoaders[type], path .. file)
            if not ok then
                print("ERROR loading " .. type .. ": " .. path .. file .. " - " .. tostring(resultOrErr))
            elseif resultOrErr == false then
                print("FAILED loading " .. type .. ": " .. path .. file .. " (returned false)")
            else
                print("OK loaded: " .. path .. file)
            end
        end
    end

    -- try load device specific resources
    if device then
        local devicePath = g_platform.getDeviceShortName(device.type)
        if devicePath ~= "" then
            table.insertall(files, importResources(dir .. '/' .. devicePath, type))
        end
        local osPath = g_platform.getOsShortName(device.os)
        if osPath ~= "" then
            table.insertall(files, importResources(dir .. '/' .. osPath, type))
        end
        return
    end
    return files
end

function reloadParticles()
    g_particles.terminate()
    local device = g_platform.getDevice()
    importResources("particles", "otps", device)
end
