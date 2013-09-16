" Vim color file
"  Maintainer: Tiza
" Last Change: 2002/10/13 Sun 16:59.
"     version: 2.2
" This color scheme uses a dark background.

set background=dark
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "night"

hi Normal       guifg=#f0f0f8 guibg=#303040

" Search
hi IncSearch    gui=UNDERLINE,BOLD guifg=#f0f0f8 guibg=#d000d0
hi Search       gui=BOLD guifg=#ffd0ff guibg=#c000c0

" Messages
hi ErrorMsg     gui=BOLD guifg=#ffffff guibg=#f00080
hi WarningMsg   gui=BOLD guifg=#ffffff guibg=#f00080
hi ModeMsg      gui=BOLD guifg=#00e0ff guibg=NONE
hi MoreMsg      gui=BOLD guifg=#00ffdd guibg=NONE
hi Question     gui=BOLD guifg=#d0d050 guibg=NONE

" Split area
hi StatusLine   gui=NONE guifg=#000000 guibg=#c8c8d8
hi StatusLineNC gui=NONE guifg=#606080 guibg=#c8c8d8
hi VertSplit    gui=NONE guifg=#606080 guibg=#c8c8d8
hi WildMenu     gui=NONE guifg=#000000 guibg=#e0e078

" Diff
hi DiffText     gui=NONE guifg=#ffffff guibg=#40a060
hi DiffChange   gui=NONE guifg=#ffffff guibg=#007070
hi DiffDelete   gui=NONE guifg=#ffffff guibg=#40a0c0
hi DiffAdd      gui=NONE guifg=#ffffff guibg=#40a0c0

" Cursor
hi Cursor       gui=NONE guifg=#ffffff guibg=#d86020
hi lCursor      gui=NONE guifg=#ffffff guibg=#e000b0
hi CursorIM     gui=NONE guifg=#ffffff guibg=#e000b0

" Fold
hi Folded       gui=NONE guifg=#ffffff guibg=#9060c0
hi FoldColumn   gui=NONE guifg=#c0a0ff guibg=#404052

" Other
hi Directory    gui=NONE guifg=#00ffff guibg=NONE
hi LineNr       gui=NONE guifg=#787894 guibg=NONE
hi NonText      gui=BOLD guifg=#8040ff guibg=#383848
hi SpecialKey   gui=BOLD guifg=#60a0ff guibg=NONE
hi Title        gui=BOLD guifg=#f0f0f8 guibg=#9000a0
hi Visual       gui=NONE guifg=#ffffff guibg=#c08040
" hi VisualNOS  gui=NONE guifg=#ffffff guibg=#c08040

" Syntax group
hi Comment      gui=NONE guifg=#e0e070 guibg=NONE
hi Constant     gui=NONE guifg=#f0f0f8 guibg=#4830a0
hi Error        gui=BOLD guifg=#ffffff guibg=#f00080
hi Identifier   gui=NONE guifg=#ffa0ff guibg=NONE
hi Ignore       gui=NONE guifg=#303040 guibg=NONE
hi Number       gui=BOLD guifg=#b8b8c8 guibg=NONE
hi PreProc      gui=NONE guifg=#40ffa0 guibg=NONE
hi Special      gui=NONE guifg=#40f8f8 guibg=#4830a0
hi Statement    gui=BOLD guifg=#00d8f8 guibg=NONE
hi Todo         gui=BOLD guifg=#00ffe0 guibg=#0080a0
hi Type         gui=BOLD guifg=#bbaaff guibg=NONE
hi Underlined   gui=UNDERLINE,BOLD guifg=#f0f0f8 guibg=NONE
