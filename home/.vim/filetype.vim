if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
    au BufNewFile,BufRead *.s,*.inc set ft=asm_ca65
    au BufNewFile,BufRead *.handlebars set ft=html
augroup END
