-- This log file was getting it from the tjdevries repo
-- https://github.com/tjdevries/express_line.nvim/blob/master/lua/el/log.lua
return require("plenary.log").new({
  -- Name of the plugin. Prepended to log messages
  plugin = "buffon",

  -- Should print the output to neovim while running
  use_console = false,

  -- Should highlighting be used in console (using echohl)
  highlights = false,

  -- Should write to a file
  use_file = true,

  -- Any messages above this level will be logged.
  -- Log more stuff for me, everyone else can just get warnings :)
  level = (vim.loop.os_getenv("USER") == "farpi" and "debug") or "warn",

  -- Level configuration
  modes = {
    { name = "trace", hl = "Comment" },
    { name = "debug", hl = "Comment" },
    { name = "info", hl = "None" },
    { name = "warn", hl = "WarningMsg" },
    { name = "error", hl = "ErrorMsg" },
    { name = "fatal", hl = "ErrorMsg" },
  },

  -- Can limit the number of decimals displayed for floats
  float_precision = 0.01,

  outfile = "/tmp/buffon.log",
})
