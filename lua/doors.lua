local M = {}

---@param input OpenSesame.Phrase
---@return string|nil line The result of setting the cursor
local function try_visit_path(input)
  local file_status = vim.fn.filereadable(input.phrase) == 1
  local dir_status = vim.fn.isdirectory(vim.fn.expand(input.phrase)) == 1
  local line = nil
  print("visit check", vim.inspect(input), file_status, dir_status)

  if file_status or dir_status then
    local has_split = #vim.api.nvim_tabpage_list_wins(0) > 1
    if has_split then
      vim.cmd('wincmd p')
    else
      vim.cmd('split')
    end
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
    local error_msg = "Cannot find target:" .. vim.inspect(input)
    vim.notify(error_msg, vim.log.levels.ERROR, { title = "Error" })
    -- return error(error_msg, 2)
  end
  return line
end

---@type OpenSesame.Phrase
-- local input = {
--   -- phrase = "./README.md",
--   phrase = "plugin/",
-- }
--
-- local res = try_visit_path(input)
-- print(res)

M.try_visit_path = try_visit_path
return M
