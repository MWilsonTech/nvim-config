local loader = require('wilsontech.loader');
local config_sets = { 'core', 'testing' };

local success, error = pcall(function()
    -- load hotkey configurations
    loader.useHotkeyFiles(unpack(config_sets));

    -- load option configurations
    loader.useOptionFiles(unpack(config_sets));

    -- load feature modules
    loader.useFeatureModules({ 'terminal', enabled = not vim.g.vscode });

    -- initialize plugin manager
    if not vim.g.vscode then
        loader.usePluginManager('lazy');
    end
end)

if not success then
    vim.notify('Error during initialization: ' .. error, vim.log.levels.ERROR, { title = "wilsontech" });
end

