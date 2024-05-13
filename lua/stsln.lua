local M = {}
local utilities = require "stsln.utilities"

local mode_colors = {
  ["n"] = "#9ccfd8",
  ["no"] = "#9ccfd8",
  ["niI"] = "#9ccfd8",
  ["niR"] = "#9ccfd8",
  ["niV"] = "#9ccfd8",
  ["no"] = "#9ccfd8",
  ["nov"] = "#9ccfd8",
  ["noV"] = "#9ccfd8",
  ["c"] = "#f6c177",
  ["i"] = "#ebbcba",
  ["ic"] = "#ebbcba",
  ["s"] = "#ebbcba",
  ["S"] = "#ebbcba",
  ["v"] = "#c4a7e7",
  ["V"] = "#c4a7e7",
  [""] = "#c4a7e7",
  [""] = "#c4a7e7",
  ["r"] = "#eb6f92",
  ["r?"] = "#eb6f92",
  ["R"] = "#eb6f92",
  ["t"] = "#e0def4",
}

local mode_icons = {
  ["n"] = "󰋜 ",
  ["no"] = "󰋜 ",
  ["niI"] = "󰋜 ",
  ["niR"] = "󰋜 ",
  ["no"] = "󰋜 ",
  ["niV"] = "󰋜 ",
  ["nov"] = "󰋜 ",
  ["noV"] = "󰋜 ",
  ["i"] = "󰏫 ",
  ["ic"] = "󰏫 ",
  ["ix"] = "󰏫 ",
  ["s"] = "󰏫 ",
  ["S"] = "󰏫 ",
  ["v"] = "󰈈 ",
  ["V"] = "󰈈 ",
  [""] = "󰈈 ",
  ["r"] = "󰛔 ",
  ["r?"] = " ",
  ["c"] = " ",
  ["t"] = " ",
  ["!"] = " ",
  ["R"] = " ",
}

local set_stsln = function()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_get_current_win() == win then
      vim.wo[win].statusline = "%!v:lua.require'stsln'.load(\"active\")"
    elseif vim.api.nvim_buf_get_name(0) ~= "" then
      vim.wo[win].statusline = "%!v:lua.require'stsln'.load()"
    end
  end
end

local get_harpoon_items = function()
  local status, harpoon = pcall(require, "harpoon")
  if not status then
    return {}
  end

  local marks = harpoon:list().items
  local current_file_path = vim.fn.expand "%:p:."
  local label = {}

  for id, item in ipairs(marks) do
    if item.value == current_file_path then
      table.insert(label, { id .. " ", active = true })
    else
      table.insert(label, { id .. " " })
    end
  end

  return label
end

local get_formatters = function()
  local status, conform = pcall(require, "conform")
  if not status then
    return {}
  end

  local formatters = conform.list_formatters(0)
  local label = {}

  for _, formatter in ipairs(formatters) do
    table.insert(label, { formatter.name .. " " })
  end

  return label
end

local get_lsp_clients = function()
  local clients = vim.lsp.get_active_clients()
  local label = {}

  for _, client in ipairs(clients) do
    table.insert(label, client.name)
  end

  return label
end

local update_branch = function()
  vim.b.stsln_branch = ""
  if vim.b.gitsigns_head then
    vim.b.stsln_branch = vim.b.gitsigns_head and vim.b.gitsigns_head or ""
    return
  end
  vim.fn.jobstart({ "git", "branch", "--show-current" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local branch = data[1]
      vim.b.stsln_branch = branch ~= "" and branch or ""
    end,
  })
end

M.load = function(status)
  local mode = vim.api.nvim_get_mode()["mode"]
  local color = mode_colors[mode] or "#9ccfd8"
  local mode_icon = mode_icons[mode] or "󰋜 "
  local harpoon_items = get_harpoon_items()
  local formatters = get_formatters()
  local lsp_clients = get_lsp_clients()

  if status == "active" then
    utilities.colorize("StatusLine", color, color)
  else
    utilities.colorize("StatusLine", "#908caa", "#191724")
  end
  utilities.colorize("StatusLineNC", "#908caa", "#191724")
  utilities.colorize("StsLnActiveItem", "#e0def4", color)

  local stsln = ""
  stsln = " " .. mode_icon .. " "
  stsln = stsln .. "%{get(b:, 'stsln_branch', '')} "
  if #harpoon_items > 0 then
    stsln = stsln .. "%=󰛢 "
    for _, item in ipairs(harpoon_items) do
      if item.active then
        stsln = stsln .. "%#StsLnActiveItem#" .. item[1] .. "%#StatusLine#"
      else
        stsln = stsln .. item[1]
      end
    end
  end
  stsln = stsln .. "%="
  local lsp_stsln = utilities.dump(lsp_clients, "󱌣")
  stsln = lsp_stsln and stsln .. lsp_stsln .. " " or stsln

  local formatters_stsln = utilities.dump(formatters, "")
  print(formatters_stsln)

  stsln = stsln .. "󰧱  "
  return stsln
end

M.setup = function()
  vim.api.nvim_create_autocmd({ "BufReadPost", "DirChanged" }, { callback = update_branch })
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufReadPost", "ColorSchemePre", "ModeChanged", "TabEnter", "TabClosed", "Filetype" },
    { callback = set_stsln }
  )
end

return M
