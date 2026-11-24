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
			require("custom.smart_path").setup(cmp)

			-- Distinct highlight colors for Folder vs File in completion menu:
			vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#89b4fa", bold = true })
			vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#94e2d5" })

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered({
						max_height = 10,
					}),
					documentation = cmp.config.window.bordered(),
				},
				matching = {
					disallow_fuzzy_matching = false,
					disallow_fullfuzzy_matching = false,
					disallow_partial_fuzzy_matching = false, -- default true (first letter must match)
					disallow_partial_matching = false,
					disallow_prefix_unmatching = false,
					disallow_symbol_nonprefix_matching = false, -- default true (ex. typing flag wont recommend --flag)
				},

				mapping = cmp.mapping.preset.insert({
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }), -- select = false -> only confirm explicitly selected items.

					-- Re-open/refresh completion on Backspace with debounce (no lag when holding BS):
					["<BS>"] = cmp.mapping(function(fallback)
						fallback()
						if _G._cmp_bs_timer then
							_G._cmp_bs_timer:stop()
						end
						_G._cmp_bs_timer = vim.defer_fn(function()
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local before = vim.api.nvim_get_current_line():sub(1, col)

							-- Check if cursor is inside quotes
							local line_before_quote, quote_char, inside_quote = before:match("^(.-)([\"'])([^\"']*)$")
							if quote_char and not inside_quote:find("/") then
								-- If inside quotes in a non-path function and there is no slash '/', close CMP immediately
								local smart_path = require("custom.smart_path")
								local is_path_func = smart_path.is_path_context
									and smart_path.is_path_context(line_before_quote)
								if not is_path_func then
									if cmp.visible() then
										cmp.abort()
									end
									return
								end
							end

							if before:match("[%w_%.%/%'%\"]$") then
								cmp.complete()
							else
								if cmp.visible() then
									cmp.abort()
								end
							end
						end, 80)
					end, { "i", "s" }),

					-- Auto-trigger completion on dot, because sometimes it bugged and did not show anything
					["."] = cmp.mapping(function(fallback)
						fallback()
						vim.schedule(function()
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local before = vim.api.nvim_get_current_line():sub(1, col)
							-- Only if its before variable, parenthesis or quotes and not already open
							if before:match("[%w_%)%]%'\"]%.$") and not cmp.visible() then
								cmp.complete()
							end
						end)
					end, { "i", "s" }),

					-- Accept 1st/selected completion with Tab, or jump snippet, or normal Tab:
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.confirm({ select = true })
						elseif luasnip.jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),

					-- Jump back to previous snippet field (or type normal Shift-Tab)
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
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
							local item = entry.completion_item
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

							-- Hide internal _variables unless you actually type an underscore
							local current_word = ctx.cursor_before_line:match("[%w_]+$") or ""
							if label:sub(1, 1) == "_" and not current_word:match("^_") then
								return false
							end

							return true
						end,
					},
					{
						name = "luasnip",
						priority = 750,

						-- Don't show snippets when inside a string
						entry_filter = function()
							local context = require("cmp.config.context")
							return not context.in_treesitter_capture("string") and not context.in_syntax_group("String")
						end,
					},
					{
						name = "smart_path",
						priority = 800,
					},
				}),

				sorting = {
					priority_weight = 2,
					comparators = {
						cmp.config.compare.offset,

						-- Auto-import demotion (local/in-scope symbols always beat unimported external modules)
						function(entry1, entry2)
							local item1 = entry1.completion_item
							local item2 = entry2.completion_item

							local is_auto_import1 = (
								item1.additionalTextEdits ~= nil and #item1.additionalTextEdits > 0
							) or (item1.data and item1.data.autoImportText ~= nil)
							local is_auto_import2 = (
								item2.additionalTextEdits ~= nil and #item2.additionalTextEdits > 0
							) or (item2.data and item2.data.autoImportText ~= nil)

							if is_auto_import1 ~= is_auto_import2 then
								return not is_auto_import1
							end
						end,

						cmp.config.compare.exact,
						cmp.config.compare.score,

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
							local rank1 = kind_rank[entry1:get_kind()] or 100
							local rank2 = kind_rank[entry2:get_kind()] or 100

							if rank1 ~= rank2 then
								return rank1 < rank2
							end
						end,

						cmp.config.compare.recently_used,
						cmp.config.compare.locality,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
			})
		end,
	},
}
