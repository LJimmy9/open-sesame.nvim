local M = {}

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
  local i_start = input:find("[/\\]")
  local break_chars = "[ \t\r\n]"

  while (i_start) do
    local phrase = {
      phrase = "",
      charms = {}
    }
    while (1 < i_start) do
      i_start = i_start - 1
      local char = input:sub(i_start, i_start)
      local is_break = char:find(break_chars)
      -- print("in relative path while", char, is_break)
      if (is_break) then
        i_start = i_start + 1
        break
      end
    end
    local trim_left = input:sub(i_start, #input)
    local i_end = trim_left:find(":") or trim_left:find(break_chars) or #trim_left + 1
    local pos = path_pos(trim_left)
    phrase.phrase = trim_left:sub(1, i_end - 1)
    phrase.charms = pos
    -- print("phrase left", vim.inspect(phrase))
    table.insert(phrases, phrase)
    local trim_phrase = input:sub(i_end, #input)
    i_start = trim_phrase:find("[/\\]")
  end

  return phrases
end

M.path_pos = path_pos
M.relative_path = relative_path
return M
