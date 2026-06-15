local visible = false
local activeTab = 1
local selRow = 1
local inSubMenu = false
local targetPlayerId = nil
local targetPlayerName = ""

local toggles = {["Troll 1"] = false, ["Troll 2"] = false}
local tabs = {"Server", "Weapons", "Troll", "Cfw", "Players"}
local tabOpts = {
    [1] = {"Server Info", "Restart UI"},
    [2] = {"Give Ammo", "Clear Weapons"},
    [3] = {"Troll 1", "Troll 2"},
    [4] = {"Player Info", "Give Money", "Spawn Car", "Respawn", "Revive"},
    [5] = {}
}

local subMenuOpts = {"< Back", "Open Inventory", "Revive Player"}

local mW = 0.23
local mH = 0.45
local hH = 0.09
local tH = 0.045
local fH = 0.035
local inputActive = false
local inputLabel = ""
local nextActionTime = 0
local onlinePlayers = {}
local lastPlayerUpdate = 0

local stars = {}
for i = 1, 25 do
    table.insert(stars, {
        x = math.random() * mW,
        y = math.random() * hH,
        speed = 0.0002 + (math.random() * 0.0005),
        alpha = math.random(80, 200)
    })
end

local function DrawTxt(text, x, y, font, scale, r, g, b, a, center, right)
    SetTextFont(font)
    SetTextScale(0.0, scale)
    SetTextColour(r, g, b, a)
    if center then
        SetTextCentre(true)
    elseif right then
        SetTextRightJustify(true)
        SetTextWrap(0.0, x)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function ShowInput(title)
    inputActive = true
    inputLabel = title
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", title, "", "", "", "", 6)
end

local function HandleAction(name)
    if name == "Revive" then
        ShowInput("Enter Player ID:")
    elseif name == "< Back" then
        inSubMenu = false
        selRow = 1
    elseif name == "Open Inventory" then
        if targetPlayerId then
            TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetPlayerId)
        end
    elseif name == "Revive Player" then
        if targetPlayerId then
            TriggerServerEvent('hospital:server:RevivePlayer', targetPlayerId)
        end
    elseif toggles[name] ~= nil then
        toggles[name] = not toggles[name]
    end
end

