-- This is my personal Nvim configuration supporting Mac, Linux and Windows, with various plugins configured.
-- This configuration evolves as I learn more about Nvim and become more proficient in using Nvim.
-- Since it is very long (more than 1000 lines!), you should read it carefully and take only the settings that suit you.
-- I would not recommend cloning this repo and replace your own config. Good configurations are personal,
-- built over time with a lot of polish.
--
-- Author: Jiedong Hao
-- Email: jdhao@hotmail.com
-- Blog: https://jdhao.github.io/
-- GitHub: https://github.com/jdhao
-- StackOverflow: https://stackoverflow.com/users/6064933/jdhao
vim.loader.enable()
vim.opt.conceallevel = 2

local utils = require("utils")

local expected_version = "0.11.5"
utils.is_compatible_version(expected_version)

local config_dir = vim.fn.stdpath("config")
---@cast config_dir string

-- some global settings
require("globals")
-- setting options in nvim
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/options.vim"))
-- various autocommands
require("custom-autocmd")
-- all the user-defined mappings
require("mappings")

-- all the plugins installed and their configurations
require("plugin_specs")

-- diagnostic related config
require("diagnostic-conf")

-- colorscheme settings
local color_scheme = require("colorschemes")

-- Set default colorscheme
color_scheme.colorscheme_conf.github()

-- Create an autocommand group to keep things organized
local markdown_prose_group = vim.api.nvim_create_augroup("MarkdownProse", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = markdown_prose_group,
  pattern = "markdown", -- Only trigger for .md files
  callback = function()
    -- Enable wrapping and visual alignment
    vim.opt_local.wrap = true           -- Enable line wrapping
    vim.opt_local.linebreak = true      -- Don't break words
    vim.opt_local.breakindent = true    -- Wrapped lines match indentation

    -- Fix the hanging indent for lists (Line 13 fix)
    vim.opt_local.breakindentopt = "list:-1" -- Align behind the bullet

    -- Disable C-style indentation that breaks lists
    vim.opt_local.smartindent = false   -- Prevents misaligned wraps
  end,
})

-- Turn off persisten undo
vim.opt.undofile = false

-- Custom command & keymap to parse and insert Bible verses using parse-verses.py
local function parse_verses_in_current_file()
  vim.cmd("update") -- Save file first
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or not file:match("%.md$") then
    vim.notify("Current buffer is not a Markdown file", vim.log.levels.WARN)
    return
  end

  local python_bin = "/Users/timothyyu-jayhuang/Documents/GitHub/verse-insertion/.venv/bin/python"
  local script_path = "/Users/timothyyu-jayhuang/Documents/GitHub/verse-insertion/parse-verses.py"

  local cmd = string.format(
    "%s %s -i %s",
    vim.fn.shellescape(python_bin),
    vim.fn.shellescape(script_path),
    vim.fn.shellescape(file)
  )

  local out = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    vim.cmd("edit!") -- Reload buffer to show inserted verses
    vim.notify("Bible verses inserted successfully!", vim.log.levels.INFO)
  else
    vim.notify("Failed to parse verses:\n" .. out, vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("ParseVerses", parse_verses_in_current_file, {
  desc = "Parse and insert Bible verse quotes into current Markdown file",
})

vim.keymap.set("n", "<leader>iv", parse_verses_in_current_file, {
  silent = true,
  desc = "Insert Bible verses into current Markdown file",
})


