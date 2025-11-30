local Adapter = require("codecompanion.adapters")

return Adapter.extend("ollama", {
  name = "qwen2_3b",
  url = "http://localhost:11434/api/chat",
  headers = {
    ["Content-Type"] = "application/json",
  },
  parameters = {
    temperature = 0.1,
    top_p = 0.9,
    num_ctx = 8192,
  },
  schema = {
    model = { default = "qwen2.5-coder:3b" },
    temperature = { default = 0.1 },
    top_p = { default = 0.9 },
    num_ctx = { default = 8192 },
  },
  callbacks = {
    on_stdout = function(self, data)
      vim.notify("Ollama streaming: " .. vim.inspect(data), vim.log.levels.INFO)
    end,
  },
  handlers = {
    inline = function(data)
      vim.notify("Handler received: " .. type(data), vim.log.levels.DEBUG)

      -- Handle NDJSON streaming format from Ollama
      if type(data) == "string" then
        local content = ""
        for line in data:gmatch("[^\r\n]+") do
          if line ~= "" then
            local ok, json_data = pcall(vim.json.decode, line)
            if ok and json_data.message and json_data.message.content then
              content = content .. json_data.message.content
            end
          end
        end
        if content ~= "" then
          vim.notify("Inline result: " .. content:sub(1, 50), vim.log.levels.INFO)
          return content
        end
      elseif data and data.message and data.message.content then
        return data.message.content
      end
      return nil
    end,
  },
})
