local U = {}

local color_to_rgb = function(color)
  local function byte(value, offset)
    return bit.band(bit.rshift(value, offset), 0xFF)
  end

  local new_color = vim.api.nvim_get_color_by_name(color)
  if new_color == -1 then
    new_color = vim.opt.background:get() == "dark" and 000 or 255255255
  end

  return { byte(new_color, 16), byte(new_color, 8), byte(new_color, 0) }
end

local blend = function(fg, bg, alpha)
  local fg_rgb = color_to_rgb(fg)
  local bg_rgb = color_to_rgb(bg)

  local function blend_channel(i)
    local ret = (alpha * fg_rgb[i] + ((1 - alpha) * bg_rgb[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02X%02X%02X", blend_channel(1), blend_channel(2), blend_channel(3))
end

U.colorize = function(n, fg, bg)
  vim.api.nvim_set_hl(0, n, { fg = fg, bg = blend(bg, "#191724", 0.1) })
end

U.get_file_icon = function(f_name, ext)
  local status, icons = pcall(require, "nvim-web-devicons")
  if not status then
    return " ", "Normal"
  end
  return icons.get_icon(f_name, ext, { default = true })
end

U.dump = function(items, icon)
  if type(items) ~= "table" or #items < 1 then
    return
  end

  local s = icon and icon .. " " or ""
  for _, item in ipairs(items) do
    if items[#item] == item then
      print(item)
      print(s)
      -- s = s .. item
      goto continue
    end
    -- s = s .. item .. ", "
    ::continue::
  end

  return s
end
return U
