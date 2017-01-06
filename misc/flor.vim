
" MIT license


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
syn match florSpecial "\\"
syn match florHead /^[ ]*[^ ;#\[\]{}()]\+/
syn match florHead /;\@<=[ ]*[^ ;#\[\]{}()]\+/
syn match florKey /\v\zs[^\s]+\ze[\s]*:/
syn keyword florKey if unless

syn region florComment start="#" end="\n"

syn region florString start=+"+  skip=+\\"+  end=+"+
syn region florString start=+'+  skip=+\\'+  end=+'+
syn region florString start=+/+  skip=+\\/+  end=+/+

hi def link florHead Keyword
hi def link florString String
hi def link florComment Comment
hi def link florSpecial Special
hi def link florKey Keyword

let b:current_syntax = "flor"

