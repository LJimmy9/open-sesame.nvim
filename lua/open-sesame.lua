local scanners = require('scanners')
local doors = require('doors')

--- *Any string input*
---@alias OpenSesame.Destination string

--- *A function that takes a `Destination` and returns `phrases`*
---@alias OpenSesame.Scanner fun(destination: OpenSesame.Destination): OpenSesame.Phrase[]

--- *Returned by a `Phrase`*
--- `phrase` The target string. A path, url, etc.
--- `charms` Extra data that is required for the `door` function
---@class OpenSesame.Phrase
---@field phrase string
---@field charms table | nil

--- *A function that takes `key`(s) to operate with*
---@alias OpenSesame.Door fun(phrases: OpenSesame.Phrase[]): any

---@class OpenSesame.Portal
---@field scanners OpenSesame.Scanner[]
---@field door OpenSesame.Door

--- *Default patterns to search with. Prefixed with `os_`*
--- `words` first locates the first slash type (`/\`) and then matches the start of the word prior. For relative directories like `tests/`
--- `slash` match the first slash (`/\`). For absolute directories like `/Users`
--- `home` matches the first `~` character. For absolute path starting at home like '~/Downloads'
--- `dot` matches the one or two `.` characters. For relative paths like `./` and `../`
-- M.default_matchers = {
-- os_word = "%s?(%a)*[/\\]",
-- os_word = scanners.relative_path,
-- os_slash = "()[/\\]",
-- os_home = "()~[/\\]",
-- os_dot = "()%.%.?[/\\]",
-- os_another_start_pattern = "%s*()[/\\]",
-- }

--- Each key is a string, and each value is a table with 'scanners' and 'door' fields
--- @class OpenSesame.Opts
--- @field [string] OpenSesame.Portal
local opts = {
  relative_paths = {
    scanners = {
      scanners.relative_path
    },
    door = doors.try_visit_path
  },
  -- absolute_paths = {
  --   scanners = {
  --     scanners.relative_path
  --   },
  --   door = doors.try_visit_path
  -- }
}


--- Patterns in Lua are described by strings.
--- Read more at the [Lua Documentation](https://www.lua.org/manual/5.4/manual.html#6.4.1)
---@param destination OpenSesame.Destination
---@return any|nil result The result of using the door. Can be the text under cursor / any relevant data that can be easily tested against..
local function execute(destination)
  local phrases = nil
  ---@type string[]
  local out = {}

  for _, portal in pairs(opts) do
    for _, scanner in ipairs(portal.scanners) do
      phrases = scanner(destination)

      if (#phrases > 0) then
        out = portal.door(phrases)
        -- if scanner was successful stop here
        goto end_loop
      end
    end
  end
  ::end_loop::

  if (#out > 0) then
    return out
  else
    local msg = "No patterns were matched"
    vim.notify(msg, vim.log.levels.ERROR, { title = "Error" })
    return error(msg, 2)
  end
end

--- Copied from https://github.com/telemachus/dotfiles/blob/main/config/nvim/lua/bitly.lua
local _should_swap = function(start_pos, end_pos)
  if start_pos[2] > end_pos[2] then
    return true
  end
  if start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3] then
    return true
  end
  return false
end

local function get_visual_selection()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  if _should_swap(start_pos, end_pos) then
    start_pos, end_pos = end_pos, start_pos
  end

  local lines = vim.fn.getregion(start_pos, end_pos)
  vim.notify(vim.inspect(lines), vim.log.levels.ERROR, { title = "Error" })
  return lines
end

local function line_to_path()
  print("before line to path")
  local line = vim.api.nvim_get_current_line()
  print("post line to path")
  if vim.fn.mode():lower() == "v" then
    local visual_selection = get_visual_selection()
    line = table.concat(visual_selection, "\n")
  end
  local _p = execute(line)
end

vim.keymap.set({ "n", "v" }, "<leader>gd", line_to_path)

-- local line = "plugin/"
-- line = "local input = ./README.md:3:8 gibberish"
-- local res = execute(line)
-- print(res)

local M = {}
M.opts = opts
M.execute = execute
M.line_to_path = line_to_path

return M
