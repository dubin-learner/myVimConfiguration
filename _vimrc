" Set Vim color scheme
set guifont=Monospace\ 13.6
colorscheme duoduo "set duduo first to support vim-airline style ???
"colorscheme desert

" Set cursor and text format related style
set number
set cursorline
set ruler
set hlsearch

syntax on
set cindent
set expandtab
set shiftwidth=2
set backspace=2 "set backspace to previous line
set wrap

set guioptions=-m
set guioptions=-T
set nobackup
set noundofile
set noswapfile
set autoread

"" Use Vim-plug to manage plugins (offline)
"call plug#begin('~/.vim/plugged')
"Plug '~/.vim/plugged/vim-airline-master'
"Plug '~/.vim/plugged/nerdtree-master'
"Plug '~/.vim/plugged/auto-pairs-master'
"Plug '~/.vim/plugged/vim-gitgutter-main'
"Plug '~/.vim/plugged/vim-auto-popmenu-master'
"Plug '~/.vim/plugged/asyncrun.vim-master'
"Plug '~/.vim/plugged/vim-preview-master'
"Plug '~/.fzf/'
"Plug '~/.vim/plugged/fzf.vim-master'
"call plug#end()

" Use Vim-plug to manage plugins (online)
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'instant-markdown/vim-instant-markdown'
Plug 'preservim/nerdtree'
Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter'
Plug 'skywind3000/vim-dict'
Plug 'skywind3000/vim-auto-popmenu'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/vim-preview'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" Settings for vim-gitgutter
let g:gitgutter_enabled=0
let g:gitgutter_highlight_lines=1
let g:gitgutter_sign_added='+'

" Settings for vim-auto-popmenu
" 1. enable this plugin for filetypes, '*' for all files
let g:apc_enable_ft = {'text':1, 'markdown':1, 'php':1}
" 2. source for dictionary, current or other loaded buffers,see ':help cpt'
set cpt=.,k,w,b
" 3. don't select the first item.
set completeopt=menu,menuone,noselect
" 4. suppress annoy messages.
set shortmess+=c

" BugFix: colorscheme duoduo will set popmenu select both fg and bg black
highlight PMenuSel ctermbg=lightblue
highlight CursorLine cterm=NONE ctermbg=240

" Function for update tags by ctags, find definition/declaration in C++ files
function! UpdateTags()
  if filereadable('./tags')
    execute "!ctags -R --verbose"
  else
    execute "!ctags -R --c++-kinds=+px --fields=+iaS --extra=+q --verbose"
  endif
endfunction
command UpdateTags call UpdateTags()
map <c-]> g<c-]>
noremap <F3> :PreviewTag<CR>

" Funciton for compile xtop
function! CompileProject()
  let compile_csh = "./compile.sh"  
  if filereadable(compile_csh)
    copen
    asyncrun#run("","", compile_csh)
  else
    echom "Error: file ". compile_csh . " not exist!"
  endif
endfunction
command CompileProject call CompileProject()    

" Keymap for internal terminal visual mode
tmap <c-v> <c-\><c-n>

" Function for AsyncRun run grep command and show its results in Quickfix window
function! AsyncGrep(pattern)
  let grep_cmd = "grep " . a:pattern . " -nwr . --include=\"*.h\" --include=\"*.cpp\""
  copen
  call asyncrun#run("!","", grep_cmd)
endfunction
command -nargs=1 AsyncGrep call AsyncGrep(<q-args>)
noremap <F5> :cprev<CR>
noremap <F6> :cnext<CR>

" Jump to the last position when reopen a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
