return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSInstall bash c css dockerfile html javascript json lua markdown markdown_inline php python regex ruby tsx typescript vim vimdoc yaml",
    config = function()
      vim.treesitter.language.add("blade", {
        install_info = {
          url = "https://github.com/EmranMR/tree-sitter-blade",
          files = { "src/parser.c" },
          branch = "main",
          generate_requires_npm = true,
          requires_generate_from_grammar = true,
        },
        filetype = "blade",
      })

      vim.filetype.add({
        extension = { blade = "blade" },
        pattern = { [".*%.blade%.php"] = "blade" },
      })

      -- Enable treesitter highlight and indent for all buffers with a parser
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Incremental treesitter selection
      local function incremental_select()
        local node = vim.treesitter.get_node()
        if not node then return end

        local mode = vim.fn.mode()
        if mode == "n" then
          vim.cmd("normal! v")
          local sr, sc, er, ec = node:range()
          vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
          vim.cmd("normal! o")
          vim.api.nvim_win_set_cursor(0, { er + 1, ec > 0 and ec - 1 or 0 })
        else
          node = node:parent()
          if not node then return end
          local sr, sc, er, ec = node:range()
          vim.cmd("normal! \27v")
          vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
          vim.cmd("normal! o")
          vim.api.nvim_win_set_cursor(0, { er + 1, ec > 0 and ec - 1 or 0 })
        end
      end

      vim.keymap.set({ "n", "x" }, "<leader>v", incremental_select, { desc = "Treesitter incremental select" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      local ts_select = require("nvim-treesitter-textobjects.select")
      local ts_move = require("nvim-treesitter-textobjects.move")

      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local map = vim.keymap.set

      map({ "x", "o" }, "af", function() ts_select.select_textobject("@function.outer") end, { desc = "outer function" })
      map({ "x", "o" }, "if", function() ts_select.select_textobject("@function.inner") end, { desc = "inner function" })
      map({ "x", "o" }, "ac", function() ts_select.select_textobject("@class.outer") end, { desc = "outer class" })
      map({ "x", "o" }, "ic", function() ts_select.select_textobject("@class.inner") end, { desc = "inner class" })
      map({ "x", "o" }, "aa", function() ts_select.select_textobject("@parameter.outer") end, { desc = "outer parameter" })
      map({ "x", "o" }, "ia", function() ts_select.select_textobject("@parameter.inner") end, { desc = "inner parameter" })

      map({ "n", "x", "o" }, "]m", function() ts_move.goto_next_start("@function.outer") end, { desc = "Next function start" })
      map({ "n", "x", "o" }, "[m", function() ts_move.goto_previous_start("@function.outer") end, { desc = "Prev function start" })
      map({ "n", "x", "o" }, "]M", function() ts_move.goto_next_end("@function.outer") end, { desc = "Next function end" })
      map({ "n", "x", "o" }, "[M", function() ts_move.goto_previous_end("@function.outer") end, { desc = "Prev function end" })
      map({ "n", "x", "o" }, "]a", function() ts_move.goto_next_start("@parameter.outer") end, { desc = "Next parameter" })
      map({ "n", "x", "o" }, "[a", function() ts_move.goto_previous_start("@parameter.outer") end, { desc = "Prev parameter" })
    end,
  },
}
