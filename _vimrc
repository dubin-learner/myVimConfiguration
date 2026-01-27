" Set Vim color scheme
set guifont=Monospace\ 13.6
colorscheme duoduo

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
"Plug '~/.vim/plugged/vim-dict-master'
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
  let update_tags_cmd = "ctags -R --verbose"
  if filereadable('./tags')
  else
    execute update_tags_cmd = "ctags -R --c++-kinds=+px --fields=+iaS --extra=+q --verbose"
  endif
  copen
  call asyncrun#run("", "", update_tags_cmd)
endfunction
command UpdateTags call UpdateTags()
map <c-]> g<c-]>
noremap <F3> :PreviewTag<CR>

" Funciton for compile
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

" Function for build project
function! Build(...)
  let build_py = "./build.py"
  if filereadable(build_py)
    let build_cmd = "./build.py -s -i -o output.log"
    let alert_cmd = "tmux display-popup printf 'Project " . getcwd() . " build finished.'"
    if a:0 > 0
      let build_type = a:1
      if build_type == "debug" || build_type == "Debug"
        let build_cmd = build_cmd . " -t Debug"
      elseif build_type == "memcheck" || build_type == "MemCheck"
        let build_cmd = build_cmd . " -t MemCheck"
      elseif build_type == "threadcheck" || build_type == "ThreadCheck"
        let build_cmd = build_cmd . " -t ThreadCheck"
      endif
    endif
    let options = { 'mode': 'async', 'post': 'caddfile output.log' }
    copen
    execute "normal! \<C-w>J"
    call asyncrun#run("", options, build_cmd . ";" . alert_cmd)
  else
    echom "Error: file " . build_py . " not exist!"
  endif
endfunction
command! -nargs=? Build call Build(<f-args>)

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

" Set tags command of fzf.vim (same as previous update tags command)
let g:fzf_vim = {}
let g:fzf_vim.tags_command = 'ctags -R --c++-kinds=+px --fields=+iaS --extra=+q --verbose'
let g:fzf_ag_prg = '~/tools/installs/bin/ag'
" Fix preview error in csh when '!' in current line
if &shell =~# 'csh'
  let s:preview_command = 'bat --color=always --style=numbers --line-ranges=:500 {}'
  let $FZF_DEFAULT_OPTS = '--preview=' . shellescape('sh -c ' . shellescape(s:preview_command))

  if executable('bash')
    let $SHELL = 'bash'
  endif
endif

" Get git blame information of current line
function! GitBlame()
  let filename = expand('%')
  let line_num = line('.')

  " Check if the file is in a Git repository
  let git_dir = system('bash -c "git rev-parse --git-dir 2>/dev/null"')
  if v:shell_error != 0
    echo "Not in a Git repository"
    return
  endif

  let blame_output = system('git blame -L ' . line_num . ',' . line_num . ' -- ' . shellescape(filename))

  " Check if the command executed successfully
  if v:shell_error != 0
      echo "Failed to get blame information"
      return
  endif
  
  let blame_info = split(blame_output, '\n')[0]
  let parts = matchlist(blame_info, '^\(\x\{8}\) \(.*+\d\{4}\)')
  if len(parts) <= 2
    echo "Failed to match blame information"
    return
  endif

  let hash_commit = parts[1]
  let git_log_oneline_output = system('git log -1 ' . hash_commit . ' --oneline')
  if v:shell_error != 0
      echo "Failed to get log information"
      return
  endif

  let log_info = split(git_log_oneline_output, '\n')[0][7:]
  echo parts[0] . ')' . log_info
endfunction
command! GitBlame call GitBlame()

" Maximize current window width/height, use <C-w>= to restore
command! Focus execute "normal! \<C-w>_\<C-w>|"
