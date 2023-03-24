local gl = require('galaxyline')
local gls = gl.section
local glt = gl.short_line_list
local condition = require('galaxyline.condition')
local component_separators = { left = '', right = '' }
local section_separators = { left = '', right = '' }

-- onedark
local colors = {
    bg = '#282c34',
    bg_dim = '#333842',
    bg_light = '#444b59',
    black = '#222222',
    white = '#abb2bf',
    gray = '#868c96',
    red = '#e06c75',
    green = '#98c379',
    yellow = '#e5c07b',
    blue = '#61afef',
    purple = '#7c7cff', -- tweaked to match custom color
    teal = '#56b6c2',
}

local function mode_alias(m)
    local alias = {
        n = 'NORMAL',
        i = 'INSERT',
        c = 'COMMAND',
        R = 'REPLACE',
        t = 'TERMINAL',
        [''] = 'V-BLOCK',
        V = 'V-LINE',
        v = 'VISUAL',
    }

    return alias[m] or ''
end

local function mode_color(m)
    local mode_colors = {
        normal = colors.green,
        insert = colors.blue,
        visual = colors.purple,
        replace = colors.red,
    }

    local color = {
        n = mode_colors.normal,
        i = mode_colors.insert,
        c = mode_colors.replace,
        R = mode_colors.replace,
        t = mode_colors.insert,
        [''] = mode_colors.visual,
        V = mode_colors.visual,
        v = mode_colors.visual,
    }

    return color[m] or colors.bg_light
end

-- disable for these file types
gl.short_line_list = { 'startify', 'nerdtree', 'term', 'NvimTree' }

local i = 0

i = i + 1
gl.section.left[i] = {
    ViModeIcon = {
        separator = '  ',
        separator_highlight = { colors.black, colors.bg_light },
        highlight = { colors.red, colors.black, 'bold' },
        -- provider = function() return "   " end,
        provider = function() return "  \u{e7c5} " end,
    }
}

i = i + 1
gl.section.left[i] = {
    CWD = {
        separator = '  ',
        separator_highlight = function()
            return { colors.bg_light, condition.buffer_not_empty() and colors.bg_dim or colors.bg }
        end,
        highlight = { colors.white, colors.bg_light },
        provider = function()
            local dirname = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            return ' ' .. dirname .. ' '
        end,
    }
}

i = i + 1
gl.section.left[i] = {
    FileIcon = {
        provider = 'FileIcon',
        condition = condition.buffer_not_empty,
        highlight = { colors.gray, colors.bg_dim },
    }
}

i = i + 1
gl.section.left[i] = {
    FileName = {
        provider = 'FileName',
        condition = condition.buffer_not_empty,
        highlight = { colors.gray, colors.bg_dim },
        separator_highlight = { colors.bg_dim, colors.bg },
        separator = '  ',
    }
}

i = i + 1
gl.section.left[i] = {
    DiffAdd = {
        icon = '  ',
        provider = 'DiffAdd',
        condition = condition.hide_in_width,
        highlight = { colors.green, colors.bg },
    }
}

i = i + 1
gl.section.left[i] = {
    DiffModified = {
        icon = '  ',
        provider = 'DiffModified',
        condition = condition.hide_in_width,
        highlight = { colors.purple, colors.bg },
    }
}

i = i + 1
gl.section.left[i] = {
    DiffRemove = {
        icon = '  ',
        provider = 'DiffRemove',
        condition = condition.hide_in_width,
        highlight = { colors.red, colors.bg },
        separator = component_separators.left,
        separator_highlight = { colors.red, colors.bg },
    }
}

i = i + 1
gl.section.left[i] = {
    DiagnosticError = {
        provider = 'DiagnosticError',
        icon = '  ',
        highlight = { colors.red, colors.bg }
    }
}

i = i + 1
gl.section.left[i] = {
    Space = {
        provider = function() return ' ' end,
        highlight = { colors.section_bg, colors.bg }
    }
}

