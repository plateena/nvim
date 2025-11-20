local ls = require("luasnip")
local f  = ls.function_node
local i  = ls.insert_node
local s  = ls.snippet

-- must be defined before usage
local function relpath(from, to)
    local function split(p)
        local t = {}
        for part in string.gmatch(p, "[^/]+") do
            table.insert(t, part)
        end
        return t
    end

    local a = split(from)
    local b = split(to)

    local i = 1
    while i <= #a and i <= #b and a[i] == b[i] do
        i = i + 1
    end

    local out = {}

    for _ = 1, (#a - i + 1) do
        table.insert(out, "..")
    end

    for j = i, #b do
        table.insert(out, b[j])
    end

    return table.concat(out, "/")
end

local function wiki_header()
    local root   = vim.fn.getcwd()
    local file   = vim.fn.expand("%:p")
    local curdir = vim.fn.fnamemodify(file, ":h")

    local rel = relpath(curdir, root)
    if rel == "" then rel = "." end

    return string.format(
        "[Home](%s/index.md) | [Work](%s/work/work.md) | [Sprint](%s/work/sprint/sprint.md) | [Info](%s/info/info.md)",
        rel, rel, rel, rel, rel
    )
end

ls.add_snippets("markdown", {
    s("wikihead", { f(wiki_header) }),
})

ls.add_snippets("markdown", {
    s("sprintheader", {
        t("# 🏃 Sprint "), i(1, "16"), t({"", "> **Sprint Dates:** "}), i(2, "9–28 Nov 2025"), t({"", "> **Week:** "}), i(3, "46")
    }),
})

ls.add_snippets("markdown", {
  s("sprintcycle", {
    -- Header
    t("[Home](../../../index.md) | [Work](../../../work/work.md) | [Sprint](../../../work/sprint/sprint.md) | [Note](../../../notes/index.md)"),
    t({"", ""}),
    t("# 🏃 Sprint "), i(1, "16"),
    t({"", "> ✅ **Sprint Dates:** "}), i(2, "9–28 Nov 2025"),
    t({"", "> ⚠️ **Weeks:** "}), i(3, "46, 47, 48"),
    t({"", "---", ""}),

    -- Planning
    t("## 📝 Planning ("), i(4, "2025-11-16"), t(")"),
    t({"", "*(No additional notes)*", ""}),
    t({"---", ""}),

    -- Review 1
    t("## 🔍 Review ("), i(5, "2025-11-17"), t(")"),
    t({"", "- "}), i(6, "First review item"),
    t({"", "- "}), i(7, "Second review item"),
    t({"", "- "}), i(8, "Third review item"),
    t({"", "> **Note:** "}), i(9, "Optional note"),
    t({"", "---", ""}),

    -- Review 2
    t("## 🔍 Review ("), i(10, "2025-11-24"), t(")"),
    t({"", "- "}), i(11, "First review item"),
    t({"", "- "}), i(12, "Second review item"),
    t({"", "- "}), i(13, "Third review item"),
    t({"", "---", ""}),

    -- Retrospective
    t("## 🔄 Retrospective ("), i(14, "2025-11-30"), t(")"),
    t({"", ""}),
    t("### ✅ What Went Well"),
    t({"", "- "}), i(15, "Positive point 1"),
    t({"", "- "}), i(16, "Positive point 2"),
    t({"", "- "}), i(17, "Positive point 3"),
    t({"", ""}),
    t("### ⚠️ What Can Be Improved"),
    t({"", "- "}), i(18, "Improvement 1"),
    t({"", "- "}), i(19, "Improvement 2"),
    t({"", ""}),
    t("### 🎯 Focus for Next Sprint"),
    t({"", "- "}), i(20, "Next focus 1"),
    t({"", "- "}), i(21, "Next focus 2"),
    t({"", "- "}), i(22, "Next focus 3"),
  }),
})
