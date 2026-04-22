local authors = "Quinnsicle, Scyth02, McChew, fallspectrum, Laurens"
local version = "1.0"

require("src/GUIDs")

available_colors = {"White", "Yellow", "Red", "Teal"}

----------------------------------------------------
-- [DEBUG] REMEMBER TO SET TO FALSE BEFORE RELEASE
----------------------------------------------------
debug = false
debug_player_count = 2
----------------------------------------------------

with_leaders = false
with_more_to_explore = false
is_face_up_discard_active = false
with_miniatures = false
with_laurens_custom_leader = false
with_pnp3_leaders = false
dont_use_base_and_pack_leaders = false
use_scavengers_scouts_deck = false
is_auto_end_round_enabled = false -- toggle end round
turn_count = 0
leader_draft_count = nil
lore_draft_count = nil

oop_components = {
    {
        Sector = {
            pos = {-0.16, 0.97, -1.02},
            rot = {0, 180, -0.01},
            scale = {2.48, 1, 2.48},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769502/1D85B9468BB538D788FCF7576A05606918CD0DD4/"
        },
        Gate = {
            pos = {-0.04, 0.97, -0.63},
            rot = {0, 189.24, -0.01},
            scale = {0.71, 1, 0.71},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
        }
    }, {
        Sector = {
            pos = {-0.50, 0.97, -0.64},
            rot = {0, 180, -0.01},
            scale = {2.48, 1, 2.48},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769605/A40A0C79B27F1F1C45E0570E46BA8A7B253F356E/"
        },
        Gate = {
            pos = {-0.23, 0.97, -0.21},
            rot = {0, 252.52, 0},
            scale = {0.44, 1, 0.44},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
        }
    }, {
        Sector = {
            pos = {-0.45, 0.97, 0.73},
            rot = {0, 179.99, -0.01},
            scale = {2.36, 1, 2.36},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769710/C408A11914F7F4DEA83686851730DDF10A8BD5D4/"
        },
        Gate = {
            pos = {-0.2, 0.97, 0.28},
            rot = {0, 305.16, 0},
            scale = {0.44, 1, 0.44},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
        }
    }, {
        Sector = {
            pos = {0.17, 0.97, 0.90},
            rot = {0, 179, -0.01},
            scale = {2.54, 1, 2.54},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769816/0AA42154550040133E7D6740F85CD487D5F6967B/"
        },
        Gate = {
            pos = {0.05, 0.97, 0.52},
            rot = {-0.01, 12.02, 0},
            scale = {0.71, 1, 0.71},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769214/A4AD66554742C2FFA93612948C38641B813947FB/"
        }
    }, {
        Sector = {
            pos = {0.5, 0.97, 0.55},
            rot = {0, 179.99, -0.01},
            scale = {2.48, 1, 2.48},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445770194/8600421030523070B8E2F05CECC3281DF24989AC/"
        },
        Gate = {
            pos = {0.24, 0.97, 0.1},
            rot = {-0.01, 72.87, -0.01},
            scale = {0.44, 1, 0.44},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
        }
    }, {
        Sector = {
            pos = {0.46, 0.97, -0.82},
            rot = {0, 180.00, -0.01},
            scale = {2.29, 1, 2.29},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445770362/76677A077FC1D6CD3672DCC036646ABFD2881F62/"
        },
        Gate = {
            pos = {0.2, 0.97, -0.39},
            rot = {-0.01, 125.02, -0.01},
            scale = {0.44, 1, 0.44},
            img = "http://cloud-3.steamusercontent.com/ugc/2313225941445769422/DFF68E0F82851F1AAE746B676B40470DDF3B2FBC/"
        }
    }
}

initiative_player_position = {-2, 0, 0}

active_players = {}
active_ambitions = {
    c9e0ee = "",
    a9b02a = "",
    b0b4d0 = ""
}

