-- Simple Sheets sender for testing
-- This module exposes a global UI callback `send_scores_to_sheet_ui`

local WEBHOOK_URL = "https://script.google.com/macros/s/AKfycbzxiXiVEsipttcM3VI_pKqfTb7ANbltd36ji3qmTPepiXYZyILFI-zNr_9y57uohzk0gA/exec"

local SheetsSender = {}

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
    local body = JSON.encode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    -- Ensure WebRequest API is available
    if not WebRequest or not WebRequest.custom then
        broadcastToAll("Sheets: WebRequest API not available in this environment", {1,0,0})
        return
    end

    -- Use WebRequest.custom with JSON body (matches the working example pattern)
    local ok, err = pcall(function()
        WebRequest.custom(WEBHOOK_URL, "POST", true, body, headers, function(response)
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

return SheetsSender
