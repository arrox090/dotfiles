-- Global Auto-Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		-- The 'bufnr' ensures it only formats the file you are actively saving
		vim.lsp.buf.format({
			async = false,
			bufnr = args.buf,
			filter = function(client)
				-- Ignore lua_ls so stylua handles Lua files exclusively
				return client.name ~= "lua_ls"
			end,
		})
	end,
})

-- Auto-compile Karabiner config on save
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*/karabiner*/*.jsonc", "*/karabiner*/base.json" },
	callback = function()
		local file_dir = vim.fn.expand("<afile>:p:h")
		local script = file_dir .. "/build.py"

		-- If saved from inside 'rules/', check the parent directory
		if not vim.uv.fs_stat(script) then
			script = vim.fn.fnamemodify(file_dir, ":h") .. "/build.py"
		end

		-- Only run if build.py actually exists
		if vim.uv.fs_stat(script) then
			vim.system({ "python3", script }, { text = true }, function(obj)
				if obj.code == 0 then
					vim.notify("Karabiner config compiled!", vim.log.levels.INFO)
				else
					vim.notify("Karabiner compile failed:\n" .. (obj.stderr or obj.stdout or ""), vim.log.levels.ERROR)
				end
			end)
		end
	end,
})

-- Close Vimux runner pane automatically when exiting Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		if vim.env.TMUX then
			pcall(vim.fn.VimuxCloseRunner)
		end
	end,
})

-- Setup colors for cmp kind and icons
local function setup_cmp_highlights()
	local kinds = {
		"Text",
		"Method",
		"Function",
		"Constructor",
		"Field",
		"Variable",
		"Class",
		"Interface",
		"Module",
		"Property",
		"Unit",
		"Value",
		"Enum",
		"Keyword",
		"Snippet",
		"Color",
		"File",
		"Reference",
		"Folder",
		"EnumMember",
		"Constant",
		"Struct",
		"Event",
		"Operator",
		"TypeParameter",
	}
	for _, kind in ipairs(kinds) do
		vim.api.nvim_set_hl(0, "CmpItemKind" .. kind .. "Icon", { link = "CmpItemKind" .. kind })
	end

	-- Distinct highlight colors for Folder vs File:
	vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#89b4fa", bold = true })
	vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#94e2d5" })
end

setup_cmp_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = setup_cmp_highlights,
})
