-- terminal has Nerd Font
vim.g.have_nerd_font = true;

-- disable cursor styling
vim.opt.guicursor = '';

-- precede each line with its line number
vim.opt.nu = true;
-- show the line number relative to the line with the cursor 
vim.opt.relativenumber = true;

-- highlight search matches
vim.opt.hlsearch = true;
vim.opt.incsearch = true;

-- preview substitutions as its typed
vim.opt.inccommand = 'split';

-- case-insensitive searching unless \C or one or search term has n+1 capital letters
vim.opt.ignorecase = true;
--vim.opt.smartcase = true;

-- minimal number of screen lines to keep above and below the cursor
vim.opt.scrolloff = 10;

-- use a mix of tabs and spaces
-- typing <Tab> and <BS> will behave like a tab appears every 2 characters
vim.opt.tabstop = 2;
vim.opt.softtabstop = 2;
vim.opt.shiftwidth = 2;
vim.opt.expandtab = true;

-- only show mode in the status line
vim.opt.showmode = false;

-- show confirmation instead of failure when closing unsaved buffers
vim.opt.confirm = true;

-- sync clipboard between OS and Neovim
-- determine environment
local is_ssh = vim.env.SSH_TTY ~= nil
local clip_path = '/mnt/c/Windows/System32/clip.exe'
local is_wsl = vim.fn.has('wsl') == 1 or vim.env.WSL_DISTRO_NAME ~= nil
local has_clip = vim.fn.executable(clip_path) == 1
if is_wsl and has_clip then
  local powershell_paste = {
     '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
    '-NoLogo',
    '-NoProfile',
    '-NonInteractive',
    '-Command',
    '[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); ' ..
    '$t = Get-Clipboard -Raw; ' ..
    '$t = $t -replace "`r",""; ' ..
    '[Console]::Out.Write($t)'
  }

  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = { ['+'] = clip_path, ['*'] = clip_path },
    paste = { ['+'] = powershell_paste, ['*'] = powershell_paste },
    cache_enabled = 0,
  }
elseif is_ssh then
  -- OSC-52 clipboard for SSH
  vim.g.clipboard = 'osc52'
end

-- Set the clipboard option to unnamedplus
vim.opt.clipboard = 'unnamedplus'

-- visually indent wrapped lines by the same amount of space as the beginning of that line
vim.opt.breakindent = true;

-- display vertical column to the left showing feedback from linters, git, debuggers
vim.opt.signcolumn = 'yes';

-- save undo history
vim.opt.undofile = true;

-- show tabs as '>', trailing spaces as '.' and non-breakable space chars as '_'
vim.opt.list = true;
vim.opt.listchars = {
    tab = '> ',
    trail = '.',
    nbsp = '_'
};

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.opt.foldcolumn = "0"
vim.opt.fillchars:append({fold = " "})

-- prefer LSP folding if client supports it
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id);
    if client ~= nil and client:supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win();
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()';
    end
  end
});

