---@module 'lazy'
---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      modules = {},
      -- list of parsers
      ignore_install = {},
      -- parsers expected to be used
      ensure_installed = {
        -- required by nvim-treesitter
        'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline',
        -- other
        'javascript', 'typescript', 'bash', 'nginx', 'json', 'ini',
        'c_sharp', 'cpp', 'css', 'csv', 'diff', 'dockerfile', 'gitignore',
        'go', 'gomod', 'gosum', 'html', 'make', 'pem', 'powershell',
        'robots', 'scss', 'sql', 'ssh_config', 'tsx', 'xml', 'yaml'
      },
      -- automatically install missing parsers when entering buffer
      auto_install = true,
      -- whether or not to install parsers synchronously
      sync_install = false,
      -- syntax highlighting
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
      }
    });
  end
}

