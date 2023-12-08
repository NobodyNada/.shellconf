if &shell =~# 'fish$'
"    set shell=zsh
endif

let &titlestring = "%t %m"
set shiftwidth=4 tabstop=4 softtabstop=4 expandtab autoindent smartindent title
au Filetype html,xml set shiftwidth=2 tabstop=2 softtabstop=2

set scrolloff=4 backspace=indent,eol,start
set ignorecase smartcase
set laststatus=2 noshowmode
set nohidden
filetype plugin indent on
syntax on
autocmd BufWritePost src.md silent !./render.sh
autocmd BufWritePost *.cho !bash -c "chordpro %:S > %:r:S.pdf"
autocmd BufNewFile *.hw 0r ~/.vim/templates/template.hw
autocmd Filetype gitcommit set textwidth=72
autocmd BufNew * set bufhidden=delete
map ; :
map <C-w>; <C-w>:
tmap <C-w>; <C-w>:
" https://vi.stackexchange.com/a/24983/13011
tmap <C-w><C-w> <C-w>w
tmap <C-e> <C-w>:<C-u>WinResizerStartResize<cr>

set incsearch nohlsearch
augroup vimrc-incsearch-highlight
  autocmd!
  autocmd CmdlineEnter /,\? :set hlsearch
  autocmd CmdlineLeave * :set nohlsearch
augroup END

" smart relativenumber https://jeffkreeftmeijer.com/vim-number/
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" && &buftype != 'terminal' | set rnu cursorline     | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                                            | set nornu nocursorline | endif
:  autocmd TermEnter * setlocal nornu nonu nocursorline
:augroup END
set number
set signcolumn=number

" Save undo history
if has('nvim')
    " only on Neovim because we want to store history in the 
    " data directory, not the working directory
    set undofile
end

if has('nvim-0.10.0')
    let g:clipboard={
                \  'name': 'OSC 52',
                \  'copy': {
                \    '+': v:lua.require('vim.ui.clipboard.osc52').copy('+'),
                \    '*': v:lua.require('vim.ui.clipboard.osc52').copy('*'),
                \  },
                \  'paste': {
                \    '+': v:lua.require('vim.ui.clipboard.osc52').paste('+'),
                \    '*': v:lua.require('vim.ui.clipboard.osc52').paste('*'),
                \  },
                \}
endif
set clipboard=unnamedplus

" Restore cursor position when opening a file (:help last-position-jump)
autocmd BufRead * autocmd FileType <buffer> ++once
  \ if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif

map <SPACE> <leader>

nmap <Leader>r  <Plug>ReplaceWithRegisterOperator
nmap <Leader>rr <Plug>ReplaceWithRegisterLine
nmap <Leader>R <Leader>r$
xmap <Leader>r  <Plug>ReplaceWithRegisterVisual

let g:pandoc#filetypes#pandoc_markdown = 0

let g:AutoPairsMapBS = 1
let g:rust_keep_autopairs_default = 1
au Filetype rust,c,cpp inoremap ;<CR> <End>;<CR>

call plug#begin('~/.vim/plugged')
if has('nvim')
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'tomtomjhj/lsp-status.nvim', {'commit': 'c220c09bc9213c25f445b19e9f1bb33e126b5925'}
    Plug 'L3MON4D3/LuaSnip', {'tag': 'v1.*', 'do': 'make install_jsregexp'}
end
Plug 'dag/vim-fish'
Plug 'rust-lang/rust.vim'
Plug 'maxbane/vim-asm_ca65'
Plug 'LunarWatcher/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ojroques/nvim-lspfuzzy'
Plug 'simeji/winresizer'
Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-fugitive'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'Shirk/vim-gas'
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'tpope/vim-abolish'
Plug 'tikhomirov/vim-glsl'
Plug 'andweeb/presence.nvim'
call plug#end()

" mac terminal supports bold/italics, but doesn't declare it
if has('mac')
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
endif

let g:onedark_terminal_italics = 1

let g:onedark_color_overrides = {
            \ "white": {"gui": "#d0d0d0", "cterm": "252", "cterm16": "7" },
            \ "black": {"gui": "#000000", "cterm": "0", "cterm16": "0"},
            \ "background": {"gui": "#000000", "cterm": "0", "cterm16": "0"},
            \ "red": { "gui": "#ff0087", "cterm": "198", "cterm16": "1" },
            \ "comment_grey": { "gui": "#909797", "cterm": "246", "cterm16": "1" },
            \ "cursor_grey": {"gui": "#121212", "cterm": "233", "cterm16": "0"},
      \ }

