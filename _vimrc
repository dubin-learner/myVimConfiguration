source $VIMRUNTIME/vimrc_example.vim

"colorscheme koehler
colo torte
set background=dark
if has('gui_win32')
  set guifont=Consolas:h12
else
  set guifont=Monospace\ 12
endif

set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
if has("win32")
  set fileencoding=chinese
else
  set fileencoding=utf-8
endif
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
language messages zh_CN.utf-8

set number
set cursorline
set ruler

syntax on
set cindent
set expandtab
set tabstop=2
set shiftwidth=2

"set go=
"set guioptions-=m
set guioptions-=T

inoremap ( ()<ESC>i
inoremap [ []<ESC>i
inoremap { {}<ESC>i
inoremap < <><ESC>i
inoremap " ""<ESC>i
inoremap ' ''<ESC>i
