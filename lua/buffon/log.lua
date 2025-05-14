-- This log file was getting it from the tjdevries repo
-- https://github.com/tjdevries/express_line.nvim/blob/master/lua/el/log.lua
local date = os.date("%Y-%m-%d")

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
	level = (vim.loop.os_getenv("BUFFON_LOGS") == "debug" and "debug") or "warn",

	-- Level configuration
	modes = {
		{ name = "trace", hl = "Comment" },
		{ name = "debug", hl = "Comment" },
		{ name = "info", hl = "None" },
		{ name = "warn", hl = "WarningMsg" },
		{ name = "error", hl = "ErrorMsg" },
		{ name = "fatal", hl = "ErrorMsg" },
	},

	outfile = "/tmp/buffon-" .. date .. ".log",
})
