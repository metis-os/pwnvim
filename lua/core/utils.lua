local M = {}

M.lazy = function(lazy_path)
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazy_path,
  }
  vim.opt.rtp:prepend(lazy_path)
end

M.lazy_load = function(plugin)
  vim.api.nvim_create_autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("BeLazyOnFileOpen" .. plugin, {}),
    callback = function()
      local file = vim.fn.expand "%"
      local condition = file ~= "NvimTree_1" and file ~= "[lazy]" and file ~= ""

      if condition then
        vim.api.nvim_del_augroup_by_name("BeLazyOnFileOpen" .. plugin)

        if plugin ~= "treesitter" then
          vim.schedule(function()
            require("lazy").load { plugins = plugin }

            if plugin == "lspconfig" then
              vim.cmd "silent! do FileType"
            end
          end, 0)
        else
          require("lazy").load { plugins = plugin }
        end
      end
    end,
  })
end

local cmds = { "nu!", "rnu!", "nonu!" }
local current_index = 1

function M.toggle_numbering()
  current_index = current_index % #cmds + 1
  vim.cmd("set " .. cmds[current_index])
end

function M.run_command()
  local terminal = require "nvterm.terminal"
  local ft_cmds = {
    rust = "cargo run",
    sh = "bash " .. vim.fn.expand "%",
    python = "python3 " .. vim.fn.expand "%",
    lua = "lua " .. vim.fn.expand "%",
    markdown = "glow " .. vim.fn.expand "%",
  }
  local command = ft_cmds[vim.bo.filetype]

  if command then
    terminal.send("clear && " .. command, "vertical")
  else
    print("No command defined for filetype: " .. vim.bo.filetype)
  end
end

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Disable 'mini.indentscope', enable beam in terminal buffer",
  callback = function(data)
    vim.b[data.buf].miniindentscope_disable = true
  end,
})

local inlay_hint_enabled = false

function M.toggle_inlay_hint()
  if vim.lsp.inlay_hint then
    inlay_hint_enabled = not inlay_hint_enabled
    vim.lsp.inlay_hint(0, inlay_hint_enabled)
    vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#f0c6c6" })
  else
    require "notify" "Inlay hint not supported"
  end
end

function M.toggle_dropbar()
  if vim.o.winbar == "" then
    vim.o.winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
  else
    vim.o.winbar = ""
  end
end

local state = 0
function M.toggle_flow()
  if state == 0 then
    vim.o.relativenumber = false
    vim.o.number = false
    vim.opt.signcolumn = "yes:4"
    vim.o.winbar = ""
    state = 1
  else
    vim.o.relativenumber = true
    vim.opt.signcolumn = "auto"
    vim.o.winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
    state = 0
  end
end

local signs = { Error = "", Warn = " ", Hint = " ", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

return M
