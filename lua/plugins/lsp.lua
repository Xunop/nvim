return {
	-- mason
	{
		{
			"williamboman/mason.nvim",
			version = "v1.11.0",
			cmd = "Mason",
			lazy = false,
			pariority = 100,
			build = ":MasonUpdate",
			-- opts_extend = { "ensure_installed" },
			opts = {
				-- ensure_installed = { "stylua", "prettierd", "shfmt", "isort", "black", "goimports" },
			},
			-- opts = {
			-- 	ensure_installed = { "stylua", "prettierd", "shfmt", "isort", "black", "goimports" },
			-- },
		},
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		version = "v2.1.0",
		dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
		event = { "BufReadPost", "BufNewFile" }, -- load when file is opened
		keys = {
			{ "gd", vim.lsp.buf.definition, desc = "Go to definition" },
			{ "[d", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
			{ "]d", vim.diagnostic.goto_next, desc = "Next diagnostic" },
			{ "gl", vim.diagnostic.open_float, desc = "Open diagnostic float" },
			{ "gr", vim.lsp.buf.references, desc = "Find references" },
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			-- mason-lspconfig provides a helper function to configure server settings
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup_handlers({
				function(server_name)
					capabilities = require("cmp_nvim_lsp").default_capabilities()
					if server_name == "pyright" then
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
							settings = {
								python = {
									analysis = {
										diagnosticSeverityOverrides = {
                                            -- 关闭恼人的字符过长警告
											["E501"] = "off",
										},
									},
								},
							},
						})
					else
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end
				end,
			})

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				update_in_insert = false,
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		version = "v1.32.0",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		opts = {
			ensure_installed = { "lua_ls", "pyright", "tailwindcss", "cssls", "gopls" },
		},
	},
	-- typescript lsp
	{
		"pmizio/typescript-tools.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		event = "BufEnter",
		ft = {
			"typescriptreact",
			"typescript",
		},
		opts = {
			settings = {
				publish_diagnostic_on = "insert_leave",
				tsserver_file_preferences = {
					includeInlayParameterNameHints = "all",
					includeCompletionsForModuleExports = true,
					quotePreference = "auto",
				},
			},

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "typescript", "typescriptreact" },
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					vim.keymap.set("n", "gd", "<cmd>TSToolsGoToSourceDefinition<CR>", {
						buffer = bufnr,
						desc = "Go to Source Definition",
					})
					-- vim.keymap.set("n", "<leader>oi", "<cmd>TSToolsOrganizeImports<CR>", {
					-- 	buffer = bufnr,
					-- 	desc = "Organize Imports",
					-- })
					-- vim.keymap.set("n", "<leader>fa", "<cmd>TSToolsFixAll<CR>", {
					-- 	buffer = bufnr,
					-- 	desc = "Fix All",
					-- })
				end,
			}),
		},
	},
	-- lint
	{
		"mfussenegger/nvim-lint",
		opts = {
			-- Event to trigger linters
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				fish = { "fish" },
				-- Use the "*" filetype to run linters on all filetypes.
				["*"] = { "global linter" },
				-- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
				-- ['_'] = { 'fallback linter' },
				-- ["*"] = { "typos" },
			},
			-- LazyVim extension to easily override linter options
			-- or add custom linters.
			---@type table<string,table>
			linters = {
				-- -- Example of using selene only when a selene.toml file is present
				-- selene = {
				--   -- `condition` is another LazyVim extension that allows you to
				--   -- dynamically enable/disable linters based on the context.
				--   condition = function(ctx)
				--     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
				--   end,
				-- },
			},
		},
		config = function(_, opts)
			local M = {}

			local lint = require("lint")
			for name, linter in pairs(opts.linters) do
				if type(linter) == "table" and type(lint.linters[name]) == "table" then
					lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
					if type(linter.prepend_args) == "table" then
						lint.linters[name].args = lint.linters[name].args or {}
						vim.list_extend(lint.linters[name].args, linter.prepend_args)
					end
				else
					lint.linters[name] = linter
				end
			end
			lint.linters_by_ft = opts.linters_by_ft

			function M.debounce(ms, fn)
				local timer = vim.uv.new_timer()
				return function(...)
					local argv = { ... }
					timer:start(ms, 0, function()
						timer:stop()
						vim.schedule_wrap(fn)(unpack(argv))
					end)
				end
			end

			function M.lint()
				-- Use nvim-lint's logic first:
				-- * checks if linters exist for the full filetype first
				-- * otherwise will split filetype by "." and add all those linters
				-- * this differs from conform.nvim which only uses the first filetype that has a formatter
				local names = lint._resolve_linter_by_ft(vim.bo.filetype)

				-- Create a copy of the names table to avoid modifying the original.
				names = vim.list_extend({}, names)

				-- Add fallback linters.
				if #names == 0 then
					vim.list_extend(names, lint.linters_by_ft["_"] or {})
				end

				-- Add global linters.
				vim.list_extend(names, lint.linters_by_ft["*"] or {})

				-- Filter out linters that don't exist or don't match the condition.
				local ctx = { filename = vim.api.nvim_buf_get_name(0) }
				ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
				names = vim.tbl_filter(function(name)
					local linter = lint.linters[name]
					if not linter then
						print("Linter not found: " .. name, { title = "nvim-lint" })
					end
					return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
				end, names)

				-- Run linters.
				if #names > 0 then
					lint.try_lint(names)
				end
			end

			vim.api.nvim_create_autocmd(opts.events, {
				group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
				callback = M.debounce(100, M.lint),
			})
		end,
	},
	-- formatting code
	{
		{
			"stevearc/conform.nvim",
			lazy = true,
			version = "v9.0.0",
			event = { "BufReadPost", "BufNewFile" },
			cmd = "ConformInfo",
			-- the formatters use mason installed
			dependencies = { "williamboman/mason.nvim" },
			keys = {
				{
					"<leader>lf",
					function()
						require("conform").format({}, function(err, did_edit)
							if err then
								vim.notify("Formatting failed: " .. err, vim.log.levels.ERROR)
							elseif did_edit then
								vim.notify("Formatted successfully", vim.log.levels.INFO)
							else
								vim.notify("No changes made by formatter", vim.log.levels.INFO)
							end
							-- print('aa')
						end)
					end,
					mode = { "n", "v" },
					desc = "Format Buffer",
				},
			},
			opts = {
				log_level = vim.log.levels.DEBUG,
				default_format_opts = {
					timeout_ms = 3000,
					async = false, -- not recommended to change
					quiet = false, -- not recommended to change
					lsp_format = "fallback", -- not recommended to change
				},
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "goimports", "gofmt" },
					sh = { "shfmt" },
					python = { "isort", "black" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					typescript = { "prettierd", "prettier", stop_after_first = true },
					typescriptreact = { "prettierd", "prettier", stop_after_first = true },
					javascriptreact = { "prettierd", "prettier", stop_after_first = true },
					-- fish = { "fish_indent" },
				},
			},
		},
	},
}
