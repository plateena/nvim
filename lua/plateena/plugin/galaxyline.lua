local gl = require('galaxyline')
local gls = gl.section
gl.short_line_list = { 'LuaTree', 'vista', 'dbui' }

local colors = {
    bg = '#282c34',
    yellow = '#fabd2f',
    cyan = '#008080',
    darkblue = '#081633',
    green = '#afd700',
    orange = '#FF8800',
    purple = '#5d4d7a',
    magenta = '#d16d9e',
    grey = '#c0c0c0',
    blue = '#0087d7',
    red = '#ec5f67'
}

local buffer_not_empty = function()
    if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
        return true
    end
    return false
end

gls.left[1] = {
    FileIcon = {
        provider = 'FileIcon',
        condition = buffer_not_empty,
        highlight = { require('galaxyline.provider_fileinfo').get_file_icon_color, colors.darkblue },
    },
}
gls.left[2] = {
    FileName = {
        provider = { 'FileName' },
        condition = buffer_not_empty,
        separator = '',
        separator_highlight = { colors.purple, colors.darkblue },
        highlight = { colors.magenta, colors.darkblue }
    }
}
gls.left[3] = {
    GitIcon = {
        provider = function() return '  ' end,
        condition = buffer_not_empty,
        highlight = { colors.orange, colors.purple },
    }
}
gls.left[4] = {
    GitBranch = {
        provider = 'GitBranch',
        condition = buffer_not_empty,
        highlight = { colors.grey, colors.purple },
    }
}

local checkwidth = function()
    local squeeze_width = vim.fn.winwidth(0) / 2
    if squeeze_width > 40 then
        return true
    end
    return false
end

gls.left[5] = {
    DiffAdd = {
        provider = 'DiffAdd',
        condition = checkwidth,
        icon = '  ',
        highlight = { colors.green, colors.purple },
    }
}
gls.left[6] = {
    DiffModified = {
        provider = 'DiffModified',
        condition = checkwidth,
        icon = ' ',
        highlight = { colors.orange, colors.purple },
    }
}
gls.left[7] = {
    DiffRemove = {
        provider = 'DiffRemove',
        condition = checkwidth,
        icon = ' ',
        highlight = { colors.red, colors.purple },
    }
}
gls.left[8] = {
    LeftEnd = {
        provider = function() return '' end,
        separator = '',
        separator_highlight = { colors.purple, colors.bg },
        highlight = { colors.purple, colors.purple }
    }
}
gls.left[9] = {
    DiagnosticError = {
        provider = 'DiagnosticError',
        icon = '  ',
        highlight = { colors.red, colors.bg }
    }
}
gls.left[10] = {
    Space = {
        provider = function() return ' ' end
    }
}
gls.left[11] = {
    DiagnosticWarn = {
        provider = 'DiagnosticWarn',
        icon = '  ',
        highlight = { colors.blue, colors.bg },
    }
}
gls.right[1] = {
    FileFormat = {
        provider = 'FileFormat',
        separator = '',
        separator_highlight = { colors.bg, colors.purple },
        highlight = { colors.grey, colors.purple },
    }
}
gls.right[2] = {
    LineInfo = {
        provider = 'LineColumn',
        separator = ' | ',
        separator_highlight = { colors.darkblue, colors.purple },
        highlight = { colors.grey, colors.purple },
    },
}
gls.right[3] = {
    PerCent = {
        provider = 'LinePercent',
        separator = '',
        separator_highlight = { colors.darkblue, colors.purple },
        highlight = { colors.grey, colors.darkblue },
    }
}
gls.right[4] = {
    ScrollBar = {
        provider = 'ScrollBar',
        highlight = { colors.yellow, colors.purple },
    }
}

gls.short_line_left[1] = {
    BufferType = {
        provider = 'FileTypeName',
        separator = '',
        separator_highlight = { colors.purple, colors.bg },
        highlight = { colors.grey, colors.purple }
    }
}


gls.short_line_right[1] = {
    BufferIcon = {
        provider = 'BufferIcon',
        separator = '',
        separator_highlight = { colors.purple, colors.bg },
        highlight = { colors.grey, colors.purple }
    }
}