zoneWaits = {}
-- track which deck objects we've already patched with the draw-bottom menu
draw_bottom_patched = {}
-- Scan the action deck zone periodically and attach the "Draw bottom card" menu
function scan_action_deck_zone()
  local zone = getObjectFromGUID(action_deck_zone_GUID)
  if not zone then return end

  local found = {}
  local objs = zone.getObjects()
  if objs then
    for _, obj in ipairs(objs) do
      local is_deck = false
      -- prefer the stable tag, fall back to name property/method
      if obj.tag and obj.tag == "Deck" then
        is_deck = true
      elseif obj.getName and obj.getName() == "Deck" then
        is_deck = true
      elseif obj.name == "Deck" then
        is_deck = true
      end
      if is_deck then
        local guid = nil
        if obj.getGUID then guid = obj.getGUID() end
        if not guid and obj.guid then guid = obj.guid end
        if guid then
          found[guid] = true
          if not draw_bottom_patched[guid] then
            pcall(function()
              obj.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
            end)
            draw_bottom_patched[guid] = true
            if debug then broadcastToAll("Attached Draw-bottom to deck " .. guid) end
          end
        end
      end
    end
  end

  -- Remove tracking for decks that have left or been destroyed
  for guid, _ in pairs(draw_bottom_patched) do
    if not found[guid] then
      draw_bottom_patched[guid] = nil
    end
  end
end

function schedule_scan()
  scan_action_deck_zone()
  Wait.time(schedule_scan, 2)
end
----------------------------------------------------
AmbitionMarkers = require("src/AmbitionMarkers")
local ActionCards = require("src/ActionCards")
local ArcsPlayer = require("src/ArcsPlayer")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Control = require("src/Control")
local Counters = require("src/Counters")
local Initiative = require("src/InitiativeMarker")
local RoundManager = require("src/RoundManager")
local SetupControl = require("src/SetupControl")
local Supplies = require("src/Supplies")
local Camera = require("src/Camera")
local Timer = require("src/Timer")
local LOG = require("src/LOG")

function assignPlayerToAvailableColor(player, color)
    local color = table.remove(available_colors, 1)
    broadcastToAll("\nAssigning " .. player.steam_name .. " to color " .. color)
    player.changeColor(color)
end

function get_arcs_player(color)
    for _, p in ipairs(active_players) do
        if (p.color == color) then
            return p
        end
    end
end

function update_player_scores()
    for _, p in ipairs(active_players) do
        p:update_score()
    end
end

function isObjectInZone(object, zone)
    if not object or not zone then return false end
    
    -- Revert to loop-based implementation since containsObject isn't working
    local zoneObjects = zone.getObjects()
    for _, obj in ipairs(zoneObjects) do
        if obj.guid == object.guid then
            return true
        end
    end
    return false
end

function onObjectDrop(player_color, object)
    local object_name = object.getName()

    -- update power
    if (object_name == "Power") then
        local power_color = object.getDescription()
        local player = get_arcs_player(power_color)
        Wait.time(function()
            player:update_score()
        end, 0.5)
    end

    -- Action card tracking
    if object and object.tag == "Card" and object.hasTag("Action") then
        local played_zone = getObjectFromGUID(action_card_zone_GUID)
        local played_zone_card = isObjectInZone(object, played_zone)
        if not played_zone_card then
            return
        end
        -- create a unique wait ID using just the object GUID
        local wait_id = object.getGUID()
        zoneWaits[wait_id] = Wait.condition(function()
            local player = get_arcs_player(Turns.turn_color)
            if (not player) then
                LOG.WARNING("Could not track last played card for " ..
                                Turns.turn_color)
                return
            end

            local seize_zone = getObjectFromGUID(seize_zone_GUID)
            local seize_zone_card = isObjectInZone(object, seize_zone)

            if object.is_face_down and seize_zone_card then
                player:set_last_played_seize_card(object.getDescription())
                broadcastToAll(player.color .. " is seizing the initiative",
                    player.color)
            elseif not object.is_face_down and played_zone_card then
                player:set_last_played_action_card(object.getDescription())
            end

        end, function()
            -- Check if the object still exists
            return object == nil or object.getGUID == nil or object.resting
        end)
    end

    -- ambitions
    if (object_name == "Ambition") then
      -- Resolve object GUID now and re-fetch when the timer runs to avoid
      -- using a stale/invalid object reference in the delayed callback.
      local obj_guid = (object and object.getGUID and object.getGUID()) or object.guid
      Wait.time(function()
        local obj = nil
        if obj_guid then
          obj = getObjectFromGUID(obj_guid)
        end
        if not obj then
          -- fallback: maybe the original object reference is still valid
          obj = object
        end
        if not obj then
          -- final fallback: use requested GUID c9e0ee per user
          obj = getObjectFromGUID("c9e0ee")
        end
        if obj and obj.getPosition then
          AmbitionMarkers.get_ambition_info(obj)
        else
          if debug then broadcastToAll("Ambition callback: object missing for guid " .. tostring(obj_guid)) end
        end
      end, 0.5)
    end
