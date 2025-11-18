---@module 'lazy'
---@type LazySpec
return {
  -- this plugin automatically adjusts 'shiftwidth' and 'expandtab' heuristically based on the current file, or, in the case the current file is new, blank, or otherwise insufficient, by looking at other files of the same type in the current and parent directories
  'tpope/vim-sleuth',
  {
    'stevearc/quicker.nvim',
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
    config = function()
      local quicker = require('quicker');
      quicker.setup({
        edit = {
          enabled = true,
          autosave = true
        },
        keys = {
          { '>', function() quicker.expand({ before = 2, after = 2, add_to_existing = true }) end, desc = 'Expand quickfix context' },
          { '<', function() quicker.collapse(); end, desc = 'Collapse quickfix context' }
        }
      });
    end,
    keys = {
      { '<leader>q', function() require('quicker').toggle() end, desc = 'Toggle quickfix' },
      { '<leader>l', function() require('quicker').toggle({ loclist = true }); end, desc = 'Toggle loclist' }
    }
  },
  {
    'tzachar/local-highlight.nvim',
    config = function()
      require('local-highlight').setup({
        file_types = nil,
        animate = {
          enabled = false
        }
      });
    end
  }
}

