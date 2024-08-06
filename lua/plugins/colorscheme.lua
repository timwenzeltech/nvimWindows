return {
    -- {
    --     "folke/tokyonight.nvim",
    --     config = function()
    --         require("tokyonight").setup({
    --             -- your configuration comes here
    --             -- or leave it empty to use the default settings
    --             style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    --             transparent = true, -- Enable this to disable setting the background color
    --             terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
    --             styles = {
    --                 -- Style to be applied to different syntax groups
    --                 -- Value is any valid attr-list value for `:help nvim_set_hl`
    --                 comments = { italic = false },
    --                 keywords = { italic = false },
    --                 -- Background styles. Can be "dark", "transparent" or "normal"
    --                 sidebars = "transparent", -- style for sidebars, see below
    --                 floats = "transparent", -- style for floating windowsawdawd
    --             },
    --         })
    --         -- vim.cmd("colorscheme tokyonight")
    --     end,
    -- },
    -- {
    --     "rose-pine/neovim",
    --     name = "rose-pine",
    --     config = function()
    --         require("rose-pine").setup({
    --             variant = "main", -- auto, main, moon, or dawn
    --             dark_variant = "main", -- main, moon, or dawn
    --             dim_inactive_windows = false,
    --             extend_background_behind_borders = false,
    --
    --             enable = {
    --                 terminal = true,
    --                 legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
    --                 migrations = true, -- Handle deprecated options automatically
    --             },
    --
    --             styles = {
    --                 bold = true,
    --                 italic = false,
    --                 transparency = true,
    --             },
    --             groups = {
    --                 border = "muted",
    --                 link = "iris",
    --                 panel = "surface",
    --
    --                 error = "love",
    --                 hint = "iris",
    --                 info = "foam",
    --                 note = "pine",
    --                 todo = "rose",
    --                 warn = "gold",
    --
    --                 git_add = "foam",
    --                 git_change = "rose",
    --                 git_delete = "love",
    --                 git_dirty = "rose",
    --                 git_ignore = "muted",
    --                 git_merge = "iris",
    --                 git_rename = "pine",
    --                 git_stage = "iris",
    --                 git_text = "rose",
    --                 git_untracked = "subtle",
    --
    --                 h1 = "iris",
    --                 h2 = "foam",
    --                 h3 = "rose",
    --                 h4 = "gold",
    --                 h5 = "pine",
    --                 h6 = "foam",
    --             },
    --         })
    --         vim.cmd("colorscheme rose-pine")
    --     end,
    -- },
    {
		"shaunsingh/nord.nvim",
		lazy = false,
		config = function()
			local highlights = require("nord").bufferline.highlights({
				italic = true,
				bold = true,
			})

			require("bufferline").setup({
				options = {
					separator_style = "thin",
				},
				highlights = highlights,
			})

			-- Example config in lua
			vim.g.nord_contrast = true
			vim.g.nord_borders = true
			vim.g.nord_disable_background = true
			vim.g.nord_italic = false
			vim.g.nord_uniform_diff_background = true
			vim.g.nord_bold = true

			-- Load the colorscheme
			require("nord").set()
			vim.cmd.colorscheme("nord")
		end,
	},
}
