return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "▁" },
          topdelete = { text = "▔" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        current_line_blame = false,
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        preview_config = { border = "rounded" },
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
          map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")

          -- Actions
          map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
          map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
          map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
          map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
          map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>gb", gs.blame_line, "Blame line")
          map("n", "<leader>gB", function() gs.blame_line({ full = true }) end, "Blame line (full)")
          map("n", "<leader>gt", gs.toggle_current_line_blame, "Toggle line blame")
        end,
      })
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "GBrowse" },
    keys = {
      { "<leader>gf", "<cmd>topleft Git<cr><cmd>resize 15<cr>", desc = "Fugitive status" },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
    },
    opts = {},
  },
}
