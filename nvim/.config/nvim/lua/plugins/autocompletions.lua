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
		"onsails/lspkind.nvim",
	},
	{
		"hrsh7th/cmp-cmdline",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			local cmp = require("cmp")

			local history_mode = false

			vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
				callback = function()
					history_mode = false
				end,
			})

			-- Command line `:` completion
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline({
					["<C-Space>"] = cmp.mapping(function()
						history_mode = false
						cmp.complete()
					end, { "c" }),
					["<C-e>"] = cmp.mapping(function()
						cmp.abort()
					end, { "c" }),

					-- C-p: in history -> previous entry; in completion menu -> previous item:
					["<Up>"] = cmp.mapping(function(fallback)
						if history_mode or not cmp.visible() then
							history_mode = true
							fallback()
						else
							cmp.select_prev_item()
						end
					end, { "c" }),

					-- C-n: in history -> next entry; in completion menu -> next item:
					["<Down>"] = cmp.mapping(function(fallback)
						if history_mode or not cmp.visible() then
							history_mode = true
							fallback()
						else
							cmp.select_next_item()
						end
					end, { "c" }),

					-- Super-Tab: immediately confirm first or selected item:
					["<Tab>"] = cmp.mapping(function(fallback)
						history_mode = false
						if cmp.visible() then
							cmp.confirm({ select = true })
						else
							cmp.complete()
						end
					end, { "c" }),

					-- Enter: confirm selected item, or execute the entered command:
					["<CR>"] = cmp.mapping(function(fallback)
						history_mode = false
						if cmp.visible() and cmp.get_selected_entry() then
							cmp.confirm({ select = false })
						else
							fallback()
						end
					end, { "c" }),
				}),

				formatting = {
					fields = { "icon", "abbr" },
					format = function(_, vim_item)
						local text = vim_item.abbr or vim_item.word or ""
						local line = vim.fn.getcmdline()

						-- Until there is a space after the command, we are completing the Vim command itself:
						local cmd = line:match("^%s*(%S+)%s+")

						local kind, icon

						if cmd then
							local is_path_cmd = ({
								e = true,
								edit = true,
								vsp = true,
								vsplit = true,
								sp = true,
								split = true,
								tabe = true,
								tabedit = true,
								source = true,
								so = true,
								cd = true,
								lcd = true,
								read = true,
								r = true,
								write = true,
								w = true,
							})[cmd]

							if is_path_cmd then
								local stat = vim.uv.fs_stat(vim.fn.expand(text))
								if (stat and stat.type == "directory") or text:match("/$") then
									kind = "Folder"
									icon = "󰉋"
								else
									kind = "File"
									icon = "󰈔"
								end
							elseif text:match("^%-") then
								kind = "Variable"
								icon = "󰫧"
							elseif text:find("%.") then
								kind = "Module"
								icon = "󰆧"
							else
								kind = "Function"
								icon = "󰘧"
							end
						else
							kind = "Function"
							icon = "󰘧"
						end

						vim_item.kind = kind
						vim_item.icon = icon
						vim_item.icon_hl_group = "CmpItemKind" .. kind
						vim_item.kind_hl_group = "CmpItemKind" .. kind

						return vim_item
					end,
				},

				sorting = {
					priority_weight = 2,
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						cmp.config.compare.recently_used,
						cmp.config.compare.order,
					},
				},

				sources = cmp.config.sources({
					{ name = "cmdline", keyword_length = 1 },
				}),
				matching = {
					disallow_fuzzy_matching = false,
					disallow_fullfuzzy_matching = false,
					disallow_partial_fuzzy_matching = false,
					disallow_partial_matching = false,
					disallow_prefix_unmatching = false,
					disallow_symbol_nonprefix_matching = false,
				},
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local types = require("cmp.types")
			require("luasnip.loaders.from_vscode").lazy_load()
			require("custom.smart_path").setup(cmp)

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
					fields = { "icon", "abbr" },
					format = require("lspkind").cmp_format({
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},

				sources = cmp.config.sources({
					{
						name = "nvim_lsp",
						-- priority = 10,
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
						-- priority = 8,

						-- Don't show snippets when inside a string
						entry_filter = function()
							local context = require("cmp.config.context")
							return not context.in_treesitter_capture("string") and not context.in_syntax_group("String")
						end,
					},
					{
						name = "smart_path",
						-- priority = 9,
					},
				}),

				sorting = {
					priority_weight = 2,
					comparators = {
						cmp.config.compare.offset,

						-- Prefix matches always beat scattered mid-word fuzzy matches
						function(entry1, entry2)
							local function is_prefix(entry)
								local input = entry.context.cursor_before_line:sub(entry.offset):lower()
								if input == "" then
									return true
								end
								local label = (entry.completion_item.filterText or entry.completion_item.label or ""):lower()
								return label:sub(1, #input) == input
							end

							local p1 = is_prefix(entry1)
							local p2 = is_prefix(entry2)
							if p1 ~= p2 then
								return p1
							end
						end,

						-- Auto-import demotion (local/in-scope symbols always beat unimported external modules)
						function(entry1, entry2)
							local function is_auto_import(entry)
								local item = entry.completion_item
								if not item then
									return false
								end
								if
									entry.source.name == "luasnip"
									or item.kind == types.lsp.CompletionItemKind.Snippet
								then
									return false
								end

								-- C# (Roslyn) before resolve
								if item.sortText and item.sortText:match("^%d+~") then
									return true
								end

								-- Python (Pyright):
								if item.data and item.data.autoImportText then
									return true
								end

								-- Other LSPs (TS, Rust, Lua, Roslyn after resolve)
								if item.additionalTextEdits and #item.additionalTextEdits > 0 then
									for _, edit in ipairs(item.additionalTextEdits) do
										local text = edit.newText or ""
										if
											text:match("^%s*using%s+")
											or text:match("^%s*import%s+")
											or text:match("^%s*from%s+[%w_%.]+%s+import")
											or text:match("^%s*#include")
											or text:match("require%s*%(")
										then
											return true
										end
									end
								end
								return false
							end

							local a1 = is_auto_import(entry1)
							local a2 = is_auto_import(entry2)
							if a1 ~= a2 then
								return not a1
							end
						end,

						cmp.config.compare.exact,
						cmp.config.compare.score,
						cmp.config.compare.locality,

						function(entry1, entry2)
							local kind_rank = {
								-- 1. Data / values
								[types.lsp.CompletionItemKind.Variable] = 1,
								[types.lsp.CompletionItemKind.Field] = 1,
								[types.lsp.CompletionItemKind.Property] = 1,
								[types.lsp.CompletionItemKind.Constant] = 1,
								[types.lsp.CompletionItemKind.EnumMember] = 1,

								-- 2. Callables
								[types.lsp.CompletionItemKind.Method] = 2,
								[types.lsp.CompletionItemKind.Function] = 2,
								[types.lsp.CompletionItemKind.Constructor] = 2,

								-- 3. Keywords
								[types.lsp.CompletionItemKind.Keyword] = 3,
								[types.lsp.CompletionItemKind.Operator] = 3,

								-- 4. Types / modules
								[types.lsp.CompletionItemKind.Class] = 4,
								[types.lsp.CompletionItemKind.Interface] = 4,
								[types.lsp.CompletionItemKind.Struct] = 4,
								[types.lsp.CompletionItemKind.Enum] = 4,
								[types.lsp.CompletionItemKind.Module] = 4,

								-- 5. Snippets and plain text
								[types.lsp.CompletionItemKind.Snippet] = 5,
								[types.lsp.CompletionItemKind.Text] = 6,
							}
							local rank1 = kind_rank[entry1:get_kind()] or 100
							local rank2 = kind_rank[entry2:get_kind()] or 100

							if rank1 ~= rank2 then
								return rank1 < rank2
							end
						end,

						cmp.config.compare.recently_used,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
			})
		end,
	},
}
