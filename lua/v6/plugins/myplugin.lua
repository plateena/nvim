return {
  dir = vim.fn.stdpath("config") .. "/lua/myplugin",
  name = "myplugin",
  lazy = false,
  config = function()
    require("myplugin.taskwiki").setup()
    require("myplugin.list_file").setup()
    require("myplugin.quickfix_manager").setup()
    require("myplugin.markdown_checkbox").setup()
    -- encrypt_decrypt registers commands on load (no setup needed)
    require("myplugin.encrypt_decrypt")
  end,
}
