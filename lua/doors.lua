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

  print("doing split", file_status, dir_status, input.phrase)

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
    -- vim.notify(error_msg, vim.log.levels.WARN, { title = "Error" })
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
    -- vim.notify(error_msg, vim.log.levels.WARN, { title = "Error" })
    -- return error(error_msg, 2)
  end
  return line
end

--- Directories that are sent cannot be visited.
--- Seems to be a bug with oil.nvim
--- https://github.com/stevearc/oil.nvim/issues/373
---@param input OpenSesame.Phrase[]
local function add_to_qf_list(input)
  vim.fn.setqflist({}, 'r')
  for _, p in ipairs(input) do
    local path = vim.fn.fnamemodify(p.phrase, ":p")
    local qf_item = {
      filename = path,
      text = "open-sesame file" .. p.phrase
    }
    if p.charms then
      qf_item.lnum = p.charms.row or 1
      qf_item.col = p.charms.col or 1
      qf_item.text = "open-sesame directory" .. p.phrase
    end
    vim.fn.setqflist({ qf_item }, 'a')
  end
end

--- If there is just one phrase, will open in split.
--- Otherwise visits each phrase in tabs
--- Navigate tabs with `gt` and `gT`
---@param input OpenSesame.Phrase[]
---@return string[] lines The result of setting the cursor
local function try_visit_path(input)
  local out = {}
  assert(#input > 0, "input must be greater than 0")

  print("CHECK", vim.inspect(input), #input)
  if #input == 1 then
    print("doing 1 things")
    local result = visit_split(input[1])
    if result then
      table.insert(out, result)
    end
  else
    print("not doing 1 things")
    for _, phrase in ipairs(input) do
      local result = visit_tab(phrase)
      if result then
        table.insert(out, result)
      end
    end
    add_to_qf_list(input)
  end

  return out
end

---@param input OpenSesame.Phrase[]
---@return string[] lines The result of setting the cursor
local function try_system_open(input)
  local out = {}
  assert(#input > 0, "input must be greater than 0")

  for _, phrase in ipairs(input) do
    phrase.phrase = phrase.phrase:gsub("#", [[\#]])
    local cmd = "!open " .. phrase.phrase
    vim.cmd(cmd)

    table.insert(out, phrase.phrase)
  end
  return out
end

local M = {}
M.try_visit_path = try_visit_path
M.try_system_open = try_system_open
return M
