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

## Usage

```lua
require('open-sesame').setup({
    scanners = {
    --- list of functions that returns a `@class OpenSesame.Key(s)`
    }
    doors ={
    --- list of functions that takes a list of `@class OpenSesame.Key(s)` to operate on
    }
})
```

