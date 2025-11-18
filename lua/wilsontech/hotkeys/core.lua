vim.g.mapleader = ' ';
vim.g.maplocalleader = ' ';

-- clear highlights on search in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>');

-- force quit all
vim.keymap.set('n', '<leader>pq', '<CMD>quitall!<cr>');

-- navigation
vim.keymap.set('n', '<C-d>', 'zz<C-d>');
vim.keymap.set('n', '<C-u>', 'zz<C-u>');

-- quickfix
vim.keymap.set('n', '<M-n>', '<CMD>cnext<cr>');
vim.keymap.set('n', '<M-p>', '<CMD>cprev<cr>');

-- diagnostic
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float);

-- floating terminal toggle hotkeys in both normal and terminal modes
local terminal = require('wilsontech.features.terminal');
local primary_terminal = terminal.get_toggle('terminal');
local secondary_terminal = terminal.get_toggle('secondary');
vim.keymap.set({ 'n', 't' }, '<C-t>', primary_terminal, { desc = 'Toggle float terminal' });
vim.keymap.set({ 'n', 't' }, '<C-0>', secondary_terminal, { desc = 'Toggle float terminal' });

