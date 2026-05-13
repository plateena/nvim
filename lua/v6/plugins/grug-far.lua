return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and replace" },
    { "<leader>sw", function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end, desc = "Search word under cursor" },
  },
  opts = {},
}
