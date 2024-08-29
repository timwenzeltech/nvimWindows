return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason.nvim",
				event = "VeryLazy",
				cmd = "Mason",
				build = ":MasonUpdate",
			},
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"b0o/SchemaStore.nvim",
		},
		opts = function()
			return {
				---@type vim.diagnostic.Opts
				diagnostics = {
					underline = true,
					update_in_insert = false,
					virtual_text = {
						spacing = 4,
						source = "if_many",
						prefix = "●",
					},
					severity_sort = true,
					signs = {
						text = {
							[vim.diagnostic.severity.ERROR] = "",
							[vim.diagnostic.severity.WARN] = "",
							[vim.diagnostic.severity.HINT] = "",
							[vim.diagnostic.severity.INFO] = "",
						},
					},
				},
				inlay_hints = {
					enabled = true,
					exclude = {}, -- filetypes for which you don't want to enable inlay hintsawdawd
				},
				codelens = {
					enabled = false,
				},
				document_highlight = {
					enabled = true,
				},
				-- add any global capabilities here
				capabilities = {
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},
				servers = {
					lua_ls = {
						-- keys = {},
						settings = {
							Lua = {
								workspace = {
									checkThirdParty = false,
								},
								codeLens = {
									enable = true,
								},
								completion = {
									callSnippet = "Replace",
								},
								doc = {
									privateName = { "^_" },
								},
								hint = {
									enable = true,
									setType = false,
									paramType = true,
									paramName = "Disable",
									semicolon = "Disable",
									arrayIndex = "Disable",
								},
							},
						},
					},
					bashls = {},
					dockerls = {},
					tailwindcss = {
						filetypes_exclude = { "markdown" },
						filetypes_include = {},
					},
					lemminx = {},
					marksman = {
						filetypes = { "markdown", "markdown.mdx" },
					},
					cssls = {},
					tsserver = {
						server_capabilities = {
							documentFormattingProvider = false,
						},
					},
					jsonls = {
						settings = {
							json = {
								schemas = require("schemastore").json.schemas(),
								validate = { enable = true },
							},
						},
					},
					yamlls = {
						settings = {
							yaml = {
								schemaStore = {
									enable = false,
									url = "",
								},
								schemas = require("schemastore").yaml.schemas(),
							},
						},
						capabilities = {
							textDocument = {
								foldingRange = {
									dynamicRegistration = false,
									lineFoldingOnly = true,
								},
							},
						},
					},
					clangd = {
						filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
						keys = {
							{
								"<leader>ch",
								"<cmd>ClangdSwitchSourceHeader<cr>",
								desc = "Switch Source/Header (C/C++)",
							},
						},
						root = {
							".clangd",
							".clang-tidy",
							".clang-format",
							"compile_commands.json",
							"compile_flags.txt",
							"configure.ac", -- AutoTools
						},
						capabilities = {
							offsetEncoding = { "utf-16" },
						},
						cmd = {
							"clangd",
							"--background-index",
							"--clang-tidy",
							"--header-insertion=iwyu",
							"--completion-style=detailed",
							"--function-arg-placeholders",
							"--fallback-style=llvm",
						},
						init_options = {
							usePlaceholders = true,
							completeUnimported = true,
							clangdFileStatus = true,
						},
					},
				},
				setup = {
					jdtls = function()
						return true --avoid duplicate servers
					end,
				},
			}
		end,

		config = function(_, opts)
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(args)
					local bufnr = args.buf
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

					-- -- I don't know if I like this better than noice.nvims lsp signatures
					require("lsp_signature").on_attach({
						bind = true, -- This is mandatory, otherwise border config won't get registered.
						handler_opts = {
							border = "single",
						},
					}, bufnr)

					local builtin = require("telescope.builtin")
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
					end
					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					-- Opens a popup that displays documentation about the word under your cursor
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gk", vim.lsp.buf.signature_help, "Signature Help")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gl", vim.diagnostic.open_float, "Diagnostics open Float")

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local servers = opts.servers

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
				"shfmt",
				-- C / CPP
				"clang-format",
				--Java:
				"jdtls",
				"java-debug-adapter",
				"java-test",
				"google-java-format",
				--Python
				"pyright",
				"debugpy",
				"mypy",
				"ruff-lsp",
				"black",
				"isort",
				--Web
				"html-lsp",
				"prettierd",
				"eslint_d",
				--Markdown
				"markdownlint",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
					["jdtls"] = function()
						return true
					end,
				},
			})
		end,
	},

	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			-- require("lsp_signature").setup(opts)
		end,
	},
}
