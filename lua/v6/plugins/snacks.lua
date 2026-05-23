return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    local snacks = require("snacks")
    snacks.setup({
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    })
    vim.ui.select = snacks.picker.select
    vim.ui.input = snacks.input.input
  end,
  keys = {
    -- Picker (replaces telescope)
    {
      "<leader>n",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Find buffers",
    },
    {
      "<leader>fA",
      function()
        Snacks.picker.files()
      end,
      desc = "Find file",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files({ args = { "--no-ignore", "--hidden" } })
      end,
      desc = "Find ALL files",
    },
    {
      "<leader>fF",
      function()
        Snacks.picker.grep()
      end,
      desc = "Live grep",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.git_files()
      end,
      desc = "Git files",
    },
    {
      "<leader>fa",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git status",
    },
    {
      "<leader>fm",
      function()
        Snacks.picker.marks()
      end,
      desc = "Marks",
    },
    {
      "<leader>fR",
      function()
        Snacks.picker.registers()
      end,
      desc = "Registers",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume",
    },
    {
      "<leader>fh",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent files",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command history",
    },
    {
      "<leader>fk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>fj",
      function()
        Snacks.picker.jumps()
      end,
      desc = "Jumplist",
    },
    {
      "<leader>fl",
      function()
        Snacks.picker.lines()
      end,
      desc = "Buffer lines",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Grep string",
    },
    {
      "<leader>fW",
      function()
        Snacks.picker.grep({ default_text = vim.fn.expand("<cword>") })
      end,
      desc = "Grep cword",
    },
    {
      "<leader>fS",
      function()
        Snacks.picker.search_history()
      end,
      desc = "Search history",
    },
    {
      "<leader>fD",
      function()
        Snacks.picker.pick("files", {
          cmd = "find",
          args = { ".", "-type", "d", "-not", "-path", "*/.*" },
          confirm = function(picker, item)
            picker:close()
            if item then
              Snacks.picker.grep({ dirs = { item.text } })
            end
          end,
        })
      end,
      desc = "Grep in directory",
    },
    -- Explorer
    {
      "<leader>ee",
      function()
        Snacks.explorer()
      end,
      desc = "File explorer",
    },
    -- Lazygit
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    -- Notifier
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss notifications",
    },
    -- Terminal
    {
      "<C-/>",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle terminal",
    },
    -- Projects
    {
      "<leader>fp",
      function()
        Snacks.picker.projects()
      end,
      desc = "Projects",
    },
  },
}
