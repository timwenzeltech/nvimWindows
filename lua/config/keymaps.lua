vim.g.mapleader = " "
--UndoTree
vim.keymap.set("n", "<leader>u", vim.cmd.UndoTreeToggle, { desc = "Toggle UndoTree" })
-- Move to window using the <ctrl> hjkl keys
vim.keymap.set({ "n" }, "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set({ "n" }, "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set({ "n" }, "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set({ "n" }, "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set({ "t", "n" }, "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set({ "t", "n" }, "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set({ "t", "n" }, "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set({ "t", "n" }, "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Jump up and down stay centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Jump down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Jump up, Jump up, " })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
--yank that shit
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank to clipboard" })
--VSWho?
vim.keymap.set("n", "<leader>rs", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
--Buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<C-c>", ":lua MiniBufremove.delete()<cr>", { desc = "Delete Buffer" })
--Terminal Navigation
vim.keymap.set("t", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("t", "<C-j>", "<C-w>j", { desc = "Go to Left Window", remap = true })
vim.keymap.set("t", "<C-k>", "<C-w>k", { desc = "Go to Left Window", remap = true })
vim.keymap.set("t", "<C-l>", "<C-w>j", { desc = "Go to Left Window", remap = true })
