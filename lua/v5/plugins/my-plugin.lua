return {
  dir = "~/.config/nvim/lua/myplugin",
  config = function()
    -- require("myplugin.encrypt_decrypt").setup()
    require("myplugin.taskwiki").setup()
    require("myplugin.list_file").setup()
    -- require("myplugin.markdown_checkbox").setup()
    -- require("myplugin.quickfix_manager").setup()
  end,
}
