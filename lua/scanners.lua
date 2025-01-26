local M = {}

---@class OpenSesame.Pos
---@field row string
---@field col string

---@param input OpenSesame.Destination
---@return OpenSesame.Pos result A table with 'row' and 'col' fields
M.path_pos = function(input)
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
---@return OpenSesame.Phrase[] | nil phrases
M.relative_path = function(input)
  ---@type OpenSesame.Phrase[] | nil
  local phrases = nil
  local i_start = input:find("[/\\]")
  local break_chars = "[ \t\r\n]"

  if i_start then
    phrases = {}
    local phrase = {
      phrase = "",
      charms = {}
    }
    while (1 < i_start) do
      i_start = i_start - 1
      local char = input:sub(i_start, i_start)
      local is_break = char:find(break_chars)
      if (is_break) then
        i_start = i_start + 1
        break
      end
    end
    local trim_left = input:sub(i_start, #input)
    local i_end = trim_left:find(":") or trim_left:find(break_chars) or #trim_left + 1
    local pos = M.path_pos(trim_left)
    phrase.phrase = trim_left:sub(1, i_end - 1)
    phrase.charms = pos
    table.insert(phrases, phrase)
    return phrases
  else
    return nil
  end
  --- TODO: fix this so it can return multiple phrases
end

return M
