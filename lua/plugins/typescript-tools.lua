return {
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
}
