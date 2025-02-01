## Introduction 

`open-sesame.nvim` is a Neovim plugin that tries to open things! 

> [!WARNING]
> This is designed for my use cases, the implementation is simple and
> may be fragile. Feedback is appreciated!

## Features

Works on most kinds of error outputs and generic text with paths in it.
Added support for row and column numbers.
Will support multiple files + urls

Add screencap here

## Overview

A `destination` is any string input.

A `scanner` is a function that takes a `destination` and returns `phrases`.

A `door` is a function that operates with `phrases`.

A `portal` stores `scanner(s)` with a `door`

## Installation

### Lazy

```lua
return {
  "ljimmy9/open-sesame.nvim",
  config = function()
    local open_sesame = require('open-sesame')
    open_sesame.setup({
      something_new = {
        scanners = {
          --- list of functions that takes a string and returns a `@class OpenSesame.Phrase[]`
          function(_dest)
            print("does nothing")
          end
        },
        --- A function that takes `@class OpenSesame.Phrase[]` to operate on
        door = function(_phrases)
          print("does nothing")
        end
      }
    })
    vim.keymap.set({ "n", "v" }, "<leader>gd", open_sesame.selection_to_path, { noremap = true })
  end
}
```

