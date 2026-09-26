return {
  "aznhe21/actions-preview.nvim",
  event = "LspAttach",
  opts = {
    backend = { "snacks" },
    snacks = {
      layout = { preset = "default" },
    },
  },
  config = function(_, opts)
    require("actions-preview").setup(opts)
  end,
}
