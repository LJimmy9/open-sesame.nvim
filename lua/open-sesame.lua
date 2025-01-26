local M = {}
local scanners = require('scanners')
local doors = require('doors')

--- *Any string input*
---@alias OpenSesame.Destination string

--- *A function that takes a `Destination` and returns `phrases`*
---@alias OpenSesame.Scanner fun(destination: OpenSesame.Destination): OpenSesame.Phrase[] | nil

--- *Returned by a `Phrase`*
--- `phrase` The target string. A path, url, etc.
--- `charms` Extra data that is required for the `door` function
---@class OpenSesame.Phrase
---@field phrase string
---@field charms table

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
M.opts = {
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
M.execute = function(destination)
  local phrases = nil
  local out = nil

  for _, portal in pairs(M.opts) do
    for _, scanner in ipairs(portal.scanners) do
      phrases = scanner(destination)
      if phrases then
        for _, phrase in ipairs(phrases) do
          out = portal.door(phrase)
          if out then
            return out
          end
        end
        break
      end
    end
  end

  local msg = "No patterns were matched"
  vim.notify(msg, vim.log.levels.ERROR, { title = "Error" })
  return error(msg, 2)
end

M.line_to_path = function()
  local line = vim.api.nvim_get_current_line()
  local path = M.execute(line)
  M.try_visit_path(path)
end

return M
