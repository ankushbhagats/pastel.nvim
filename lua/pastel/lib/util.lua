local M = {}

M.state = {}

-- get list of all highlight files path
function M.get_highlight_files(path, opts)
	local highlight_paths = {
		core = path .. "groups/core",
		plugins = path .. "groups/plugins",
	}

	local highlight_files = {}

	for group, path in pairs(highlight_paths) do
		local files = vim.fn.readdir(path)
		for _, file in ipairs(files) do
			local name = vim.fn.fnamemodify(file, ":r") -- remove extension
			if opts.exclude and not opts.exclude[group][name] then
				highlight_files[#highlight_files + 1] = path .. "/" .. file
			end
		end
	end

	return highlight_files
end

-- configure and get the highlight groups from a module callback
function M.get_module_highlights(colors, opts, module)
	local file_avail, file = pcall(dofile, module)
	if type(file) == "function" then
		file = file(colors, opts.style)
	end
	if file_avail then
		return file
	end
end

function M.list_highlights(path, colors, opts)
	local highlights = {}
	for _, module in ipairs(M.get_highlight_files(path, opts)) do
		local module_hl = M.get_module_highlights(colors, opts, module)
		highlights = vim.tbl_deep_extend("force", module_hl or {}, highlights)
	end

	-- Metatable to control assignments for the highlights table (any value)
	setmetatable(highlights, {
		__newindex = function(tbl, key, val)
			rawset(tbl, key, val)
		end,
	})

	return highlights
end

---  merge all module highlights into a single table
function M.get_highlights(path, colors, opts)
	local highlights = M.list_highlights(path, colors, opts)

	-- set highlights from a callback function
	pcall(opts.highlights.global, highlights, colors) -- safely call the global function to set highlights
	pcall(opts.highlights[opts.theme], highlights, colors) -- safely call the active theme function to set highlights

	return highlights
end

-- Setup and merge palette
function M.set_palettes(name, opts)
	local common = require("pastel.palettes.common")
	local palette = require("pastel.palettes." .. name)

	common = vim.tbl_deep_extend("force", common, { common = opts.colors.common } or {})
	palette = vim.tbl_deep_extend("force", palette, common, opts.colors[name] or {}, opts.colors.global or {})

	return palette
end

function M.apply_highlight_style(key, hl, opts)
	if opts.style and type(opts.style[key]) == "table" then
		for _, name in pairs(opts.style[key]) do
			if vim.startswith(name, "!") then
				hl[name:gsub("^!", "")][key] = false
			else
				hl[name][key] = true
			end
		end
	end
end

function M.apply_global_style(key, hl, opts)
	if opts.style[key] == false then
		hl[key] = false
	elseif opts.style[key] == "*" then
		hl[key] = true
	end
end

--- Set highlights groups
function M.set_highlights(highlights, opts)
	local styles = {
		"bold",
		"italic",
		"underline",
	}

	-- apply provided hl group styles.
	for _, key in ipairs(styles) do
		M.apply_highlight_style(key, highlights, opts)
	end

	for name, hl in pairs(highlights) do
		if type(hl) == "string" then
			hl = { link = hl }
		end

		-- apply global hl styles.
		for _, key in ipairs(styles) do
			M.apply_global_style(key, hl, opts)
		end

		vim.api.nvim_set_hl(0, name, hl) -- set hl
	end
end

return M