end

function onPlayerAction(player, action, targets)
    if action ~= Player.Action.FlipOver then
        return
    end

    -- Ensure onObjectDrop when someone flips an action card
    if #targets == 1 and targets[1].hasTag("Action") then
        Wait.time(function()
            onObjectDrop(player.color, targets[1])
        end, 0.25)
    end

    -- Convert ship flips into damage state changes
    for _, obj in ipairs(targets) do
        if obj.hasTag("Ship") then
            obj.setState(obj.getStateId() == 1 and 2 or 1)
        end
    end
end

function onObjectEnterScriptingZone(zone, object)
  if not zone or not object then return end

  -- Only care about decks entering the action deck zone
  if zone.getGUID and zone.getGUID() == action_deck_zone_GUID then
    local is_deck = false
    if object.tag and object.tag == "Deck" then is_deck = true end
    if object.getName and object.getName() == "Deck" then is_deck = true end
    if object.name == "Deck" then is_deck = true end
    if not is_deck then return end
    local guid = nil
    if object.getGUID then guid = object.getGUID() end
    if not guid and object.guid then guid = object.guid end
    if not guid then return end
    if draw_bottom_patched[guid] then return end
    pcall(function()
      object.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)
    end)
    draw_bottom_patched[guid] = true
    if debug then broadcastToAll("Attached Draw-bottom to deck " .. guid) end
  end
end

function onPlayerTurn(player, previous_player)

    turn_count = turn_count + 1
    if is_auto_end_round_enabled then
        if turn_count > #getSeatedPlayers() then
            RoundManager.endRound() -- turn count is reset within RoundManager.endRound()
        end
    end

end

function onObjectEnterZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end

    if ((object.getGUID() == initiative_GUID or object.getGUID() ==
        seized_initiative_GUID) and zone_name == "initiative_zone") then
        local zone_color = zone.getDescription()
        Global.setVar("initiative_player", zone_color)
    end
end

function onObjectSpawn(object)
    Initiative.add_menu()
    Supplies.addMenuToObject(object)
  -- If the zero marker spawns (or finishes loading), ensure its ambition button is attached
  local ok, guid = pcall(function() return object.getGUID and object.getGUID() end)
  if ok and guid and guid == zero_marker_GUID then
    pcall(function() AmbitionMarkers.add_button() end)
  end
end

function onObjectLeaveZone(zone, object)
    Counters.update(zone)

    local zone_name = zone.getName()
    if (zone_name == "player" or zone_name == "trophies" or zone_name ==
        "captives" or zone_name == "hand") then
        local zone_color = zone.getDescription()
        for _, p in ipairs(active_players) do
            if (p.color == zone_color) then
                p:update_score()
            end
        end
    end

    -- create a unique wait ID
    local wait_id = zone.getGUID() .. object.getGUID()

    -- check for and remove the Wait.condition if it exists
    if zoneWaits[wait_id] then
        Wait.stop(zoneWaits[wait_id])
    end
end

function onObjectEnterContainer(container, object)
    Counters.update(container)
end

function onObjectLeaveContainer(container, leave_object)
    Counters.update(container)
    local container_tags = container.getTags()
    if #container_tags > 0 then
        if container.type == "Bag" or container.type == "Infinite" then
            leave_object.setTags(container.getTags())

            -- set snap
            leave_object.use_snap_points = true

            -- ships pulled from supply should always be fresh
            Wait.time(function()
                if leave_object.hasTag('Ship') and leave_object.getStateId() == 2 then
                    leave_object.setState(1)
                end
            end, 0.1)
        end
    end
end

