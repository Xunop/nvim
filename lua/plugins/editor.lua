return {
	{
		"folke/which-key.nvim",
		version = "v3.17.0",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			spec = {
				{
					"<leader>b",
					group = "buffer",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
				{
					"<leader>f",
					group = "telecope",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		tag = "v0.9.3",
		lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			-- disable slow treesitter highlight for large files
			disable = function(lang, buf)
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
		},
	},
	-- { "catppuccin/nvim", name = "catppuccin", priority = 1000,
	-- config = function()
	-- 	vim.cmd([[colorscheme catppuccin-mocha]])
	-- end,
	-- },

	-- the colorscheme should be available when starting Neovim
	{
		"folke/tokyonight.nvim",
		version = "v4.11.0",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			-- load the colorscheme here
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "NeoTree" },
		},
		lazy = false, -- neo-tree will lazily load itself
		opts = {
			-- fill any relevant options here
			window = {
				mappings = {
					["h"] = "close_node",
					["l"] = "open",
				},
			},
		},
	},
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		tag = "v0.15.0",
		opts = {
			modes = { insert = true, command = true, terminal = false },
			-- skip autopair when next character is one of these
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			-- skip autopair when the cursor is inside these treesitter nodes
			skip_ts = { "string" },
			-- skip autopair when next character is closing pair
			-- and there are more closing pairs than opening pairs
			skip_unbalanced = true,
			-- better deal with markdown code blocks
			markdown = true,
		},
	},
	-- nvim-cmp
	{
		"hrsh7th/nvim-cmp",
		version = "v0.0.2",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"jcha0713/cmp-tw2css", -- tailwindcss to css
		},
		config = function()
			local cmp = require("cmp")
			local snippets = require("luasnip")
			-- require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						-- vim.fn["vsnip#anonymous"](args.body)
						snippets.lsp_expand(args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif snippets.expandable() then
							snippets.expand()
						elseif snippets.has_snippet_nodes() then
							snippets.next_pos()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif snippets.has_snippet_nodes(-1) then
							snippets.prev_pos()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					format = function(entry, vim_item)
						-- local kind_icons = {
						-- 	Text = "",
						-- 	Method = "m",
						-- 	Function = "",
						-- 	Constructor = "",
						-- 	Field = "",
						-- 	Variable = "",
						-- 	Class = "",
						-- 	Interface = "",
						-- 	Module = "",
						-- 	Property = "",
						-- 	Unit = "",
						-- 	Value = "",
						-- 	Enum = "",
						-- 	Keyword = "",
						-- 	Snippet = "",
						-- 	Color = "",
						-- 	File = "",
						-- 	Reference = "",
						-- 	Folder = "",
						-- 	EnumMember = "",
						-- 	Constant = "",
						-- 	Struct = "",
						-- 	Event = "",
						-- 	Operator = "",
						-- 	TypeParameter = "",
						-- }
						-- vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							snippets = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		config = function(_, opts)
			if opts then
				require("luasnip").config.setup(opts)
			end
			vim.tbl_map(function(type)
				require("luasnip.loaders.from_" .. type).lazy_load()
			end, { "vscode", "snipmate", "lua" })
			-- friendly-snippets - enable standardized comments snippets
			require("luasnip").filetype_extend("typescript", { "tsdoc" })
			require("luasnip").filetype_extend("javascript", { "jsdoc" })
			require("luasnip").filetype_extend("lua", { "luadoc" })
			require("luasnip").filetype_extend("python", { "pydoc" })
			require("luasnip").filetype_extend("rust", { "rustdoc" })
			require("luasnip").filetype_extend("cs", { "csharpdoc" })
			require("luasnip").filetype_extend("java", { "javadoc" })
			require("luasnip").filetype_extend("c", { "cdoc" })
			require("luasnip").filetype_extend("cpp", { "cppdoc" })
			require("luasnip").filetype_extend("php", { "phpdoc" })
			require("luasnip").filetype_extend("kotlin", { "kdoc" })
			require("luasnip").filetype_extend("ruby", { "rdoc" })
			require("luasnip").filetype_extend("sh", { "shelldoc" })
		end,
	},
	{
		"folke/ts-comments.nvim",
		version = "v1.5.0",
		opts = {},
		event = "VeryLazy",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
	},
	{
		"numToStr/Comment.nvim",
		tag = "v0.8.0",
		opts = {
			mappings = {
				---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
				basic = true,
				---Extra mapping; `gco`, `gcO`, `gcA`
				extra = false,
			},
			toggler = {
				---Line-comment toggle keymap
				line = "<leader>/",
				---Block-comment toggle keymap
				block = "gbc",
			},
			opleader = {
				line = "<leader>/",
				block = "gb",
			},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		version = "v2.1.0",
		opts = {},
        -- stylua: ignore
        keys = {
          { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
          { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
          { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
          { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
          { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = {},
	},
	-- show undo tree
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>ut", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
			{ "<leader>uf", "<cmd>UndotreeFocus<cr>", desc = "Focus Undotree" },
		},
	},
	{
		"hedyhli/outline.nvim",
		lazy = true,
		cmd = { "Outline", "OutlineOpen" },
		keys = {
			{ "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
		},
		opts = {
			-- Your setup opts here
		},
	},
	-- show indentation
	-- {
	-- 	"lukas-reineke/indent-blankline.nvim",
	-- 	main = "ibl",
	-- 	---@module "ibl"
	-- 	---@type ibl.config
	-- 	opts = {},
	-- },
	{
		"ap/vim-css-color",
		opts = {},
		config = function(_, opts) end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		opts = {},
	},
}
