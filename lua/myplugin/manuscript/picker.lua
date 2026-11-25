local M = {}

local function get_snacks()
  local ok, snacks = pcall(require, "snacks")

  if not ok or not snacks.picker then
    vim.notify("myplugin: snacks.nvim with picker is required.", vim.log.levels.ERROR)
    return nil
  end

  return snacks
end

local function get_display(chapter)
  return chapter.display or chapter.filename or chapter.name or chapter.path
end

function M.open(chapters, tag_chapter, initial_query)
  if #chapters == 0 then
    vim.notify("No chapter files found.", vim.log.levels.INFO)
    return
  end

  local snacks = get_snacks()

  if not snacks then
    return
  end

  local items = {}

  for _, chapter in ipairs(chapters) do
    items[#items + 1] = {
      text = get_display(chapter),
      file = chapter.path,
      value = chapter,
    }
  end

  snacks.picker.pick({
    source = "manuscript_chapters",
    title = "Manuscript Chapters",
    items = items,
    pattern = initial_query or "",
    format = function(item)
      return {
        { item.text },
      }
    end,
    preview = "file",

    actions = {
      tag_chapter = function(picker)
        local selection = picker:current()

        if not selection or not selection.value then
          return
        end

        local chapter = selection.value

        picker:close()

        tag_chapter(chapter.path, function()
          vim.schedule(function()
            require("myplugin.manuscript").jump_to_chapter(initial_query)
          end)
        end)
      end,
    },

    win = {
      input = {
        keys = {
          ["<C-t>"] = { "tag_chapter", mode = { "i", "n" } },
        },
      },
    },

    layout = {
      preset = "default",
      preview = true,
    },
  })
end

return M
