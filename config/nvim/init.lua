require "settings"
require "keybinds"

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
