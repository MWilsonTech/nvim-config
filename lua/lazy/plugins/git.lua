---@module 'lazy'
---@type LazySpec
return {
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        current_line_blame = true
      });
    end
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg', '<cmd>G<cr><cmd>on<cr>', desc = 'Open git window' }
    }
  },
  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    config = function()
      require('oil-git-status').setup({
        show_ignored = false
      });
    end
  }
}

