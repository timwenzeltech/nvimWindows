return {
	-- lspconfig
	{
		"neovim/nvim-lspconfig",
		event = "BufEnter",
		dependencies = {
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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
						-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
						-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
						-- prefix = "icons",
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
					lemminx = {},
					marksman = {
						filetypes = { "markdown", "markdown.mdx" },
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
				},
				setup = {
					jdtls = function()
						return true --avoid duplicate servers
					end,
				},
			}
		end,

		config = function(_, opts)
			local servers = opts.servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			-- get all the servers that are available through mason-lspconfig
			local have_mason, mlsp = pcall(require, "mason-lspconfig")
			local all_mslp_servers = {}
			if have_mason then
				all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			end

			local ensure_installed = {} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					if server_opts.enabled ~= false then
						-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
						if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
							setup(server)
						else
							ensure_installed[#ensure_installed + 1] = server
						end
					end
				end
			end

			if have_mason then
				mlsp.setup({
					ensure_installed = vim.tbl_deep_extend(
						"force",
						ensure_installed,
						require("mason-lspconfig").ensure_installed or {}
					),
					handlers = { setup },
				})
			end

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

					local settings = servers[client.name]
					if type(settings) ~= "table" then
						settings = {}
					end

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
				end,
			})
		end,
	},

	-- cmdline tools and lsp servers
	{

		"williamboman/mason.nvim",
		event = "VeryLazy",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"stylua",
				"shfmt",
				--Java:
				"jdtls",
				"java-debug-adapter",
				"java-test",
				"google-java-format",
				--Markdown
				"markdownlint",
			},
		},
		---@param opts MasonSettings | {ensure_installed: string[]}
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					-- trigger FileType event to possibly load this newly installed LSP server
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)

			mr.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end)
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