i = i + 1
gl.section.left[i] = {
    DiagnosticWarn = {
        provider = 'DiagnosticWarn',
        icon = '  ',
        highlight = { colors.yellow, colors.bg }
    }
}

i = i + 1
gl.section.left[i] = {
    Space = {
        provider = function() return ' ' end,
        highlight = { colors.section_bg, colors.bg }
    }
}

i = i + 1
gl.section.left[i] = {
    DiagnosticInfo = {
        provider = 'DiagnosticInfo',
        icon = '  ',
        highlight = { colors.blue, colors.section_bg },
        separator = ' ',
        separator_highlight = { colors.section_bg, colors.bg }
    }
}
-- end left section


-- start right section

i = 0
i = i + 1
gl.section.right[i] = {
    ShowLspClient = {
        provider = 'GetLspClient',
        condition = function()
            local tbl = { ['dashboard'] = true,[''] = true }
            if tbl[vim.bo.filetype] then
                return false
            end
            return true
        end,
        icon = '  LSP: ',
        highlight = { colors.cyan, colors.bg, 'bold' }
    }
}

i = i + 1
gl.section.right[i] = {
    Space = {
        provider = function ()
           return  ' ' 
        end
    }
}

i = i + 1
gl.section.right[i] = {
    FileType = {
        highlight = { colors.gray, colors.bg },
        provider = function()
            local buf = require('galaxyline.provider_buffer')
            return string.lower(buf.get_buffer_filetype())
        end,
        separator = component_separators.right .. ' ',
        separator_highlight = { colors.cyan, colors.bg, 'bold'  }
    }
}

i = i + 1
gl.section.right[i] = {
    GitBranch = {
        icon = ' ',
        separator = '  ',
        condition = condition.check_git_workspace,
        highlight = { colors.teal, colors.bg },
        provider = 'GitBranch',
    }
}

i = i + 1
gl.section.right[i] = {
    CurrentPosition = {
        icon = ' \u{f07b7} ',
        provider = 'LineColumn',
        separator = ' ' .. component_separators.right,
        separator_highlight = { colors.green, colors.bg },
    }
}

i = i + 1
gl.section.right[i] = {
    FileLocation = {
        icon = ' ',
        -- separator = ' ',
        separator = ' ' .. section_separators.right,
        separator_highlight = { colors.bg_dim, colors.bg },
        highlight = { colors.gray, colors.bg_dim },
        provider = function()
            local current_line = vim.fn.line('.')
            local total_lines = vim.fn.line('$')

            if current_line == 1 then
                return 'Top'
            elseif current_line == total_lines then
                return 'Bot'
            end

            local percent, _ = math.modf((current_line / total_lines) * 100)
            return '' .. percent .. '%'
        end,
    }
}

vim.api.nvim_command('hi GalaxyViModeReverse guibg=' .. colors.bg_dim)

i = i + 1
gl.section.right[i] = {
    ViMode = {
        icon = '  ',
        -- separator = ' ',
        separator = ' ' .. section_separators.right,
        separator_highlight = 'GalaxyViModeReverse',
        highlight = { colors.bg, mode_color() },
        provider = function()
            local m = vim.fn.mode() or vim.fn.visualmode()
            local mode = mode_alias(m)
            local color = mode_color(m)
            vim.api.nvim_command('hi GalaxyViMode guibg=' .. color)
            vim.api.nvim_command('hi GalaxyViModeReverse guifg=' .. color)
            return ' ' .. mode .. ' '
        end,
    }
}

-- end of right section

-- short_line

i = 0;
i = i + 1
gl.section.short_line_left[i] = {
    GitBranch = {
        icon = ' ',
        separator = '  ',
        condition = condition.check_git_workspace,
        highlight = { colors.teal, colors.bg },
        provider = 'GitBranch',
    }
}
