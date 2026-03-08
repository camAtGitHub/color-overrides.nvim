# color-overrides.nvim

Ever installed a beautiful colorscheme in Neovim, only to find that one annoying highlight group ruins it? Maybe the search highlight is blinding, the line numbers are impossible to read, or the git signs in the gutter look wrong. And then you switch colorschemes and have to fix it all over again.

**color-overrides.nvim** lets you declare "these highlight groups should always look like *this*" — and it keeps them that way, even after you switch themes.

### Requirements

Neovim **≥ 0.7**

---

### What's a highlight group?

In Neovim, every visual element — search results, line numbers, the cursor line, error indicators, comments — is styled by a named "highlight group". For example:

- `CursorLine` → the line your cursor is on
- `Search` → text that matches your search (`/foo`)
- `LineNr` → the line number column
- `Comment` → code comments
- `SignColumn` → the thin column on the left where git and diagnostic icons appear

Colorschemes set all of these. This plugin lets you override specific ones without touching the colorscheme itself.

---

### Installing

#### With [lazy.nvim](https://github.com/folke/lazy.nvim) (recommended)

```lua
{ "cwebster2/color-overrides.nvim" }
```

#### With [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'cwebster2/color-overrides.nvim'
```

#### With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'cwebster2/color-overrides.nvim'
```

---

### How to use it

Call `set_overrides` somewhere in your Neovim config (e.g. `init.lua`) **after** your colorscheme is set. Pass it a table of highlight group names and how you want them to look.

```lua
require('color-overrides').set_overrides({
  -- your overrides go here
})
```

That's it. The overrides apply immediately and will re-apply automatically every time you change colorscheme with `:colorscheme`.

---

### Common use cases

#### Make the cursor line more visible

The line your cursor is on can be hard to see in some themes. Pick a background colour that works for you:

```lua
require('color-overrides').set_overrides({
  CursorLine = { bg = '#2a2d3a', ctermbg = 236 },
})
```

> **Tip:** `bg` is for true-colour terminals (most modern terminals). `ctermbg` is a fallback number (0–255) for older terminals.

#### Fix search highlights that are too bright

Some themes use very intense colours for `/search` results. Tone it down:

```lua
require('color-overrides').set_overrides({
  Search    = { bg = '#3a5f3a', fg = '#ffffff' },
  IncSearch = { bg = '#5f875f', fg = '#ffffff', bold = true },
})
```

#### Remove the distracting background from the gutter

The "sign column" (left-side column with git/diagnostic icons) often inherits a different background colour. Setting it to `false` clears it entirely, making it transparent:

```lua
require('color-overrides').set_overrides({
  SignColumn = false,
})
```

#### Clean up git signs (if you use gitsigns.nvim or vim-gitgutter)

```lua
require('color-overrides').set_overrides({
  GitSignsAdd    = false,
  GitSignsChange = false,
  GitSignsDelete = false,
})
```

This clears the background behind the `+`, `~`, `-` icons so they don't clash with your theme.

#### Turn off underlines you don't want

Some plugins add underlines that you may not want — for example:

```lua
require('color-overrides').set_overrides({
  WhichKeyIcon = { underline = false },
})
```

#### Make a group inherit from another group (linking)

If you want `FloatBorder` to look the same as `Normal`, you can link it:

```lua
require('color-overrides').set_overrides({
  FloatBorder = { link = "Normal" },
})
```

#### Force an override that keeps getting overwritten by a plugin

Some plugins defensively set their highlight groups with `default = true`, which
means they're designed to only apply if nothing else has set them yet. If you
find your override keeps getting ignored no matter what you try, `force = true`
is the sledgehammer:
```lua
require('color-overrides').set_overrides({
  -- This will win even against groups protected with default = true
  DiagnosticError = { fg = '#ff5555', force = true },
  DiagnosticWarn  = { fg = '#ffaa00', force = true },
})
```

> **Note:** Only reach for `force` when a normal override isn't sticking. It
> bypasses Neovim's highlight protection intentionally, so use it selectively.

#### A more complete real-world example

```lua
require('color-overrides').set_overrides({
  -- Clear distracting backgrounds
  SignColumn     = false,
  GitSignsAdd    = false,
  GitSignsChange = false,
  GitSignsDelete = false,

  -- Tweak the cursor line
  CursorLine = { bg = '#414725', ctermbg = 233 },

  -- Softer search highlight
  Search = { bg = '#00efff' },

  -- Make leap.nvim labels pop
  LeapLabel  = { bold = true, ctermfg = 198, bg = '#00dfff', fg = '#ff007c' },
  HopNextKey = { bold = true, fg = '#ff007c', ctermfg = 198 },

  -- Remove an underline from which-key
  WhichKeyIcon = { underline = false },
})
```

---

### All supported attributes

| Attribute | What it does | Example value |
|---|---|---|
| `fg` | Foreground (text) colour | `'#ff0000'` or `'red'` |
| `bg` | Background colour | `'#1e1e2e'` |
| `ctermfg` | Foreground for terminal (256-colour number) | `198` |
| `ctermbg` | Background for terminal (256-colour number) | `233` |
| `bold` | Bold text | `true` or `false` |
| `italic` | Italic text | `true` or `false` |
| `underline` | Underline | `true` or `false` |
| `undercurl` | Wavy underline (used for spell/diagnostics) | `true` or `false` |
| `strikethrough` | Strikethrough text | `true` or `false` |
| `reverse` | Swap fg and bg colours | `true` or `false` |
| `link` | Inherit from another highlight group | `'Normal'` |
| `false` (the value itself) | Clear the group entirely | `GroupName = false` |

---

### How do I find out what a highlight group is called?

Move your cursor over any text and run:

```vim
:Inspect
```

Neovim will tell you exactly which highlight groups are active under your cursor. You can then override whichever one you want.

---

### Old calling style (still supported)

If you find configs using the older two-argument style, it still works:

```lua
local clear_these = { 'SignColumn', 'GitSignsAdd' }

local override_these = {
  CursorLine = { bg = '#414725', ctermbg = 233 },
}

require('color-overrides').set_overrides(clear_these, override_these)
```

The new single-table style is recommended for new configs as it's cleaner and supports all features.
