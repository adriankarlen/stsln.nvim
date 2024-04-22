local M = {}

local set_stsln = function()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_get_current_win() == win then
      vim.wo[win].statusline = "%!v:lua.require'stsln'.load(\"active\")"
    elseif vim.api.nvim_buf_get_name(0) ~= "" then
      vim.wo[win].statusline = "%!v:lua.require'stsln'.load()"
    end
  end
end

local function color_to_rgb(color)
  local function byte(value, offset)
    return bit.band(bit.rshift(value, offset), 0xFF)
  end

  local new_color = vim.api.nvim_get_color_by_name(color)
  if new_color == -1 then
    new_color = vim.opt.background:get() == "dark" and 000 or 255255255
  end

  return { byte(new_color, 16), byte(new_color, 8), byte(new_color, 0) }
end

local function blend(fg, bg, alpha)
  local fg_rgb = color_to_rgb(fg)
  local bg_rgb = color_to_rgb(bg)

  local function blend_channel(i)
    local ret = (alpha * fg_rgb[i] + ((1 - alpha) * bg_rgb[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02X%02X%02X", blend_channel(1), blend_channel(2), blend_channel(3))
end

local colorize = function(n, fg, bg)
  vim.api.nvim_set_hl(0, n, { fg = fg, bg = blend(bg, "#191724", 0.1) })
end

local get_file_icon = function(f_name, ext)
  local status, icons = pcall(require, "nvim-web-devicons")
  if not status then
    return " ", "Normal"
  end
  return icons.get_icon(f_name, ext, { default = true })
end

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

function M.load(status)
  local mode = vim.api.nvim_get_mode()["mode"]
  local color = mode_colors[mode] or "#9ccfd8"
  local mode_icon = mode_icons[mode] or "󰋜 "
  local f_icon = get_file_icon(vim.fn.expand "%:t", vim.fn.expand "%:e")
  local edited = vim.bo.mod and " 󰏫 " or ""
  if status == "active" then
    colorize("StatusLine", color, color)
  else
    colorize("StatusLine", "#908caa", "#191724")
  end
  colorize("StatusLineNC", "#908caa", "#191724")
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufReadPost", "ColorSchemePre", "ModeChanged", "TabEnter", "TabClosed", "Filetype" },
    { callback = set_stsln }
  )
  local stsln = ""
  stsln = " " .. mode_icon .. " "
  stsln = stsln .. f_icon .. " %t " .. edited .. " "
  stsln = stsln .. "%= %l:%c 󰧱 "
  return stsln
end

return M
