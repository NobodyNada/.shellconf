set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
set inccommand=nosplit

function! InsertIfTerminal()
    if &buftype == "terminal"
        startinsert
    endif
endfunction

" https://vi.stackexchange.com/a/3765/13011
autocmd BufWinEnter,WinEnter,TermOpen,CmdlineLeave * call InsertIfTerminal()

" Allow C-w commands in terminal in Neovim
tnoremap <expr> <C-w> '<C-\><C-n><C-w>'.nr2char(getchar())
command! -nargs=* T split | terminal <args>
command! -nargs=* VT vsplit | terminal <args>
autocmd TermClose * bdelete!
