" Archilang syntax — spec: ~/archilang/SPEC.md
if exists("b:current_syntax") | finish | endif

syntax match alangComment  "#.*$"
syntax match alangName     "^\s*[A-Za-z0-9_-]\+\s*=" contains=alangEq
syntax match alangEq       "=" contained
syntax match alangRef      "{[A-Za-z0-9_-]\+}"
syntax match alangDuplex   "[A-Z]"
syntax match alangMark     "[>|<]"
syntax match alangJoin     "2[xc]\?"
syntax match alangOp       "[\^-]"
syntax match alangParen    "[()]"

highlight default link alangComment Comment
highlight default link alangName    Identifier
highlight default link alangEq      Operator
highlight default link alangRef     Function
highlight default link alangDuplex  Type
highlight default link alangMark    Special
highlight default link alangJoin    Operator
highlight default link alangOp      Operator
highlight default link alangParen   Delimiter

let b:current_syntax = "alang"
