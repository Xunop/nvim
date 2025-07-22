return {
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
                    { name = "nvim_lsp" }, -- lsp
                    { name = "luasnip" },  -- snippests
                    { name = "buffer" },   -- text within current buffer
                    { name = "path" },     -- file system path
                }),
                mapping = cmp.mapping.preset.insert({
                    ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
                    ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
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
}