function! s:extend_highlights()
    call onedark#set_highlight("TypeDeclaration", {"fg": s:colors.yellow, "gui": "bold", "cterm": "bold"})
    call onedark#set_highlight("CocSemProperty", {"fg": s:colors.blue})
    call onedark#set_highlight("CocSemLibraryProperty", {"fg": s:colors.blue, "gui": "bold", "cterm": "bold"})
    call onedark#set_highlight("Function", {"fg": s:colors.cyan})
    call onedark#set_highlight("LibraryFunction", {"fg": s:colors.cyan, "gui": "bold", "cterm": "bold"})
    call onedark#set_highlight("Identifier", {"fg": s:colors.white, "gui": "italic", "cterm": "italic"})
    call onedark#set_highlight("IdentifierDeclaration", {"fg": s:colors.white})
    call onedark#set_highlight("StorageClass", {"fg": s:colors.yellow, "gui": "italic", "cterm": "italic"})
    call onedark#set_highlight("Conditional", {"fg": s:colors.purple, "gui": "bold", "cterm": "bold"})
    call onedark#set_highlight("DiagnosticSignError", {"fg": s:colors.black, "bg": s:colors.red})
    call onedark#set_highlight("DiagnosticSignWarn", {"fg": s:colors.black, "bg": s:colors.yellow})
endfunction

if has_key(g:plugs, "onedark.vim")
    let s:colors = onedark#GetColors()
    augroup colorextend
        autocmd!
        autocmd ColorScheme * call s:extend_highlights()
    augroup END

    colorscheme onedark
endif

highlight Pmenu ctermfg=cyan ctermbg=black
highlight CocErrorHighlight ctermfg=white ctermbg=red
highlight CocWarningHighlight ctermfg=yellow cterm=bold,underline
highlight CocErrorFloat ctermfg=red cterm=bold
highlight CocWarningFloat ctermfg=yellow cterm=bold
highlight CocInlayHint cterm=italic ctermfg=240
hi link CocSemStruct Type
hi link CocSemDeclarationStruct TypeDeclaration
hi link CocSemDeclarationEnum TypeDeclaration
hi link CocSemDeclarationClass TypeDeclaration
hi link CocSemDeclarationVariable IdentifierDeclaration
hi link CocSemDeclarationParameter IdentifierDeclaration
hi link CocSemControlFlow Conditional
hi link CocSemMethod Function
hi link CocSemLibraryMethod LibraryFunction

hi LspReferenceText ctermbg=236
hi LspReferenceRead ctermbg=236
hi LspReferenceWrite ctermbg=52

let g:gitgutter_highlight_linenrs = 1
let g:gitgutter_sign_added = ''
let g:gitgutter_sign_modified = ''
let g:gitgutter_sign_modified_removed = ''
let g:gitgutter_sign_removed = ''
hi link GitGutterAddLineNr GitGutterAdd
hi link GitGutterDeleteLineNr GitGutterDelete
hi link GitGutterChangeLineNr GitGutterChange
hi link GitGutterChangeDeleteLineNr GitGutterChange

let s:cached_git_status=""
function! CachedGitStatus()
    if empty(s:cached_git_status)
        let s:cached_git_status=FugitiveHead()
    end
    return s:cached_git_status
endfunction
autocmd User FugitiveChanged let s:cached_git_status=""

let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'lspstatus' ] ]
      \ },
      \ 'component_expand': {
      \   'lspstatus': 'LightlineLspStatus',
      \ },
      \ 'component_type': {
      \   'lspstatus': 'raw'
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'gitbranch': 'CachedGitStatus'
      \ },
      \ }
function! LightlineLspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return '%< %{luaeval("require(''lsp-status'').status()")}'
  else
    return ''
  endif
endfunction
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : &modifiable ? '' : ' -'
  return filename . modified
endfunction
autocmd LspAttach * call lightline#update()

let g:coc_status_error_sign = '❌'
let g:coc_status_warning_sign = "⚠"

let g:closetag_filetypes = 'html,xhtml,phtml,xml'

" https://github.com/neoclide/coc.nvim/issues/4059
let g:auto_session_pre_save_cmds = ["call coc#float#close_all()"]

set updatetime=300

