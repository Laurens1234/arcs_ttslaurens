-- Used in all aspects of manipulating zero marker and 3 ambition markers
require("src/GUIDs")

local ambitionMarkers = {}

local action_cards = require("src/ActionCards")
local ArcsPlayer = require("src/ArcsPlayer")
local Log = require("src/LOG")

-- is_face_down = false = lower (teal) side is face up
-- is_face_down = true  = higher (yellow) side is face up
local markers = {
    {
        object = getObjectFromGUID(ambition_marker_GUIDs[1]),
        column_pos = Vector({-0.83, 0.2, -1.07}),
        [false] = {
            first_power = 5,
            second_power = 3,
            power_desc = "5 / 3 power"
        },
        [true] = {
            first_power = 9,
            second_power = 4,
            power_desc = "9 / 4 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[2]),
        column_pos = Vector({-0.92, 0.2, -1.07}),
        [false] = {
            first_power = 3,
            second_power = 2,
            power_desc = "3 / 2 power"
        },
        [true] = {
            first_power = 6,
            second_power = 3,
            power_desc = "6 / 3 power"
        }
    }, {
        object = getObjectFromGUID(ambition_marker_GUIDs[3]),
        column_pos = Vector({-1.00, 0.21, -1.07}),
        [false] = {
            first_power = 2,
            second_power = 0,
            power_desc = "2 / 0 power"
        },
        [true] = {
            first_power = 4,
            second_power = 2,
            power_desc = "4 / 2 power"
        }
    }
}

local ambitions = {
    {
        name = "Undeclared",
        row_pos = Vector({0, 0, -0.01})
    }, {
        name = "Tycoon",
        row_pos = Vector({0, 0, 0.35})
    }, {
        name = "Tyrant",
        row_pos = Vector({0, 0, 0.74})
    }, {
        name = "Warlord",
        row_pos = Vector({0, 0, 1.12})
    }, {
        name = "Keeper",
        row_pos = Vector({0, 0, 1.5})
    }, {
        name = "Empath",
        row_pos = Vector({0, 0, 1.91})
    }
}

local last_declared_marker = nil

function ambitionMarkers:get_ambition_info(object)
    -- Guard against missing object or reach board (load-order issues)
    if not object or not object.getPosition then
        -- Try resolving the ambition marker by any known ambition_marker_GUIDs
        local found = nil
        if ambition_marker_GUIDs then
            for i = 1, #ambition_marker_GUIDs do
                local g = ambition_marker_GUIDs[i]
                local o = getObjectFromGUID(g)
                if o and o.getPosition then
                    found = o
                    break
                end
            end
        end
        if not found then
            Log.WARNING("get_ambition_info called with invalid object and no ambition marker fallbacks available")
            return
        end
        object = found
    end

    -- safe guid for retry tracking and indexing
    local obj_guid = (object.getGUID and object.getGUID()) or object.guid or "unknown"

    local reach_map = getObjectFromGUID(reach_board_GUID)
    if not reach_map then
        -- Wait and retry a few times in case the reach board hasn't loaded yet
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("reach_board not found; aborting ambition info for " .. tostring(obj_guid))
            return
        end
    end

    -- ensure object has a valid position
    local obj_pos = object.getPosition()
    if not obj_pos then
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("object has no position; aborting ambition info for " .. tostring(obj_guid))
            return
        end
    end

    local local_pos = reach_map.positionToLocal(obj_pos)
    if not local_pos then
        ambitionMarkers._retry_counts = ambitionMarkers._retry_counts or {}
        local count = ambitionMarkers._retry_counts[obj_guid] or 0
        if count < 6 then
            ambitionMarkers._retry_counts[obj_guid] = count + 1
            Wait.time(function()
                ambitionMarkers.get_ambition_info(object)
            end, 0.5)
            return
        else
            Log.WARNING("positionToLocal returned nil; aborting for " .. tostring(obj_guid))
            return
        end
    end

    -- Instead of computing only for the moved object, refresh all markers
    ambitionMarkers.refresh_all_ambitions()
end


-- Scan all ambition markers and update the global ambitions table
function ambitionMarkers:refresh_all_ambitions()
    local reach_map = getObjectFromGUID(reach_board_GUID)
    if not reach_map then
        -- retry shortly if reach board missing
        Wait.time(function()
            ambitionMarkers.refresh_all_ambitions()
        end, 0.5)
        return
    end

    local global_ambitions = {}
    for i = 1, (ambition_marker_GUIDs and #ambition_marker_GUIDs or 0) do
        local guid = ambition_marker_GUIDs[i]
        local obj = getObjectFromGUID(guid)
        if obj and obj.getPosition then
            local pos = obj.getPosition()
            local local_pos = reach_map.positionToLocal(pos)
            if local_pos then
                local ambition_pos_z = local_pos.z
                local ambition_number = math.floor((ambition_pos_z + 1.83) / 0.39)
                if (ambition_number == 1) then
                    global_ambitions[guid] = ""
                elseif (ambition_number == 2) then
                    global_ambitions[guid] = "Tycoon"
                elseif (ambition_number == 3) then
                    global_ambitions[guid] = "Tyrant"
                elseif (ambition_number == 4) then
                    global_ambitions[guid] = "Warlord"
                elseif (ambition_number == 5) then
                    global_ambitions[guid] = "Keeper"
                elseif (ambition_number == 6) then
                    global_ambitions[guid] = "Empath"
                else
                    global_ambitions[guid] = ""
                end
            else
                global_ambitions[guid] = ""
            end
        else
            global_ambitions[guid] = ""
        end
    end

    Global.setVar("active_ambitions", global_ambitions)
    Global.call("update_player_scores")
end

function ambitionMarkers:add_button()
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    -- If the zero marker object isn't present yet (load order), retry shortly
    if not zero_marker then
        Wait.time(function()
            ambitionMarkers.add_button()
        end, 0.5)
        return
    end

    -- If a button already exists, edit it rather than creating a duplicate
    local existing = {}
    if zero_marker.getButtons then
        existing = zero_marker.getButtons() or {}
    end
    for _, b in ipairs(existing) do
        if b and b.click_function == 'declare_ambition' then
            local ok, err = pcall(function()
                zero_marker.editButton({
                    click_function = 'declare_ambition',
                    function_owner = zero_marker,
                    position = {0, 0.05, 0},
                    width = 3800,
                    height = 950,
                    tooltip = 'Declare Ambition'
                })
            end)
            if ok then return end
            break
        end
    end

    -- Try creating the button, and verify it exists; if not, retry a few times
    local function try_create(attempt)
        attempt = attempt or 1
        local ok, err = pcall(function()
            zero_marker.createButton({
                click_function = 'declare_ambition',
                function_owner = zero_marker,
                position = {0, 0.05, 0},
                width = 3800,
                height = 950,
                tooltip = 'Declare Ambition'
            })
        end)

        -- verify
        local btn_exists = false
        if zero_marker.getButtons then
            local buttons = zero_marker.getButtons() or {}
            for _, b in ipairs(buttons) do
                if b and b.click_function == 'declare_ambition' then
                    btn_exists = true
                    break
                end
            end
        end

        if not btn_exists and attempt < 8 then
            Wait.time(function()
                -- ensure the zero_marker still exists
                local zm = getObjectFromGUID(zero_marker_GUID)
                if zm then
                    ambitionMarkers.add_button_attempts = (ambitionMarkers.add_button_attempts or 0) + 1
                    if ambitionMarkers.add_button_attempts < 8 then
                        ambitionMarkers.add_button()
                    end
                end
            end, 0.5)
        end
    end

    try_create(1)
end

function ambitionMarkers:display_declare_button()
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.editButton({
        click_function = 'declare_ambition',
        tooltip = 'Declare Ambition'
    })
end

function ambitionMarkers:display_undo_button()
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.editButton({
        click_function = 'undo_ambition',
        tooltip = 'Undo'
    })
end


function ambitionMarkers:undo()
    broadcastToAll("Undo Ambition Declaration")
    if (last_declared_marker == nil) then
        Log.ERROR(
            "Could not find last declared ambition marker, resetting zero marker.")
        -- ambitionMarkers.display_declare_button()
        return
    end
    local reach_board = getObjectFromGUID(reach_board_GUID)
    local undo_pos =
        reach_board.positionToWorld(last_declared_marker.column_pos)
    last_declared_marker.object.setPositionSmooth(undo_pos)

    -- move zero marker back
    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94, 0.2, 1.09}))
    zero_marker.setRotationSmooth({0.00, 180.00, 0.00})

    -- ambitionMarkers.display_declare_button()
