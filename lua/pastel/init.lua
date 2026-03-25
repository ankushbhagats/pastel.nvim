local M = {}

M.path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")

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

M.settings = {
	path = M.path,
	config = M.config,
	colors = M.colors,
	highlights = M.highlights,
}

local util = require("pastel.lib.util")

function M.load(name)
	local theme = M.config.palette
	if not name then
		theme = theme or M.config.background[vim.o.background]
	else
		theme = theme or name
	end
	M.config.theme = theme
	M.config.palette = false -- set false to prevent constant theme every time changing colorscheme via cmd

	if vim.g.colors_name then
		vim.cmd.highlight("clear")
	end
	if vim.fn.exists("syntax_on") then
		vim.cmd.syntax("reset")
	end
	vim.o.termguicolors = M.config.termguicolors
	vim.g.colors_name = name or "pastel"

	M.colors = util.set_palettes(M.config.theme, M.config)
	M.highlights = util.get_highlights(M.path, M.colors, M.config)
	util.set_highlights(M.highlights, M.config)

	-- WARN: Experimental feature.
	vim.schedule(function()
		if vim.bo.buftype ~= "" then
			return
		end

		local ft = vim.bo.filetype
		local ftopts = M.config.filetypes[ft]

		if not next(ftopts or {}) then
			return
		end

		local ftcolors = util.set_palettes(M.config.theme, ftopts)
		local ft_highlights = util.get_highlights(M.path, ftcolors, ftopts)
		util.set_highlights(ft_highlights, ftopts)
	end)
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
