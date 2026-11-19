-- Global Auto-Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		-- The 'bufnr' ensures it only formats the file you are actively saving
		vim.lsp.buf.format({ async = false, bufnr = args.buf })
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
