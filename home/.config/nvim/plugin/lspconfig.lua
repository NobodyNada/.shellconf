local lspconfig = require('lspconfig')
require('lspfuzzy').setup {}

local signs = { Error = "❌", Warn = "⚠", Hint = "ℹ︎", Info = "ℹ︎" }

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local status = require('lsp-status')
status.register_progress()
capabilities = vim.tbl_extend('keep', capabilities, status.capabilities)
status_config = {
    indicator_errors = signs.Error,
    indicator_warnings = signs.Warn,
    indicator_hint = signs.Hint,
    indicator_info = signs.Info,
    indicator_ok = '✓',
    indicator_separator = '',
    component_separator = ' ',
    status_symbol = '',
    diagnostics = true,
    current_function = true
}
status.config(status_config)
status.status = function(bufnr)
    bufnr = bufnr or 0
    if vim.tbl_count(vim.lsp.buf_get_clients(bufnr)) == 0 then return '' end
    local buf_diagnostics = status_config.diagnostics and require('lsp-status/diagnostics')(bufnr) or nil
    local only_hint = true
    local some_diagnostics = false
    local status_parts = {}
    if buf_diagnostics then
        if buf_diagnostics.errors and buf_diagnostics.errors > 0 then
          table.insert(status_parts,
                       status_config.indicator_errors .. status_config.indicator_separator .. buf_diagnostics.errors)
          only_hint = false
          some_diagnostics = true
        end

        if buf_diagnostics.warnings and buf_diagnostics.warnings > 0 then
          table.insert(status_parts, status_config.indicator_warnings .. status_config.indicator_separator ..
                         buf_diagnostics.warnings)
          only_hint = false
          some_diagnostics = true
        end
    end

    local msgs = require('lsp-status/statusline').progress()

    local base_status = vim.trim(table.concat(status_parts, status_config.component_separator) .. ' ' .. msgs)
    local symbol = status_config.status_symbol;
    if status_config.current_function then
        local current_function = vim.b.lsp_current_function
        if current_function and current_function ~= '' then
          symbol = symbol .. '(' .. current_function .. ')' .. status_config.component_separator
        end
    end

    if base_status ~= '' then return symbol .. base_status .. ' ' end
    if not status_config.diagnostics then return symbol end
    return symbol .. status_config.indicator_ok .. ' '
end

lspconfig.rust_analyzer.setup {
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = {
                command = "clippy"
            }
        },
    },
    on_attach = status.on_attach,
    capabilities = capabilities
}
lspconfig.clangd.setup {
    on_attach = status.on_attach,
    capabilities = capabilities
}

local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },

    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
    }, {
        { name = 'buffer'}
    }),

    mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
     elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
}


luasnip.setup({
    region_check_events = "InsertLeave",
    delete_check_events = "TextChanged,InsertEnter",
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

vim.diagnostic.config({
    severity_sort = true
})

for type, icon in pairs(signs) do
   local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { texthl = hl, numhl = hl })
end

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<Plug>(diagnostic-goto-prev)', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<Plug>(diagnostic-goto-next)', vim.diagnostic.goto_next)

vim.api.nvim_create_autocmd('CursorHold', { callback = vim.lsp.buf.document_highlight })
vim.api.nvim_create_autocmd('CursorHoldI', { callback = vim.lsp.buf.document_highlight })
vim.api.nvim_create_autocmd('CursorMoved', { callback = vim.lsp.buf.clear_references })

group = vim.api.nvim_create_augroup('UserLspConfig', {})
vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(env)
        local opts = { buffer = env.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'go', vim.lsp.buf.document_symbol)
        vim.keymap.set('n', 'gs', function() vim.lsp.buf.workspace_symbol('') end)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({'n', 'v'}, '<leader>d', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>g', function()
                vim.lsp.buf.code_action({ context = { only = {'quickfix' } }, apply = true})
            end, opts)
        vim.keymap.set('n', '<space>f', function()
                vim.lsp.buf.format { async = true }
            end, opts)
        vim.api.nvim_create_autocmd('BufWritePre', { group = group, callback = function() vim.lsp.buf.format() end })

        local client = vim.lsp.get_client_by_id(env.data.client_id)
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint(env.buf, true)
        end
    end
})

vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buffer,
    callback = function()
        vim.lsp.buf.format { async = false }
    end
})
