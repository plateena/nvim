-- ~/.config/nvim/lua/myvimwiki/encrypt_decrypt.lua

-- Function to encrypt the current Vimwiki file
local function encrypt_vimwiki()
    local filename = vim.fn.expand('%:p')
    if filename:match("%.gpg$") then
        print("This file is already encrypted!")
        return
    end

    -- Prompt for the passphrase
    local passphrase = vim.fn.inputsecret("Enter passphrase for encryption: ")
    -- Prompt for confirmation of the passphrase
    local confirm_passphrase = vim.fn.inputsecret("Confirm passphrase: ")

    -- Check if the passphrases match
    if passphrase ~= confirm_passphrase then
        print("Passphrases do not match. Encryption cancelled.")
        return
    end

    -- Encrypt the file using the given passphrase
    vim.fn.system('gpg --batch --yes -c --passphrase "' .. passphrase .. '" ' .. filename)

    -- Remove the original file after encryption
    vim.fn.system('rm ' .. filename)

    -- Set permissions of the encrypted file to 600
    local encrypted_filename = filename .. '.gpg'
    vim.fn.system('chmod 600 ' .. encrypted_filename)

    -- Open the newly encrypted file
    vim.cmd('edit ' .. encrypted_filename)
    print("File encrypted!")
end

-- Function to decrypt the current Vimwiki file
local function decrypt_vimwiki()
    local filename = vim.fn.expand('%:p')
    if not filename:match("%.gpg$") then
        print("This file is not encrypted!")
        return
    end

    -- Securely prompt for the passphrase
    local passphrase = vim.fn.inputsecret("Enter passphrase for decryption: ")

    -- Decrypt the file using the provided passphrase
    vim.fn.system('gpg --batch --yes --passphrase "' .. passphrase .. '" ' .. filename)

    -- Remove the encrypted file after decryption
    -- vim.fn.system('rm ' .. filename)

    -- Open the decrypted file
    local decrypted_filename = filename:sub(1, -5)  -- Remove .gpg extension
    vim.cmd('edit ' .. decrypted_filename)

    -- Set permissions of the decrypted file to +r for all users
    vim.fn.system('chmod a+r ' .. decrypted_filename)
    print("File decrypted!")
end

-- Register commands for user access
vim.api.nvim_create_user_command('Encrypt', encrypt_vimwiki, {})
vim.api.nvim_create_user_command('Decrypt', decrypt_vimwiki, {})

