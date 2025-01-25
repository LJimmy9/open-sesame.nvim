local M = {}

--- *The `KeyChain` returned by a `Phrase`*
--- `key` The parsed `Travelor` output
--- `trinkets` Any extra data
---@class OpenSesame.KeyChain
---@field key string
---@field trinkets table

---@alias OpenSesame.Travelor string
---@alias OpenSesame.Phrase fun(string): OpenSesame.KeyChain | nil

--- *Holds options for scan*
--- `input` = A string to scan
--- `pattern` = A table of patterns. Only the first successful match will be returned.
---@class OpenSesame.Opt
---@field phrases OpenSesame.Phrase[] | nil
---@field travelor string

---
---@class OpenSesame.Pos
---@field row string
---@field col string

---@param input OpenSesame.Travelor
---@return OpenSesame.Pos result A table with 'row' and 'col' fields
M.s_find_pos = function(input)
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
---@param input OpenSesame.Travelor
---@return OpenSesame.KeyChain|nil result
M.os_word = function(input)
  local i_start = input:find("[/\\]")
  local break_chars = "[ \t\r\n]"
  local result = {
    key = i_start,
    trinkets = {
      "",
      ""
    }
  }

  if i_start then
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
    local pos = M.s_find_pos(trim_left)
    result.key = trim_left:sub(1, i_end - 1)
    result.trinkets = pos
    return result
  else
    return nil
  end
end
--- *Scan's default patterns to search with. Prefixed with `s_`*
--- `words` first locates the first slash type (`/\`) and then matches the start of the word prior. For relative directories like `tests/`
--- `slash` match the first slash (`/\`). For absolute directories like `/Users`
--- `home` matches the first `~` character. For absolute path starting at home like '~/Downloads'
--- `dot` matches the one or two `.` characters. For relative paths like `./` and `../`
M.default_matchers = {
  -- os_word = "%s?(%a)*[/\\]",
  os_word = M.os_word,
  -- os_slash = "()[/\\]",
  -- os_home = "()~[/\\]",
  -- os_dot = "()%.%.?[/\\]",
  -- os_another_start_pattern = "%s*()[/\\]",
}

--- Patterns in Lua are described by strings.
--- Read more at the [Lua Documentation](https://www.lua.org/manual/5.4/manual.html#6.4.1)
---@param opt OpenSesame.Opt An input string to target and optional matchers
---@return OpenSesame.KeyChain|nil result The `target` and `pos` which contains the data required to visit the path.
M.find_path = function(opt)
  opt = opt or {
    input = "",
  }
  opt.phrases = vim.tbl_extend("keep", opt.phrases or {}, M.default_matchers)
  local out = nil

  for _, matcher in pairs(opt.phrases) do
    out = matcher(opt.travelor)
    if out then
      return out
    end
  end

  local msg = "No patterns were matched"
  vim.notify(msg, vim.log.levels.ERROR, { title = "Error" })
  return error(msg, 2)
end

---@param result OpenSesame.KeyChain|nil
---@return string|nil line The result of setting the cursor
M.try_visit_path = function(result)
  result = result or {}
  local file_status = vim.fn.filereadable(result.key) == 1
  local dir_status = vim.fn.isdirectory(vim.fn.expand(result.key)) == 1
  local line = nil

  if file_status or dir_status then
    local has_split = #vim.api.nvim_tabpage_list_wins(0) > 1
    if has_split then
      vim.cmd('wincmd p')
    else
      vim.cmd('split')
    end
    vim.cmd('e ' .. result.key)
    if file_status then
      local target_row = tonumber(result.trinkets.row) or 1
      local target_col = tonumber(result.trinkets.col) or 1
      local status, msg = pcall(vim.api.nvim_win_set_cursor, 0, { target_row, target_col })
      if not status then
        local error_msg = "Error setting cursor at:" .. target_row .. ", " .. target_col .. msg
        vim.notify(error_msg, vim.log.levels.WARN, { title = "Warning" })
        return error(error_msg, 2)
      end
      vim.cmd('normal zz')
      line = vim.api.nvim_get_current_line()
      print("NAVIG LINE", line, target_row, target_col)
      line = line:sub(target_col, target_col)
    end
  else
    local error_msg = "Cannot find target:" .. vim.inspect(result)
    vim.notify(error_msg, vim.log.levels.ERROR, { title = "Error" })
    return error(error_msg, 2)
  end
  return line
end

M.line_to_path = function()
  local line = vim.api.nvim_get_current_line()
  local path = M.find_path({ travelor = line, phrases = {} }) or {}
  M.try_visit_path(path)
end

return M
