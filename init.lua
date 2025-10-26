-- === Path to lazy.nvim ===
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- === Plugins ===
require("lazy").setup({
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-buffer",
  "nvim-lualine/lualine.nvim",
  "kyazdani42/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons", -- devicons для красивых иконок
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│", tab_char = "│" },
        scope = { enabled = true, char = "│", show_start = true, show_end = true },
        exclude = { filetypes = { "help","alpha","dashboard","neo-tree","Trouble","lazy","mason","notify","toggleterm","lazyterm" } },
      })
    end,
  },
  "windwp/nvim-autopairs",
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = { cpp = { "clang_format" }, c = { "clang_format" } },
        format_on_save = { timeout_ms = 500, lsp_fallback = true, quiet = true },
      })
    end,
  },
  {
    "Exafunction/codeium.vim",
    lazy = false,
    config = function()
      vim.g.codeium_disable_bindings = 1
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        direction = "horizontal",
        start_in_insert = true,
        persist_size = true,
      })
    end,
  },
})

-- === General settings ===
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.termguicolors = true

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#000000" })
  end,
})

-- === nvim-cmp setup ===
local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback) fallback() end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback) fallback() end, { "i", "s" }),
    ["<Down>"] = cmp.mapping.select_next_item(),
    ["<Up>"] = cmp.mapping.select_prev_item(),
  },
  sources = { { name = "nvim_lsp" }, { name = "buffer" }, { name = "path" } },
})

-- === LSP setup ===
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
lspconfig.clangd.setup({ capabilities = capabilities })

vim.api.nvim_set_keymap("n", "<Leader>f", "<cmd>lua require('conform').format()<CR>", { noremap = true, silent = true })

-- === nvim-tree setup with icons ===
require("nvim-tree").setup({
  renderer = {
    icons = {
      show = { file = true, folder = true, folder_arrow = true },
    },
  },
  view = {
    side = "left",
    width = 30,
    preserve_window_proportions = true,
  },
  actions = {
    open_file = { quit_on_open = false, window_picker = { enable = true } },
  },
})
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.cmd("autocmd VimEnter * NvimTreeOpen")
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.bo.filetype == "NvimTree" then
      vim.cmd("quit")
    end
  end,
})

-- === Status line ===
require("lualine").setup({ options = { theme = "gruvbox" } })

-- === Auto pairs ===
require("nvim-autopairs").setup()

-- === ToggleTerm and compile/run C++ ===
local Terminal = require("toggleterm.terminal").Terminal
local compile_run = Terminal:new({
  cmd = [[bash -c 'cmake -S . -B build && cmake --build build && ./build/app; printf "\n"; read -r -p "Press Enter to exit..." < /dev/tty']],
  hidden = true,
  direction = "horizontal",
  on_open = function() vim.cmd("startinsert!") end,
})
function _G.ToggleCompileRun()
  local ft = vim.bo.filetype
  if ft == "cpp" then
    vim.cmd("silent! w")
    vim.defer_fn(function() compile_run:toggle() end, 100)
  else
    print("Unknown filetype for build/run: " .. ft)
  end
end
vim.api.nvim_set_keymap("n", "<F5>", "<cmd>lua ToggleCompileRun()<CR>", { noremap = true, silent = true })

-- === Splits ===
vim.api.nvim_set_keymap("n", "<Leader>v", ":vsplit<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>s", ":split<CR>", { noremap = true, silent = true })

-- === Window navigation ===
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })

-- === Codeium accept suggestion (Ctrl+l) ===
function _G.CodeiumAccept()
  if vim.fn["codeium#Accept"]() ~= "" then
    return vim.fn["codeium#Accept"]()
  else
    return "<Tab>"
  end
end
vim.api.nvim_set_keymap("i", "<C-l>", 'v:lua.CodeiumAccept()', { expr = true, silent = true })

