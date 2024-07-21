return {
	{
		"mfussenegger/nvim-dap",
		lazy = "VeryLazy",
		dependencies = {
			-- Creates a beautiful debugger UI
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"jay-babu/mason-nvim-dap.nvim",

			-- Add your own debuggers here:
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			require("dapui").setup()

			-- Basic debugging keymaps, feel free to change to your liking!
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<F4>", dap.step_back, { desc = "Debug: Step Back" })
			vim.keymap.set("n", "<F13>", dap.restart, { desc = "Debug: Restart" })

			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Set Breakpoint" })

			-- Eval var under cursor
			vim.keymap.set("n", "<space>?", function()
				require("dapui").eval(nil, { enter = true })
			end, { desc = "Debug: Eval under cursor" })

			vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			-- Install language specific debuggers
			local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
			require("dap-python").setup(debugpy_path)
		end,
	},
	{
		"nvim-neotest/neotest",
		lazy = "VeryLazy",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			adapters = {
				["neotest-python"] = {
					-- Here you can specify the settings for the adapter, i.e.
					-- runner = "pytest",
					-- python = ".venv/bin/python",
				},
			},
		},
	},
}
