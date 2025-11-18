---@module 'lazy'
---@type LazySpec
return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/oil.nvim'
  },
  keys = {
    { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
    { '<leader>fs', '<cmd>Telescope live_grep<cr>', desc = 'Search current directory for a regex pattern' },
    { '<leader>vh', '<cmd>Telescope help_tags<cr>', desc = 'View Help Tags' },
    { '<C-p>', function()
      require('telescope.builtin').registers();
    end, mode = 'i', desc = 'Paste register in insert mode' }
  },
  config = function()
    local telescope = require('telescope');
    telescope.setup({
      defaults = {
        file_ignore_patterns = { 'node_modules/', '%.git', '%.next/' }
      },
      pickers = {
        live_grep = {
          file_ignore_patterns = { 'package%-lock%.json' },
          additional_args = {
            '-u',
            '--hidden',
            '--glob=!node_modules/*',
            '--glob=!.git/*',
            '--glob=!.next/*'
          }
        },
        find_files = {
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true
        }
      }
    });
  end,
  cmd = 'Telescope'
}

