" Set Vim color scheme
set guifont=Monospace\ 13.6
colorscheme duoduo
let g:airline_theme='ayu_dark'

" Set colorscheme for dark/light mode in MacOS
if has('mac') || has('macunix')
  silent let s:is_dark = system("defaults read -g AppleInterfaceStyle 2>/dev/null")
  let g:is_night_mode = (v:shell_error == 0)
else
  let g:is_night_mode = 1
endif

if g:is_night_mode
  colorscheme duoduo
  let g:airline_theme='ayu_dark'
else
  colorscheme shine
  let g:airline_theme='ayu_light'
endif

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
Plug 'vim-airline/vim-airline-themes'
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
if g:is_night_mode
  highlight PMenuSel ctermbg=lightblue
  highlight CursorLine cterm=NONE ctermbg=240
endif

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
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-c': 'vsplit' }
" Fix preview error in csh when '!' in current line
if &shell =~# 'csh'
  let s:preview_command = 'bat --color=always --style=numbers --line-ranges=:500 {}'
  let $FZF_DEFAULT_OPTS = '--preview=' . shellescape('sh -c ' . shellescape(s:preview_command))

  if executable('bash')
    let $SHELL = 'bash'
  endif
endif

" Maximize current window width/height, use <C-w>= to restore
command! Focus execute "normal! \<C-w>_\<C-w>|"

" Change tab styles
highlight TabLine ctermfg=240 ctermbg=bg
highlight TabLineSel ctermfg=fg ctermbg=240
highlight TabLineFill ctermfg=bg ctermbg=fg
highlight TabLineTable ctermfg=bg ctermbg=darkgreen

" Display tab ids, modified flag and filename
function! MyTabLine()
  let s = '%#TabLineTable#' . ' tabs '
  for i in range(tabpagenr('$'))
    " tab ids from 1 to N
    let tabnr = i + 1
    let winnr = tabpagewinnr(tabnr)
    let buflist = tabpagebuflist(tabnr)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let modified_flag = getbufvar(bufnr, '&modified') ? ' [+]' : ''
    let filetype = getbufvar(bufnr, '&filetype')
    let filename = fnamemodify(bufname, ':t')
    if filetype == 'qf'
      let filename = '[Quickfix]'
    elseif filetype == 'help'
      let filename = '[Help]'
    elseif filetype == 'gitblame'
      let filename = '[GitBlame]'
    elseif filename == ''
      let filename = '[No Name]'
    endif
    if tabnr == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    let s .= ' ' . tabnr . ':'. modified_flag . filename . ' '
  endfor
  let s .= '%#TabLineFill#'
  return s
endfunction
set tabline=%!MyTabLine()

" Auto set light/dark colorscheme following system light/dark mode
function! SetThemeBySystemAppearance()
  silent let s:is_dark = system("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if v:shell_error == 0
    colorscheme duoduo
    highlight PMenuSel ctermbg=lightblue
    highlight CursorLine cterm=NONE ctermbg=240
    let g:airline_theme='ayu_dark'
  else
    colorscheme shine
    let g:airline_theme='ayu_light'
  endif
endfunction
if has('mac') || has('macunix')
  autocmd BufRead,BufNewFile * call SetThemeBySystemAppearance()
endif
autocmd VimEnter * AirlineRefresh

function! GitBlame()
    " 检查当前文件是否在 Git 仓库中
    if !filereadable('.git/config') && !findfile('.git', '.;') != ''
        echo "Not in a git repository"
        return
    endif
    
    " 获取当前文件的一些信息
    let current_file = expand('%:p')
    let current_linenum = line('.')
    let current_filename = expand('%:t')
    
    " 创建临时文件名（用于存储 blame 结果）
    let temp_file = tempname()
    
    " 执行 git blame，使用人性化格式
    " -w: 忽略空白字符变更
    " --date=short: 显示短日期格式
    " --pretty: 显示作者和时间
    execute "silent !git blame -w --date=short --pretty=format:\"%h %an %ad %s\" " . shellescape(current_file) . " > " . temp_file
    
    " 检查命令是否执行成功
    if v:shell_error != 0
        call delete(temp_file)
        echo "Git blame failed"
        return
    endif
    
    " 设置窗口属性
    tabnew
    setlocal buftype=nofile      " 不与文件关联
    setlocal bufhidden=hide      " 隐藏时不删除
    setlocal noswapfile          " 不使用交换文件
    
    " 读取 blame 结果
    execute "read " . temp_file
    
    " 删除第一行（空行）
    normal! ggdd

    " 跳转到指定行并居中显示
    execute "normal! " . current_linenum . "G"
    normal! zz
    
    " 删除临时文件
    call delete(temp_file)

    " 在删除第一行后设置不可修改，否则报错
    setlocal readonly            " 只读模式
    setlocal nomodifiable        " 不可修改
    
    " 设置文件类型为 git blame（可选语法高亮）
    setfiletype gitblame
    
    " 设置窗口标题
    execute "setlocal statusline=Git\\ Blame:\\ " . current_filename
    
    " 添加语法高亮（可选）
    if !exists("g:loaded_gitblame_syntax")
        syntax match GitBlameHash   '^\x\+' 
        syntax match GitBlameAuthor '\x\+\s\+\zs[^(]*\ze\s\+('
        syntax match GitBlameDate   '(\zs\d\{4}-\d\{2}-\d\{2\}\ze\s'
        syntax match GitBlameCommit '[^)]*)$'
        
        highlight default link GitBlameHash   Identifier
        highlight default link GitBlameAuthor Function
        highlight default link GitBlameDate    Comment
        highlight default link GitBlameCommit  String
        
        let g:loaded_gitblame_syntax = 1
    endif
    
    echo "Git blame loaded in read-only buffer"
    redraw
endfunction
command! GitBlame call GitBlame()

" 辅助函数：查看具体提交，只能在GitBlame的窗口中使用
function! ViewCommit()
  let current_line = getline('.')
  let commit_hash = matchstr(current_line, '^\x\+')
  let commit_info = system('git show --stat ' . commit_hash)
  let lines = split(commit_info, '\n')
  call popup_create(lines, #{title: "Commit: " . commit_hash, border: [], padding: [1,1,1,1]})
endfunction
command! ViewCommit call ViewCommit()
