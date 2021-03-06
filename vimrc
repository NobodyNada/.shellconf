if &shell =~# 'fish$'
"    set shell=zsh
endif

set scrolloff=4 backspace=indent,eol,start
set shiftwidth=4 tabstop=4 expandtab autoindent smartindent
set ignorecase smartcase
set laststatus=2
set number
if has('linux')
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif
syntax on
autocmd BufWritePost src.md silent !./render.sh
autocmd BufWritePost *.cho silent !bash -c 'chordpro % 2>/dev/null'
autocmd Filetype gitcommit set textwidth=72
map ; :
map <C-w>; <C-w>:
tmap <C-w>; <C-w>:
" https://vi.stackexchange.com/a/24983/13011
tnoremap <C-w><C-w> <C-w>w
tnoremap <C-e> <C-w>:<C-u>WinResizerStartResize<cr>

map <SPACE> <leader>

filetype plugin indent on
au Filetype html set shiftwidth=2 tabstop=2

call plug#begin('~/.vim/plugged')
Plug 'dag/vim-fish'
Plug 'rust-lang/rust.vim'
Plug 'maxbane/vim-asm_ca65'
Plug 'neoclide/coc.nvim'
Plug 'Raimondi/delimitMate'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'simeji/winresizer'
Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-fugitive'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
call plug#end()

" mac terminal supports bold/italics, but doesn't declare it
if has('mac')
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
endif

let g:onedark_terminal_italics = 1

let g:onedark_color_overrides = {
            \ "black": {"gui": "#000000", "cterm": "0", "cterm16": "0"},
            \ "red": { "gui": "#ff0087", "cterm": "198", "cterm16": "1" },
            \ "comment_grey": { "gui": "#ff0087", "cterm": "109", "cterm16": "1" }
      \ }

function! s:extend_highlights()
    call onedark#set_highlight("Identifier", {"fg": s:colors.purple, "gui": "bold", "cterm": "bold"})
    call onedark#set_highlight("StorageClass", {"fg": s:colors.yellow, "gui": "italic", "cterm": "italic"})
    call onedark#set_highlight("Conditional", {"fg": s:colors.purple, "gui": "bold", "cterm": "bold"})
endfunction

if (has("autocmd"))
    let s:colors = onedark#GetColors()
    augroup colorextend
        autocmd!
        autocmd ColorScheme * call s:extend_highlights()
    augroup END
endif
colorscheme onedark

let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified', 'cocstatus' ] ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

highlight Pmenu ctermfg=cyan ctermbg=black
highlight CocErrorHighlight ctermfg=white ctermbg=red
highlight CocWarningHighlight ctermfg=yellow cterm=bold,underline
highlight CocErrorFloat ctermfg=red cterm=bold
highlight CocWarningFloat ctermfg=yellow cterm=bold

set updatetime=300
"set signcolumn=number

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')


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

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" fuzzy find files & buffers
nnoremap <silent><nowait> <Leader>f :GFiles<cr>
nnoremap <silent><nowait> <Leader>v :Files<cr>
nnoremap <silent><nowait> <Leader>b :Buffers<cr>

" delimitMate: recognize <> pairs only in HTML mode
let delimitMate_matchpairs = "(:),[:],{:}"
au FileType html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
