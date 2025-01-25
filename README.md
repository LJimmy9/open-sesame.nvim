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

A `travelor` is any string input.
A `phrase` is a function that takes a `travelor` and returns `key`(s).
A `door` is a function that takes `key`(s) to operate with. 

## Usage

```lua
require('open-sesame').setup({
    phrases = {
    --- table of functions that returns an `@class OpenSesame.Result`
    }
    doors ={
    --- table of functions that takes a list of `@class OpenSesame.Result`
    }
})
```

