return {
	"nvimtools/none-ls.nvim",
	event = "BufEnter",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		-- get access to the none-ls functions
		local null_ls = require("null-ls")
		-- run the setup function for none-ls to setup our different formatters
		null_ls.setup({
			sources = {
				-- Lua:
				null_ls.builtins.formatting.stylua,
				-- Docker
				null_ls.builtins.diagnostics.hadolint,
				-- Markdown
				null_ls.builtins.diagnostics.markdownlint,
			},
		})
		vim.keymap.set("n", "<leader>fo", vim.lsp.buf.format, { desc = "[F]ormat" })
		-- Format on Save:
		local format_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		vim.api.nvim_create_autocmd({ "BufWritePre" }, {
			group = format_augroup,
			callback = function()
				vim.lsp.buf.format({ async = true })
			end,
		})
	end,
}
