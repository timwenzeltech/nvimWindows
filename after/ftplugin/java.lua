local status, jdtls = pcall(require, "jdtls")
if not status then
	vim.notify("jdtls not found", vim.log.levels.ERROR)
	return
end
local nvim_data = vim.fn.stdpath("data")
local os_config = "win"

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls/workspace-root/" .. project_name

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- Needed for debugging
local bundles = {
	vim.fn.glob(vim.fn.stdpath("data") .. "/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar"),
}

-- Needed for running/debugging unit tests
-- vim.list_extend(bundles, vim.split(vim.fn.glob(vim.fn.stdpath("data") .. "/mason/share/java-test/*.jar", 1), "\n"))

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. nvim_data .. "/mason/packages/jdtls/lombok.jar",
		"-jar",
		vim.fn.glob(nvim_data .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration",
		nvim_data .. "/mason/packages/jdtls/config_" .. os_config,
		"-data",
		workspace_dir,
	},
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
	capabilities = capabilities,
	settings = {
		java = {
			eclipse = {
				downloadSources = true,
			},
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-17",
						path = "C:/Program Files/Java/jdk-17",
					},
				},
			},
			maven = {
				downloadSources = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "all", -- literals, all, none
				},
			},
			format = {
				enabled = true,
				settings = {
					url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
				},
			},
			signatureHelp = { enabled = true },
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
				importOrder = {
					"java",
					"javax",
					"com",
					"org",
				},
			},
		},
	},
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = extendedClientCapabilities,
	},
}
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")
		if client and client.name == "jdtls" then
			local _, _ = pcall(vim.lsp.codelens.refresh)
			require("jdtls").setup_dap({ hotcodereplace = "auto" })
			-- Comment out the following line if you don't want intellij like inlay hints
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			require("jdtls.dap").setup_dap_main_class_configs()

			vim.opt.tabstop = 4
			vim.opt.shiftwidth = 4

			local builtin = require("telescope.builtin")
			vim.keymap.set(
				"n",
				"<leader>co",
				"<Cmd>lua require'jdtls'.organize_imports()<CR>",
				{ desc = "Organize Imports" }
			)
			vim.keymap.set(
				"n",
				"<leader>crv",
				"<Cmd>lua require('jdtls').extract_variable()<CR>",
				{ desc = "Extract Variable" }
			)
			vim.keymap.set(
				"v",
				"<leader>crv",
				"<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
				{ desc = "Extract Variable" }
			)
			vim.keymap.set(
				"n",
				"<leader>crc",
				"<Cmd>lua require('jdtls').extract_constant()<CR>",
				{ desc = "Extract Constant" }
			)
			vim.keymap.set(
				"v",
				"<leader>crc",
				"<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
				{ desc = "Extract Constant" }
			)
			vim.keymap.set(
				"v",
				"<leader>crm",
				"<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
				{ desc = "Extract Method" }
			)
			vim.keymap.set(
				"n",
				"<leader>Jt",
				"<Cmd> lua require('jdtls').test_nearest_method()<CR>",
				{ desc = "[J]ava [T]est Method" }
			)
			-- Set a Vim motion to <Space> + <Shift>J + t to run the test method that is currently selected in visual mode
			vim.keymap.set(
				"v",
				"<leader>Jt",
				"<Esc><Cmd> lua require('jdtls').test_nearest_method(true)<CR>",
				{ desc = "[J]ava [T]est Method" }
			)
			-- Set a Vim motion to <Space> + <Shift>J + <Shift>T to run an entire test suite (class)
			vim.keymap.set(
				"n",
				"<leader>JT",
				"<Cmd> lua require('jdtls').test_class()<CR>",
				{ desc = "[J]ava [T]est Class" }
			)
			-- Set a Vim motion to <Space> + <Shift>J + u to update the project configuration
			vim.keymap.set("n", "<leader>Ju", "<Cmd> JdtUpdateConfig<CR>", { desc = "[J]ava [U]pdate Config" })
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.java" },
	callback = function()
		local _, _ = pcall(vim.lsp.codelens.refresh)
	end,
})

require("jdtls").start_or_attach(config)
