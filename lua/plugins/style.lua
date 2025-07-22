return {
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
		"akinsho/bufferline.nvim",
		version = "v4.9.1",
		dependencies = "nvim-tree/nvim-web-devicons",
		event = "VeryLazy",
		lazy = false,
		keys = {
			{ "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
			{ "<leader>bd", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{
				"<leader>br",
				"<cmd>BufferLineCloseRight<cr>",
				desc = "Delete Buffers to the Right",
			},
			{ "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Delete Buffers to the Left" },
			{ "<leader>b|", "<cmd>vsplit | BufferLinePick<cr>", desc = "Pick Buffer to vsplit" },
			{ "<leader>b\\", "<cmd>split | BufferLinePick<cr>", desc = "Pick Buffer to split" },
		},
		opts = {
			options = {
				offsets = {
					{
						filetype = "neo-tree",
						text = function()
							return vim.fn.getcwd()
						end,
						highlight = "Directory",
						separator = true, -- use a "true" to enable the default, or set your own character
					},
				},
			},
		},
	},
	-- {
	-- 	"nvim-lualine/lualine.nvim",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- 	opts = {
	-- 		options = {
	-- 			theme = "ayu_mirage",
	-- 		},
	-- 	},
	-- },
}