function onObjectNumberTyped(number_object, player_color, number_typed)
    if number_object.type == "Deck" then
        print(player_color .. " tried to deal a card to themselves from top of deck, which is unusual, please do it manually")
        return true
    end

    if number_object.hasTag("Action") then
        if number_typed == 1 then
            local player_pieces = {
                ["White"] = {
                    hand_zone = "c832bf"
                },
                ["Yellow"] = {
                    hand_zone = "856b9d"
                },
                ["Teal"] = {
                    hand_zone = "c9dd8d"
                },
                ["Red"] = {
                    hand_zone = "54730a"
                }
            }

            local hand_zone_guid = player_pieces[player_color].hand_zone
            local hand_zone = getObjectFromGUID(hand_zone_guid)
            local hand_pos = hand_zone.getPosition()

            local card_rotation = number_object.getRotation()
            number_object.setPositionSmooth(hand_pos, false, false)
            Wait.time(function()
                number_object.setRotation({0, 180, card_rotation[3]})
            end, 0.25)
            -- we set a slight delay on turning the card face up in hand
            -- this avoids revealing the card when it passes through the played zone
            Wait.time(function()
                number_object.setRotation({0, 180, 0})
            end, 0.75)

        elseif number_typed >= 2 then
            print(player_color .. ", you're only allowed to pull 1 card at a time to yourself, use key 1 only")
        end
        return true
    end
end

function tryObjectEnterContainer(container, object)

    -- allow objects with at least one shared container tag to enter, with exceptions
    for _, tag in ipairs(container.getTags()) do
        if tag == "TealPiece" or tag == "YellowPiece" or tag == "RedPiece" or tag ==
            "WhitePiece" or tag == "lock" then
            goto continue
        end
            
        if object.hasTag(tag) then
            return true
        end
        ::continue::
    end

    return false
end

