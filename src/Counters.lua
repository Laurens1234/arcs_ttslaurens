require("src/GUIDs")
local LOG = require("src/LOG")

-- Create counters that can be attached to containers or zones to count the objects contained inside.

local ObjectCounters = {}
local the_counters
local player_pieces_guids
local has_counter = {}

local function initializeCounters()
    player_pieces_guids = Global.getVar("player_pieces_GUIDs")
    return {
        {
            container_GUID = player_pieces_guids["White"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["White"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["White"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Yellow"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Red"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["ships"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["agents"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = player_pieces_guids["Teal"]["starports"],
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {1, 1, 1}
        }, {
            container_GUID = Global.getVar("imperial_ships_GUID") or imperial_ships_GUID,
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.8, 0.58, 0.27}
        }, {
            container_GUID = blight_GUID,
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.7, 0.9, 0.7}
        }, {
            container_GUID = Global.getVar("free_cities_GUID") or free_cities_GUID,
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0.06, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.7, 0.7, 0.7}
        }, {
            container_GUID = Global.getVar("free_starports_GUID") or free_starports_GUID,
            position = {0.5, 0.06, 0.03},
            shadow = {0.03, 0.06, 0.02},
            scale = {1, 1, 1},
            font_size = 365,
            font_color = {0.7, 0.7, 0.7}
        }
    }
end

function ObjectCounters.setup()
    the_counters = initializeCounters()
    for _, counter in pairs(the_counters) do
        local obj = nil
        if counter and counter.container_GUID then
            obj = getObjectFromGUID(counter.container_GUID)
        end
        if not obj then
            if debug and LOG and LOG.WARNING then
                LOG.WARNING("ObjectCounters.setup: missing object for GUID " .. tostring(counter and counter.container_GUID) .. ", scheduling retry")
            end
            -- Schedule a retry: wait until the object becomes available, then attach the counter
            local missing_guid = counter and counter.container_GUID
            if missing_guid then
                pcall(function()
                    -- attempt to match by GUID or by expected nickname (fallback)
                    local expected_name = nil
                    pcall(function()
                        if player_pieces_guids then
                            for color, tbl in pairs(player_pieces_guids) do
                                for kind, guidval in pairs(tbl) do
                                    if guidval == missing_guid then
                                        if kind == "ships" then expected_name = color .. " Ship Supply"
                                        elseif kind == "agents" then expected_name = color .. " Agent Supply"
                                        elseif kind == "starports" then expected_name = color .. " Starport Supply"
                                        end
                                    end
                                end
                            end
                        end
                    end)

                    Wait.condition(function()
                        local o = getObjectFromGUID(missing_guid)
                        if not o and expected_name then
                            local objs = getAllObjects()
                            for _, obj in ipairs(objs) do
                                local ok, name = pcall(function() return obj.getName and obj.getName() end)
                                if ok and name == expected_name then
                                    o = obj
                                    break
                                end
                            end
                        end
                            -- If still not found, try to find a container that holds Imperial Ship objects
                            if not o then
                                local all = getAllObjects()
                                for _, cand in ipairs(all) do
                                    local ok_get, inner = pcall(function() return cand.getObjects and cand.getObjects() end)
                                    if ok_get and inner then
                                        for _, item in ipairs(inner) do
                                            local iname = nil
                                            pcall(function()
                                                if type(item) == "table" then iname = item.name end
                                                if type(item) == "userdata" and item.getName then iname = item.getName() end
                                            end)
                                            if iname and string.find(iname, "Imperial Ship") then
                                                o = cand
                                                break
                                            end
                                        end
                                    end
                                    if o then break end
                                end
                            end
                        if o then
                            -- slight delay to allow the object to fully initialize
                            Wait.time(function() ObjectCounters.add(o, counter) end, 0.1)
                        end
                    end, function()
                        if getObjectFromGUID(missing_guid) ~= nil then return true end
                        if expected_name then
                            local objs = getAllObjects()
                            for _, obj in ipairs(objs) do
                                local ok, name = pcall(function() return obj.getName and obj.getName() end)
                                if ok and name == expected_name then
                                    return true
                                end
                            end
                        end
                            -- Also treat presence of a container holding Imperial Ship items as success
                            local all = getAllObjects()
                            for _, cand in ipairs(all) do
                                local ok_get, inner = pcall(function() return cand.getObjects and cand.getObjects() end)
                                if ok_get and inner then
                                    for _, item in ipairs(inner) do
                                        local iname = nil
                                        pcall(function()
                                            if type(item) == "table" then iname = item.name end
                                            if type(item) == "userdata" and item.getName then iname = item.getName() end
                                        end)
                                        if iname and string.find(iname, "Imperial Ship") then
                                            return true
                                        end
                                    end
                                end
                            end
                        return false
                    end)
                end)
            end
        else
            if debug and LOG and LOG.INFO then
                local ok, _type = pcall(function() return obj.type end)
                local ok2, _name = pcall(function() return obj.getName and obj.getName() or obj.name end)
                LOG.INFO("ObjectCounters.setup: found object for GUID " .. tostring(counter and counter.container_GUID) .. " type=" .. tostring(_type) .. " name=" .. tostring(_name))
            end
            -- slight delay to ensure object is fully ready before attaching buttons
            Wait.time(function() ObjectCounters.add(obj, counter) end, 0.1)
        end
    end
    -- Final pass: ensure counters' labels are correct for any containers that exist
    for _, counter in pairs(the_counters or {}) do
        local existing_obj = counter and counter.container_GUID and getObjectFromGUID(counter.container_GUID)
        if existing_obj then
            pcall(function() ObjectCounters.update(existing_obj) end)
        end
    end
end

function ObjectCounters.add(container, button)
    if not container then
        if debug and LOG and LOG.WARNING then
            LOG.WARNING("ObjectCounters.add: called with nil container")
        end
        return
    end
    local guid = nil
    pcall(function() guid = container.getGUID() end)
    local existing = {}
    local ok_buttons = pcall(function() existing = container.getButtons() or {} end)
    if not ok_buttons then
        if debug and LOG and LOG.WARNING then LOG.WARNING("ObjectCounters.add: failed to read buttons for " .. tostring(guid)) end
        return
    end
    if debug and LOG and LOG.INFO then
        pcall(function()
            LOG.INFO("ObjectCounters.add: target GUID=" .. tostring(guid) .. " type=" .. tostring(container.type) .. " existing_buttons=" .. tostring(#existing) .. " button_spec=" .. tostring(button and button.container_GUID))
        end)
    end

    if (container.type == "Infinite") then
        -- If buttons already exist, edit them instead of creating duplicates
        if #existing >= 2 then
            has_counter[guid] = true
            pcall(function() container.editButton({index = 0, label = "∞"}) end)
            pcall(function() container.editButton({index = 1, label = "∞"}) end)
            if debug and LOG and LOG.INFO then pcall(function() LOG.INFO("ObjectCounters.add: edited Infinite buttons for "..tostring(guid)) end) end
            return
        end

        if debug and LOG and LOG.INFO then pcall(function() LOG.INFO("ObjectCounters.add: creating Infinite buttons for "..tostring(guid)) end) end
        container.createButton({
            function_owner = self,
            click_function = "doNothing",
            label = "∞",
            position = Vector(button.shadow) + Vector(button.position),
            rotation = button.rotation and button.rotation or {0, 0, 0},
            width = 0,
            height = 0,
            scale = button.scale,
            font_size = button.font_size,
            font_color = {0, 0, 0}
        })
        container.createButton({
            function_owner = self,
            click_function = "doNothing",
            label = "∞",
            position = button.position,
            rotation = button.rotation and button.rotation or {0, 0, 0},
            width = 0,
            height = 0,
            scale = button.scale,
            font_size = button.font_size,
            font_color = button.font_color
        })
        has_counter[guid] = true
        return
    end

    local objs = nil
    local ok_objs = pcall(function() objs = container.getObjects() end)
    if not ok_objs or not objs then
        if debug and LOG and LOG.WARNING then LOG.WARNING("ObjectCounters.add: failed to read objects for " .. tostring(guid) .. ", scheduling retry") end
        -- Try again shortly: object may not be fully initialized after reload/rewind
        Wait.time(function()
            pcall(function()
                -- Only retry if the container still exists
                local g = nil
                pcall(function() g = container.getGUID() end)
                if g and getObjectFromGUID(g) then
                    ObjectCounters.add(getObjectFromGUID(g), button)
                end
            end)
        end, 0.5)
        return
    end
    if debug and LOG and LOG.INFO then pcall(function() LOG.INFO("ObjectCounters.add: objects_count="..tostring(#objs).." for "..tostring(guid)) end) end
    local label = "" .. #objs
    if #existing >= 2 then
        has_counter[guid] = true
        container.editButton({index = 0, label = label})
        container.editButton({index = 1, label = label})
        if debug and LOG and LOG.INFO then pcall(function() LOG.INFO("ObjectCounters.add: edited buttons for "..tostring(guid).." label="..tostring(label)) end) end
        return
    end

    has_counter[guid] = true
    if debug and LOG and LOG.INFO then pcall(function() LOG.INFO("ObjectCounters.add: creating buttons for "..tostring(guid).." label="..tostring(label)) end) end
    container.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = label,
        position = Vector(button.shadow) + Vector(button.position),
        rotation = button.rotation and button.rotation or {0, 0, 0},
        width = 0,
        height = 0,
        scale = button.scale,
        font_size = button.font_size,
        font_color = {0, 0, 0}
    })
    container.createButton({
        function_owner = self,
        click_function = "doNothing",
        label = label,
        position = button.position,
        rotation = button.rotation and button.rotation or {0, 0, 0},
        width = 0,
        height = 0,
        scale = button.scale,
        font_size = button.font_size,
        font_color = button.font_color
    })
    -- log("Attached counter to: "..container.getName())
end

function ObjectCounters.update(container)
    if has_counter[container.getGUID()] then
        container.editButton({
            index = 0,
            label = "" .. #container.getObjects()
        })
        container.editButton({
            index = 1,
            label = "" .. #container.getObjects()
        })
    end
end

return ObjectCounters
