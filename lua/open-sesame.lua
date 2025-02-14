local scanners = require('scanners')
local doors = require('doors')

--- *Any string input*
---@alias OpenSesame.Destination string

--- *A function that takes a `Destination` and returns `Phrase[]`*
---@alias OpenSesame.Scanner fun(destination: OpenSesame.Destination): OpenSesame.Phrase[]

--- *Returned by a `Scanner`*
--- `phrase` The target string. A path, url, etc.
--- `charms` Extra data that is required for the `door` function
---@class OpenSesame.Phrase
---@field phrase string
---@field charms table | nil

--- *A function that takes `Phrase[]` to operate with*
---@alias OpenSesame.Door fun(phrases: OpenSesame.Phrase[]): any

---@class OpenSesame.Portal
---@field scanners OpenSesame.Scanner[]
---@field door OpenSesame.Door

--- Each key is a string, and each value is a table with 'scanners' and 'door' fields
--- @class OpenSesame.Opts
--- @field [string] OpenSesame.Portal
local opts = {}

--- @type OpenSesame.Opts
local default_opts = {
  url_open = {
    scanners = {
      scanners.find_url
    },
    door = doors.try_system_open
  },
  nvim_paths = {
    scanners = {
      scanners.find_file,
      scanners.find_path,
    },
    door = doors.try_visit_path
  },
}

---@param destination OpenSesame.Destination
---@return any|nil result The result of using the door. Can be the text under cursor / any relevant data that can be easily tested against..
local function execute(destination)
  local phrases = nil
  ---@type string[]
  local out = {}

  for k, portal in pairs(opts) do
    for _, scanner in ipairs(portal.scanners) do
      phrases = scanner(destination)

      if (#phrases > 0) then
        out = portal.door(phrases)
        -- if scanner was successful stop here
        if #out > 0 then
          return out
        end
      end
    end
  end
  local msg = "No patterns were matched"
  vim.notify(msg, vim.log.levels.ERROR, { title = "Error" })
  return error(msg, 2)
end

---@param visual_mode any Usually the result of `vim.fn.mode()`
local function get_visual_selection(visual_mode)
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local lines = vim.fn.getregion(start_pos, end_pos, { type = visual_mode })
  return lines
end

local function selection_to_path()
  local line = vim.api.nvim_get_current_line()
  local mode = vim.fn.mode()
  if mode:match('[vV]') then
    local visual_selection = get_visual_selection(mode)
    line = table.concat(visual_selection, "\n")
  end
  local _p = execute(line)
end


local M = {}
M.default_opts = default_opts
M.opts = opts
M.execute = execute
M.selection_to_path = selection_to_path
M.did_setup = false

---@param user_opts OpenSesame.Opts?
M.setup = function(user_opts)
  if M.did_setup then
    return vim.notify("open-sesame.nvim is already setup", vim.log.levels.ERROR, { title = "open-sesame.nvim" })
  end
  user_opts = user_opts or {}
  opts = vim.tbl_deep_extend('force', opts, M.default_opts)
  opts = vim.tbl_deep_extend('force', opts, user_opts)
  M.did_setup = true
end

return M
