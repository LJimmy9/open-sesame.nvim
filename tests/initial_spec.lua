---@diagnostic disable: undefined-global, undefined-field
local eq = assert.are.same
local open_sesame = require("open-sesame")
open_sesame.setup({})
local doors = require("doors")
local scanners = require("scanners")
local function should_fail(fun)
  local stat = pcall(fun)
  assert(not stat, "Function should fail")
end


describe("smoke tests", function()
  it("invalid path should fail", function()
    local in_path = "./\\0.txt"
    should_fail(function()
      local result = open_sesame.execute(in_path)
      return open_sesame.try_visit_path(result)
    end)
  end)
  it("empty path should fail", function()
    local in_path = ""
    should_fail(function()
      return open_sesame.execute(in_path)
    end)
  end)
  it("this file should work", function()
    local in_path = "./tests/initial_spec.lua"
    local out_path = "./tests/initial_spec.lua"
    local result = scanners.find_path(in_path)
    -- check not the execute but the return of phrases
    eq(
      {
        {
          phrase = out_path,
          charms = {
            row = '',
            col = ''
          }
        },
      },
      result
    )
  end)
end)

describe("pattern smoke tests", function()
  it("invalid path should fail", function()
    should_fail(function()
      return open_sesame.execute(" nothing valuable here")
    end)
  end)
end)

describe("scan word function", function()
  it("plugin/ should return 1", function()
    local input = "plugin/"
    local output = open_sesame.execute(input)
    eq({ input }, output)
  end)
  it("with leading gibberish plugin/ should return 4", function()
    local input = "ea plugin/"
    local output = open_sesame.execute(input)
    eq({ "plugin/" }, output)
  end)
  it("with leading \n should return 2", function()
    local input = "\nplugin/"
    local output = open_sesame.execute(input)
    eq({ "plugin/" }, output)
  end)
  it("with leading \t should return 2", function()
    local input = "\tlua/"
    local output = open_sesame.execute(input)
    eq({ "lua/" }, output)
  end)
  it("with leading \r\n should return 3", function()
    local input = "\r\ntests/"
    local output = open_sesame.execute(input)
    eq({ "tests/" }, output)
  end)
  it("should return readme with just colon", function()
    local input = "./README.md:"
    local output = open_sesame.execute(input)
    eq({ "#" }, output)
  end)
  it("should return readme with row and excess gibberish", function()
    local input = "./README.md:1 trash"
    local output = open_sesame.execute(input)
    eq({ "#" }, output)
  end)
  it("should return readme with row and col", function()
    local input = "./README.md:1:2"
    local output = open_sesame.execute(input)
    eq({ "#" }, output)
  end)
  it("should return readme with row and column and excess gibberish", function()
    local input = "./README.md:3:8 gibberish"
    local output = open_sesame.execute(input)
    eq({ "e" }, output)
  end)
  it("should return multiple results", function()
    local input = "./README.md:3:8 gibberish ./README.md:1:2 gibberish"
    local output = open_sesame.execute(input)
    eq({ "e", "#" }, output)
  end)
end)

describe("visit url smoke test", function()
  it("google should work", function()
    local input = "https://google.com somethingafter https://google.com"
    local result = scanners.find_url(input)
    eq(
      {
        {
          phrase = "https://google.com"
        },
        {
          phrase = "https://google.com"
        }
      }, result)
  end)
  --- TODO: This test doesnt ever fail. Adjustments need to be made to the scanner function
  --- Unsure how to extract the error from vim.cmd
  it("# in url should work", function()
    local input = "https://www.lua.org/manual/5.1/manual.html#6.4.1"
    local result = scanners.find_url(input)
    eq(
      {
        {
          phrase = "https://www.lua.org/manual/5.1/manual.html#6.4.1"
        },
      }, result)
  end)
end)

-- https://www.lua.org/manual/5.1/manual.html#6.4.1

-- local input = "https://google.com somethingafter https://google.com\n"
-- find_url(input)
