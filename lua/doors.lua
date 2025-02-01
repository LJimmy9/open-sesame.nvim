--- Will use existing split if it exists, otherwise creates a new one
local function create_or_use_split()
  local has_split = #vim.api.nvim_tabpage_list_wins(0) > 1
  if has_split then
    vim.cmd('wincmd p')
  else
    vim.cmd('split')
  end
end

--- As of right now, this wrapper is not very useful
local function create_tab()
  vim.cmd('tabe')
end

---@param input OpenSesame.Phrase
local function visit_split(input)
  local file_status = vim.fn.filereadable(vim.fn.expand(input.phrase)) == 1
  local dir_status = vim.fn.isdirectory(vim.fn.expand(input.phrase)) == 1
  local line = nil

  if file_status or dir_status then
    create_or_use_split()

    vim.cmd('e ' .. input.phrase)
    if file_status then
      input.charms = input.charms or {}
      local target_row = tonumber(input.charms.row) or 1
      local target_col = tonumber(input.charms.col) or 1
      local status, msg = pcall(vim.api.nvim_win_set_cursor, 0, { target_row, target_col })
      if not status then
        local error_msg = "Error setting cursor at:" .. target_row .. ", " .. target_col .. msg
        vim.notify(error_msg, vim.log.levels.WARN, { title = "Warning" })
        return error(error_msg, 2)
      end
      vim.cmd('normal zz')
      line = vim.api.nvim_get_current_line()
      line = line:sub(target_col, target_col)
    else
      line = input.phrase
    end
  else
    local error_msg = "Cannot find target: " .. input.phrase
    vim.notify(error_msg, vim.log.levels.WARN, { title = "Error" })
    -- return error(error_msg, 2)
  end
  return line
end

---@param input OpenSesame.Phrase
local function visit_tab(input)
  local file_status = vim.fn.filereadable(vim.fn.expand(input.phrase)) == 1
  local dir_status = vim.fn.isdirectory(vim.fn.expand(input.phrase)) == 1
  local line = nil

  if file_status or dir_status then
    create_tab()

    vim.cmd('e ' .. input.phrase)
    if file_status then
      input.charms = input.charms or {}
      local target_row = tonumber(input.charms.row) or 1
      local target_col = tonumber(input.charms.col) or 1
      local status, msg = pcall(vim.api.nvim_win_set_cursor, 0, { target_row, target_col })
      if not status then
        local error_msg = "Error setting cursor at:" .. target_row .. ", " .. target_col .. msg
        vim.notify(error_msg, vim.log.levels.WARN, { title = "Warning" })
        return error(error_msg, 2)
      end
      vim.cmd('normal zz')
      line = vim.api.nvim_get_current_line()
      line = line:sub(target_col, target_col)
    else
      line = input.phrase
    end
  else
    local error_msg = "Cannot find target: " .. input.phrase
    vim.notify(error_msg, vim.log.levels.WARN, { title = "Error" })
    -- return error(error_msg, 2)
  end
  return line
end

--- If there is just one phrase, will open in split.
--- Otherwise visits each phrase in tabs
--- Navigate tabs with `gt` and `gT`
---@param input OpenSesame.Phrase[]
---@return string[] lines The result of setting the cursor
local function try_visit_path(input)
  local out = {}
  assert(#input > 0, "Input must be greater than 0")

  if #input == 1 then
    local result = visit_split(input[1])
    if result then
      table.insert(out, result)
    end
  else
    for _, phrase in ipairs(input) do
      local result = visit_tab(phrase)
      if result then
        table.insert(out, result)
      end
    end
  end

  return out
end

---@type OpenSesame.Phrase[]
-- local input = {
--   {
--     -- phrase = "./README.md",
--     phrase = "./plugin/",
--     -- phrase = "~/projects/open-sesame.nvim/"
--   },
--   {
--     phrase = "./tests/",
--   }
-- }
-- local res = try_visit_path(input)
-- print(res)

local M = {}
M.try_visit_path = try_visit_path
return M
