" Vim color file
"  Maintainer: Tiza
" Last Change: 2002/10/14 Mon 16:41.
"     version: 1.0
" This color scheme uses a light background.

set background=light
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "autumn"

hi Normal       guifg=#404040 guibg=#fff4e8

" Search
hi IncSearch    gui=UNDERLINE guifg=#404040 guibg=#e0e040
hi Search       gui=NONE guifg=#544060 guibg=#f0c0ff

" Messages
hi ErrorMsg     gui=BOLD guifg=#f8f8f8 guibg=#4040ff
hi WarningMsg   gui=BOLD guifg=#f8f8f8 guibg=#4040ff
hi ModeMsg      gui=NONE guifg=#d06000 guibg=NONE
hi MoreMsg      gui=NONE guifg=#0090a0 guibg=NONE
hi Question     gui=NONE guifg=#8000ff guibg=NONE

" Split area
hi StatusLine   gui=BOLD guifg=#f8f8f8 guibg=#904838
hi StatusLineNC gui=BOLD guifg=#c0b0a0 guibg=#904838
hi VertSplit    gui=NONE guifg=#f8f8f8 guibg=#904838
hi WildMenu     gui=BOLD guifg=#f8f8f8 guibg=#ff3030

" Diff
hi DiffText     gui=NONE guifg=#2850a0 guibg=#c0d0f0
hi DiffChange   gui=NONE guifg=#208040 guibg=#c0f0d0
hi DiffDelete   gui=NONE guifg=#ff2020 guibg=#eaf2b0
hi DiffAdd      gui=NONE guifg=#ff2020 guibg=#eaf2b0

" Cursor
hi Cursor       gui=NONE guifg=#ffffff guibg=#0080f0
hi lCursor      gui=NONE guifg=#ffffff guibg=#8040ff
hi CursorIM     gui=NONE guifg=#ffffff guibg=#8040ff

" Fold
hi Folded       gui=NONE guifg=#804030 guibg=#ffc0a0
hi FoldColumn   gui=NONE guifg=#a05040 guibg=#f8d8c4

" Other
hi Directory    gui=NONE guifg=#7050ff guibg=NONE
hi LineNr       gui=NONE guifg=#e0b090 guibg=NONE
hi NonText      gui=BOLD guifg=#a05040 guibg=#ffe4d4
hi SpecialKey   gui=NONE guifg=#0080ff guibg=NONE
hi Title        gui=BOLD guifg=fg      guibg=NONE
hi Visual       gui=NONE guifg=#804020 guibg=#ffc0a0
" hi VisualNOS  gui=NONE guifg=#604040 guibg=#e8dddd

" Syntax group
hi Comment      gui=NONE guifg=#ff5050 guibg=NONE
hi Constant     gui=NONE guifg=#00884c guibg=NONE
hi Error        gui=BOLD guifg=#f8f8f8 guibg=#4040ff
hi Identifier   gui=NONE guifg=#b07800 guibg=NONE
hi Ignore       gui=NONE guifg=bg guibg=NONE
hi PreProc      gui=NONE guifg=#0090a0 guibg=NONE
hi Special      gui=NONE guifg=#8040f0 guibg=NONE
hi Statement    gui=BOLD guifg=#80a030 guibg=NONE
hi Todo         gui=BOLD,UNDERLINE guifg=#0080f0 guibg=NONE
hi Type         gui=BOLD guifg=#b06c58 guibg=NONE
hi Underlined   gui=UNDERLINE guifg=blue guibg=NONE
