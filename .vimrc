"  ________ __   _(_)_ __ ___  _ __ ___
" |_  /_  / \ \ / / | '_ ` _ \| '__/ __|
"  / / / /   \ V /| | | | | | | | | (__
" /___/___|   \_/ |_|_| |_| |_|_|  \___|


" Configuration file for vim set modelines=0		" CVE-2007-2438
" Normally we use vim-extensions. If you want true vi-compatibility 
" remove change the following statements
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=2		" more powerful backspacing

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup


"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
"" config
syntax on
set cursorline
set wrap
set wildmenu 

" split windows config 
map sl :set splitright<CR>:vsplit<CR>
map sk :set splitbelow<CR>:split<CR>
map <up> :res +5<CR>
map <down> :res -5<CR>
map <left> :vertical resize-5<CR>
map <right> :vertical resize+5<CR>
map wl <C-W>l
map wh <C-W>h
map wj <C-W>j
map wk <C-W>k

" cursor config
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
set scrolloff=5 

" yank to clipboard
if has("clipboard")
  set clipboard=unnamed " copy to the system clipboard
  if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
  endif
endif

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set bomb
set binary
set ttyfast

"" Fix backspace indent allow backspacing over everything in insert mode
set backspace=indent,eol,start

"" Tabs. May be overriten by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

"" Map leader to ,
let mapleader=','

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

"" Directories for swp files
set nobackup
set noswapfile

set fileformats=unix,dos,mac
set showcmd
set shell=/bin/sh

" session management
let g:session_directory = "~/./session"
let g:session_autoload = "no"
let g:session_autosave = "no"
let g:session_command_aliases = 1

" ----个性化配置--------
" 关闭方向键, 强迫自己用 hjkl
" map <Left> <Nop>
" map <Right> <Nop>
" map <Up> <Nop>
" map <Down> <Nop>

"******************************************
"************* vundle plugin config********
"******************************************
set nocompatible 
filetype off 
" 插件位置
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" =========vundle开始，写git地址即可=======
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tomasr/molokai'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-markdown'
Plugin 'suan/vim-instant-markdown'
Plugin 'majutsushi/tagbar'
Plugin 'ervandew/supertab'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'Valloric/YouCompleteMe'
Plugin 'Lokaltog/vim-powerline'
Plugin 'scrooloose/nerdcommenter'
Plugin 'dracula/vim'
Plugin 'tpope/vim-surround'
Plugin 'fatih/vim-go'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/goyo.vim'
Plugin 'ybian/smartim'

call vundle#end()            " required
filetype plugin indent on    " required
"=================Vundle end=================


"****************插件配置********************
"----------------NERDTree--------------------
" F5 打开关闭nerdtree
nmap tt :NERDTreeToggle<cr>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" vim 自动打开nerdtree
" autocmd vimenter * NERDTree
" 显示行号
let NERDTreeShowLineNumbers=0
let NERDTreeAutoCenter=1
" 是否显示隐藏文件
let NERDTreeShowHidden=0
" 设置宽度
let NERDTreeWinSize=31
" 在终端启动vim时，共享NERDTree
let g:nerdtree_tabs_open_on_console_startup=1
" 忽略一下文件的显示
let NERDTreeIgnore=['\.pyc','\~$','\.swp']
" 显示书签列表
let NERDTreeShowBookmarks=1



" Set syntax highlighting for specific file types
autocmd BufRead,BufNewFile Appraisals set filetype=ruby
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd Syntax javascript set syntax=jquery

"----------------color--------------------
" Color scheme
" colorscheme molokai
" highlight NonText guibg=#060606
" highlight Folded  guibg=#0A0A0A guifg=#9090D0
color dracula