----------------------------------------------------
-- returns a table of colors in order
function getOrderedPlayers()
    local seated_players = getSeatedPlayers()
    if (debug and #seated_players == 1) then
        broadcastToAll("\nDebugging enabled for " .. debug_player_count ..
                           " players.")
        if (debug_player_count > 3) then
            seated_players = {"White", "Yellow", "Teal", "Red"}
        else
            local all_colors = {"White", "Yellow", "Teal", "Red"}
            -- remove seated players from all_colors
            for _, seated in ipairs(seated_players) do
                for i, all in ipairs(all_colors) do
                    if (seated == all) then
                        table.remove(all_colors, i)
                    end
                end
            end
            -- insert random color in seated_players
            for i = 1, debug_player_count - 1, 1 do
                local rng = math.random(#all_colors)
                local random_color = all_colors[rng]
                table.insert(seated_players, random_color)
                table.remove(all_colors, rng)
            end
        end
    end

    local player_count = #seated_players
    if (player_count > 4 or player_count < 2) then
        msg = "This multiplayer game will only start with 2-4 players. " ..
        "\nTo explore the mod solo, return to main menu, create the game as 'hotseat', " ..
        "load the mod from the Games menu, then pick player colors last."
        broadcastToAll(msg, {
            r = 1,
            g = 0,
            b = 0
        })
        return {""}
    end

    local clockwise_order = {"White", "Yellow", "Teal", "Red"}
    local ordered_players = {}
    local start_index = math.random(player_count)

    for i = 1, #clockwise_order do
        local color = clockwise_order[(start_index + i - 2) % #clockwise_order +
                          1]
        for _, seated_color in ipairs(seated_players) do
            if color == seated_color then
                table.insert(ordered_players, ArcsPlayer:new{
                    color = color
                })
                break
            end
        end
    end

    broadcastToAll("Randomly choosing first player...", Color.Purple)

    return ordered_players
end


----------------------------------------------------

starting_locations = {
    [frontiers_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "a"
            },
            B = {
                cluster = 5,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 4,
                system = "a"
            }
        }
    },
    [homelands_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 5,
                system = "c"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 2,
                system = "a"
            }
        }
    },
    [mix_up_1_2P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "a"
            }
        },
        [2] = {
            A = {
                cluster = 6,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            },
            D = {
                cluster = 1,
                system = "b"
            }
        }
    },
    [mix_up_2_2P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            },
            D = {
                cluster = 6,
                system = "b"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            },
            D = {
                cluster = 3,
                system = "c"
            }
        }
    },
    [homelands_3P_GUID] = {
        [1] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [frontiers_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        }
    },
    [core_conflict_3P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_3P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [frontiers_4P_GUID] = {
        [1] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "b"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 4,
                system = "b"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "a"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        }
    },
    [mix_up_1_4P_GUID] = {
        [1] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 6,
                system = "c"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 4,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "c"
            },
            C = {
                cluster = 6,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 5,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 4,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 6,
                system = "a"
            },
            B = {
                cluster = 1,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_2_4P_GUID] = {
        [1] = {
            A = {
                cluster = 5,
                system = "c"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 2,
                system = "c"
            },
            B = {
                cluster = 1,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "a"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    },
    [mix_up_3_4P_GUID] = {
        [1] = {
            A = {
                cluster = 3,
                system = "c"
            },
            B = {
                cluster = 5,
                system = "b"
            },
            C = {
                cluster = 1,
                system = "gate"
            }
        },
        [2] = {
            A = {
                cluster = 1,
                system = "a"
            },
            B = {
                cluster = 3,
                system = "a"
            },
            C = {
                cluster = 2,
                system = "gate"
            }
        },
        [3] = {
            A = {
                cluster = 1,
                system = "c"
            },
            B = {
                cluster = 4,
                system = "c"
            },
            C = {
                cluster = 3,
                system = "gate"
            }
        },
        [4] = {
            A = {
                cluster = 4,
                system = "a"
            },
            B = {
                cluster = 2,
                system = "b"
            },
            C = {
                cluster = 5,
                system = "gate"
            }
        }
    }
}

starting_pieces = {
    Default = {
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        }
    },
    ["bcc792"] = { -- Elder
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "material"}
    },
    ["a7e9eb"] = { -- Fuel-Drinker
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "fuel"}
    },
    ["8109e1"] = { -- Upstart
        A = {
            building = "city",
            ships = 4
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "material"}
    },
    ["aa0e68"] = { -- Mystic
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "relic"}
    },
    ["c37bb3"] = { -- Demagogue
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "weapon"}
    },
    ["996b9d"] = { -- Feastbringer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["da8b99"] = { -- Rebel
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"material", "weapon"}
    },
    ["639b42"] = { -- Warrior
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"weapon", "material"}
    },
    ["1848eb"] = { -- Noble
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"psionic", "psionic"}
    },
    ["2a5b6f"] = { -- Archivist
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "city",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "relic"}
    },
    ["942aaa"] = { -- Quartermaster
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["4363db"] = { -- Agitator
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 4
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    },
    ["003bc2"] = { -- Anarchist
        A = {
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"relic", "weapon"}
    },
    ["843e46"] = { -- Shaper
        A = {
            building = "city",
            ships = 3
        },
        B = {
            ships = 3
        },
        C = {
            ships = 3
        },
        D = {
            ships = 3
        },
        resources = {"relic", "material"}
    },
    ["a1b65d"] = { -- Corsair
        A = {
            building = "starport",
            ships = 4
        },
        B = {
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "weapon"}
    },
    ["2409c0"] = { -- Overseer
        A = {
            building = "city",
            ships = 3
        },
        B = {
            building = "starport",
            ships = 3
        },
        C = {
            ships = 2
        },
        D = {
            ships = 2
        },
        resources = {"fuel", "material"}
    }
}

-- params = {obj, is_visible}
function move_and_lock_object(params)
    local y_pos = params.is_visible and 1 or -2
    local pos = params.obj.getPosition()
    pos.y = y_pos
    params.obj.setPosition(pos)
    if (params.obj.hasTag("Lock")) then
        params.obj.locked = true
    else
        params.obj.locked = not params.is_visible
    end
end

function set_active_players(players)
    active_players = players
end

function setup_custom_game()

    BaseGame.destroy_grey_setup_menu_objects()

    for _, v in ipairs({"Red", "White", "Yellow", "Teal"}) do
        local arcs_player = ArcsPlayer:new{
            color = v
        }
        table.insert(active_players, arcs_player)
    end
    for _, v in ipairs(active_players) do
        ArcsPlayer.components_visibility(v.color, true, true)
    end

    with_miniatures = Global.getVar("with_miniatures")
    BaseGame.setup_or_destroy_miniatures(with_miniatures)

    local p = {
        is_campaign = true,
        is_4p = true,
        leaders_and_lore = true,
        leaders_and_lore_expansion = true,
        with_faceup_discard = true,
        with_miniatures = with_miniatures,
        players = {"Red", "White", "Yellow", "Teal"}
    }
    set_game_in_progress(p)

    BaseGame.base_exclusive_components_visibility(true)
    BaseGame.setupOutOfPlayForCustom()
