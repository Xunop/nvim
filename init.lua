require("config.options")
require("config.lazy")
-- local ansible_ft_group = vim.api.nvim_create_augroup('AnsibleFiletype', { clear = true })
-- vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
--   group = ansible_ft_group,
--   pattern = { '*.yaml', '*.yml' },
--   command = 'set filetype=yaml.ansible',
-- })
--
-- local jinja_ft_group = vim.api.nvim_create_augroup('JinjaFiletype', { clear = true })
-- vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
--   group = jinja_ft_group,
--   pattern = { '*.j2' },
--   command = 'set filetype=jinja',
-- })
