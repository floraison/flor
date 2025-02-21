
" MIT licensed


" in the vimrc file itself:
"au BufRead *.flo set filetype=flor
"au BufRead *.flor set filetype=flor
"au BufRead *.flon set filetype=flor
"au BufRead *.fln set filetype=flor


" Quit when a (custom) syntax file is already loaded
if exists("b:current_syntax")
  finish
endif


syn match florSpecial ";"
syn match florSpecial "|"
syn match florSpecial "\\"
syn match florSpecial "\v\s_"
"syn match florOn /\v^\s*on\s(cancel|error|receive)\b/
"syn match florOn "on receive"
syn match florHead /^[ ]*[^ ;#\[\]{}()]\+/
syn match florHead /;\@<=[ ]*[^ ;#\[\]{}()]\+/
syn match florKey /\v\zs[^' ]+\ze[ ]*:/
syn keyword florKey if unless

syn region florString start=+"+  skip=+\\"+  end=+"+
syn region florString start=+'+  skip=+\\'+  end=+'+
syn region florString start=+/+  skip=+\\/+  end=+/+
syn region florComment start="#" end="\n"

hi def link florHead Keyword
hi def link florString String
hi def link florComment Comment
hi def link florSpecial Special
hi def link florKey Keyword
"hi def link florOn Keyword

let b:current_syntax = "flor"

