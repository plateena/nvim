return {
  ["Code Review"] = {
    strategy = "chat",
    description = "Review the selected code",
    prompts = {
      {
        role = "system",
        content = "You are an expert code reviewer. Review the code for bugs, security issues, performance, and best practices.",
      },
      {
        role = "user",
        content = function(context)
          return "Please review this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
        end,
      },
    },
  },
  ["Explain Code"] = {
    strategy = "chat",
    description = "Explain how the code works",
    prompts = {
      {
        role = "system",
        content = "You are an expert programmer. Explain code clearly and concisely.",
      },
      {
        role = "user",
        content = function(context)
          return "Explain this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
        end,
      },
    },
  },
  ["Generate Tests"] = {
    strategy = "chat",
    description = "Generate unit tests for the code",
    prompts = {
      {
        role = "system",
        content = "You are an expert at writing tests using TDD methodology. Generate comprehensive unit tests.",
      },
      {
        role = "user",
        content = function(context)
          return "Generate unit tests for this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
        end,
      },
    },
  },
  ["Refactor"] = {
    strategy = "inline",
    description = "Refactor selected code",
    prompts = {
      {
        role = "system",
        content = "You are an expert programmer. Refactor code to improve readability, maintainability, and performance while preserving functionality.",
      },
      {
        role = "user",
        content = "Refactor this code",
      },
    },
  },
  ["Fix Bug"] = {
    strategy = "inline",
    description = "Fix bugs in selected code",
    prompts = {
      {
        role = "system",
        content = "You are an expert debugger. Fix bugs while maintaining code style and functionality.",
      },
      {
        role = "user",
        content = "Fix any bugs in this code",
      },
    },
  },
  ["Check Exist and Empty"] = {
    strategy = "inline",
    description = "Transform condition to check both existence and empty string",
    prompts = {
      {
        role = "system",
        content = "You are an expert programmer. Transform conditional checks to verify both existence and empty values. Return only the code, no explanations.",
      },
      {
        role = "user",
        content = "Transform this condition to check if the variable exists AND is not empty (handles null, undefined, and empty strings)",
      },
    },
  },
  ["Suggest Code"] = {
    strategy = "inline",
    description = "Suggest code completion after cursor",
    prompts = {
      {
        role = "system",
        content = function(context)
          return "You are an expert "
            .. context.filetype
            .. " programmer. Given the code context, suggest the most logical continuation of the code. Return only the code that should come next, no explanations or markdown. Match the existing code style and indentation."
        end,
      },
      {
        role = "user",
        content = function(context)
          local bufnr = context.bufnr
          local cursor = vim.api.nvim_win_get_cursor(0)
          local current_line = cursor[1]

          -- Get context: previous 20 lines and current line up to cursor
          local start_line = math.max(0, current_line - 20)
          local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, current_line, false)

          -- Get current line up to cursor position
          local current_line_text = vim.api.nvim_buf_get_lines(bufnr, current_line - 1, current_line, false)[1] or ""
          local before_cursor = current_line_text:sub(1, cursor[2])

          table.insert(lines, before_cursor)

          local code_context = table.concat(lines, "\n")

          return "Continue this code:\n\n```"
            .. context.filetype
            .. "\n"
            .. code_context
            .. "\n```\n\nProvide only the next logical code continuation."
        end,
      },
    },
  },
}
