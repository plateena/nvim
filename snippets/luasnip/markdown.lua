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
    "[Home](%s/index.md) | [Work](%s/work/work.md) | [Sprint](%s/work/sprint/sprint.md) | [Info](%s/info/info.md) | [Notes](%s/notes/notes.md) | [Archive](%s/archive/archive.md) | [Journal](%s/journal/index.md)",
    rel,
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

local t = ls.text_node

ls.add_snippets("markdown", {
  s("wikihead", { f(wiki_header) }),

  -- Journal entry for today
  s("journal", {
    f(wiki_header),
    t({ "", "", "# " }),
    f(current_date),
    t({ "", "", "## Done", "", "- " }),
    i(1, "task"),
    t({ "", "", "## Notes", "", "- " }),
    i(2, "note"),
    t({ "", "" }),
  }),

  -- Meeting note
  s("meeting", {
    t("## 📋 Meeting: "),
    i(1, "Title"),
    t({ "", "> 📅 " }),
    f(current_date),
    t(" | 👥 "),
    i(2, "attendees"),
    t({ "", "", "### Agenda", "", "- " }),
    i(3, "topic"),
    t({ "", "", "### Decisions", "", "- " }),
    i(4, "decision"),
    t({ "", "", "### Action Items", "", "- [ ] " }),
    i(5, "action"),
    t(" — "),
    i(6, "owner"),
    t({ "", "" }),
  }),

  -- Jira/ticket task block
  s("ticket", {
    t("## "),
    i(1, "CAR-000"),
    t(": "),
    i(2, "Title"),
    t({ "", "", "**Link:** [" }),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t("](https://inscaleasia.atlassian.net/browse/"),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t({ ")", "", "" }),
    t({ "### Notes", "", "- " }),
    i(3, "note"),
    t({ "", "", "### TODO", "", "- [ ] " }),
    i(4, "task"),
    t({ "", "" }),
  }),

  -- Wiki internal link (relative to current file)
  s("wlink", {
    t("["),
    i(1, "text"),
    t("](./"),
    i(2, "file.md"),
    t(")"),
  }),

  -- Callout / admonition block
  s("callout", {
    t("> **"),
    i(1, "⚠️ Warning"),
    t({ "**", "> " }),
    i(2, "content"),
    t({ "", "" }),
  }),

  -- New wiki page with header + title
  s("wikipage", {
    f(wiki_header),
    t({ "", "", "# " }),
    i(1, "Page Title"),
    t({ "", "", "" }),
    i(2),
  }),

  -- Collapsible details section
  s("details", {
    t({ "<details>", "<summary>" }),
    i(1, "Click to expand"),
    t({ "</summary>", "", "" }),
    i(2, "content"),
    t({ "", "", "</details>", "" }),
  }),

  -- Decorated title banner
  s("banner", {
    t({ "---", "", "# ✨ " }),
    i(1, "Title"),
    t({ "", "", "> " }),
    i(2, "A short description or tagline"),
    t({ "", "", "---", "" }),
  }),

  -- Section header with emoji + divider
  s("hsection", {
    t({ "", "---", "", "## " }),
    i(1, "📌"),
    t(" "),
    i(2, "Section Title"),
    t({ "", "", "" }),
  }),

  -- Fancy page header with metadata
  s("pagetitle", {
    f(wiki_header),
    t({ "", "" }),
    t({ "---", "" }),
    t("# "),
    i(1, "Page Title"),
    t({ "", "" }),
    t("> **Author:** "),
    f(function()
      return vim.fn.system("git config --get user.name"):gsub("%s+$", "")
    end),
    t({ "", "> **Created:** " }),
    f(current_date),
    t("  "),
    t({ "", "> **Tags:** `" }),
    i(2, "tag1"),
    t("` `"),
    i(3, "tag2"),
    t({ "`", "" }),
    t({ "---", "", "" }),
    i(4),
  }),

  -- Decorative divider
  s("divider", {
    t({ "", "---", "" }),
  }),

  -- Status badge line
  s("status", {
    t("> **Status:** "),
    i(1, "🟢 Active"),
    t(" | **Updated:** "),
    f(current_date),
    t({ "", "" }),
  }),

  -- Table template
  s("table", {
    t("| "),
    i(1, "Header 1"),
    t(" | "),
    i(2, "Header 2"),
    t(" | "),
    i(3, "Header 3"),
    t({ " |", "| --- | --- | --- |", "| " }),
    i(4, "cell"),
    t(" | "),
    i(5, "cell"),
    t(" | "),
    i(6, "cell"),
    t({ " |", "" }),
  }),
})

ls.add_snippets("markdown", {
  -- Jira ticket link: type "jira" then enter ticket ID e.g. CAR-111
  s("jira", {
    t("["),
    i(1, "CAR-111"),
    t("](https://inscaleasia.atlassian.net/browse/"),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t(")"),
  }),
})

ls.add_snippets("markdown", {
  s("worklog", {
    t("### 📅 "),
    f(current_date),
    t({ "", "- " }),
    i(1, "task"),
    t({ "", "" }),
  }),

  s("sprintcycle", {
    t(
      "[Home](../../../index.md) | [Work](../../../work/work.md) | [Sprint](../../../work/sprint/sprint.md) | [Info](../../../info/info.md) | [Notes](../../../notes/notes.md) | [Archive](../../../archive/archive.md) | [Journal](../../../journal/index.md)"
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