end

----------------------------------------------------
-- params = {
--     is_campaign = false,
--     is_4p = #active_players == 4,
--     leaders_and_lore = with_leaders,
--     leaders_and_lore_expansion = with_ll_expansion,
--     faceup_discard = ActionCards.is_face_up_discard_active(),
--     players = active_players
-- }
function set_game_in_progress(params)
    Counters.setup()
    local reach_board = getObjectFromGUID(reach_board_GUID)
    reach_board.setDescription("in progress")

    local visibility = {"Red", "White", "Yellow", "Teal", "Black", "Grey"}

    if (params.with_faceup_discard) then
        ActionCards.faceup_discard_visibility(true)
        local fud_marker = getObjectFromGUID(FUDiscard_marker_GUID)
        fud_marker.setDescription("active")
    end

    BaseGame.core_components_visibility(true)
    if (params.is_campaign) then
        local campaign_rules = getObjectFromGUID(Campaign.guids.rules)
        campaign_rules.setDescription("active")

        Campaign.components_visibility(true)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    else
        BaseGame.base_exclusive_components_visibility(true)
    end
    if (params.is_4p) then
        BaseGame.four_player_cards_visibility(true)
    end
    if (params.leaders_and_lore) then
        BaseGame.leaders_visibility(true, params.leaders_and_lore_expansion)
        BaseGame.lore_visibility(true, params.leaders_and_lore_expansion)
    end

    -- player components visibility
    for _, color in ipairs(params.players) do
        ArcsPlayer.components_visibility(color, true, params.is_campaign)
        local player_board = getObjectFromGUID(
            player_pieces_GUIDs[color].player_board)
        player_board.setDescription("active")
    end
    -- for _, v in ipairs(getOrderedPlayers()) do
    --     ArcsPlayer.components_visibility(v.color, true, params.is_campaign)
    --     local player_board = getObjectFromGUID(v.components.board)
    --     player_board.setDescription("active")
    -- end
end

