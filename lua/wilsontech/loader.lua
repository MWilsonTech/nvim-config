local MODULE_NAME = 'wilsontech';
local loader = {
  features = {}
};

local fallback_levels = {
  INFO = 1,
  WARN = 2,
  ERROR = 3
};
local log_levels = (vim and vim.log and vim.log.levels) or fallback_levels;

local function notify(message, level)
  if vim and vim.notify then
    vim.notify(message, level or log_levels.INFO, { title = MODULE_NAME });
  else
    -- fallback when running outside Neovim
    print(string.format('[%s] %s', MODULE_NAME, message));
  end
end

local function safeRequire(moduleName, optional, raise_on_error)
  local ok, result = pcall(require, moduleName);
  if not ok then
    local level = optional and log_levels.WARN or log_levels.ERROR;
    notify(string.format("Failed loading module '%s': %s", moduleName, result), level);

    if raise_on_error then
      error(result);
    end

    return nil;
  end

  return result;
end

local function requireModule(...)
  local parts = { ... };
  local moduleName = table.concat(parts, '.');

  return safeRequire(moduleName, false, true);
end

local function buildModulePath(dir, name)
  if dir and #dir > 0 then
    return table.concat({ MODULE_NAME, dir, name }, '.');
  end

  return table.concat({ MODULE_NAME, name }, '.');
end

local function deepcopy(tbl)
  if type(tbl) ~= 'table' then
    return tbl;
  end

  local copy = {};
  for k, v in pairs(tbl) do
    copy[k] = deepcopy(v);
  end

  return copy;
end

local function normalizeSpec(dir, entry)
  local entryType = type(entry);
  if entryType == 'string' then
    entry = { name = entry };
  elseif entryType == 'table' then
    entry = deepcopy(entry);
  else
    return nil;
  end

  entry.name = entry.name or entry[1];
  if type(entry.name) ~= 'string' then
    return nil;
  end

  local spec = {
    name = entry.name,
    as = entry.as,
    enabled = entry.enabled ~= false,
    optional = entry.optional or false,
    setup = entry.setup,
    opts = entry.opts,
    on_load = entry.on_load
  };

  spec.module = entry.module or buildModulePath(dir, spec.name);

  return spec;
end

local function callHook(hook, module, spec, hook_name)
  if type(hook) ~= 'function' then
    return;
  end

  local ok, err = pcall(hook, module, spec);
  if not ok then
    notify(string.format("Error running %s hook for '%s': %s", hook_name, spec.module, err), log_levels.ERROR);
  end
end

local function runSetup(spec, module)
  if not spec.setup then
    return;
  elseif type(spec.setup) == 'function' then
    callHook(spec.setup, module, spec, 'setup');
    return;
  elseif spec.setup == true and type(module) == 'table' then
    local setupFn = module.setup;
    if type(setupFn) == 'function' then
      local ok, err = pcall(setupFn, spec.opts);
      if not ok then
        notify(string.format("Error running setup() for '%s': %s", spec.module, err), log_levels.ERROR);
      end
    else
      notify(string.format("Module '%s' has no setup() function to call", spec.module), log_levels.WARN);
    end
  end
end

local function iterateSpecs(dir, entries, collect_results)
  local specs = {};
  for _, entry in ipairs(entries) do
    local spec = normalizeSpec(dir, entry);
    if spec and spec.enabled then
      table.insert(specs, spec);
    end
  end

  local results = collect_results and {} or nil;
  for _, spec in ipairs(specs) do
    local module = safeRequire(spec.module, spec.optional, false);
    if module then
      runSetup(spec, module);
      callHook(spec.on_load, module, spec, 'on_load');
      if results then
        results[spec.as or spec.name] = module;
      end
    end
  end

  return results;
end

-- Take name of folder and require ~/.config/nvim/lua/{pluginManager}/bootstrap.lua
function loader.usePluginManager(pluginManager)
  requireModule(pluginManager, 'bootstrap');
end

function loader.useFiles(dir, ...)
  iterateSpecs(dir, { ... }, false);
end

function loader.useHotkeyFiles(...)
  loader.useFiles('hotkeys', ...);
end

function loader.useOptionFiles(...)
  loader.useFiles('options', ...);
end

function loader.useFeatureModules(...)
  local loaded = iterateSpecs('features', { ... }, true) or {};
  for name, module in pairs(loaded) do
    loader.features[name] = module;
  end

  return loaded;
end

function loader.getFeature(name)
  return loader.features[name];
end

return loader;

