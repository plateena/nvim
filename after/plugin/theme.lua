function ColorMyPencil(color)
    color = color or "ayu-mirage"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencil()

-- Sets colors to line numbers Above, Current and Below  in this order
function LineNumberColors()
    vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = '#a0c8a0', bold = false })
    -- vim.api.nvim_set_hl(0, 'LineNr', { fg='white', bold=false })
    vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = '#c8a0a0', bold = false })
end

LineNumberColors()
