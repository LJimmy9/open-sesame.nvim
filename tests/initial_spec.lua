---@diagnostic disable: undefined-global, undefined-field
local eq = assert.are.same
local open_sesame = require("open-sesame")
local function should_fail(fun)
  local stat = pcall(fun)
  assert(not stat, "Function should fail")
end


describe("smoke tests", function()
  it("invalid path should fail", function()
    local in_path = "./\\0.txt"
    should_fail(function()
      local result = open_sesame.find_path({
        travelor = in_path
      })
      return open_sesame.try_visit_path(result)
    end)
  end)
  it("empty path should fail", function()
    local in_path = ""
    should_fail(function()
      return open_sesame.find_path({
        travelor = in_path
      })
    end)
  end)
  it("this file should work", function()
    local in_path = "./tests/initial_spec.lua"
    local out_path = "./tests/initial_spec.lua"
    local result = open_sesame.find_path({
      travelor = in_path
    })
    eq(
      {
        key = out_path,
        trinkets = {
          row = '',
          col = ''
        }
      },
      result
    )
    open_sesame.try_visit_path(result)
  end)
end)

describe("pattern smoke tests", function()
  it("invalid path should fail", function()
    should_fail(function()
      return open_sesame.find_path({
        travelor = " nothing valuable here",
        phrases = {}
      })
    end)
  end)
end)

describe("scan word function", function()
  local key_plugin = {
    key = "plugin/",
    trinkets = {
      row = "",
      col = ""
    }
  }
  local key_readme = {
    key = "./README.md",
    trinkets = {
      row = "",
      col = ""
    }
  }
  it("plugin/ should return 1", function()
    local input = "plugin/"
    local output = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    eq(key_plugin, output)
  end)
  it("with leading gibberish plugin/ should return 4", function()
    local input = "ea plugin/"
    local output = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    eq(key_plugin, output)
  end)
  it("with leading \n should return 2", function()
    local input = "\nplugin/"
    local output = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    eq(key_plugin, output)
  end)
  it("with leading \t should return 2", function()
    local input = "\tplugin/"
    local output = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    eq(key_plugin, output)
  end)
  it("with leading \r\n should return 3", function()
    local input = "\r\nplugin/"
    local output = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    eq(key_plugin, output)
  end)
  it("should return readme with just colon", function()
    local input = "./README.md:"
    local output = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    key_readme.trinkets.row = ""
    key_readme.trinkets.col = ""
    eq(key_readme, output)
  end)
  it("should return readme with row", function()
    local input = "./README.md:"
    local result = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    key_readme.trinkets.row = ""
    key_readme.trinkets.col = ""
    eq(key_readme, result)
    local line = open_sesame.try_visit_path(result)
    eq("#", line)
  end)
  it("should return readme with row and excess gibberish", function()
    local input = "./README.md:1 trash"
    local result = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    key_readme.trinkets.row = "1"
    key_readme.trinkets.col = ""
    eq(key_readme, result)
    local line = open_sesame.try_visit_path(result)
    eq("#", line)
  end)
  it("should return readme with row and col", function()
    local input = "./README.md:1:2"
    local result = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    key_readme.trinkets.row = "1"
    key_readme.trinkets.col = "2"
    eq(key_readme, result)
    local line = open_sesame.try_visit_path(result)
    eq("#", line)
  end)
  it("should return readme with row and column and excess gibberish", function()
    local input = "./README.md:2:8 gibberish"
    local output = open_sesame.find_path({
      travelor = input,
      phrases = {}
    })
    key_readme.trinkets.row = "2"
    key_readme.trinkets.col = "8"
    eq(key_readme, output)
  end)
end)
