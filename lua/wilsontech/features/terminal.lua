local terminal = {};

terminal.defaults = {
  layout = {
    relative = 'editor',
    width = 0.8,
    height = 0.8,
    row = 0.1,
    col = 0.1,
    style = 'minimal',
    border = 'rounded',
    zindex = 100,
  },
  close_others = true,
  on_open = nil,
  on_close = nil,
};

local registry = {};
terminal._registry = registry;

local function deepcopy(value)
  if type(value) ~= 'table' then
    return value;
  elseif vim and vim.deepcopy then
    return vim.deepcopy(value);
  end

  local copy = {};
  for k, v in pairs(value) do
    copy[k] = deepcopy(v);
  end

  return copy;
end

local function mergeOptions(base, overrides)
  if type(overrides) ~= 'table' or next(overrides) == nil then
    return deepcopy(base);
  elseif vim and vim.tbl_deep_extend then
    return vim.tbl_deep_extend('force', deepcopy(base), overrides);
  end

  local merged = deepcopy(base);
  for k, v in pairs(overrides) do
    if type(v) == 'table' and type(merged[k]) == 'table' then
      merged[k] = mergeOptions(merged[k], v);
    else
      merged[k] = deepcopy(v);
    end
  end

  return merged;
end

local function resolveDimension(value, maxValue, fallback)
  local number = fallback;
  if type(value) == 'number' then
    number = value;
  elseif type(value) == 'function' then
    local ok, result = pcall(value, maxValue);
    if ok then
      number = result;
    end
  end

  if type(number) ~= 'number' then
    number = fallback;
  end

  if number > 0 and number < 1 then
    return math.max(1, math.floor(maxValue * number));
  end

  return math.max(1, math.floor(number));
end

local function resolvePosition(value, maxValue, fallback)
  local number = fallback;
  if type(value) == 'number' then
    number = value;
  elseif type(value) == 'function' then
    local ok, result = pcall(value, maxValue);
    if ok then
      number = result;
    end
  end

  if type(number) ~= 'number' then
    number = fallback;
  end

  if number >= 0 and number <= 1 then
    return math.floor(maxValue * number);
  end

  return math.floor(number);
end

local function buildWindowConfig(id, opts)
  local layout = opts.layout or {};
  return {
    title = id,
    relative = layout.relative or terminal.defaults.layout.relative,
    width = resolveDimension(layout.width, vim.o.columns, terminal.defaults.layout.width),
    height = resolveDimension(layout.height, vim.o.lines, terminal.defaults.layout.height),
    row = resolvePosition(layout.row, vim.o.lines, terminal.defaults.layout.row),
    col = resolvePosition(layout.col, vim.o.columns, terminal.defaults.layout.col),
    style = layout.style or terminal.defaults.layout.style,
    border = layout.border or terminal.defaults.layout.border,
    zindex = layout.zindex or terminal.defaults.layout.zindex,
  };
end

local function validateState(state)
  if state.buf and not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = nil;
  end

  if state.win and not vim.api.nvim_win_is_valid(state.win) then
    state.win = nil;
  end
end

local function closeWindow(state)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true);
    state.win = nil;
  end
end

local function fireHook(handler, entry)
  if type(handler) ~= 'function' then
    return;
  end

  local ok, err = pcall(handler, entry);
  if not ok and vim and vim.notify then
    local level = (vim.log and vim.log.levels and vim.log.levels.ERROR) or 3;
    vim.notify(string.format('Error in terminal hook for %s: %s', entry.id, err), level, { title = 'wilsontech' });
  end
end

local function ensureEntry(id, opts)
  id = id or 'primary';

  local entry = registry[id];
  if not entry then
    entry = {
      id = id,
      opts = mergeOptions(terminal.defaults, opts),
      state = { buf = nil, win = nil, was_insert = true },
    };
    registry[id] = entry;
  elseif opts then
    entry.opts = mergeOptions(entry.opts, opts);
  end

  return entry;
end

local function closeOtherTerminals(current)
  if current.opts.close_others == false then
    return;
  end

  for id, entry in pairs(registry) do
    if id ~= current.id then
      validateState(entry.state);

      local was_open = entry.state.win ~= nil;
      closeWindow(entry.state);
      if was_open then
        fireHook(entry.opts.on_close, entry);
      end
    end
  end
end

local function openTerminal(entry)
  local state = entry.state;
  if not state.buf then
    vim.cmd('split | terminal');

    state.buf = vim.api.nvim_get_current_buf();
    local win = vim.api.nvim_get_current_win();
    vim.api.nvim_win_close(win, true);
  end

  state.win = vim.api.nvim_open_win(state.buf, true, buildWindowConfig(entry.id, entry.opts));
  fireHook(entry.opts.on_open, entry);

  if state.was_insert then
    vim.cmd('startinsert');
  end
end

local function toggleEntry(entry)
  local state = entry.state;
  validateState(state);

  if state.win then
    local ok, mode = pcall(vim.api.nvim_get_mode);
    if ok and mode and mode.mode == 't' then
      state.was_insert = true;
    else
      state.was_insert = false;
    end

    closeWindow(state);
    fireHook(entry.opts.on_close, entry);
    return;
  end

  closeOtherTerminals(entry);
  openTerminal(entry);
end

function terminal.get_toggle(id, opts)
  local entry = ensureEntry(id, opts);
  if not entry.toggle then
    entry.toggle = function()
      toggleEntry(entry);
    end;
  end

  return entry.toggle;
end

function terminal.toggle(id, opts)
  local handler = terminal.get_toggle(id, opts);
  handler();
end

function terminal.is_open(id)
  local entry = registry[id];
  if not entry then
    return false;
  end

  validateState(entry.state);
  return entry.state.win ~= nil;
end

function terminal.close_all()
  for _, entry in pairs(registry) do
    validateState(entry.state);

    local was_open = entry.state.win ~= nil;
    closeWindow(entry.state);
    if was_open then
      fireHook(entry.opts.on_close, entry);
    end
  end
end

function terminal.setup(opts)
  if not opts then
    return;
  end

  terminal.defaults = mergeOptions(terminal.defaults, opts);
  for _, entry in pairs(registry) do
    entry.opts = mergeOptions(entry.opts, opts);
  end
end

return terminal;

