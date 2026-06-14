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

-- Load a random colorscheme
color_scheme.rand_colorscheme()

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

vim.keymap.set('n', '<leader>tl', function()
  -- The snippet to insert
  local snippet = {
    "```dataviewjs",
    'dv.view("99_Systems/04_Scripts/dv-js/tag-list", { tags: ["insert your tag here"] });',
    "```"
  }

  -- Insert the lines
  vim.api.nvim_put(snippet, 'l', true, true)

  -- Move cursor to the middle line inside the tags
  vim.cmd('normal! k0f[ll')

  -- Switch to insert mode
  vim.cmd('startinsert')
end, { desc = "Insert DataviewJS tag-list view" })

