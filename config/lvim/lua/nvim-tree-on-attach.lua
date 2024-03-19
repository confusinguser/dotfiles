--
-- This function has been generated from your
--   view.mappings.list
--   view.mappings.custom_only
--   remove_keymaps
--
-- You should add this function to your configuration and set on_attach = on_attach in the nvim-tree setup call.
--
-- Although care was taken to ensure correctness and completeness, your review is required.
--
-- Please check for the following issues in auto generated content:
--   "Mappings removed" is as you expect
--   "Mappings migrated" are correct
--
-- Please see https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach for assistance in migrating.
--
local M = {}
function M.on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end


  -- Default mappings. Feel free to modify or remove as you wish.
  --
  -- BEGIN_DEFAULT_ON_ATTACH
  vim.keymap.set('', '<C-]>', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
  vim.keymap.set('', '<C-k>', api.node.show_info_popup, opts('Info'))
  vim.keymap.set('', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
  vim.keymap.set('', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
  vim.keymap.set('', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
  vim.keymap.set('', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
  vim.keymap.set('', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
  vim.keymap.set('', '<CR>', api.node.open.edit, opts('Open'))
  vim.keymap.set('', 'ö', api.node.open.edit, opts('Open'))
  vim.keymap.set('', '<Tab>', api.node.open.preview, opts('Open Preview'))
  vim.keymap.set('', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
  vim.keymap.set('', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  vim.keymap.set('', '.', api.node.run.cmd, opts('Run Command'))
  vim.keymap.set('', '-', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('', 'j', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('', 'a', api.fs.create, opts('Create'))
  vim.keymap.set('', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
  vim.keymap.set('', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle No Buffer'))
  vim.keymap.set('', 'c', api.fs.copy.node, opts('Copy'))
  vim.keymap.set('', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Git Clean'))
  vim.keymap.set('', '[c', api.node.navigate.git.prev, opts('Prev Git'))
  vim.keymap.set('', ']c', api.node.navigate.git.next, opts('Next Git'))
  vim.keymap.set('', 'd', api.fs.remove, opts('Delete'))
  vim.keymap.set('', 'D', api.fs.trash, opts('Trash'))
  vim.keymap.set('', 'E', api.tree.expand_all, opts('Expand All'))
  vim.keymap.set('', 'e', api.fs.rename_basename, opts('Rename: Basename'))
  vim.keymap.set('', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
  vim.keymap.set('', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
  vim.keymap.set('', 'F', api.live_filter.clear, opts('Clean Filter'))
  vim.keymap.set('', 'f', api.live_filter.start, opts('Filter'))
  vim.keymap.set('', 'g?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
  vim.keymap.set('', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
  vim.keymap.set('', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
  vim.keymap.set('', 'K', api.node.navigate.sibling.last, opts('Last Sibling'))
  vim.keymap.set('', 'L', api.node.navigate.sibling.first, opts('First Sibling'))
  vim.keymap.set('', 'm', api.marks.toggle, opts('Toggle Bookmark'))
  vim.keymap.set('', 'o', api.node.open.edit, opts('Open'))
  vim.keymap.set('', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
  vim.keymap.set('', 'p', api.fs.paste, opts('Paste'))
  vim.keymap.set('', 'P', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.set('', 'q', api.tree.close, opts('Close'))
  vim.keymap.set('', 'r', api.fs.rename, opts('Rename'))
  vim.keymap.set('', 'R', api.tree.reload, opts('Refresh'))
  vim.keymap.set('', 's', api.node.run.system, opts('Run System'))
  vim.keymap.set('', 'S', api.tree.search_node, opts('Search'))
  vim.keymap.set('', 'U', api.tree.toggle_custom_filter, opts('Toggle Hidden'))
  vim.keymap.set('', 'W', api.tree.collapse_all, opts('Collapse'))
  vim.keymap.set('', 'x', api.fs.cut, opts('Cut'))
  vim.keymap.set('', 'y', api.fs.copy.filename, opts('Copy Name'))
  vim.keymap.set('', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
  vim.keymap.set('', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
  vim.keymap.set('', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
end

return M
