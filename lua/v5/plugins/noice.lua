return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  config = function()
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline", -- telescope-style popup
      },
      popupmenu = {
        enabled = true,
        backend = "cmp", -- use nvim-cmp UI for cmdline
      },
      presets = {
        command_palette = true,
        lsp_doc_border = true,
      },
    })
  end,
}
