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

  local keys = { "row", "col" }
  local i_key = 0

  for i = 1, #input do
    if i_key > 2 then
      break
    end
    local char = string.sub(input, i, i)
    if (tonumber(char)) then
      result[keys[i_key]] = result[keys[i_key]] .. char
    else
      i_key = i_key + 1
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

      local file_status = vim.fn.filereadable(vim.fn.expand(phrase)) == 1
      local dir_status = vim.fn.isdirectory(vim.fn.expand(phrase)) == 1
      if file_status or dir_status then
        table.insert(phrases, {
          phrase = phrase,
          charms = pos
        })
      end
    end
  end

  return phrases
end


--- TODO: This works but it really needs to be simplified
---@param input OpenSesame.Destination
---@return OpenSesame.Phrase[] phrases
local function find_file(input)
  ---@type OpenSesame.Phrase[]
  local phrases = {}
  local start_chars = "[/]"
  local break_chars = "[ \t\r\n\"']"

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
    local i = s:match("file:()") or 1
    s = s:sub(i, #input)

    local i_start = s:find(start_chars)
    if i_start then
      local i_end = s:find("%(") or s:find(":") or #s + 1

      local phrase = s:sub(1, i_end - 1)
      local pos = path_pos(s:sub(i_end))

      local file_status = vim.fn.filereadable(vim.fn.expand(phrase)) == 1
      local dir_status = vim.fn.isdirectory(vim.fn.expand(phrase)) == 1
      if file_status or dir_status then
        table.insert(phrases, {
          phrase = phrase,
          charms = pos
        })
      end
    end
  end

  return phrases
end

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
      local last_char = phrase:sub(#phrase, #phrase)
      if last_char == ")" then
        phrase = phrase:sub(1, #phrase - 1)
      end
      table.insert(phrases, {
        phrase = phrase,
      })
    end
  end

  return phrases
end

local M = {}
M.path_pos = path_pos
M.find_path = find_path
M.find_file = find_file
M.find_url = find_url
return M
