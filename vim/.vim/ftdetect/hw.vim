let s:scriptdir = expand('<sfile>:h')

function s:load_pandoc()
    if exists("loaded_pandoc")
        finish
    endif
    let g:loaded_pandoc=1

python3 << EOF
import sys
import vim
sys.path.append(vim.eval("s:scriptdir"))
import hw
hw.main()
EOF

    set filetype=hw.pandoc.markdown

    autocmd BufReadPost,BufWritePost,CursorHold,CursorHoldI,InsertLeave * python3 hw.refresh()
endfunction

autocmd BufRead,BufNewFile *.hw call s:load_pandoc()