end

function ambitionMarkers:reset_zero_marker()
    last_declared_marker = nil
    -- ambitionMarkers.display_declare_button()

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    local reach_board = getObjectFromGUID(reach_board_GUID)
    zero_marker.setPositionSmooth(reach_board.positionToWorld({0.94, 0.2, 1.09}))
    zero_marker.setRotationSmooth({0.00, 180.00, 0.00})
end

function ambitionMarkers:highest_undeclared()
    local marker_zone = getObjectFromGUID(ambition_marker_zone_GUID)
    local available_markers = marker_zone.getObjects()
    local high_points = 0
    local high_marker = nil
    local marker_mapping = {
        [ambition_marker_GUIDs[1]] = markers[1],
        [ambition_marker_GUIDs[2]] = markers[2],
        [ambition_marker_GUIDs[3]] = markers[3]
    }

    for _, marker in pairs(available_markers) do
        local this_marker = marker_mapping[marker.getGUID()]
        local this_points = this_marker[this_marker.object.is_face_down]
                                .first_power
        if this_points > high_points then
            high_points = this_points
            high_marker = this_marker
        end
    end

    return high_marker

end

-- Begin Object Code --
function onLoad()
    -- ambitionMarkers.add_button()
end
function declare_ambition(obj, player_color)

    local lead_info = action_cards.get_lead_info()

    -- Is there a lead card?
    if (not lead_info) then
        broadcastToColor("No lead card has been played", player_color)
        return
    end

    -- Is there an ambition marker?
    local high_marker = ambitionMarkers.highest_undeclared()
    if (not high_marker) then
        broadcastToColor("No ambition markers available", player_color)
        return
    end

    -- Get declared ambition 
    local is_faithful = (lead_info.type == "Faithful Zeal" or lead_info.type ==
                            "Faithful Wisdom")

    -- Is the lead card a 1?
    if (lead_info.real_number == 1 and not is_faithful) then
        broadcastToColor("Actions numbered 1 cannot be declared", player_color)
        return
    end

    local power = high_marker[high_marker.object.is_face_down].power_desc
    local reach_board = getObjectFromGUID(reach_board_GUID)

    local this_ambition
    if (lead_info.real_number == 7 or is_faithful) then
        broadcastToAll("" .. player_color ..
                           " is declaring ambition of choice for " .. power,
            player_color)
        broadcastToColor("Move " .. power ..
                             " ambition marker to desired ambition",
            player_color)
    else
        this_ambition = ambitions[lead_info.real_number]
        local pos = high_marker.column_pos + this_ambition.row_pos;
        pos = reach_board.positionToWorld(pos)
        high_marker.object.setPositionSmooth(pos)
        broadcastToAll("" .. player_color .. " has declared " ..
                           this_ambition.name .. " ambition for " .. power,
            player_color)
    end

    last_declared_marker = high_marker

    if this_ambition and ((this_ambition.name == "Keeper" or this_ambition.name == "Empath") and
        ArcsPlayer.has_secret_order(player_color)) then
        broadcastToAll(player_color .. " has SECRET ORDER")
        return
    end

    local zero_marker = getObjectFromGUID(zero_marker_GUID)
    zero_marker.setPositionSmooth(reach_board.positionToWorld({1.02, 0.2, 0.67}))
    zero_marker.setRotationSmooth({0.00, 90.00, 0.00})

    -- ambitionMarkers.display_undo_button()
end
function undo_ambition(obj, player_color)
    ambitionMarkers.undo(obj)
end
-- End Object Code --

return ambitionMarkers
