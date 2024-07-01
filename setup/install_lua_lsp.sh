#!/bin/bash

# Clone lua-language-server repository
git clone https://github.com/sumneko/lua-language-server

# Navigate to the cloned directory
cd lua-language-server

# Run the installation script to download and install dependencies
bash install.sh

# Build the Lua language server
cd 3rd/luamake
./compile/install.sh
cd ../..
./3rd/luamake/luamake rebuild

# Print a message indicating successful installation
echo "Lua language server (sumneko_lua) installed successfully."
