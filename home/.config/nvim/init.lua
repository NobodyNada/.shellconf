vim.cmd('source ' .. vim.api.nvim_get_runtime_file('_init.vim', false)[1])

require('lualine').setup {
  options = {
    theme = 'onedark',
    component_separators = { left = '|', right = '|' },
    section_separators   = { left = ' ', right = ' ' },
    alway_show_tabline = false,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
      'branch',
      'diff',
      {
        'diagnostics',
        sections = { 'error', 'warn' }
      },
    },
    lualine_c = {'filename'},
    lualine_x = {
      'lsp_status',
      'encoding', 
      {
        'fileformat',
        icons_enabled = false,
      },
      'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
}

