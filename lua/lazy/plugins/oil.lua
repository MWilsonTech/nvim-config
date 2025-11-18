---@module 'lazy'
---@type LazySpec
return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
      natural_order = true
    },
    win_options = {
      signcolumn = 'yes:2'
    },
    float = {
      preview_split = 'auto',
      padding = 0,
      max_height = 0.6,
      max_width = 0.5
    }
  },
  dependencies = {
    { 'echasnovski/mini.icons', opts = {} }
  },
  -- lazy loading here should remain disabled based on author's recommendation
  lazy = false,
  keys = {
    { '-', '<CMD>Oil --float<CR>', desc = 'Open parent directory' }
  }
}

