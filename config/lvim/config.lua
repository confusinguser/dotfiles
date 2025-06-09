-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.keys.normal_mode["j"] = "h"
lvim.keys.normal_mode["k"] = "gj"
lvim.keys.normal_mode["l"] = "gk"
lvim.keys.normal_mode["ö"] = "l"
lvim.keys.visual_mode["j"] = "h"
lvim.keys.visual_mode["k"] = "gj"
lvim.keys.visual_mode["l"] = "gk"
lvim.keys.visual_mode["ö"] = "l"

vim.api.nvim_set_keymap("n", "<C-Tab>", "<cmd>BufferLineCycleNext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w>", "<cmd>BufferKill<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>tabNew<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-j>", "<cmd>winc h<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>winc j<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<cmd>winc k<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-ö>", "<cmd>winc l<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-S-v>", "<C-v>", { noremap = true, silent = true })

lvim.lsp.buffer_mappings.normal_mode['K'] = { vim.lsp.buf.hover, "Show documentation" }
lvim.lsp.buffer_mappings.normal_mode['<F6>'] = { vim.lsp.buf.rename, "Rename" }
lvim.builtin.which_key.mappings['rc'] = { vim.lsp.buf.incoming_calls, "Incoming Calls" }

vim.keymap.set("n", "<M-d>", function() vim.diagnostic.open_float(nil, { focusable = false }) end)

-- Stop cursor from wrapping on navigation keys
vim.opt.whichwrap = "b,s"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.api.nvim_set_option('updatetime', 1000)

-- use treesitter folding
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- require 'nvim-treesitter.configs'.setup {
--   ensure_installed = { "svelte", "typescript", "ron", "wgsl", "wgsl_bevy", "javascript", "css", "rust", "lua" },
--   auto_install = true,
--   highlight = { enable = true },
-- }

lvim.format_on_save = true
--vim.api.nvim_create_autocmd({"BufWritePre"}, {
--  pattern = {"*.rs"},
--  callback = function()
--    vim.lsp.buf.format()
--  end,
--})

local fast_event_aware_notify = function(msg, level, opts)
  if vim.in_fast_event() then
    vim.schedule(function()
      vim.notify(msg, level, opts)
    end)
  else
    vim.notify(msg, level, opts)
  end
end

local info = function(msg)
  fast_event_aware_notify(msg, vim.log.levels.INFO, {})
end

local warn = function(msg)
  fast_event_aware_notify(msg, vim.log.levels.WARN, {})
end

local err = function(msg)
  fast_event_aware_notify(msg, vim.log.levels.ERROR, {})
end

local sudo_exec = function(cmd, print_output)
  vim.fn.inputsave()
  local password = vim.fn.inputsecret("Password: ")
  vim.fn.inputrestore()
  if not password or #password == 0 then
    warn("Invalid password, sudo aborted")
    return false
  end
  local out = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    print("\r\n")
    err(out)
    return false
  end
  if print_output then print("\r\n", out) end
  return true
end

local sudo_write = function(tmpfile, filepath)
  if not tmpfile then tmpfile = vim.fn.tempname() end
  if not filepath then filepath = vim.fn.expand("%") end
  if not filepath or #filepath == 0 then
    err("E32: No file name")
    return
  end
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  local cmd = string.format("dd if=%s of=%s bs=1048576",
    vim.fn.shellescape(tmpfile),
    vim.fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
  if sudo_exec(cmd) then
    info(string.format([[\r\n"%s" written]], filepath))
    vim.cmd("e!")
  end
  vim.fn.delete(tmpfile)
end

vim.api.nvim_create_user_command("Sw", function()
  sudo_write(nil, nil);
end, {})

sudo_exec = function(cmd, print_output)
  vim.fn.inputsave()
  local password = vim.fn.inputsecret("Password: ")
  vim.fn.inputrestore()
  if not password or #password == 0 then
    warn("Invalid password, sudo aborted")
    return false
  end
  local out = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    print("\r\n")
    err(out)
    return false
  end
  if print_output then print("\r\n", out) end
  return true
end

sudo_write = function(tmpfile, filepath)
  if not tmpfile then tmpfile = vim.fn.tempname() end
  if not filepath then filepath = vim.fn.expand("%") end
  if not filepath or #filepath == 0 then
    err("E32: No file name")
    return
  end
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  local cmd = string.format("dd if=%s of=%s bs=1048576",
    vim.fn.shellescape(tmpfile),
    vim.fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
  if sudo_exec(cmd) then
    info(string.format([[\r\n"%s" written]], filepath))
    vim.cmd("e!")
  end
  vim.fn.delete(tmpfile)
end

vim.api.nvim_create_user_command("Sw", function()
  sudo_write(nil, nil);
end, {})
