local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim';
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local success, error = pcall(vim.fn.system, {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable', -- clone the latest stable lazy.nvim release from GitHub
    'https://github.com/folke/lazy.nvim.git',
    lazypath
  });

  if not success then
    vim.notify('Failed to clone lazy.nvim. Reason: ' .. error, vim.log.levels.ERROR, { title = "lazy" });
    return;
  end
end
vim.opt.rtp:prepend(lazypath);

require('lazy').setup('lazy.plugins', require('lazy.options'));