local function UpdatePlayersList()
    local currentTime = GetGameTimer()
    if currentTime - lastPlayerUpdate > 2000 and not inSubMenu then 
        onlinePlayers = {}
        local players = GetActivePlayers()
        for _, player in ipairs(players) do
            local sId = GetPlayerServerId(player)
            local pName = GetPlayerName(player)
            table.insert(onlinePlayers, {id = sId, name = pName, label = "[" .. sId .. "] " .. pName})
        end
        
        tabOpts[5] = {}
        for _, pData do
            table.insert(tabOpts[5], pData.label)
        end
        lastPlayerUpdate = currentTime
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(0, 344) then
            visible = not visible
            if not visible then
                inputActive = false
            end
            Citizen.Wait(200)
        end

        if inputActive then
            local status = UpdateOnscreenKeyboard()
            if status == 1 then
                local result = GetOnscreenKeyboardResult()
                if result and tonumber(result) then
                    TriggerServerEvent('hospital:server:RevivePlayer', tonumber(result))
                end
                inputActive = false
            elseif status == 2 then
                inputActive = false
            end
        end

        if visible and not inputActive then
            UpdatePlayersList()

            local cx, cy = 0.15, 0.45
            local hT = cy - mH/2
            local hY = hT + hH/2
            local tY = hT + hH + tH/2
            local cTop = tY + tH/2
            local fY = cy + mH/2 - fH/2
            local tW = mW / #tabs

            ShowCursorThisFrame()
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)

            DrawRect(cx, cy, mW + 0.005, mH + 0.005, 0, 180, 220, 150)
            DrawRect(cx, cy, mW + 0.003, mH + 0.003, 0, 220, 255, 200)
            DrawRect(cx, cy, mW, mH, 10, 16, 20, 245)

            DrawRect(cx, hY, mW, hH, 6, 12, 18, 255)
            
            for _, star in ipairs(stars) do
                star.y = star.y + star.speed
                if star.y > hH then
                    star.y = 0
                    star.x = math.random() * mW
                end
                local sx = (cx - mW/2) + star.x
                local sy = (hY - hH/2) + star.y
                DrawRect(sx, sy, 0.0015, 0.0015, 0, 230, 255, star.alpha)
            end
            
            DrawTxt("JOKER MENU V3", cx, hY - 0.02, 1, 0.72, 0, 225, 255, 255, true, false)

            for i = 1, #tabs do
                local tx = cx - mW/2 + tW * (i - 1) + tW/2
                
                if i == activeTab then
                    DrawRect(tx, tY, tW, tH, 0, 160, 220, 220)
                    DrawTxt(tabs[i], tx, tY - 0.012, 0, 0.24, 255, 255, 255, 255, true, false)
                else
                    DrawRect(tx, tY, tW, tH, 14, 22, 28, 255)
                    DrawTxt(tabs[i], tx, tY - 0.012, 0, 0.24, 140, 140, 140, 255, true, false)
                end
            end

            local opts = tabOpts[activeTab] or {}
            if activeTab == 5 and inSubMenu then
                opts = subMenuOpts
            end
            
            local oph = 0.045

            for i = 1, #opts do
                local ry = cTop + (i - 1) * oph + oph/2
                local opt = opts[i]
                
                if i == selRow then
                    DrawRect(cx, ry, mW - 0.01, oph - 0.004, 0, 120, 180, 190)
                end

                DrawTxt(">", cx - mW/2 + 0.015, ry - 0.015, 0, 0.35, 255, 255, 255, 255, false, false)
                DrawTxt(opt, cx + mW/2 - 0.015, ry - 0.015, 0, 0.30, 255, 255, 255, 255, false, true)
            end

            DrawRect(cx, fY, mW, fH, 6, 12, 18, 255)
            DrawTxt("(" .. selRow .. "/" .. #opts .. ")", cx - mW/2 + 0.015, fY - 0.01, 0, 0.25, 0, 220, 255, 255, false, false)
            DrawTxt("Joker v3.0 | Discord.gg/joker", cx + mW/2 - 0.015, fY - 0.01, 0, 0.25, 140, 140, 140, 255, false, true)

            local mx = GetControlNormal(0, 239)
            local my = GetControlNormal(0, 240)

            if GetGameTimer() > nextActionTime then
                if mx > 0 and my > 0 then
                    for i = 1, #tabs do
                        local tx = cx - mW/2 + tW * (i - 1) + tW/2
                        if mx > tx - tW/2 and mx < tx + tW/2 and my > tY - tH/2 and my < tY + tH/2 then
                            if IsDisabledControlJustPressed(0, 237) then
                                activeTab = i
                                selRow = 1
                                inSubMenu = false
                                nextActionTime = GetGameTimer() + 200
                            end
                        end
                    end

                    for i = 1, #opts do
                        local ry = cTop + (i - 1) * oph + oph/2
                        if mx > cx - mW/2 and mx < cx + mW/2 and my > ry - oph/2 and my < ry + oph/2 then
                            selRow = i
                            if IsDisabledControlJustPressed(0, 237) then
                                if activeTab == 5 and not inSubMenu then
                                    local pData = onlinePlayers[i]
                                    if pData then
                                        targetPlayerId = pData.id
                                        targetPlayerName = pData.name
                                        inSubMenu = true
                                        selRow = 1
                                    end
                                else
                                    HandleAction(opts[i])
                                end
                                nextActionTime = GetGameTimer() + 200
                            end
                        end
                    end
                end

                if IsDisabledControlJustPressed(0, 172) then
                    selRow = math.max(1, selRow - 1)
                    nextActionTime = GetGameTimer() + 150
                elseif IsDisabledControlJustPressed(0, 173) then
                    selRow = math.min(#opts, selRow + 1)
                    nextActionTime = GetGameTimer() + 150
                elseif IsDisabledControlJustPressed(0, 174) and not inSubMenu then
                    activeTab = math.max(1, activeTab - 1)
                    selRow = 1
                    nextActionTime = GetGameTimer() + 150
                elseif IsDisabledControlJustPressed(0, 175) and not inSubMenu then
                    activeTab = math.min(#tabs, activeTab + 1)
                    selRow = 1
                    nextActionTime = GetGameTimer() + 150
                elseif IsDisabledControlJustPressed(0, 191) then
                    if #opts > 0 and opts[selRow] then
                        if activeTab == 5 and not inSubMenu then
                            local pData = onlinePlayers[selRow]
                            if pData then
                                targetPlayerId = pData.id
                                targetPlayerName = pData.name
                                inSubMenu = true
                                selRow = 1
                            end
                        else
                            HandleAction(opts[selRow])
                        end
                    end
                    nextActionTime = GetGameTimer() + 200
                end
            end
        end
    end
end)