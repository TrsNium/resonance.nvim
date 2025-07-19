" Vim filetype plugin for TidalCycles
" Language: TidalCycles

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" Set local options
setlocal commentstring=--\ %s
setlocal comments=:--
setlocal formatoptions-=t formatoptions+=croql

" Set indentation (Haskell-style)
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal autoindent
setlocal smartindent

" Match words for % jumping
let b:match_words = '\<do\>:\<return\>,' .
  \ '\<if\>:\<then\>:\<else\>,' .
  \ '\<case\>:\<of\>,' .
  \ '\<let\>:\<in\>'

" Set undo options
let b:undo_ftplugin = "setl com< cms< fo< ts< sts< sw< et< ai< si<"