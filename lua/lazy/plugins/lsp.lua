---@module 'lazy'
---@type LazySpec
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
    {
      'folke/lazydev.nvim',
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } }
        }
      }
    }
  },
  opts = {
    servers = {
      -- brew install llvm
      clangd = {},
      -- brew install lua-language-server
      -- https://luals.github.io/wiki/build/
      lua_ls = {},
      -- npm install -g typescript-language-server
      ts_ls = {},
      -- pip install -U nginx-language-server
      nginx_language_server = {},
      -- go install golang.org/x/tools/gopls@latest
      gopls = {},
      -- npm install -g yaml-language-server
      yamlls = {},
      -- npm install -g vscode-langservers-extracted
      jsonls = {},
      -- Install rust toolchain: https://rustup.rs/
      -- curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      -- cargo install systemd-lsp
      systemd_ls = {
        cmd = { 'systemd-lsp' },
        filetypes = { 'systemd' },
        root_markers = { '.git' }
      }
    }
  },
  config = function(_, opts)
    for server, config in pairs(opts.servers) do
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      vim.lsp.config(server, config);
      vim.lsp.enable(server);
    end
  end
}

