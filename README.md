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

```lua
return {
  "ljimmy9/open-sesame.nvim",
  opts = {
    scanners = {
    --- list of functions that returns a `@class OpenSesame.Phrase[]`
    }
    doors ={
    --- list of functions that takes a list of `@class OpenSesame.Phrase[]` to operate on
    }
  }
  config = function()
    vim.keymap.set({ "n", "v" }, "<leader>gd", require('open-sesame').line_to_path, { noremap = true })
  end
}
```

