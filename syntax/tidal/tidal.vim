" Vim syntax file for TidalCycles
" Language: TidalCycles
" Maintainer: resonance.nvim

if exists("b:current_syntax")
  finish
endif

" Include Haskell syntax as base
runtime! syntax/haskell.vim
unlet! b:current_syntax

" TidalCycles specific keywords
syn keyword tidalFunction d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16
syn keyword tidalFunction p hush solo mute unmute once asap
syn keyword tidalFunction setcps getcps getnow resetCycles
syn keyword tidalFunction xfade xfadeIn histpan wait waitT jump jumpIn jumpIn' jumpMod jumpMod'
syn keyword tidalFunction mortal interpolate interpolateIn clutch clutchIn anticipate anticipateIn

" Pattern functions
syn keyword tidalPattern sound s n note midinote
syn keyword tidalPattern gain amp pan speed accelerate
syn keyword tidalPattern delay delaytime delayfeedback delayAmp delayTime delayFeedback
syn keyword tidalPattern room size dry roomSize
syn keyword tidalPattern crush coarse bandf bandq
syn keyword tidalPattern cutoff resonance hcutoff hresonance
syn keyword tidalPattern attack hold release sustain
syn keyword tidalPattern orbit channel
syn keyword tidalPattern shape distort

" Pattern transformers
syn keyword tidalTransform fast slow hurry rev palindrome iter iter'
syn keyword tidalTransform every whenmod within
syn keyword tidalTransform chunk chunksOf gap
syn keyword tidalTransform jux juxBy
syn keyword tidalTransform stack cat append
syn keyword tidalTransform overlay superimpose
syn keyword tidalTransform off offBy
syn keyword tidalTransform struct mask
syn keyword tidalTransform scale scaleList
syn keyword tidalTransform choose chooseby chooseBy wchoose wchooseby
syn keyword tidalTransform rand irand perlin
syn keyword tidalTransform sine saw square tri
syn keyword tidalTransform run scan spaceOut

" Operators
syn match tidalOperator "|>|"
syn match tidalOperator "|<|"
syn match tidalOperator "||>"
syn match tidalOperator "<||"
syn match tidalOperator "|+|"
syn match tidalOperator "|-|"
syn match tidalOperator "|*|"
syn match tidalOperator "|/|"
syn match tidalOperator "#"
syn match tidalOperator "##"
syn match tidalOperator "###"
syn match tidalOperator "<\$>"
syn match tidalOperator "<\*>"
syn match tidalOperator "\*>"
syn match tidalOperator "<\*"

" Mini-notation
syn region tidalMiniNotation start=/"/ end=/"/ contains=tidalMiniNotationContent
syn match tidalMiniNotationContent /[0-9a-zA-Z\[\]()<>{}*,.\-~_: ]\+/ contained

" Numbers in patterns
syn match tidalNumber /\<[0-9]\+\(\.[0-9]\+\)\?\>/

" Highlighting
hi def link tidalFunction Function
hi def link tidalPattern Type
hi def link tidalTransform Statement
hi def link tidalOperator Operator
hi def link tidalMiniNotation String
hi def link tidalMiniNotationContent String
hi def link tidalNumber Number

let b:current_syntax = "tidal"