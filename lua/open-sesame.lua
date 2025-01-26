local M = {}
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
M.default_matchers = {
  -- os_word = "%s?(%a)*[/\\]",
  os_word = scanners.relative_path,
  -- os_slash = "()[/\\]",
  -- os_home = "()~[/\\]",
  -- os_dot = "()%.%.?[/\\]",
  -- os_another_start_pattern = "%s*()[/\\]",
}

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
  absolute_paths = {
    scanners = {
      scanners.relative_path
    },
    door = doors.try_visit_path
  }
}


--- Patterns in Lua are described by strings.
--- Read more at the [Lua Documentation](https://www.lua.org/manual/5.4/manual.html#6.4.1)
---@param destination OpenSesame.Destination
---@return OpenSesame.Phrase|nil result The `target` and `pos` which contains the data required to visit the path.
local function execute(destination)
  local phrases = nil
  ---@type string[]
  local out = {}

  for _, portal in pairs(opts) do
    for _, scanner in ipairs(portal.scanners) do
      phrases = scanner(destination)
      -- if scanner was successful stop there
      if (#phrases > 0) then
        for _, phrase in ipairs(phrases) do
          local result = portal.door(phrase)
          if result then
            table.insert(out, result)
          end
        end
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

local function line_to_path()
  local line = vim.api.nvim_get_current_line()
  local _path = execute(line)
end

-- local line = "./tests/initial_spec.lua"
-- local res = execute(line)
-- print(res)

M.opts = opts
M.execute = execute
M.line_to_path = line_to_path

return M
