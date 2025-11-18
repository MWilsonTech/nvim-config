---@module 'lazy'
---@type LazySpec
return {
  'saghen/blink.cmp',
  version = '1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'default' },
    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },
    completion = {
      documentation = {
        auto_show = true
      },
      list = {
        selection = {
          auto_insert = false
        }
      },
      accept = {
        auto_brackets = {
          enabled = false
        }
      },
      menu = {
        auto_show = true
      }
    },
    -- Show parameters from docs to actively reference (`(` and `,` are triggers)
    signature = {
      enabled = true,
      trigger = {
        show_on_keyword = true
      }
    },
  }
}

