local ls = require("luasnip")
local c = ls.choice_node
local f = ls.function_node
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

-- Detect line comment symbol based on filetype
local function comment_prefix()
    local ft = vim.bo.filetype
    local map = {
        lua = "--",
        python = "#",
        sh = "#",
        bash = "#",
        javascript = "//",
        typescript = "//",
        go = "//",
        rust = "//",
        html = "<!--",
        css = "/*",
        ruby = "#",
    }
    return map[ft] or "//"
end

-- Git user + date string
local function git_meta()
    local user = vim.fn.system("git config --get user.name"):gsub("%s+$", "")
    local date = os.date("%Y-%m-%d")
    return user .. ":" .. date
end

return {
    s({
        trig = "tc",
        name = "Tagged Comment",
        desc = "Insert a structured comment with selectable tags and git metadata"
    }, fmt("{} @{}: <{}> {}", {
        f(comment_prefix, {}),
        c(1, {
            t("TODO"),
            t("FIX"), t("FIXME"), t("BUG"), t("FIXIT"), t("ISSUE"), t("DEBUG"),
            t("HACK"),
            t("WARN"), t("WARNING"), t("XXX"),
            t("PERF"), t("OPTIM"), t("PERFORMANCE"), t("OPTIMIZE"),
            t("NOTE"), t("INFO"),
            t("TEST"), t("TESTING"), t("PASSED"), t("FAILED"),
            t("SPEC"), t("SPECIFICATION"), t("BEHAVIOR"),
            t("MOCK"), t("STUB"), t("FAKE"),
            t("REFACTOR"), t("CLEANUP"), t("IMPROVE"),
        }),
        f(git_meta, {}),
        i(2, "what to be done"),
    })),

    s({
        trig = "todo",
        name = "TODO Comment",
        desc = "Insert a TODO comment with git metadata"
    }, fmt("{} @TODO: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "what to be done")
    })),

    s({
        trig = "fix",
        name = "FIX Comment",
        desc = "Insert a FIX comment for bugs or issues"
    }, fmt("{} @FIX: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "what to fix")
    })),

    s({
        trig = "note",
        name = "NOTE Comment",
        desc = "Insert a NOTE comment for important information"
    }, fmt("{} @NOTE: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "note to self")
    })),

    s({
        trig = "hack",
        name = "HACK Comment",
        desc = "Insert a HACK comment for temporary workarounds"
    }, fmt("{} @HACK: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "hacky workaround")
    })),

    s({
        trig = "warn",
        name = "WARNING Comment",
        desc = "Insert a WARNING comment for potential issues"
    }, fmt("{} @WARN: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "potential issue")
    })),

    s({
        trig = "perf",
        name = "PERFORMANCE Comment",
        desc = "Insert a PERF comment for performance concerns"
    }, fmt("{} @PERF: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "performance concern")
    })),

    s({
        trig = "test",
        name = "TEST Comment",
        desc = "Insert a TEST comment for testing requirements"
    }, fmt("{} @TEST: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "test this case")
    })),

    s({
        trig = "refactor",
        name = "REFACTOR Comment",
        desc = "Insert a REFACTOR comment for code cleanup tasks"
    }, fmt("{} @REFACTOR: <{}> {}", {
        f(comment_prefix, {}),
        f(git_meta, {}),
        i(1, "clean up logic")
    })),

    s("dateYMD", fmt("{}{}{}{}{}", {
        i(1, os.date("%Y")),                              -- Editable year with current year as default
        c(2, { t("-"), t("/"), t("."), t(" "), t("_") }), -- Separator choice
        i(3, os.date("%m")),                              -- Editable month
        f(function(args) return args[1] end, { 2 }),      -- Reuse the chosen separator
        i(4, os.date("%d")),                              -- Editable day
    })),

    s("dateDMY", fmt("{}{}{}{}{}", {
        i(1, os.date("%d")),                              -- Editable day
        c(2, { t("-"), t("/"), t("."), t(" "), t("_") }), -- Separator choice
        i(3, os.date("%m")),                              -- Editable month
        f(function(args) return args[1] end, { 2 }),      -- Reuse separator
        i(4, os.date("%Y")),                              -- Editable year
    })),
}
