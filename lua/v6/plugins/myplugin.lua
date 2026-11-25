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
    require("myplugin.manuscript").setup({
      dir = { "manuscript/ms", "manuscript/en" },
      extensions = { "md", "txt" },
      allow_extensionless = true,
      preset_tags = {
        "draft",
        "reviewed",
        "locked",
        "publish",
      },
    })
  end,
}
