local overrides_module = {}

-- Modern internal apply function (supports bold, underline=false, link, etc.)
local function apply_override(group_name, attributes)
  if not attributes or attributes == false then
    vim.api.nvim_set_hl(0, group_name, {})
    return
  end

  local highlight_def = {}
  for attr_name, attr_value in pairs(attributes) do
    if attr_name == "fg" or attr_name == "guifg" then
      highlight_def.fg = attr_value
    elseif attr_name == "bg" or attr_name == "guibg" then
      highlight_def.bg = attr_value
    elseif attr_name == "sp" or attr_name == "guisp" then
      highlight_def.sp = attr_value
    elseif attr_name == "ctermfg" then
      highlight_def.ctermfg = attr_value
    elseif attr_name == "ctermbg" then
      highlight_def.ctermbg = attr_value
    elseif attr_name == "ctermul" then
      highlight_def.ctermul = attr_value
    elseif attr_name == "bold"
      or attr_name == "italic"
      or attr_name == "underline"
      or attr_name == "undercurl"
      or attr_name == "strikethrough"
      or attr_name == "reverse" then
      highlight_def[attr_name] = attr_value
    elseif attr_name == "link" then
      highlight_def.link = attr_value
    elseif attr_name == "default" then
      highlight_def.default = attr_value
    elseif attr_name == "force" then
      highlight_def.force = attr_value
    end
  end

  vim.api.nvim_set_hl(0, group_name, highlight_def)
end

-- Public API — supports BOTH old and new calling styles
function overrides_module.set_overrides(first_arg, second_arg)
  local overrides = {}

  if type(first_arg) == "table" and type(second_arg) == "table" then
    -- OLD STYLE (still fully supported — zero breaking changes)
    for _, group_name in ipairs(first_arg) do
      overrides[group_name] = false
    end
    for group_name, attributes in pairs(second_arg) do
      overrides[group_name] = attributes
    end
  elseif type(first_arg) == "table" then
    -- NEW STYLE (recommended)
    overrides = first_arg
  else
    error("color-overrides.nvim: set_overrides expects either one table (new style) or two tables (old style)")
  end

  -- Apply immediately
  for group_name, attributes in pairs(overrides) do
    apply_override(group_name, attributes)
  end

  -- Make persistent across colorscheme changes
  vim.api.nvim_create_augroup("ColorOverrides", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "ColorOverrides",
    callback = function()
      for group_name, attributes in pairs(overrides) do
        apply_override(group_name, attributes)
      end
    end,
    desc = "Re-apply color overrides after colorscheme change",
  })
end

return overrides_module
