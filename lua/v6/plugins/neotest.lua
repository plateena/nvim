return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "olimorris/neotest-phpunit",
    "olimorris/neotest-rspec",
  },
  keys = {
    {
      "<leader>tn",
      function() require("neotest").run.run() end,
      desc = "Test: nearest",
    },
    {
      "<leader>tf",
      function() require("neotest").run.run(vim.fn.expand("%")) end,
      desc = "Test: file",
    },
    {
      "<leader>ts",
      function() require("neotest").run.run(vim.uv.cwd()) end,
      desc = "Test: suite",
    },
    {
      "<leader>tl",
      function() require("neotest").run.run_last() end,
      desc = "Test: last",
    },
    {
      "<leader>to",
      function() require("neotest").output.open({ enter = true }) end,
      desc = "Test: output",
    },
    {
      "<leader>tO",
      function() require("neotest").output_panel.toggle() end,
      desc = "Test: output panel",
    },
    {
      "<leader>tt",
      function() require("neotest").summary.toggle() end,
      desc = "Test: summary",
    },
    {
      "<leader>tS",
      function() require("neotest").run.stop() end,
      desc = "Test: stop",
    },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-phpunit"),
        require("neotest-rspec"),
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
    })
  end,
}
