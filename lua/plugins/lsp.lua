-- Need to install efm-langserver, mason will do it

local on_attach = function(client, bufnr)
    -- Use { buffer = bufnr } to make sure these keys are only valid for the current buffer
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to Declaration" })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Find References" })
    vim.keymap.set("n", "gl", vim.diagnostic.open_float, { buffer = bufnr, desc = "Open diagnostic float" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover Documentation" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code Action" })
    vim.keymap.set("n", "<leader>lf", function()
        vim.lsp.buf.format({ bufnr = bufnr })
    end, { buffer = bufnr, desc = "Format Buffer" })

    if client.name == "tsserver" then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormatTs", { clear = true }),
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
    end

    -- Debug
    -- print("LSP client '" .. client.name .. "' attached to buffer " .. bufnr)
end

local config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")
    -- lspconfig.pyright.setup({
    --     capabilities = capabilities,
    --     settings = {
    --         python = {
    --             analysis = {
    --                 diagnosticSeverityOverrides = {
    --                     -- 关闭恼人的字符过长警告
    --                     ["E501"] = "off",
    --                 },
    --             },
    --         },
    --     },
    -- })

    vim.filetype.add({
        extension = {
            jinja = "jinja",
            jinja2 = "jinja",
            j2 = "jinja",
            py = "python",
            yaml = "yaml.ansible",
            yml = "yaml.ansible"
        },
    })

    -- mason-lspconfig provides a helper function to configure server settings
    -- use it to config all servers
    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup_handlers({
        -- Default handler for servers that don't need custom settings
        function(server_name)
            lspconfig[server_name].setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end,

        ["pyright"] = function()
            lspconfig.pyright.setup({
                capabilities = capabilities,
                on_attach = on_attach,
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
        end,
        ["bashls"] = function()
            lspconfig.bashls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                filetypes = { "sh" },
            })
        end,
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        -- make the language server recognize "vim" global
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            -- make language server aware of runtime files
                            library = {
                                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                                [vim.fn.stdpath("config") .. "/lua"] = true,
                            },
                        },
                    },
                },
            })
        end,

        ["jinja_lsp"] = function()
            lspconfig.jinja_lsp.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                filetypes = { "jinja" },
            })
        end,
        ["ansiblels"] = function()
            if vim.fn.executable("ansible") == 1 and vim.fn.executable("ansible-lint") == 1 then
                -- print("Ansible executables found. Setting up ansiblels.")
                lspconfig.ansiblels.setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                    filetypes = { "yaml.ansible" },
                    root_dir = lspconfig.util.root_pattern("ansible.cfg", ".ansible-lint"),
                    settings = {
                        ansible = {
                            ansible = {
                                path = "ansible",
                            },
                            executionEnvironment = {
                                enabled = false,
                            },
                            python = {
                                interpreterPath = "python",
                            },
                            validation = {
                                enabled = true,
                                lint = {
                                    enabled = true,
                                    path = "ansible-lint",
                                },
                            },
                        },
                    },
                })
            else
                -- print("Ansible executables not found. Skipping ansiblels setup.")
            end
        end,
    })

    -- efm

    -- local luacheck = require("efmls-configs.linters.luacheck")
    local stylua = require("efmls-configs.formatters.stylua")
    local goimports = require("efmls-configs.formatters.goimports")
    local flake8 = require("efmls-configs.linters.flake8")
    local black = require("efmls-configs.formatters.black")
    local eslint_d = require("efmls-configs.linters.eslint_d")
    local prettierd = require("efmls-configs.formatters.prettier_d")
    local fixjson = require("efmls-configs.formatters.fixjson")
    local shellcheck = require("efmls-configs.linters.shellcheck")
    local shfmt = require("efmls-configs.formatters.shfmt")
    -- local alex = require("efmls-configs.linters.alex")
    local hadolint = require("efmls-configs.linters.hadolint")

    -- configure efm server
    lspconfig.efm.setup({
        on_attach = on_attach,
        filetypes = {
            "go",
            "lua",
            "python",
            "json",
            "jsonc",
            "sh",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "svelte",
            "vue",
            "markdown",
            "dockerfile",
            "yaml.ansible",
        },
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
            hover = true,
            documentSymbol = true,
            codeAction = true,
            completion = true,
        },
        settings = {
            languages = {
                go = { goimports },
                lua = {
                    -- {
                    -- 	lintCommand = "luacheck --quiet --formatter plain --globals vim --",
                    -- 	lintFormats = { "%f:%l:%c: %m" },
                    -- },
                    -- OR use
                    -- luacheck,
                    stylua,
                },
                python = { flake8, black },
                typescript = { eslint_d, prettierd },
                json = { eslint_d, fixjson },
                jsonc = { eslint_d, fixjson },
                sh = { shellcheck, shfmt },
                javascript = { eslint_d, prettierd },
                javascriptreact = { eslint_d, prettierd },
                typescriptreact = { eslint_d, prettierd },
                svelte = { eslint_d, prettierd },
                vue = { eslint_d, prettierd },
                markdown = { prettierd },
                dockerfile = { hadolint, prettierd },
                -- ansible = { ansiblels },
            },
        },
    })

    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
    })
end

return {
    {
        "neovim/nvim-lspconfig",
        version = "v2.1.0",
        dependencies = {
            "windwp/nvim-autopairs",
            "williamboman/mason.nvim",
            "creativenull/efmls-configs-nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
        },
        lazy = false,
        -- event = { "BufReadPost", "BufNewFile" }, -- load when file is opened
        -- keys = {
        --     { "gd", vim.lsp.buf.definition,    desc = "Go to definition" },
        --     { "[d", vim.diagnostic.goto_prev,  desc = "Previous diagnostic" },
        --     { "]d", vim.diagnostic.goto_next,  desc = "Next diagnostic" },
        --     { "gl", vim.diagnostic.open_float, desc = "Open diagnostic float" },
        --     { "gr", vim.lsp.buf.references,    desc = "Find references" },
        -- },
        config = config,
    },
}