function onLoad(script_state)
  -- Restore persistent state saved by onSave (if present)
  if script_state and script_state ~= "" then
    local ok, state = pcall(function()
      return JSON.decode(script_state)
    end)
    if ok and state then
      if state.initiative then
        initiative_player = state.initiative.player or initiative_player
        initiative_player_position = state.initiative.position or initiative_player_position
      end
      if state.settings then
        is_face_up_discard_active = state.settings.is_face_up_discard_active or is_face_up_discard_active
      end
    end
  end
    -- create a blank table to store the Wait.conditions in
    zoneWaits = {}

    Initiative.add_menu()

    -- Reattach supply/context menus for all existing objects after load
    Supplies.addMenuToAllObjects()
    -- Recreate visible counters (numbers) on supply containers and similar
    Counters.setup()

    -- Ensure zero marker ambition button exists at startup
    pcall(function() AmbitionMarkers.add_button() end)

    -- start periodic scan to ensure Draw-bottom is attached to any new decks
    schedule_scan()

    local reach_board = getObjectFromGUID(reach_board_GUID)
    if (reach_board.getDescription() == "in progress") then
        broadcastToAll("Loading game in progress")

        for _, v in ipairs({"Red", "White", "Yellow", "Teal"}) do
            local player_board = getObjectFromGUID(
                player_pieces_GUIDs[v].player_board)
            if (player_board.getDescription() == "active") then
                local arcs_player = ArcsPlayer:new{
                    color = v
                }
                table.insert(active_players, arcs_player)
            end
        end

        -- Ensure player boards for colors not active remain hidden
        local all_colors = {"Red", "White", "Yellow", "Teal"}
        for _, col in ipairs(all_colors) do
          local pb = getObjectFromGUID(player_pieces_GUIDs[col].player_board)
          if pb then
            if pb.getDescription() == "active" then
              ArcsPlayer.components_visibility(col, true, false)
            else
              ArcsPlayer.components_visibility(col, false, false)
            end
          end
        end

        -- Safe reattachment of various UI helpers and object onload handlers
        local setup_obj = getObjectFromGUID(SetupControl.setup_control_guid)
        if setup_obj then pcall(function() setup_obj.call("onload") end) end

        local ctrl_obj = getObjectFromGUID(Global.getVar("control_GUID"))
        if ctrl_obj then pcall(function() ctrl_obj.call("onload") end) end

        pcall(function() AmbitionMarkers.add_button() end)
        pcall(function() LawBook.setup() end)

        -- for _, tag in ipairs({"DiceCounter", "DiceBoard"}) do
        --   for _, o in pairs(getObjectsWithTag(tag)) do
        --     pcall(function() o.call("onload") end)
        --     pcall(function() o.call("onLoad") end)
        --   end
        -- end

    elseif debug then
        Campaign.components_visibility(true)
        BaseGame.components_visibility({
            is_visible = true,
            is_campaign = true,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true,
            with_faceup_discard = true
        })
    else
        -- Hide components
        Campaign.components_visibility(false)
        BaseGame.components_visibility({
            is_visible = false,
            is_campaign = false,
            is_4p = true,
            leaders_and_lore = true,
            leaders_and_lore_expansion = true -- ,
            -- faceup_discard = true
        })

        for _, v in pairs(available_colors) do
            ArcsPlayer.components_visibility(v, false, false)
        end
    end

    local action_deck = ActionCards.get_action_deck()
    action_deck.addContextMenuItem("Draw bottom card", ActionCards.draw_bottom)

    for _, obj in pairs(getObjectsWithTag("Noninteractable")) do
        obj.locked = true
        obj.interactable = false
    end

    if (not debug) then
        local face_up_discard_action_deck = getObjectFromGUID(
            face_up_discard_action_deck_GUID)
        face_up_discard_action_deck.setInvisibleTo({
            "Red", "White", "Yellow", "Teal", "Black", "Grey"
        })
        face_up_discard_action_deck.interactable = false
        face_up_discard_action_deck.locked = false -- set this to false otherwise it breaks
    end

    -- Initialize turn system
    Turns.enable = true
    Turns.pass_turns = true

    -- Initialize timer system
    resetTimer() -- Reset all player timers
    loadCameraTimerMenu(false) -- Load the UI with menu closed initially
end

  function onSave()
    local state = {
      initiative = {
        player = initiative_player,
        position = initiative_player_position
      },
      settings = {
        is_face_up_discard_active = is_face_up_discard_active
      }
    }
    return JSON.encode(state)
  end


-- Generated by tools/yml_to_lua.py from leaders.yml
starting_pieces = starting_pieces or {}

