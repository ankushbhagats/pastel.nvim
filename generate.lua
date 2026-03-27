local pastel = dofile("./lua/pastel/init.lua")

local palettes = pastel.palettes

local function write(path, content)
	local dir = path:match("(.+)/[^/]+$")
	if dir then
		os.execute("mkdir -p " .. dir)
	end

	local f = assert(io.open(path, "w"))
	f:write(content)
	f:close()
end

local count = 0

for name, _ in pairs(palettes) do
  count = count + 1
	-- colorscheme file
	write("colors/" .. name .. ".lua", 'require("pastel").load("' .. name .. '")\n')

	-- lualine file
	write("lua/lualine/themes/" .. name .. ".lua", 'return require("pastel.special.lualine").load("' .. name .. '")\n')
end

print("Generated " .. (count * 2) .. " files.")
