-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.plugins = {
  { "simrat39/rust-tools.nvim" },
  {
    "saecki/crates.nvim",
    version = "v0.3.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup {
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
        popup = {
          border = "rounded",
        },
      }
    end,
  },
}


lvim.keys.normal_mode["j"] = "h"
lvim.keys.normal_mode["k"] = "gj"
lvim.keys.normal_mode["l"] = "gk"
lvim.keys.normal_mode["ö"] = "l"
lvim.keys.visual_mode["j"] = "h"
lvim.keys.visual_mode["k"] = "gj"
lvim.keys.visual_mode["l"] = "gk"
lvim.keys.visual_mode["ö"] = "l"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.api.nvim_set_keymap("n", "<C-Tab>", "<cmd>BufferLineCycleNext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w>", "<cmd>BufferKill<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-j>", "<cmd>winc h<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>winc j<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<cmd>winc k<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-ö>", "<cmd>winc l<CR>", { noremap = true, silent = true })

local dap = require 'dap'
local dapui = require 'dapui'
vim.keymap.set("n", "<F1>", dap.step_over)
vim.keymap.set("n", "<F2>", dap.step_into)
vim.keymap.set("n", "<F7>", dap.continue)
vim.keymap.set("n", "<F8>", dap.toggle_breakpoint)
vim.keymap.set("n", "<F12>", function()
  dap.disconnect()
  dapui.close()
end)


local api = require("nvim-tree.api")
api.events.subscribe(api.events.Event.TreeAttachedPost, function(bufnr)
  vim.keymap.set("n", "l", "k", { buffer = bufnr, noremap = true, silent = true, nowait = true })
  vim.keymap.set("n", "ö", api.node.open.edit, { buffer = bufnr, noremap = true, silent = true, nowait = true })
end)

lvim.lsp.buffer_mappings.normal_mode['K'] = { vim.lsp.buf.hover, "Show documentation" }
lvim.lsp.buffer_mappings.normal_mode['<F6>'] = { vim.lsp.buf.rename, "Rename" }
lvim.builtin.which_key.mappings['rc'] = { vim.lsp.buf.incoming_calls, "Incoming Calls" }

local telescope = require('telescope.builtin')
lvim.builtin.which_key.mappings['td'] = { telescope.diagnostics, "Diagnostics" }

vim.keymap.set("n", "<M-d>", function() vim.diagnostic.open_float(nil, { focusable = false }) end)

-- Stop cursor continuing on next line
vim.opt.whichwrap:remove({ "h", "l" })
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.wrap = true
vim.opt.linebreak = true
vim.api.nvim_set_option('updatetime', 300)

-- use treesitter folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "svelte", "typescript", "ron", "wgsl", "wgsl_bevy", "javascript", "css", "rust", "lua" },
  auto_install = true,
  highlight = { enable = true },
}

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      extra_args = { "--no-semi", "--tab-width", "4", "--prose-wrap", "always", "--bracket-same-line", "true" }
    }),
    -- null_ls.builtins.completion.spell,
    null_ls.builtins.diagnostics.fish,
    -- null_ls.builtins.diagnostics.php,
    null_ls.builtins.formatting.fish_indent,
    null_ls.builtins.hover.dictionary,
  },
})
lvim.format_on_save = true
--vim.api.nvim_create_autocmd({"BufWritePre"}, {
--  pattern = {"*.rs"},
--  callback = function()
--    vim.lsp.buf.format()
--  end,
--})

local rt = require("rust-tools")

rt.setup({
  capabilities = require("lvim.lsp").common_capabilities(),
  tools = {
    executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
    reload_workspace_from_cargo_toml = true,
    runnables = {
      use_telescope = true,
    },
    inlay_hints = {
      auto = true,
      only_current_line = false,
      show_parameter_hints = false,
      parameter_hints_prefix = "<-",
      other_hints_prefix = "=>",
      max_len_align = false,
      max_len_align_padding = 1,
      right_align = false,
      right_align_padding = 7,
      highlight = "Comment",
    },
    hover_actions = {
      border = "rounded",
    },
    on_initialized = function()
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
        pattern = { "*.rs" },
        callback = function()
          local _, _ = pcall(vim.lsp.codelens.refresh)
        end,
      })
    end,
  },
  server = {
    on_attach = function(client, bufnr)
      require("lvim.lsp").common_on_attach(client, bufnr)
      -- Hover actions
      vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<M-CR>", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
    settings = {
      ["rust-analyzer"] = {
        check = { command = "clippy" },
        cargo = { features = "all" },
        imports = { prefix = "self", granularity = { group = "module", enforce = true } },
        assist = { emitMustUse = true },
        lens = { location = "above_whole_item" },
        semanticHighlighting = {
          operator = { specialization = { enable = true } },
          puncutation = {
            enable = true,
            specialization = { enable = true },
            separate = { macro = { bang = true } }
          }
        },
      }
    }
  },
  dap = {
    adapter = {
      type = "executable",
      command = "lldb-vscode",
      name = "rt_lldb",
    },
  },
})
rt.inlay_hints.enable()