-- Kaiju
starting_pieces["Kaiju"] = {
  A = {
    building = "city",
    ships = 4
  },
  B = {
    building = "city",
    ships = 4
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Shapeshifter
starting_pieces["Shapeshifter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Sentient
starting_pieces["Sentient"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "None",
    ships = 2
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Hierarch
starting_pieces["Hierarch"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Smuggler
starting_pieces["Smuggler"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Manipulator
starting_pieces["Manipulator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Necromancer
starting_pieces["Necromancer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Composer
starting_pieces["Composer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Maw
starting_pieces["Maw"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Saint
starting_pieces["Saint"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Seer
starting_pieces["Seer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Terrestrial
starting_pieces["Terrestrial"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- General
starting_pieces["General"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Sentinel
starting_pieces["Sentinel"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Prefect
starting_pieces["Prefect"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Ghost
starting_pieces["Ghost"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Chosen
starting_pieces["Chosen"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Sage
starting_pieces["Sage"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Gambler
starting_pieces["Gambler"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Engineer
starting_pieces["Engineer"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Magician
starting_pieces["Magician"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Weaver
starting_pieces["Weaver"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Dreamer
starting_pieces["Dreamer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Seeker
starting_pieces["Seeker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Augur
starting_pieces["Augur"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Alchemist
starting_pieces["Alchemist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Architect
starting_pieces["Architect"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Martyr
starting_pieces["Martyr"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Scourge
starting_pieces["Scourge"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Beggar
starting_pieces["Beggar"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"None", "None"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Feral
starting_pieces["Feral"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Conduit
starting_pieces["Conduit"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Puppeteer
starting_pieces["Puppeteer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Automaton
starting_pieces["Automaton"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Golem
starting_pieces["Golem"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Solian
starting_pieces["Solian"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Racketeer
starting_pieces["Racketeer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Terraformer
starting_pieces["Terraformer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Trickster
starting_pieces["Trickster"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Nomad
starting_pieces["Nomad"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Iconoclast
starting_pieces["Iconoclast"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Fiend
starting_pieces["Fiend"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"None", "None"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Hustler
starting_pieces["Hustler"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Curator
starting_pieces["Curator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Cartographer
starting_pieces["Cartographer"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Custodian
starting_pieces["Custodian"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Salvager
starting_pieces["Salvager"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Chief
starting_pieces["Chief"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Duelist
starting_pieces["Duelist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Prophet
starting_pieces["Prophet"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Broker
starting_pieces["Broker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Siegebreaker
starting_pieces["Siegebreaker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Courier
starting_pieces["Courier"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Forager
starting_pieces["Forager"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Punter
starting_pieces["Punter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Insurgent
starting_pieces["Insurgent"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Bomber
starting_pieces["Bomber"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Musician
starting_pieces["Musician"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Ozymandias
starting_pieces["Ozymandias"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Collector
starting_pieces["Collector"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Samurai
starting_pieces["Samurai"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Assassin
starting_pieces["Assassin"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Witch
starting_pieces["Witch"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Ambassador
starting_pieces["Ambassador"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Shaman
starting_pieces["Shaman"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Mediator
starting_pieces["Mediator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Despot
starting_pieces["Despot"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Viceroy
starting_pieces["Viceroy"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Artificer
starting_pieces["Artificer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Warmonger
starting_pieces["Warmonger"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Extortioner
starting_pieces["Extortioner"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Emperor
starting_pieces["Emperor"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Titan
starting_pieces["Titan"] = {
  A = {
    building = "city",
    ships = 4
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Egoist
starting_pieces["Egoist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Enforcer
starting_pieces["Enforcer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Treasurer
starting_pieces["Treasurer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Wayfinder
starting_pieces["Wayfinder"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 4
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Champion
starting_pieces["Champion"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Tribune
starting_pieces["Tribune"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Dissector
starting_pieces["Dissector"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Schemer
starting_pieces["Schemer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Hydra
starting_pieces["Hydra"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Enchanter
starting_pieces["Enchanter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Creator
starting_pieces["Creator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Messiah
starting_pieces["Messiah"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Abomination
starting_pieces["Abomination"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Crusader
starting_pieces["Crusader"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Phantom
starting_pieces["Phantom"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Harbormaster
starting_pieces["Harbormaster"] = {
  A = {
    building = "starport",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Investor
starting_pieces["Investor"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"None", "None"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Envoy
starting_pieces["Envoy"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Fuel", "Psionic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Syndic
starting_pieces["Syndic"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Solicitor
starting_pieces["Solicitor"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Relic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Seraph
starting_pieces["Seraph"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Fuel", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}

-- Paragon
starting_pieces["Paragon"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Relic"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Tactician
starting_pieces["Tactician"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Purist
starting_pieces["Purist"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Marauder
starting_pieces["Marauder"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Berserker
starting_pieces["Berserker"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Weapon", "Fuel"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Underwriter
starting_pieces["Underwriter"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}

-- Doppelganger
starting_pieces["Doppelganger"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 2
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 2
  }
}


------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

starting_pieces["Imperator"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

starting_pieces["Poet"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Weapon"},
  D = {
    building = "None",
    ships = 3
  }
}

starting_pieces["Diplomat"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Scavenger"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Material", "Fuel"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Oracle"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Brainbox"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Material"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Abbot"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Relic", "Relic"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["God's Hand"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "city",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Psionic", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Firebrand"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Ancient Wraith"] = {
  A = {
    building = "None",
    ships = 4
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Paladin"] = {
  A = {
    building = "None",
    ships = 4
  },
  B = {
    building = "None",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}
starting_pieces["Profiteer"] = {
  A = {
    building = "city",
    ships = 3
  },
  B = {
    building = "starport",
    ships = 3
  },
  C = {
    building = "None",
    ships = 3
  },
  resources = {"Weapon", "Psionic"},
  D = {
    building = "None",
    ships = 3
  }
}