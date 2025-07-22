return {
	-- mason
	{
		"williamboman/mason.nvim",
		version = "v1.*",
		cmd = "Mason",
		dependencies = {},
		-- lazy = false,
		event = "BufReadPre",
		-- priority = 1000,
		build = ":MasonUpdate",
		-- opts_extend = { "ensure_installed" },
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		version = "v1.*",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		opts = {
			ensure_installed = {
				-- EFM (External Formatters and Linters) server itself
				"efm",

                "yamlls",

				-- Lua
				"lua_ls", -- Lua language server

				-- Python language server (Microsoft)
				(vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1) and "pyright" or nil,

				-- Web/Frontend (JS/TS/CSS/Tailwind)
				"cssls", -- CSS language server
				"tailwindcss", -- Tailwind CSS language server

				-- Go language server
				(vim.fn.executable("go") == 1) and "gopls" or nil,

				-- Shell Script
				"bashls", -- Bash language server

				-- Other Linters/Tools
				"ansiblels", -- Ansible language server
			},

			automatic_enable = true,
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		opts = function()
			local packages = {
				-- Always install these
				"hadolint", -- Dockerfile linter
				"shellcheck", -- Shell script linter
				"shfmt", -- Shell script formatter
				"fixjson", -- JSON formatter/linter
				"stylua", -- Lua formatter
                "goimports",
			}

			if vim.fn.executable("luarocks") == 1 then
				vim.list_extend(packages, { "luacheck" })
			end

			-- Conditionally add Python tools
			if vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1 then
				vim.list_extend(packages, {
					"flake8", -- Python linter
					"black", -- Python formatter
				})
			end

			-- Conditionally add JS/TS tools (check for node)
			if vim.fn.executable("node") == 1 then
				vim.list_extend(packages, {
					"eslint_d", -- JavaScript/TypeScript linter
					"prettierd", -- Formatter
				})
			end

			-- Return the final opts table with the dynamically built list
			return {
				ensure_installed = packages,
			}
		end,
	},
}
