-- Global Auto-Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		-- The 'bufnr' ensures it only formats the file you are actively saving
		vim.lsp.buf.format({ async = false, bufnr = args.buf })
	end,
})

-- Use // for comments in json
vim.api.nvim_create_autocmd("FileType", {
	pattern = "json",
	callback = function()
		vim.bo.commentstring = "// %s"
	end,
})
