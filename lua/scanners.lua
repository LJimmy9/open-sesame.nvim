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

--- Locates the first start char and then matches the start of the word prior.
---@param input OpenSesame.Destination
---@return OpenSesame.Phrase[] phrases
local function find_path(input)
  ---@type OpenSesame.Phrase[]
  local phrases = {}
  local start_chars = "[~./..//\\]"
  local break_chars = "[ \t\r\n\"']"

  --- "ea plugin/"
  ---  _________^  find slash
  ---  __^_______  find break and add one or stop if at end
  ---  ___^_____^  phrase is substring
  ---  __________^ continue after break if it exists

  ---@type string[]
  local substrs = {}
  local substr = ""
  for c in input:gmatch(".") do
    if c:match(break_chars) then
      table.insert(substrs, substr)
      substr = ""
    else
      substr = substr .. c
    end
  end
  table.insert(substrs, substr)

  for _, s in ipairs(substrs) do
    local i_start = s:find(start_chars)
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

  return phrases
end


local M = {}
M.path_pos = path_pos
M.find_path = find_path
return M
