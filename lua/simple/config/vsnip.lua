vim.cmd("let g:vsnip_snippet_dir='" .. vim.fn.stdpath("config") .. "/snippets'")

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

_G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif vim.fn['vsnip#available'](1) == 1 then
        return t "<Plug>(vsnip-expend-or-jump)"
    elseif check_back_space() then
        return t "<Tab>"
    else
        return vim.fn['compe#complete']()
    end
end

vim.keymap.set("i", "<Tab>", "v:lua.tab_complete()", { expr = true })
vim.keymap.set("s", "<Tab>", "v:lua.tab_complete()", { expr = true })
vim.keymap.set("i", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
vim.keymap.set("s", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
