## Overview

A `destination` is any string input.

A `scanner` is a function that takes a `destination` and returns `phrases`.

A `door` is a function that operates with `phrases`.

A `portal` stores `scanner(s)` with a `door`

## Tutorial

We'll go over how to customize and add additional open features by creating a
small feature that opens the selected text if it's a valid URL in a browser. (*Using the generic open command*)

1. Scanner Function

> [!NOTE]
> You can create multiple `OpenSesame.Scanner` functions that will be executed
> one after another until something is matched.

First, we need to create a function that can extract the URL from a string and
returns a list of `OpenSesame.Phrase` for use in the next step.

```lua
---@param input OpenSesame.Destination
---@return OpenSesame.Phrase[] phrases
local function find_url(input)
  ---@type OpenSesame.Phrase[]
  local phrases = {}
  local substrs = {}
  local substr = ""

  --- Split the string into pieces by locating break characters
  local break_chars = "[ \t\r\n\"']"
  for c in input:gmatch(".") do
    if c:match(break_chars) then
      table.insert(substrs, substr)
      substr = ""
    else
      substr = substr .. c
    end
  end
  --- Add the final substr that may not have a break char
  table.insert(substrs, substr)

  --- Create the phrase if the URL pattern exists
  local url_pattern = "https?://"
  for _, s in ipairs(substrs) do
    local i_start = s:find(url_pattern)
    if i_start then
      local phrase = s:sub(i_start, #s)
      table.insert(phrases, {
        phrase = phrase,
      })
    end
  end

  return phrases
end
```


2. Door Function

Next, we will create a function that takes in a list of `OpenSesame.Phrase` and
operates on it. We will use the system `open` command to open the URL in the
default browser.


```lua
---@param input OpenSesame.Phrase[]
---@return string[] lines The result of setting the cursor
local function try_system_open(input)
  local out = {}
  assert(#input > 0, "input must be greater than 0")

  for _, phrase in ipairs(input) do
    local cmd = "!open " .. phrase.phrase
    vim.cmd(cmd)
    table.insert(out, phrase.phrase)
  end
  return out
end
```

3. Plugin setup

Lastly, we will put the scanner and door together into a `OpenSesame.Portal` and
pass it into our setup function.

```lua
---@type OpenSesame.Portal
local url_open_portal = {
  scanners = {
    find_url
  },
  door = try_system_open
}

open_sesame.setup({
  url_open = url_open_portal,
})
```

4. Done!

That's all! You can test it by finishing your config and assigning a keybind. 
> [!NOTE]
> This portal is already a part of the defaults. This is strictly for
> documentation.

```lua
vim.keymap.set({ "n", "v" }, "<leader>gd", open_sesame.selection_to_path, { noremap = true })
```

> [!WARNING]
> All of the portal configurations will be run in order. There may be conflicts
> with the default portals depending on what you're attempting to do. 
> Remove those from the default_opts table by setting the corresponding key to
> nil
> `require('open-sesame').default_opts["url_open"] = nil`

