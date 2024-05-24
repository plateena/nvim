-- Function to set the colorscheme and adjust some highlight groups
local function setColorscheme(color)
    color = color or "sonokai"

    local colorscheme_exists = vim.fn.exists("&background")
    if colorscheme_exists == 0 then
        color = "default" -- Set to the default colorscheme if it doesn't exist
    end

    local success, error_message = pcall(function()
        vim.cmd("colorscheme " .. color)

        local highlight = vim.api.nvim_set_hl
        local normal_bg = "none"

        -- highlight(0, 'Normal', { bg = normal_bg })
        -- highlight(0, 'LineNr', { bg = normal_bg })
    end)

    if not success then
        print("Error setting colorscheme:", error_message)
    end
end

-- Function to set colors for line numbers above, current, and below
local function setLineNumberColors()
    local success, error_message = pcall(function()
        local highlight = vim.api.nvim_set_hl
        local above_fg = "#a0c8a0"
        local below_fg = "#c8a0a0"

        highlight(0, "LineNrAbove", { fg = above_fg, bold = false })
        highlight(0, "LineNr", { fg = "white", bold = false })
        highlight(0, "LineNrBelow", { fg = below_fg, bold = false })
    end)

    if not success then
        print("Error setting line number colors:", error_message)
    end
end

-- Set colorscheme and adjust some highlight groups
setColorscheme()

-- Set colors for line numbers
setLineNumberColors()