if has_key(g:plugs, "coc.nvim")
    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Use tab for trigger completion with characters ahead and navigate.
    inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1):
          \ <SID>check_back_space() ? "\<Tab>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

    " Make <CR> to accept selected completion item or notify coc.nvim to format
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)
    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)
    nmap <silent> <leader>g <Plug>(coc-fix-current)
    command! -nargs=* -range CocFix    :call CocActionAsync('codeActionRange', <line1>, <line2>, 'quickfix')

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call <SID>show_documentation()<CR>
    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      elseif has_key(g:plugs, "coc.nvim") && (coc#rpc#ready())
        call CocActionAsync('doHover')
      else
        execute '!' . &keywordprg . " " . expand('<cword>')
      endif
    endfunction

        " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)

    " Formatting selected code.
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

    " Show all diagnostics.
    nnoremap <silent><nowait> <Leader>a  :<C-u>CocList diagnostics<cr>
    " Find symbol of current document.
    nnoremap <silent><nowait> <Leader>o  :<C-u>CocList outline<cr>
    " Search workspace symbols.
    nnoremap <silent><nowait> <Leader>s  :<C-u>CocList -I symbols<cr>
    " Resume latest coc list.
    nnoremap <silent><nowait> <Leader>p  :<C-u>CocListResume<CR>

    " Applying code actions to the selected code block
    " Example: `<leader>dap` for current paragraph
    xmap <leader>d  <Plug>(coc-codeaction-selected)
    nmap <leader>d  <Plug>(coc-codeaction-selected)

    nmap <leader>dd  <Plug>(coc-codeaction-line)
    nmap <leader>D   <leader>d$
    " Remap keys for applying code actions at the cursor position
    nmap <leader>dc  <Plug>(coc-codeaction-cursor)
    " Remap keys for apply code actions affect whole buffer
    nmap <leader>ds  <Plug>(coc-codeaction-source)

    " Remap keys for applying refactor code actions
    nmap <silent> <leader>xe <Plug>(coc-codeaction-refactor)
    xmap <silent> <leader>x  <Plug>(coc-codeaction-refactor-selected)
    nmap <silent> <leader>x  <Plug>(coc-codeaction-refactor-selected)
    nmap <silent> <leader>xx <Plug>(coc-codeaction-refactor-line)
    nmap <silent> <leader>X  <leader>x$


    " Add `:Format` command to format current buffer.
    command! -nargs=0 Format :call CocAction('format')
endif

" fuzzy find files & buffers
nnoremap <silent><nowait> <Leader>f :GFiles<cr>
nnoremap <silent><nowait> <Leader>F :Files<cr>
nnoremap <silent><nowait> <Leader>b :Buffers<cr>

" use n/N to repeat last jump/goto action
let s:jump_next = "n"
let s:jump_prev = "N"
function JumpNext(...)
    if a:0 == 0
        return s:jump_next
    elseif a:0 == 2
        let s:jump_next = a:1
        let s:jump_prev = a:2
        return s:jump_next
    elseif a:0 == 3
        let s:jump_next = a:1
        let s:jump_prev = a:2
        return a:3
    endif
endf
function JumpPrev(...)
    if a:0 == 0
        return s:jump_prev
    elseif a:0 == 2
        let s:jump_next = a:1
        let s:jump_prev = a:2
        return s:jump_prev
    elseif a:0 == 3
        let s:jump_next = a:1
        let s:jump_prev = a:2
        return a:3
    endif
endf
noremap <expr> n JumpNext()
noremap <expr> N JumpPrev()

cnoremap <expr> <Enter> getcmdtype() =~# '[?/]' ? JumpNext('n', 'N', '<CR>') : '<CR>'
noremap <expr> * JumpNext('n', 'N', '*')
noremap <expr> ]g JumpNext('<Plug>(diagnostic-goto-next)', '<Plug>(diagnostic-goto-prev)')
noremap <expr> [g JumpPrev('<Plug>(diagnostic-goto-next)', '<Plug>(diagnostic-goto-prev)')
noremap <expr> ]c JumpNext('<Plug>(GitGutterNextHunk)', '<Plug>(GitGutterPrevHunk)')
noremap <expr> [c JumpPrev('<Plug>(GitGutterNextHunk)', '<Plug>(GitGutterPrevHunk)')

inoremap ;<CR> <End>;<CR>

let g:presence_neovim_image_text = 'Neovim'

let g:pandoc#modules#disabled = ["folding"]
