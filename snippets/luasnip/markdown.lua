local ls = require("luasnip")
local f = ls.function_node
local i = ls.insert_node
local s = ls.snippet

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
  local root = vim.fn.getcwd()
  local file = vim.fn.expand("%:p")
  local curdir = vim.fn.fnamemodify(file, ":h")

  local rel = relpath(curdir, root)
  if rel == "" then
    rel = "."
  end

  return string.format(
    "[Home](%s/index.md) | [Work](%s/work/work.md) | [Sprint](%s/work/sprint/sprint.md) | [Info](%s/info/info.md) | [Notes](%s/notes/notes.md) | [Archive](%s/archive/archive.md)",
    rel,
    rel,
    rel,
    rel,
    rel,
    rel
  )
end

local function current_month_year()
  return os.date("%B %Y")
end

local function current_date()
  return os.date("%Y-%m-%d")
end

ls.add_snippets("markdown", {
  s("wikihead", { f(wiki_header) }),
})

ls.add_snippets("markdown", {
  s("sprintcycle", {
    t(
      "[Home](../../../index.md) | [Work](../../../work/work.md) | [Sprint](../../../work/sprint/sprint.md) | [Note](../../../notes/notes.md) | [Archive](../../../archive/archive.md)"
    ),
    t({ "", "" }),

    t("# 🏃 Sprint "),
    i(1, "16"),
    t({ "", "> 📅 **Sprint Period:** " }),
    f(current_month_year),
    t({ "", "> ⚠️ **Weeks:** " }),
    i(2, "46, 47, 48"),
    t({ "", "---", "" }),

    t("## 👉  Task: "),
    t({ "", "<!-- TASKWARRIOR:START -->", "" }),
    t({ "<!-- TASKWARRIOR:END -->", "" }),
    t({ "", "---", "" }),

    t("## 📝 Planning ("),
    f(current_date),
    t(")"),
    t({ "", "*(No additional notes)*", "" }),
    t({ "---", "" }),

    t("## 🔍 Review ("),
    f(current_date),
    t(")"),
    t({ "", "- " }),
    i(3, "First review item"),
    t({ "", "- " }),
    i(4, "Second review item"),
    t({ "", "- " }),
    i(5, "Third review item"),
    t({ "", "> **Note:** " }),
    i(6, "Optional note"),
    t({ "", "---", "" }),

    t("## 🔍 Review ("),
    f(current_date),
    t(")"),
    t({ "", "- " }),
    i(7, "First review item"),
    t({ "", "- " }),
    i(8, "Second review item"),
    t({ "", "- " }),
    i(9, "Third review item"),
    t({ "", "---", "" }),

    t("## 🔄 Retrospective ("),
    f(current_date),
    t(")"),
    t({ "", "" }),

    t("### ✅ What Went Well"),
    t({ "", "- " }),
    i(10, "Positive point 1"),
    t({ "", "- " }),
    i(11, "Positive point 2"),
    t({ "", "- " }),
    i(12, "Positive point 3"),
    t({ "", "" }),

    t("### ⚠️ What Can Be Improved"),
    t({ "", "- " }),
    i(13, "Improvement 1"),
    t({ "", "- " }),
    i(14, "Improvement 2"),
    t({ "", "" }),

    t("### 🎯 Focus for Next Sprint"),
    t({ "", "- " }),
    i(15, "Next focus 1"),
    t({ "", "- " }),
    i(16, "Next focus 2"),
    t({ "", "- " }),
    i(17, "Next focus 3"),
  }),
})
