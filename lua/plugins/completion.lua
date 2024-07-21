return {
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    -- Build Step is needed for regex support in snippets.
                    -- This step is not supported in many windows environments.
                    -- Remove the below condition to re-enable on windows.
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
            },
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
            -- "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "rcarriga/cmp-dap",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            lspkind.init({})
            local ls = require("luasnip")
            require("luasnip.loaders.from_vscode").load({})
            ls.config.set_config({
                history = true,
                updateevents = "TextChanged,TextChangedI",
                override_builtin = true,
            })
            cmp.setup({
                snippet = {
                    expand = function(args)
                        ls.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = "menu,menuone,noinsert" },
                view = {
                    entries = { selection_order = "near_cursor", follow_cursor = true, name = "custom" },
                    anchor = "bottom",
                },

                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete({}),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif ls.locally_jumpable(1) then
                            ls.jump(1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif ls.locally_jumpable(-1) then
                            ls.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                },
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol",
                        maxwidth = 50,
                        ellipsis_char = "...",
                        show_labelDetails = true,
                    }),
                },
            })
            -- require("cmp").setup({
            -- 	enabled = function()
            -- 		return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
            -- 	end,
            -- })
            --
            -- require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
            -- 	sources = {
            -- 		{ name = "dap" },
            -- 	},
            -- })
        end,
    },
}
