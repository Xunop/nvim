-- Global indentation settings
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.tabstop = 4 -- Display tabs as 4 columns
vim.o.shiftwidth = 4 -- Indentation width (4 spaces)
vim.o.softtabstop = 4 -- Tab key inserts 4 spaces

vim.wo.relativenumber = true
vim.wo.number = true

vim.api.nvim_set_keymap("n", "<Esc>", ":nohlsearch<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<Esc>", ":nohlsearch<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<Esc>", ":nohlsearch<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("o", "<Esc>", ":nohlsearch<CR>", { noremap = true, silent = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf", -- quickfix (location list use qf)
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true, nowait = true, desc = "Close quickfix/location window" })
  end,
})

vim.o.timeoutlen = 200
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })

-- Ensure TypeScript filetypes use 4 spaces
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	callback = function()
		vim.bo.expandtab = true
		vim.bo.tabstop = 4
		vim.bo.shiftwidth = 4
		vim.bo.softtabstop = 4
	end,
})

-- will store in `~/.local/state/nvim/` folder
-- undo history persistence
-- local undodir = vim.fn.expand("~/.local/state/nvim/undo")
-- if not vim.loop.fs_stat(undodir) then
-- 	vim.fn.mkdir(undodir, "p")
-- end

vim.opt.undofile = true
-- vim.opt.undodir = undodir

-- restore cursor
vim.api.nvim_create_autocmd('BufRead', {
  callback = function(opts)
    vim.api.nvim_create_autocmd('BufWinEnter', {
      once = true,
      buffer = opts.buf,
      callback = function()
        local ft = vim.bo[opts.buf].filetype
        local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
        if
          not (ft:match('commit') and ft:match('rebase'))
          and last_known_line > 1
          and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
        then
          vim.api.nvim_feedkeys([[g`"]], 'nx', false)
        end
      end,
    })
  end,
})
