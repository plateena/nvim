return {
  -- vim-fugitive: Core Git integration
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
    config = function()
      -- Git keymaps
      vim.keymap.set("n", "<Leader>g", "", { desc = "Git" })
      vim.keymap.set("n", "<Leader>gs", "<Cmd>Git<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<Leader>gP", "<Cmd>Git pull<CR>", { desc = "Git pull" })
      vim.keymap.set("n", "<Leader>gv", "<Cmd>Gvdiffsplit<CR>", { desc = "Git diff split" })

      -- Create augroup for Fugitive-specific mappings
      local augroup = vim.api.nvim_create_augroup("FugitiveDiffMaps", { clear = true })

      -- Attach diff-specific keymaps in merge conflict buffers
      local function setup_fugitive_diff_maps()
        local bufname = vim.api.nvim_buf_get_name(0)
        if not vim.wo.diff or not bufname:match("^fugitive://") then
          -- return false
        end

        local opts = { buffer = true, silent = true }

        -- Get changes from target/merge branches
        vim.keymap.set("n", "<Leader>gh", "<Cmd>diffget //2<CR>", opts)
        vim.keymap.set("n", "<Leader>gl", "<Cmd>diffget //3<CR>", opts)

        -- Put changes to target/merge branches
        vim.keymap.set("n", "<Leader>gu", "<Cmd>diffput //2<CR>", opts)
        vim.keymap.set("n", "<Leader>gi", "<Cmd>diffput //3<CR>", opts)

        return true
      end

      -- Auto-attach diff mappings
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
        group = augroup,
        callback = setup_fugitive_diff_maps,
      })

      -- Manual attachment command
      vim.api.nvim_create_user_command("FugitiveDiffMaps", function()
        if setup_fugitive_diff_maps() then
          vim.notify("Fugitive diff keymaps attached", vim.log.levels.INFO)
        else
          vim.notify("Not a Fugitive diff buffer", vim.log.levels.WARN)
        end
      end, { desc = "Attach Fugitive diff keymaps" })
    end,
  },

  -- LazyGit: Terminal UI for Git
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
  },

  -- Gitsigns: Git decorations and hunks
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "rounded",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
      })
    end,
  },
}
