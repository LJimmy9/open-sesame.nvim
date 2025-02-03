## ✨ Introduction 

`open-sesame.nvim` is a Neovim plugin that tries to open things! 

> [!WARNING]
> This is designed for my use cases, the implementation may be fragile. Feedback is appreciated!
> For basic usage, the defaults builtin to vim may suffice. Check out [alternatives](#👀-alternatives)

## 🖥️ Showcase
Add screencap here

## 📋 Features

Works on most kinds of error outputs and generic text with paths in it like:

- ./CUSTOMIZATION.md:3:5 *Works with row and column numbers*
- ./lua/ *Works with directories*
- https://github.com/ljimmy9/open-sesame.nvim/ *Works with URLs*

Multiple selections of either paths or URLs are supported. *Each selection will be open
in a new tab. Navigate with `gt` and `gT`*

## ⚡️ Requirements

- Neovim version >= 0.10.0

## 🔨 Installation

[lazy](https://github.com/folke/lazy.nvim):

```lua
return {
  "ljimmy9/open-sesame.nvim",
  config = function()
    local open_sesame = require('open-sesame')
    vim.keymap.set({ "n", "v" }, "<leader>gd", open_sesame.selection_to_path, { noremap = true })
  end
}
```

## 📜 Customization

See [CUSTOMIZATION.md](https://github.com/ljimmy9/open-sesame.nvim/CUSTOMIZATION.md)

## 👀 Alternatives

Builtin 
- `gx` opens a URL
- `gf` opens a file
- `CTRL-W gf` Opens the file under the cursor in a new tab. This is particularly useful when you want to navigate to a file but keep your current context in another tab.
- `CTRL-W CTRL-F` This does essentially the same thing as gf but splits the window horizontally and opens the file in the new window at the bottom.
- `CTRL-W f` This is similar to CTRL-W CTRL-F but opens the file in a split window to the right.


## 🙏 I made this originally for use with

- [compile-mode.nvim](https://github.com/ej-shafran/compile-mode.nvim)
