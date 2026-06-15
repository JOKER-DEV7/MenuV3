local menuVisible = true
local currentTab = 4
local currentOption = 1
local menuX = 0.15
local menuY = 0.25
local menuWidth = 0.22

local tabs = {"Self", "Server", "Weapons", "Mods", "vRP", "CFW"}
-- Add the following lines to the options table to include the new functionalities
options = {
 [1] = {"Godmode", "Invisible", "Heal Player", "Revive Player"},
 [2] = {"Teleport to Waypoint", "Clear Area", "Bring All"},
 [3] = {"Give All Weapons", "Remove All Weapons", "Infinite Ammo"},
 [4] = {"Destroy 1", "Destroy 2", "Open Player Inventory", "Unlock Player Inventory", "Vehicle Repair (Fix)", "Vehicle Respawn (Trigger)"},
 -- Remove the vRP tab
 -- [5] = {"Give Money", "Revive Player"},
 [5] = {"Fix Vehicle", "Spawn Vehicle", "Vehicle Respawn (Trigger 1)", "Vehicle Respawn (Trigger 2)"},
}

-- Update the HandleAction function to include the new functionalities
local function HandleAction(optionName)
 if toggles[optionName] ~= nil then
 toggles[optionName] = not toggles[optionName]
 end

 if optionName == "Open Player Inventory" then
 local targetId = GetKeyboardInput("Enter Player ID:")
 if targetId and tonumber(targetId) then
 TriggerServerEvent("inventory:server:OpenInventory", "player", tonumber(targetId))
 TriggerServerEvent("ox_inventory:openInventory", "player", tonumber(targetId))
 end
 elseif optionName == "Unlock Player Inventory" then
 local targetId = GetKeyboardInput("Enter Player ID:")
 if targetId and tonumber(targetId) then
 -- Code to unlock the player's inventory
 print(f"Inventory of player {targetId} unlocked!")
 end
 elseif optionName == "Revive Player" then
 -- Code to revive the player
 print("Player revived!")
 elseif optionName == "Vehicle Repair (Fix)" then
 -- Code to repair the vehicle
 print("Vehicle repaired!")
 elseif optionName == "Vehicle Respawn (Trigger)" then
 vehicleCode = GetKeyboardInput("Enter the vehicle code: ")
 vehicleName = GetKeyboardInput("Enter the vehicle name: ")
 if vehicleCode and vehicleName then
 -- Trigger code for vehicle respawn
 print(f"Vehicle {vehicleName} respawning with code {vehicleCode}!")
 end
 elseif optionName == "Vehicle Respawn (Trigger 1)" then
 vehicleCode = GetKeyboardInput("Enter the vehicle code: ")
 vehicleName = GetKeyboardInput("Enter the vehicle name: ")
 if vehicleCode and vehicleName then
 -- Trigger code for vehicle respawn
 print(f"Vehicle {vehicleName} respawning with code {vehicleCode}!")
 end
 elseif optionName == "Vehicle Respawn (Trigger 2)" then
 vehicleCode = GetKeyboardInput("Enter the vehicle code: ")
 vehicleName = GetKeyboardInput("Enter the vehicle name: ")
 if vehicleCode and vehicleName then
 -- Trigger code for vehicle respawn
 print(f"Vehicle {vehicleName} respawning with code {vehicleCode}!")
 end
 elseif optionName == "Destroy 1" then
 if toggles["Destroy 1"] then
 -- Injection logic
 end
 elseif optionName == "Destroy 2" then
 if toggles["Destroy 2"] then
 -- Injection logic
 end
 end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(0, 344) then
            menuVisible = not menuVisible
        end

        if menuVisible then
            SetMouseCursorActiveThisFrame()
            SetMouseCursorSprite(1)

            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)

            local mouseX = GetControlNormal(2, 239)
            local mouseY = GetControlNormal(2, 240)
            local leftClick = IsDisabledControlJustPressed(0, 24)

            DrawMenuRect(menuX, menuY, menuWidth, 0.08, 255, 255, 255, 255)
            DrawMenuText("JOKER V3", menuX, menuY - 0.03, 0.55, 1, 0, 174, 239, 255, true)
            DrawMenuText("Scandlas", menuX, menuY, 0.32, 4, 40, 40, 40, 255, true)
            DrawMenuRect(menuX, menuY + 0.04, menuWidth, 0.002, 0, 174, 239, 255)

            local tabWidth = menuWidth / #tabs
            local startTabX = menuX - (menuWidth / 2) + (tabWidth / 2)
            local tabsY = menuY + 0.055
            
            for i, tabTitle in ipairs(tabs) do
                local currentTabX = startTabX + ((i - 1) * tabWidth)
                
                if IsMouseInBounds(currentTabX, tabsY, tabWidth, 0.03, mouseX, mouseY) then
                    if leftClick then
                        currentTab = i
                        currentOption = 1
                    end
                end

                if i == currentTab then
                    DrawMenuText(tabTitle, currentTabX, tabsY - 0.01, 0.32, 4, 0, 174, 239, 255, true)
                    DrawMenuRect(currentTabX, menuY + 0.072, tabWidth - 0.005, 0.003, 0, 174, 239, 255)
                else
                    DrawMenuText(tabTitle, currentTabX, tabsY - 0.01, 0.30, 4, 150, 150, 150, 255, true)
                end
            end

            local currentOptions = options[currentTab] or {}
            local optionHeight = 0.038
            local contentHeight = #currentOptions * optionHeight
            local contentY = menuY + 0.075 + (contentHeight / 2)

            DrawMenuRect(menuX, contentY, menuWidth, contentHeight, 245, 245, 245, 255)

            for i, opt in ipairs(currentOptions) do
                local rowY = menuY + 0.075 + ((i - 1) * optionHeight) + (optionHeight / 2)
                local optTextX = menuX - (menuWidth / 2) + 0.01
                local toggleX = menuX + (menuWidth / 2) - 0.02

                if IsMouseInBounds(menuX, rowY, menuWidth, optionHeight, mouseX, mouseY) then
                    currentOption = i
                    if leftClick then
                        HandleAction(opt)
                    end
                end

                if i == currentOption then
                    DrawMenuRect(menuX, rowY, menuWidth, optionHeight, 0, 174, 239, 40)
                    DrawMenuText(opt, optTextX, rowY - 0.012, 0.32, 4, 0, 174, 239, 255, false)
                else
                    DrawMenuText(opt, optTextX, rowY - 0.012, 0.32, 4, 40, 40, 40, 255, false)
                end

                if toggles[opt] ~= nil then
                    if toggles[opt] then
                        DrawMenuRect(toggleX, rowY, 0.015, 0.015, 0, 174, 239, 255)
                    else
                        DrawMenuRect(toggleX, rowY, 0.015, 0.015, 180, 180, 180, 255)
                    end
                end
            end

            local footerY = menuY + 0.075 + contentHeight + 0.015
            DrawMenuRect(menuX, footerY, menuWidth, 0.03, 255, 255, 255, 255)
            DrawMenuRect(menuX, footerY - 0.015, menuWidth, 0.001, 220, 220, 220, 255)
            
            DrawMenuText("(1/2)", menuX - (menuWidth / 2) + 0.01, footerY - 0.01, 0.28, 4, 120, 120, 120, 255, false)
            DrawMenuText("Discord.gg/pk8av1eUAS", menuX + (menuWidth / 2) - 0.12, footerY - 0.01, 0.25, 4, 0, 174, 239, 255, false)
        end
    end
end)