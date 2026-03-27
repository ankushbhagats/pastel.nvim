local M = {}

local applied = ""

local PATH = debug.getinfo(1, "S").source:sub(2):match("(.*/)")

M.config = {
	background = {
		dark = "pasteldark",
		light = "pastelsoft",
	},
	palette = nil, -- force a specific theme variant (overrides :colorscheme and background)
	termguicolors = true,
	style = {
		transparent = false,
		inactive = true,
		float = true,
		border = true,
		bold = true,
		italic = false,
		underline = true,
		invert_title = false,
		simple_syntax = false,
		dynamic_statusline = false,
	},
	colors = {
		common = {},
		global = {},
	},
	highlights = {
		global = {},
	},
	exclude = {
		core = {},
		plugins = {},
	},
	filetypes = {},
}

M.palettes = {
	-- Dark
	pasteldark = "dark",
	pastelforest = "dark",
	pastelmint = "dark",
	pastelrose = "dark",
	pastelcream = "dark",
	pastelcool = "dark",
	pastelfog = "dark",
	pastelnight = "dark",
	pastelpop = "dark",
	pastelwarm = "dark",

	-- Light
	pastelsoft = "light",
	pastelwhite = "light",
	pastelsilk = "light",
	pastelsnow = "light",
	pastelcloud = "light",
	pastelrice = "light",
	pastelglow = "light",
	pastelgold = "light",
	pastelshell = "light",
	pastelfrost = "light",
}

local function set_colorscheme(theme, auto)
	local opts = M.config
  local name = theme
	theme = auto or theme
	local background = M.palettes[theme]

	if not background then
		vim.notify(string.format("pastel.nvim: invalid palette: %s", theme))
		theme = "pasteldark"
		background = "dark"
		opts.palette = theme
	end

	if applied ~= theme then
		vim.api.nvim_set_option_value("background", background, {})
	end

	M.config.theme = theme

	if vim.g.colors_name then
		vim.cmd.highlight("clear")
	end
	if vim.fn.exists("syntax_on") then
		vim.cmd.syntax("reset")
	end

	vim.o.termguicolors = M.config.termguicolors
	vim.g.colors_name = name

	return theme
end

function M.load(name)
	-- TODO: Add cache support
	local opts = M.config

  local theme = opts.palette or name or "pastel"
	local auto = theme == "pastel" and opts.background[vim.o.background]
	theme = set_colorscheme(theme, auto)

	local util = require("pastel.lib.util")
	util.set_highlights(PATH, opts)

	-- WARN: Experimental feature.
	vim.schedule(function()
		if vim.bo.buftype ~= "" then
			return
		end

		local ft = vim.bo.filetype
		local ftopts = opts.filetypes[ft]

		if not next(ftopts or {}) then
			return
		end

		ftopts.theme = theme
		util.set_highlights(PATH, ftopts)
	end)

	applied = theme
end

function M.setup(opts)
	-- merge config with provided opts
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	vim.schedule(function()
		if vim.bo.buftype ~= "" then
			return
		end

		local ft = vim.bo.filetype

		M.config.filetypes[ft] = vim.tbl_deep_extend("force", M.config, M.config.filetypes[ft] or {})
	end)
end

return M
