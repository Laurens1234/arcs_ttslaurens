local ArcsPlayer = require("src/ArcsPlayer")
local ActionCards = require("src/ActionCards")
local BaseGame = require("src/BaseGame")
local Campaign = require("src/Campaign")
local Counters = require("src/Counters")

local GOLD = {0.8, 0.58, 0.27}
local BLACK = {0.05, 0.05, 0.05}
local GREEN = {0.2, 0.5, 0.2}
local PURPLE = {0.5, 0.3, 0.7}
local RED = {0.8, 0.3, 0.2}
local HEADER_FONT_SIZE = 170
local HEADER_SCALE = {0.6, 0.6, 0.6}
local HEADER_WIDTH = 0
local HEADER_HEIGHT = 0
local BUTTON_FONT_SIZE = 140
local BUTTON_SCALE = {0.3, 0.6, 0.6}
local BUTTON_WIDTH = 1500
local BUTTON_HEIGHT = 380

local optionsText_params = {
    click_function = "doNothing",
    function_owner = self,
    label = "Options",
    tooltip = "Toggle the below options to modify the game setup",
    position = {-0.52, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}


local toggleLeadersWITHOUT_params = {
    index = 1,
    click_function = "toggle_leaders",
    function_owner = self,
    label = " Leaders & Lore ",
    tooltip = "Enable Leaders & Lore mode for base game (8 leaders, 14 lore)",
    position = {-0.51, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleLeadersWITH_params = {
    index = 1,
    click_function = "toggle_leaders",
    function_owner = self,
    label = " Leaders & Lore ",
    tooltip = "Disable Leaders & Lore mode for base game",
    position = {-0.51, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local toggleExpansionEXCLUDE_params = {
    index = 2,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion Pack",
    tooltip = "Enable Leaders & Lore Expansion Pack (16 total leaders, 28 total lore)",
    position = {-0.51, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleExpansionINCLUDE_params = {
    index = 2,
    click_function = "toggle_expansion",
    function_owner = self,
    label = "Leaders & Lore\nExpansion Pack",
    tooltip = "Disable Leaders & Lore Expansion Pack",
    position = {-0.51, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local splitDiscardFACEDOWN_params = {
    index = 3,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Reveal face-up played action cards to all players throughout the game",
    position = {-0.51, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local splitDiscardFACEUP_params = {
    index = 3,
    function_owner = self,
    click_function = "toggle_split_discard",
    label = "Split\nDiscard Piles",
    tooltip = "Use single face-down discard pile for action cards",
    position = {-0.51, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local miniaturesDISABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Enable Miniatures",
    position = {-0.51, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local miniaturesENABLED_params = {
    index = 4,
    function_owner = self,
    click_function = "toggle_miniatures",
    label = "Miniatures",
    tooltip = "Disable Miniatures",
    position = {-0.51, 0.5, 1.16},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local toggleLaurensEXCLUDE_params = {
    index = 9,
    click_function = "toggle_laurens_custom",
    function_owner = self,
    label = " Celestial Leaders\n Expansion",
    tooltip = "Include Celestial Leaders Expansion made by Laurens https://laurens1234.github.io/arcs-arsenal/custom-cards",
    position = {-0.51, 0.5, 1.75},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleLaurensINCLUDE_params = {
    index = 9,
    click_function = "toggle_laurens_custom",
    function_owner = self,
    label = "Celestial Leaders\n Expansion",
    tooltip = "Exclude Celestial Leaders Expansion made by Laurens https://laurens1234.github.io/arcs-arsenal/custom-cards",
    position = {-0.51, 0.5, 1.75},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local toggleDontUseBasePackEXCLUDE_params = {
    index = 10,
    click_function = "toggle_dont_use_base_pack",
    function_owner = self,
    label = " Don't use\n Base & Pack Leaders",
    tooltip = "Remove base and pack leaders from setup",
    position = {-0.51, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = RED
}
local toggleDontUseBasePackINCLUDE_params = {
    index = 10,
    click_function = "toggle_dont_use_base_pack",
    function_owner = self,
    label = " Don't use\n Base & Pack Leaders",
    tooltip = "Restore base and pack leaders in setup",
    position = {-0.51, 0.5, 2.32},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = RED,
    font_color = BLACK,
    hover_color = GREEN
}
local leaderCountDec_params = {
    index = 11,
    click_function = "leader_count_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease leader draft count",
    position = {-1.82, 0.5, -0.59},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local leaderCountDisplay_params = {
    index = 12,
    click_function = "doNothing",
    function_owner = self,
    label = "",
    tooltip = "Leader draft count",
    position = {-1.51, 0.5, -0.59},
    width = 300,
    height = 220,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local leaderCountInc_params = {
    index = 13,
    click_function = "leader_count_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase leader draft count",
    position = {-1.2, 0.5, -0.59},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local loreCountDec_params = {
    index = 14,
    click_function = "lore_count_dec",
    function_owner = self,
    label = "-",
    tooltip = "Decrease lore draft count",
    position = {-1.82, 0.5, 0},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = RED,
    font_color = BLACK,
    hover_color = PURPLE
}
local loreCountDisplay_params = {
    index = 15,
    click_function = "doNothing",
    function_owner = self,
    label = "",
    tooltip = "Lore draft count",
    position = {-1.51, 0.5, 0},
    width = 300,
    height = 220,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = BLACK,
    font_color = GOLD
}
local loreCountInc_params = {
    index = 16,
    click_function = "lore_count_inc",
    function_owner = self,
    label = "+",
    tooltip = "Increase lore draft count",
    position = {-1.2, 0.5, 0},
    width = 330,
    height = 250,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local setDefault_params = {
    index = 17,
    click_function = "set_default_counts",
    function_owner = self,
    label = "Set default",
    tooltip = "Set Leaders and Lore to player_count + 1",
    -- position above the Leaders display (same column, one row up)
    position = {-1.51, 0.5, -1.0},
    width = 1200,
    height = 400,
    font_size = 170,
    scale = {0.3,0.3,0.3},
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local setupStartGame_params = {
    click_function = "doNothing",
    function_owner = self,
    label = "Start",
    tooltip = "Once all players have joined, and options are set",
    position = {0.52, 0.5, -1.15},
    width = HEADER_WIDTH,
    height = HEADER_HEIGHT,
    font_size = HEADER_FONT_SIZE,
    scale = HEADER_SCALE,
    color = BLACK,
    font_color = GOLD,
}
local setupBaseGame_params = {
    index = 6,
    click_function = "setup_base_game",
    function_owner = self,
    label = "Base Game \nSetup",
    position = {0.52, 0.5, -0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local setupCampaignGame_params = {
    index = 7,
    click_function = "setup_campaign",
    function_owner = self,
    label = "Campaign \nSetup",
    position = {0.52, 0.5, 0},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local customSetup_params = {
    index = 8,
    function_owner = self,
    click_function = "custom_setup",
    label = "Manual \nSetup",
    tooltip = "",
    position = {0.52, 0.5, 0.59},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GREEN,
    font_color = BLACK,
    hover_color = PURPLE
}
local toggleScavengersEXCLUDE_params = {
    index = 18,
    click_function = "toggle_scavengers",
    function_owner = self,
    label = "PnP#1 Scavengers\n & Scouts Deck",
    tooltip = "Include PnP#1 Scavengers & Scouts deck in setup intead of base court deck",
    position = {-0.51, 0.5, 2.89},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local toggleScavengersINCLUDE_params = {
    index = 18,
    click_function = "toggle_scavengers",
    function_owner = self,
    label = "PnP#1 Scavengers\n & Scouts Deck",
    tooltip = "Exclude PnP#1 Scavengers & Scouts deck from setup",
    position = {-0.51, 0.5, 2.89},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local togglePnp3EXCLUDE_params = {
    index = 20,
    click_function = "toggle_pnp3_custom",
    function_owner = self,
    label = " PnP#3\n Fated Leaders",
    tooltip = "Include PnP#3 fated leader deck in setup",
    position = {-0.51, 0.5, 4.03},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local togglePnp3INCLUDE_params = {
    index = 20,
    click_function = "toggle_pnp3_custom",
    function_owner = self,
    label = " PnP#3\n Fated Leaders",
    tooltip = "Exclude PnP#3 fated leader deck from setup",
    position = {-0.51, 0.5, 4.03},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
local togglePnp2EXCLUDE_params = {
    index = 19,
    click_function = "toggle_pnp2_custom",
    function_owner = self,
    label = " PnP#2\n Lost Vaults",
    tooltip = "Include PnP#2 Lost Vaults leader deck in setup",
    position = {-0.51, 0.5, 3.46},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = BLACK,
    font_color = GOLD,
    hover_color = GREEN
}
local togglePnp2INCLUDE_params = {
    index = 19,
    click_function = "toggle_pnp2_custom",
    function_owner = self,
    label = " PnP#2\n Lost Vaults",
    tooltip = "Exclude PnP#2 Lost Vaults leader deck from setup",
    position = {-0.51, 0.5, 3.46},
    width = BUTTON_WIDTH,
    height = BUTTON_HEIGHT,
    font_size = BUTTON_FONT_SIZE,
    scale = BUTTON_SCALE,
    color = GOLD,
    font_color = BLACK,
    hover_color = RED
}
SetupControl = {
    setup_control_guid = "7299d7",
    setup_control = {},
    teal = {0.4, 0.6, 0.6}
}

function SetupControl:new(o)
    o = o or SetupControl -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function onload()
    -- compute sensible defaults for leader/lore counts so display buttons start with numbers
    local function initial_resolved_default_count()
        local active = Global.getTable("active_players") or {}
        local n = #active
        if n >= 2 and n <= 4 then
            return n + 1
        end
        local players = Player.getPlayers() or {}
        local pn = #players
        if pn >= 1 then
            return pn + 1
        end
        local dbg = Global.getVar("debug_player_count") or 3
        return dbg + 1
    end
    local init_lcount = Global.getVar("leader_draft_count") or initial_resolved_default_count()
    local init_locount = Global.getVar("lore_draft_count") or initial_resolved_default_count()
    leaderCountDisplay_params.label = "Leaders: \n" .. tostring(init_lcount)
    loreCountDisplay_params.label = "Lore: \n" .. tostring(init_locount)

    self.createButton(optionsText_params)
    self.createButton(toggleLeadersWITHOUT_params)
    self.createButton(toggleExpansionEXCLUDE_params)
    self.createButton(splitDiscardFACEDOWN_params)
    self.createButton(miniaturesDISABLED_params)
    self.createButton(setupStartGame_params)
    self.createButton(setupBaseGame_params)
    self.createButton(setupCampaignGame_params)
    self.createButton(customSetup_params)
    self.createButton(toggleLaurensEXCLUDE_params)
    self.createButton(toggleDontUseBasePackEXCLUDE_params)
    -- Leader/Lore draft count controls
    self.createButton(leaderCountDec_params)
    self.createButton(leaderCountDisplay_params)
    self.createButton(leaderCountInc_params)
    self.createButton(loreCountDec_params)
    self.createButton(loreCountDisplay_params)
    self.createButton(loreCountInc_params)
    self.createButton(setDefault_params)
    self.createButton(toggleScavengersEXCLUDE_params)
    self.createButton(togglePnp2EXCLUDE_params)
    self.createButton(togglePnp3EXCLUDE_params)
    -- must add buttons in the order of the actual indices !!!!!!!!!!

    -- Initialize numeric display labels from globals (resolve default if nil)
    local function resolved_default_count()
        local active = Global.getTable("active_players") or {}
        local n = #active
        if n >= 2 and n <= 4 then
            return n + 1
        end
        local players = Player.getPlayers() or {}
        local pn = #players
        if pn >= 1 then
            return pn + 1
        end
        local dbg = Global.getVar("debug_player_count") or 3
        return dbg + 1
    end
    local lcount = Global.getVar("leader_draft_count") or resolved_default_count()
    local locount = Global.getVar("lore_draft_count") or resolved_default_count()
    Global.setVar("leader_draft_count", lcount)
    Global.setVar("lore_draft_count", locount)
    -- Ensure buttons reflect final values (in case globals changed elsewhere)
    self.editButton({index=12, label = "Leaders: \n" .. tostring(lcount)})
    self.editButton({index=15, label = "Lore: \n" .. tostring(locount)})
end

function toggle_leaders(obj, color, alt_click)
    local toggle = Global.getVar("with_leaders")
    local expansion_toggle = Global.getVar("with_more_to_explore")

    toggle = not toggle
    Global.setVar("with_leaders", toggle)

    if (toggle) then
        self.editButton(toggleLeadersWITH_params)
    else
        self.editButton(toggleLeadersWITHOUT_params)
        if expansion_toggle then
            toggle_expansion()
        end
    end
end

function toggle_expansion()
    local toggle = Global.getVar("with_more_to_explore")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_more_to_explore", toggle)

    if (toggle) then
        self.editButton(toggleExpansionINCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(toggleExpansionEXCLUDE_params)
    end
end

function toggle_split_discard()
    local is_faceup_active = ActionCards.toggle_face_up_discard()
    if (is_faceup_active) then
        self.editButton(splitDiscardFACEUP_params)
    else
        self.editButton(splitDiscardFACEDOWN_params)
    end
end

function toggle_miniatures()
    local toggle = Global.getVar("with_miniatures")
    toggle = not toggle 
    Global.setVar("with_miniatures", toggle)
    if (toggle) then
        self.editButton(miniaturesENABLED_params)
        -- Hide meeples, show miniatures
        BaseGame.miniatures_visibility(true)
    else
        self.editButton(miniaturesDISABLED_params)
        -- Show meeples, hide miniatures
        BaseGame.miniatures_visibility(false)
    end
end

function toggle_laurens_custom()
    local toggle = Global.getVar("with_laurens_custom_leader")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_laurens_custom_leader", toggle)

    if (toggle) then
        self.editButton(toggleLaurensINCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(toggleLaurensEXCLUDE_params)
    end
end

function toggle_pnp2_custom()
    local toggle = Global.getVar("with_pnp2_custom_leader")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_pnp2_custom_leader", toggle)

    if (toggle) then
        self.editButton(togglePnp2INCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(togglePnp2EXCLUDE_params)
    end
end

function toggle_pnp3_custom()
    local toggle = Global.getVar("with_pnp3_custom_leader")
    local leaders_toggle = Global.getVar("with_leaders")

    toggle = not toggle
    Global.setVar("with_pnp3_custom_leader", toggle)

    if (toggle) then
        self.editButton(togglePnp3INCLUDE_params)
        if not leaders_toggle then
            Global.setVar("with_leaders", true)
            self.editButton(toggleLeadersWITH_params)
        end
    else
        self.editButton(togglePnp3EXCLUDE_params)
    end
end

function toggle_dont_use_base_pack()
    local toggle = Global.getVar("dont_use_base_and_pack_leaders")
    toggle = not toggle
    Global.setVar("dont_use_base_and_pack_leaders", toggle)

    if (toggle) then
        self.editButton(toggleDontUseBasePackINCLUDE_params)
    else
        self.editButton(toggleDontUseBasePackEXCLUDE_params)
    end
end

function toggle_scavengers()
    local toggle = Global.getVar("use_scavengers_scouts_deck")

    toggle = not toggle
    Global.setVar("use_scavengers_scouts_deck", toggle)

    if (toggle) then
        self.editButton(toggleScavengersINCLUDE_params)
        
    else
        self.editButton(toggleScavengersEXCLUDE_params)
    end
end
-- Leader/Lore draft count controls
-- Resolve a sensible default (player_count + 1) using active players or debug fallback
local function resolved_default_count()
    local active = Global.getTable("active_players") or {}
    local n = #active
    if n >= 2 and n <= 4 then
        return n + 1
    end
    local players = Player.getPlayers() or {}
    local pn = #players
    if pn >= 1 then
        return pn + 1
    end
    local dbg = Global.getVar("debug_player_count") or 3
    return dbg + 1
end

local function display_count_label(count)
    return tostring(count)
end

function change_leader_count(obj, color, delta)
    local current = Global.getVar("leader_draft_count")
    if not current then current = resolved_default_count() end
    local count = math.max(1, math.min(100, current + delta))
    Global.setVar("leader_draft_count", count)
    self.editButton({index=12, label="Leaders: \n" .. display_count_label(count)})
end

function change_lore_count(obj, color, delta)
    local current = Global.getVar("lore_draft_count")
    if not current then current = resolved_default_count() end
    local count = math.max(1, math.min(28, current + delta))
    Global.setVar("lore_draft_count", count)
    self.editButton({index=15, label="Lore: \n" .. display_count_label(count)})
end

function leader_count_dec(obj, color, alt_click)
    change_leader_count(obj, color, -1)
end

function leader_count_inc(obj, color, alt_click)
    change_leader_count(obj, color, 1)
end

function lore_count_dec(obj, color, alt_click)
    change_lore_count(obj, color, -1)
end

function lore_count_inc(obj, color, alt_click)
    change_lore_count(obj, color, 1)
end

function set_default_counts(obj, color, alt_click)
    local def = resolved_default_count()
    Global.setVar("leader_draft_count", def)
    Global.setVar("lore_draft_count", def)
    -- Update displays with prefixes
    self.editButton({index=12, label = "Leaders: \n" .. tostring(def)})
    self.editButton({index=15, label = "Lore: \n" .. tostring(def)})
end

function setup_base_game()
    local base_setup_success = BaseGame.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (base_setup_success and Global.getVar("with_leaders")) then
        leader_buttons()
        return
    end

    if (base_setup_success) then
        destroyObject(self)
    end

end

function setup_leaders()
    if BaseGame.setup_leaders() == false then
        broadcastToAll("\nPlace chosen leader near player board to continue.", {
            r = 1,
            g = 0,
            b = 0
        })
        return
    end

    destroyObject(self)
end

function setup_campaign()
    local campaign_setup_success = Campaign.setup(Global.getVar("with_leaders"),
        Global.getVar("with_more_to_explore"),
        Global.getVar("with_miniatures"))

    if (campaign_setup_success) then
        destroyObject(self)
    end
end

function custom_setup()
    Global.call("setup_custom_game")
    destroyObject(self)
end

function leader_buttons()
    self.setPositionSmooth({54.25, 1.2, 0})

    self.editButton({
        index = 2,
        click_function = "setup_leaders",
        label = "Setup Leaders",
        color = GREEN,
        font_color = BLACK,
        hover_color = PURPLE,
        tooltip = "Setup ship placements and acquire resources based on the leader detected to the left of each player board"
    })

    -- Clear all other buttons
    local empty_button = {
        height = 1,
        width = 1,
        click_function = "doNothing",
        label = "",
        tooltip = ""
    }

    for i = 0, 19 do
        if i ~= 2 then  -- Skip the leader button
            empty_button.index = i
            self.editButton(empty_button)
        end
    end
end

function doNothing()
end

return SetupControl