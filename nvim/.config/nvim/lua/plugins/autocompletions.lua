return {
	{
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),

				formatting = {
					format = function(entry, vim_item)
						-- Remove the menu from showing
						vim_item.menu = ""
						return vim_item
					end,
				},

				sources = cmp.config.sources({
					{
						name = "nvim_lsp",
						priority = 1000,
						entry_filter = function(entry, ctx)
							local item = entry:get_completion_item()
							local label = item.label or ""
							local detail = item.detail or ""
							local description = (item.labelDetails and item.labelDetails.description) or ""

							-- Combine everything into one lowercase string so we can't miss it
							local search_string = string.lower(detail .. " " .. description)

							-- 1. Completely nuke _typeshed
							if search_string:find("_typeshed") then
								return false
							end

							-- 2. Completely nuke typing and typing_extensions
							if search_string:find("typing") then
								return false
							end

							-- 3. Hide internal _variables unless you actually type an underscore
							if label:sub(1, 1) == "_" and ctx.cursor_before_line:sub(-1) ~= "_" then
								return false
							end

							return true
						end,
					},
					{ name = "luasnip", priority = 750 },
				}, {
					{ name = "buffer", priority = 500 },
				}),

				sorting = {
					comparators = {
						cmp.config.compare.exact,
						cmp.config.compare.locality, -- 1. Locals pushed to top

						-- 2. THE PYCHARM RANKER: Sort by Type (Variables > Methods > Classes > Snippets)
						function(entry1, entry2)
							local types = require("cmp.types")
							local kind_rank = {
								[types.lsp.CompletionItemKind.Variable] = 1,
								[types.lsp.CompletionItemKind.Field] = 2,
								[types.lsp.CompletionItemKind.Property] = 3,
								[types.lsp.CompletionItemKind.Method] = 4,
								[types.lsp.CompletionItemKind.Keyword] = 5,
								[types.lsp.CompletionItemKind.Function] = 6,
								[types.lsp.CompletionItemKind.Class] = 7,
								[types.lsp.CompletionItemKind.Snippet] = 8,
								[types.lsp.CompletionItemKind.Text] = 9,
							}
							-- Get the rank, default to 100 if it's some weird unknown type
							local rank1 = kind_rank[entry1:get_kind()] or 100
							local rank2 = kind_rank[entry2:get_kind()] or 100

							if rank1 ~= rank2 then
								return rank1 < rank2 -- Smaller number means higher up on the list
							end
						end,

						-- 3. Fallbacks if two items are the same type (e.g., two Variables)
						cmp.config.compare.recently_used,
						cmp.config.compare.score,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
			})
		end,
	},
}
