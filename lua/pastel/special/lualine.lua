local M = {}

function M.load(name)
	local main = require("pastel")
	local opts = main.config
  name = name or opts.theme
	local c = require("pastel.lib.util").set_palettes(name, opts)
	local inactive = { bg = c.statusline, fg = c.inactive_text, gui = "bold" }
	local statusline = {
		inactive = {
			a = inactive,
			b = inactive,
			c = inactive,
		},
	}

	if opts.style.dynamic_statusline then
		statusline.normal = {
			a = { bg = "#7DC4FF", fg = "#00347D", gui = "bold" },
			b = { bg = c.common.section, fg = c.common.text },
			c = { bg = c.none, fg = c.common.text },
		}

		statusline.insert = {
			a = { bg = "#9ADA6B", fg = "#204600", gui = "bold" },
		}

		statusline.command = {
			a = { bg = "#F8CA74", fg = "#543700", gui = "bold" },
		}

		statusline.visual = {
			a = { bg = "#F096FC", fg = "#46014D", gui = "bold" },
		}

		statusline.replace = {
			a = { bg = "#F793A0", fg = "#4B000A", gui = "bold" },
		}

		statusline.terminal = {
			a = { bg = "#B0F4AE", fg = "#004D1E", gui = "bold" },
		}
	else
		statusline.normal = {
			a = { bg = c.blue, fg = c.statusline, gui = "bold" },
			b = { bg = c.section, fg = c.text },
			c = { bg = c.statusline, fg = c.active_text },
		}

		statusline.insert = { a = { bg = c.green, fg = c.statusline, gui = "bold" } }
		statusline.command = { a = { bg = c.yellow, fg = c.statusline, gui = "bold" } }
		statusline.visual = { a = { bg = c.purple, fg = c.statusline, gui = "bold" } }
		statusline.replace = { a = { bg = c.red, fg = c.statusline, gui = "bold" } }
		statusline.terminal = { a = { bg = c.green, fg = c.statusline, gui = "bold" } }
	end

	return statusline
end

return M
