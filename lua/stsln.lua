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
  local harpoon = require "harpoon"
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

M.load = function(status)
  local mode = vim.api.nvim_get_mode()["mode"]
  local color = mode_colors[mode] or "#9ccfd8"
  local mode_icon = mode_icons[mode] or "󰋜 "
  local harpoon_items = get_harpoon_items()

  if status == "active" then
    utilities.colorize("StatusLine", color, color)
  else
    utilities.colorize("StatusLine", "#908caa", "#191724")
  end
  utilities.colorize("StatusLineNC", "#908caa", "#191724")
  utilities.colorize("StsLnActiveItem", "#e0def4", color)

  local stsln = ""
  stsln = " " .. mode_icon .. " "
  if #harpoon_items > 0 then
    stsln = stsln .. "%=󰛢 "
    for _, item in ipairs(harpoon_items) do
      stsln = stsln .. item[1]
    end
  end
  stsln = stsln .. "%= %l:%c 󰧱 "
  return stsln
end

M.setup = function()
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufReadPost", "ColorSchemePre", "ModeChanged", "TabEnter", "TabClosed", "Filetype" },
    { callback = set_stsln }
  )
end

return M
