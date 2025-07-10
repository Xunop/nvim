return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	-- or                              , branch = '0.1.x',
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader>,",
			"<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
			desc = "Switch Buffer",
		},
		{ "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
		-- find
		{
			"<leader>fb",
			"<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
			desc = "Buffers",
		},
		{
			"<leader>fw",
			"<cmd>Telescope live_grep<CR>",
			desc = "Grep (cwd)",
		},
		{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files (cwd)" },
		{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
		-- git
		{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
		{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
		-- search
		{ '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
		{ "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
		{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
		{ "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
		{ "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
		{ "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
		{ "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
		{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
		{ "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
		{ "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
		{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
		{ "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
		{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
		{ "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
		{ "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
		{ "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
		{ "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
	},
    opts = {
        defaults = {
            mappings = {
                n = {
                    ["q"] = require("telescope.actions").close,
                }
            }
        }
    }
}
