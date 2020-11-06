if &shell =~# 'fish$'
    set shell=zsh
endif

set scrolloff=4 backspace=indent,eol,start
set shiftwidth=4 tabstop=4 expandtab autoindent smartindent
if system("uname -s") == "Darwin\n"
    set clipboard=unnamed
else
    set clipboard=unnamedplus
endif
syntax on
autocmd BufWritePost src.md silent !render.sh
autocmd Filetype gitcommit set textwidth=72
map ; :
