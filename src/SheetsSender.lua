-- Simple Sheets sender for testing
-- This module exposes a global UI callback `send_scores_to_sheet_ui`

local WEBHOOK_URL = "https://script.google.com/macros/s/AKfycbyd1biU0k3XFlLWFGS6Y9aU_pLMJjJG3CvQuYtMmnIl1UTzMzHqbSgJtlR-cxSr-AWNBA/exec"

local SheetsSender = {}
-- last computed preview rows (table form) so Send Now posts the exact preview
local last_preview_rows = nil
local ActionCards = require("src/ActionCards")

-- Resolve player GUIDs from available sources: local player_pieces, Global var player_pieces_GUIDs, or global player_pieces_GUIDs
local function get_player_guid(color, key)
    -- try local player_pieces (used in ArcsPlayer.lua)
    if player_pieces and player_pieces[color] then
        -- direct key (e.g., area_zone, hand_zone)
        if player_pieces[color][key] then return player_pieces[color][key] end
        -- components table (e.g., score_board)
        if player_pieces[color]["components"] and player_pieces[color]["components"][key] then
            return player_pieces[color]["components"][key]
        end
    end

    -- try Global stored GUIDs
    local ok, pp_guids = pcall(function() return Global.getVar("player_pieces_GUIDs") end)
    if ok and pp_guids and pp_guids[color] then
        if pp_guids[color][key] then return pp_guids[color][key] end
        if pp_guids[color]["components"] and pp_guids[color]["components"][key] then return pp_guids[color]["components"][key] end
        -- some modules expose player_pieces_GUIDs as a global table
        if _G["player_pieces_GUIDs"] and _G["player_pieces_GUIDs"][color] then
            if _G["player_pieces_GUIDs"][color][key] then return _G["player_pieces_GUIDs"][color][key] end
        end
    end

    -- final fallback to global player_pieces_GUIDs
    if _G["player_pieces_GUIDs"] and _G["player_pieces_GUIDs"][color] then
        if _G["player_pieces_GUIDs"][color][key] then return _G["player_pieces_GUIDs"][color][key] end
        if _G["player_pieces_GUIDs"][color]["components"] and _G["player_pieces_GUIDs"][color]["components"][key] then
            return _G["player_pieces_GUIDs"][color]["components"][key]
        end
    end

    return nil
end

-- Return true if the given object appears to be a card (Card/Deck or tagged/ named as a card)
local function is_card_object(obj)
    if not obj then return false end
    local ok, typ = pcall(function() return obj.type end)
    if ok and typ then
        if typ == "Card" or typ == "Deck" then return true end
    end
    local okTag, hasCardTag = pcall(function() return obj.hasTag and obj.hasTag("Card") end)
    if okTag and hasCardTag then return true end
    local okName, name = pcall(function() return obj.getName and obj.getName() end)
    if okName and name and tostring(name) ~= "" then
        local lname = string.lower(tostring(name))
        if string.find(lname, "card") or string.find(lname, "action") then return true end
    end
    return false
end

