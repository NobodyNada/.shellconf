if &shell =~# 'fish$'
"    set shell=zsh
endif

set scrolloff=4 backspace=indent,eol,start
set shiftwidth=4 tabstop=4 expandtab autoindent smartindent
if system("uname -s") == "Linux\n"
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif
syntax on
autocmd BufWritePost src.md silent !./render.sh
autocmd Filetype gitcommit set textwidth=72
map ; :

filetype plugin indent on
augroup filetypedetect
    au BufNewFile,BufRead *.s,*.inc set ft=asm_ca65
augroup END

call plug#begin('~/.vim/plugged')
Plug 'dag/vim-fish'
Plug 'rust-lang/rust.vim'
Plug 'maxbane/vim-asm_ca65'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
call plug#end()

"if executable('clangd')
"    au User lsp_setup call lsp#register_server({
"    \ 'name': 'clangd',
"    \ 'cmd': {server_info->['clangd', '-background-index']},
"    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp']
"    \ })
"endif


function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    "setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    
    " refer to doc to add more commands
endfunction

let g:lsp_signs_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 0

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
