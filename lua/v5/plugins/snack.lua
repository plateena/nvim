return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function(_, opts)
    require("snacks").setup(opts)
  end,
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = false },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    command = {
      enabled = true,
      commands = {
        Snack = {
          args = 1,
          complete = function(_, line, pos)
            local snacks = { "apple", "banana", "cookie", "donut" }
            local input = line:sub(pos):match("%S*$") or ""
            local matches = {}
            for _, s in ipairs(snacks) do
              if s:match("^" .. input) then
                table.insert(matches, s)
              end
            end
            return matches
          end,
          callback = function(args)
            print("You chose: " .. args)
          end,
        },
      },
    },
  },
}