-- URL-encode a string for form-encoding
local function url_encode(str)
    if str == nil then return "" end
    str = tostring(str)
    -- normalize newlines
    str = str:gsub("\n", "\r\n")
    return (str:gsub("([^%w%-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end))
end

local function _broadcast_response(response)
    -- Prefer explicit error flag if present
    if response and response.is_error then
        local text = (response and response.text) and response.text or tostring(response)
        broadcastToAll("Sheets: send failed - " .. tostring(text), {1, 0, 0})
        return
    end

    -- If no explicit error, consider it successful (some WebRequest responses
    -- don't expose numeric responseCode). Show OK and optionally the text.
    local text = (response and response.text) and response.text or tostring(response)
    broadcastToAll("Sheets: sent OK", {0, 1, 0})
    if text and tostring(text) ~= "table: 0x0" and tostring(text) ~= "nil" and tostring(text) ~= "" then
        broadcastToAll("Sheets response: " .. tostring(text), {0, 1, 0})
    end
end

local function send_simple_test(player, value, id)
    -- Simple payload matching the Apps Script: send a single `word` field
    local payload = {
        word = "hello from TTS"
    }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    -- Debug: show what we're about to send (shorten if extremely long)
    local dbg = body_json
    if #dbg > 1200 then dbg = dbg:sub(1, 1200) .. "... (truncated)" end
    broadcastToAll("Sheets: sending JSON payload (truncated): " .. tostring(dbg), {0.2,0.5,1})

    -- Ensure WebRequest API is available
    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available in this environment", {1,0,0})
        return
    end

    -- Use WebRequest.custom with JSON body (matches the working example pattern)
    -- Append URL-encoded JSON as a `payload` query param too, to support appscripts
    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            _broadcast_response(response)
        end)
    end)
    if not ok then
        broadcastToAll("Sheets: WebRequest.custom error: " .. tostring(err), {1,0,0})
    end
    return
end

-- Expose as a global function so UI onClick can call it by name
_G["send_scores_to_sheet_ui"] = send_simple_test

-- Open a preview UI showing the payload to be sent (sample data for now)
local function generate_preview_xml(active)
    -- Prefer the live var; fall back to saved table
    active = active or Global.getVar("active_players") or Global.getTable("active_players") or {}
    broadcastToAll("Sheets preview: generate_preview_xml active count=" .. tostring(#active), {0.6,0.6,0.9})

    -- reset stored preview rows
    last_preview_rows = {}
    local rows = {}
    table.insert(rows, [[
        <HorizontalLayout spacing="8">
            <Text text="Player" color="#dcdcdc" fontSize="16" preferredWidth="160" />
            <Text text="Cards" color="#dcdcdc" fontSize="16" preferredWidth="220" />
            <Text text="Power" color="#dcdcdc" fontSize="16" preferredWidth="60" />
            <Text text="Hand" color="#dcdcdc" fontSize="16" preferredWidth="50" />
            <Text text="Tycoon" color="#dcdcdc" fontSize="16" preferredWidth="60" />
            <Text text="Captives" color="#dcdcdc" fontSize="16" preferredWidth="60" />
            <Text text="Trophies" color="#dcdcdc" fontSize="16" preferredWidth="60" />
            <Text text="Keeper" color="#dcdcdc" fontSize="16" preferredWidth="60" />
            <Text text="Empath" color="#dcdcdc" fontSize="16" preferredWidth="60" />
        </HorizontalLayout>
    ]])

    if #active == 0 then
        -- fallback sample row
        table.insert(rows, [[
        <HorizontalLayout spacing="8">
            <Text text="Alice" color="white" fontSize="14" preferredWidth="160" />
            <Text text="12" color="white" fontSize="14" preferredWidth="80" />
            <Text text="Leader: Duke; Hand: Noble, Spy" color="white" fontSize="14" preferredWidth="320" />
        </HorizontalLayout>
        ]])
    else
        for _, p in ipairs(active) do
            local name = nil
            local power = ""
            local hand_size = ""
            local tycoon = ""
            local captives = ""
            local trophies = ""
            local keeper = ""
            local empath = ""

            local arcs_player = nil
            if type(p) == "table" and p.color then
                arcs_player = p
                local ok, pl = pcall(function() return Player[p.color] end)
                if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                    name = pl.steam_name
                else
                    name = p.color
                end
            elseif type(p) == "string" then
                -- try to resolve ArcsPlayer by color
                local ok, ap = pcall(function() return get_arcs_player(p) end)
                if ok and ap then
                    arcs_player = ap
                end
                local ok2, pl = pcall(function() return Player[p] end)
                if ok2 and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
            else
                name = tostring(p)
            end

            if arcs_player and type(arcs_player.update_score) == "function" then
                pcall(function() arcs_player:update_score() end)
                power = arcs_player.power or ""
                hand_size = arcs_player.hand_size or ""
                tycoon = arcs_player.tycoon or ""
                captives = arcs_player.captives or ""
                trophies = arcs_player.trophies or ""
                keeper = arcs_player.keeper or ""
                empath = arcs_player.empath or ""

                -- Try to read the actual labels from the player's score_board buttons
                local sb = arcs_player.score_board
                if not sb and arcs_player.color then
                    local sb_guid = get_player_guid(arcs_player.color, "score_board")
                    if sb_guid then
                        pcall(function() sb = getObjectFromGUID(sb_guid) end)
                    end
                end
                if sb and type(sb.getButtons) == "function" then
                    local ok, btns = pcall(function() return sb.getButtons() end)
                    if ok and btns then
                        local btnMap = {}
                        for _, b in ipairs(btns) do
                            if b.index ~= nil then btnMap[b.index] = b.label end
                        end
                        -- Debug: broadcast the button labels we found for this score_board
                        local dbg = {}
                        for idx, lbl in pairs(btnMap) do table.insert(dbg, tostring(idx) .. ":" .. tostring(lbl)) end
                        if #dbg > 0 then
                            broadcastToAll("Sheets preview: score_board labels for " .. tostring(name) .. " -> " .. table.concat(dbg, ", "), {0.4,0.6,1})
                        else
                            broadcastToAll("Sheets preview: no score_board labels found for " .. tostring(name), {1,0.6,0.2})
                        end
                        local function labelOr(orig, idx)
                            local v = btnMap[idx]
                            if v == nil or tostring(v) == "" then return orig end
                            return tostring(v)
                        end
                        power = labelOr(power, 0)
                        hand_size = labelOr(hand_size, 2)
                        tycoon = labelOr(tycoon, 4)
                        captives = labelOr(captives, 6)
                        trophies = labelOr(trophies, 8)
                        keeper = labelOr(keeper, 10)
                        empath = labelOr(empath, 12)
                    end
                end
            end

            -- Gather cards from the player's area and hand (use ActionCards.get_info when available)
            local cards_list = {}
            local function push_card_obj(obj, source)
                if not obj then return end
                local added = false
                if ActionCards and type(ActionCards.get_info) == "function" then
                    local ok, info = pcall(function() return ActionCards.get_info(obj) end)
                    if ok and info and info.type then
                        table.insert(cards_list, tostring(info.type) .. (info.number and ("#" .. tostring(info.number)) or ""))
                        added = true
                    end
                end
                if not added then
                    local ok, nm = pcall(function() return obj.getName and obj.getName() end)
                    if ok and nm and tostring(nm) ~= "" then
                        table.insert(cards_list, tostring(nm))
                        added = true
                    end
                end
                if not added then
                    local ok, desc = pcall(function() return obj.getDescription and obj.getDescription() end)
                    if ok and desc and tostring(desc) ~= "" then
                        table.insert(cards_list, tostring(desc))
                    end
                end
            end

            -- area_zone
            local area_zone_obj = nil
            pcall(function()
                if arcs_player and arcs_player.color then
                    local area_guid = get_player_guid(arcs_player.color, "area_zone")
                    if area_guid then area_zone_obj = getObjectFromGUID(area_guid) end
                end
            end)
            if area_zone_obj and type(area_zone_obj.getObjects) == "function" then
                local ok, objs = pcall(function() return area_zone_obj.getObjects() end)
                if ok and objs then
                    broadcastToAll("Sheets preview: found " .. tostring(#objs) .. " area objects for " .. tostring(name), {0.3,0.6,0.9})
                    for _, o in ipairs(objs) do
                        if not is_card_object(o) then
                            -- skip non-card objects in area
                        else
                            local okn, nm = pcall(function() return o.getName and o.getName() end)
                            if okn and nm and tostring(nm) ~= "" then
                                table.insert(cards_list, tostring(nm))
                            else
                                -- fallback to generic handling (action card info, description, etc.)
                                push_card_obj(o, "area")
                            end
                        end
                    end
                else
                    broadcastToAll("Sheets preview: could not read area objects for " .. tostring(name), {1,0.4,0.2})
                end
            else
                broadcastToAll("Sheets preview: no area zone object for " .. tostring(name), {1,0.4,0.2})
            end

            -- hand_zone
            local hand_zone_obj = nil
            pcall(function()
                if arcs_player and arcs_player.color then
                    local hand_guid = get_player_guid(arcs_player.color, "hand_zone")
                    if hand_guid then hand_zone_obj = getObjectFromGUID(hand_guid) end
                end
            end)
            if hand_zone_obj and type(hand_zone_obj.getObjects) == "function" then
                local ok, objs = pcall(function() return hand_zone_obj.getObjects() end)
                if ok and objs then
                    broadcastToAll("Sheets preview: found " .. tostring(#objs) .. " hand objects for " .. tostring(name), {0.3,0.6,0.9})
                    for _, o in ipairs(objs) do
                        if is_card_object(o) then
                            push_card_obj(o, "hand")
                        end
                    end
                else
                    broadcastToAll("Sheets preview: could not read hand objects for " .. tostring(name), {1,0.4,0.2})
                end
            else
                broadcastToAll("Sheets preview: no hand zone object for " .. tostring(name), {1,0.4,0.2})
            end

            -- store a structured row so send uses exactly the preview content (include cards array)
            table.insert(last_preview_rows, {
                name = name,
                color = (arcs_player and arcs_player.color) or ((type(p) == "table" and p.color) and p.color) or (type(p) == "string" and p) or tostring(p),
                power = tostring(power),
                hand_size = tostring(hand_size),
                tycoon = tostring(tycoon),
                captives = tostring(captives),
                trophies = tostring(trophies),
                keeper = tostring(keeper),
                empath = tostring(empath),
                cards = cards_list,
            })

            table.insert(rows, string.format([[
        <HorizontalLayout spacing="8">
            <Text text="%s" color="white" fontSize="14" preferredWidth="160" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="220" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="60" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="50" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="60" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="60" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="60" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="60" />
            <Text text="%s" color="white" fontSize="14" preferredWidth="60" />
        </HorizontalLayout>
        ]], name, table.concat(cards_list, " | "), tostring(power), tostring(hand_size), tostring(tycoon), tostring(captives), tostring(trophies), tostring(keeper), tostring(empath)))
        end
    end

    local rows_xml = table.concat(rows, "\n")

    return string.format([[
    <Canvas>
        <Panel id="sheetsPreviewPanel" rectAlignment="MiddleCenter" allowDragging="true" width="600" height="360" color="#222222CC" childForceExpandWidth="false" childForceExpandHeight="false">
            <VerticalLayout spacing="8" padding="10" childForceExpandHeight="false" childForceExpandWidth="false">
                <Text text="Sheets Payload Preview" fontSize="22" color="white" />
                %s
                <HorizontalLayout spacing="8" childForceExpandWidth="false">
                    <Button text="Send Now" onClick="send_preview_to_sheet_ui" color="#2e8b57" textColor="white" width="120" height="36" preferredWidth="120" preferredHeight="36" fontSize="16" />
                    <Button text="Close" onClick="loadCameraTimerMenu" color="#888888" textColor="white" width="80" height="36" preferredWidth="80" preferredHeight="36" fontSize="16" />
                </HorizontalLayout>
            </VerticalLayout>
        </Panel>
    </Canvas>
    ]], rows_xml)
end

local function open_preview(player, value, id)
    broadcastToAll("Sheets preview: open_preview called", {0.3,0.7,0.3})
    -- Clear tooltip so it doesn't persist
    pcall(function()
        UI.setAttribute("sheetsSendBtn", "tooltip", "")
        UI.setAttribute("sheetsSendBtn", "tooltipBackgroundColor", "")
    end)
    local active = Global.getVar("active_players") or Global.getTable("active_players") or {}
    broadcastToAll("Sheets preview: open_preview active count=" .. tostring(#active), {0.3,0.7,0.3})
    -- Debug: broadcast resolved names to help diagnose empty name issue
    local resolved = {}
    for _, p in ipairs(active) do
        local name = nil
        if type(p) == "table" and p.color then
            local ok, pl = pcall(function() return Player[p.color] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then
                name = pl.steam_name
            else
                name = p.color
            end
        elseif type(p) == "string" then
            local ok, pl = pcall(function() return Player[p] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
        else
            name = tostring(p)
        end
        table.insert(resolved, name)
    end
    if #resolved == 0 then
        broadcastToAll("Sheets Preview: no active players found", {1,0.5,0})
    else
        broadcastToAll("Sheets Preview players: " .. table.concat(resolved, ", "), {0.2,0.8,0.2})
    end
    local previewXml = generate_preview_xml(active)
    UI.setXml(previewXml)
end

_G["open_sheets_preview_ui"] = open_preview

-- Build payload from active players and send to the webhook (used by preview Send Now)
local function send_preview_to_sheet(player, value, id)
    local active = Global.getVar("active_players") or Global.getTable("active_players") or {}
    local rows = {}
    for _, p in ipairs(active) do
        local color = nil
        local name = nil
        if type(p) == "table" and p.color then
            color = p.color
            local ok, pl = pcall(function() return Player[p.color] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p.color end
        elseif type(p) == "string" then
            color = p
            local ok, pl = pcall(function() return Player[p] end)
            if ok and pl and pl.steam_name and pl.steam_name ~= "" then name = pl.steam_name else name = p end
        else
            name = tostring(p)
        end

        local arcs_player = nil
        if color then
            local ok, ap = pcall(function() return get_arcs_player(color) end)
            if ok and ap then arcs_player = ap end
        elseif type(p) == "table" and p.color then arcs_player = p end

        local power = ""; local hand_size = ""; local tycoon = ""; local captives = ""; local trophies = ""; local keeper = ""; local empath = ""
        if arcs_player and type(arcs_player.update_score) == "function" then
            pcall(function() arcs_player:update_score() end)
            power = arcs_player.power or ""
            hand_size = arcs_player.hand_size or ""
            tycoon = arcs_player.tycoon or ""
            captives = arcs_player.captives or ""
            trophies = arcs_player.trophies or ""
            keeper = arcs_player.keeper or ""
            empath = arcs_player.empath or ""

            -- try to read actual score_board labels if present
            local sb = arcs_player.score_board
            if not sb and arcs_player.color then
                local sb_guid = get_player_guid(arcs_player.color, "score_board")
                if sb_guid then pcall(function() sb = getObjectFromGUID(sb_guid) end) end
            end
            if sb and type(sb.getButtons) == "function" then
                local ok, btns = pcall(function() return sb.getButtons() end)
                if ok and btns then
                    local btnMap = {}
                    for _, b in ipairs(btns) do if b.index ~= nil then btnMap[b.index] = b.label end end
                    local function labelOr(orig, idx)
                        local v = btnMap[idx]
                        if v == nil or tostring(v) == "" then return orig end
                        return tostring(v)
                    end
                    power = labelOr(power, 0)
                    hand_size = labelOr(hand_size, 2)
                    tycoon = labelOr(tycoon, 4)
                    captives = labelOr(captives, 6)
                    trophies = labelOr(trophies, 8)
                    keeper = labelOr(keeper, 10)
                    empath = labelOr(empath, 12)
                end
            end
        end

        table.insert(rows, {
            name = name,
            color = color,
            power = power,
            hand_size = hand_size,
            tycoon = tycoon,
            captives = captives,
            trophies = trophies,
            keeper = keeper,
            empath = empath,
        })
    end

    -- Prefer using the last preview rows if available so the posted payload matches the preview
    local rows_to_send = nil
    if last_preview_rows and type(last_preview_rows) == "table" and #last_preview_rows > 0 then
        rows_to_send = last_preview_rows
    else
        rows_to_send = rows
    end

    local payload = { players = rows_to_send }
    local body_json = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    -- Debug: show payload being sent (truncated)
    local dbg = body_json
    if #dbg > 1200 then dbg = dbg:sub(1,1200) .. "... (truncated)" end
    broadcastToAll("Sheets: sending JSON payload (truncated): " .. tostring(dbg), {0.2,0.5,1})

    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available", {1,0,0})
        return
    end

    local url_with_q = WEBHOOK_URL .. "?payload=" .. url_encode(body_json)
    local ok, err = pcall(function()
        WebRequest.custom(url_with_q, "POST", true, body_json, headers, function(response)
            _broadcast_response(response)
            -- close preview and restore camera UI
            pcall(function() loadCameraTimerMenu(true) end)
        end)
    end)
    if not ok then broadcastToAll("Sheets: WebRequest.custom error: " .. tostring(err), {1,0,0}) end
end

_G["send_preview_to_sheet_ui"] = send_preview_to_sheet

function SheetsSender.generateButtonXml()
    return [[
    <VerticalLayout
        id="sheetsSenderLayout"
        allowDragging="true"
        returnToOriginalPositionWhenReleased="false"
        rectAlignment="UpperRight"
        anchorMin="1 1"
        anchorMax="1 1"
        offsetXY="-120 -250"
        width="160"
        height="60"
        childForceExpandHeight="false"
        childForceExpandWidth="false"
        >
        <Button
            id="sheetsSendBtn"
            onClick="open_sheets_preview_ui"
            text="Send Scores"
            textColor="white"
            color="#2e8b57"
            tooltipBackgroundColor="#2e8b57"
            tooltipTextColor="Black"
            width="160"
            height="48"
            preferredWidth="160"
            preferredHeight="48"
            fontSize="20"
            />
    </VerticalLayout>
    ]]
end

return SheetsSender
