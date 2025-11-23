local lspconfig = require('lspconfig')
local fzf = require('fzf-lua')

require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true
    },
    indent = {
        enable = true
    }
}

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
    if vim.tbl_count(vim.lsp.get_clients()) == 0 then return '' end
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

local settings = vim.tbl_deep_extend(
    "keep",
    require('lspsettings').settings,
    {
        ['rust-analyzer'] = {
            checkOnSave = true,
            check = {
                command = "clippy",
                allTargets = true
            },
        }
    }
)

lspconfig.util.default_config = vim.tbl_deep_extend(
    "force",
    lspconfig.util.default_config,
    { 
        on_attach = status.on_attach,
        capabilities = capabilities,
        settings = settings
    }
)

lspconfig.rust_analyzer.setup {
    cmd = { vim.fn.executable('ra-multipex') and 'ra-multiplex' or 'rust-analyzer' }
}
lspconfig.clangd.setup {}
lspconfig.pylsp.setup {}

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

group = vim.api.nvim_create_augroup('UserLspConfig', {})
vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(env)
        local opts = { buffer = env.buf }
        vim.keymap.set('n', 'gD', fzf.lsp_declarations, opts)
        vim.keymap.set('n', 'gd', fzf.lsp_definitions, opts)
        vim.keymap.set('n', 'gy', fzf.lsp_typedefs, opts)
        vim.keymap.set('n', 'gi', fzf.lsp_implementations, opts)
        vim.keymap.set('n', 'gr', fzf.lsp_references, opts)
        vim.keymap.set('n', 'go', fzf.lsp_document_symbols)
        vim.keymap.set('n', 'gs', function() vim.lsp.buf.workspace_symbol('') end)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({'n', 'v'}, '<leader>d', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>g', function()
                vim.lsp.buf.code_action({ context = { only = {'quickfix' } }, apply = true})
            end, opts)
        vim.api.nvim_create_autocmd('BufWritePre', { pattern = {'*.rs'}, group = group, callback = function() vim.lsp.buf.format() end })

        local client = vim.lsp.get_client_by_id(env.data.client_id)
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true)
        end

        if client.server_capabilities.documentHighlightProvidor then
            vim.api.nvim_create_autocmd('CursorHold', { callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd('CursorHoldI', { callback = vim.lsp.buf.document_highlight })
        end
        vim.api.nvim_create_autocmd('CursorMoved', { callback = vim.lsp.buf.clear_references })
    end
})

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
    "rust"
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {},
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Tab>", -- set to `false` to disable one of the mappings
      node_incremental = "<Tab>",
      node_decremental = "<S-Tab>",
    },
  },
}

-- local llm = require('llm')
-- 
-- llm.setup({
--   api_token = "no token",
--   tokens_to_clear = { "<EOT>" },
--   fim = {
--     enabled = true,
--     prefix = "<PRE> ",
--     middle = " <MID>",
--     suffix = " <SUF>",
--   },
--   query_params = {
--     maxNewTokens = 60,
--     temperature = 0.2,
--     topP = 0.95,
--     stop_tokens = nil,
--   },
--   model = "http://localhost:11434/api/generate",
--   context_window = 4096,
--   tokenizer = {
--     repository = "codellama/CodeLlama-7b-hf",
--   },
--   adaptor = "ollama",
--   request_body = { model = "codellama:7b-code" },
--   lsp = {
--     bin_path = "/Users/jonathan/.cargo/bin/llm-ls"
--   },
--   enable_suggestions_on_startup = true,
--   enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
-- })
