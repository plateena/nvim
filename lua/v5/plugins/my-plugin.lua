return {
    dir = '~/.config/nvim/lua/myplugin',
    config = function()
        -- require('myplugin.encrypt_decrypt')
        require('markdown_checkbox').setup()
    end
}
