---@class OpenSesame.Pos
---@field row string
---@field col string

---@param input OpenSesame.Destination
---@return OpenSesame.Pos result A table with 'row' and 'col' fields
local function path_pos(input)
  local result = {
    row = "",
    col = ""
  }

  local break_chars = "[ \t\r\n]"
  local i_break = string.find(input, ":") or string.find(input, break_chars) or #input + 1
  local char = string.sub(input, i_break, i_break)
  for _, key in ipairs({ "row", "col" }) do
    if (char == ":") then
      i_break = i_break + 1
      char = string.sub(input, i_break, i_break)
      while (tonumber(char)) do
        result[key] = result[key] .. char
        i_break = i_break + 1
        char = string.sub(input, i_break, i_break)
      end
    end
  end

  return result
end

--- Locates the first slash type and then matches the start of the word prior.
--- For relative directories like `tests/`
---@param input OpenSesame.Destination
---@return OpenSesame.Phrase[] phrases
local function relative_path(input)
  ---@type OpenSesame.Phrase[]
  local phrases = {}
  local slash_chars = "[~./..//\\]"
  local break_chars = "[ \t\r\n\"']"

  --- "ea plugin/"
  ---  _________^  find slash
  ---  __^_______  find break and add one or stop if at end
  ---  ___^_____^  phrase is substring
  ---  __________^ continue after break if it exists

  ---@type string[]
  local substrs = {}
  local substr = ""
  -- vim.notify("adding phrase here" .. vim.inspect(input), vim.log.levels.ERROR, { title = "Error" })
  for c in input:gmatch(".") do
    if c:match(break_chars) then
      -- vim.notify("last substr here" .. vim.inspect(substr), vim.log.levels.ERROR, { title = "Error" })
      table.insert(substrs, substr)
      substr = ""
    else
      substr = substr .. c
    end
  end
  table.insert(substrs, substr)
  -- vim.notify("after substr " .. vim.inspect(substrs), vim.log.levels.ERROR, { title = "Error" })

  for _, s in ipairs(substrs) do
    local i_start = s:find(slash_chars)
    if i_start then
      local i_end = s:find(":") or #s + 1
      local phrase = s:sub(1, i_end - 1)
      local pos = path_pos(s)
      table.insert(phrases, {
        phrase = phrase,
        charms = pos
      })
    end
  end

  -- vim.notify("phrases: " .. vim.inspect(phrases), vim.log.levels.ERROR, { title = "Error" })

  -- vim.notify("after phrases " .. vim.inspect(phrases), vim.log.levels.ERROR, { title = "Error" })
  return phrases
end


-- TODO: DONE! this results in an infinite loop
-- TODO: add tests for this
-- local input = "ea ../README.md:2 plugin/:4:2 something_else/ ../README.md:4:2"
-- input = "./plugin/ ./tests/"
-- input = "plugin/"
-- input = "../README.md:1 trash"
-- input = "./README.md:1:3 trash"
-- input = "~/projects/open-sesame.nvim/"
-- input = "vim: filetype=compilation:path+=~/projects/open-sesame.nvim"
-- input = "./README.md:1:2"
-- input = "./README.md:3:8 gibberish"
-- input = [[local input = "./README.md:1:2"]]
-- local result = relative_path(input)
-- print(vim.inspect(result))

local M = {}
M.path_pos = path_pos
M.relative_path = relative_path
return M
