" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=2		" more powerful backspacing

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

syntax on

set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set nu
set autoindent 
set cindent


"=========== vundle plugin config==========
set nocompatible 
filetype off 
" 插件位置
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" =========vundle开始，写git地址即可=======
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'dracula/vim'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-markdown'
Plugin 'suan/vim-instant-markdown'
Plugin 'majutsushi/tagbar'
Plugin 'ervandew/supertab'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'valloric/youcompleteme'

call vundle#end()            " required
filetype plugin indent on    " required
" ------------------------------------------
nmap <F5> :NERDTreeToggle<cr>

" Javascript syntax hightlight
syntax enable

" Set syntax highlighting for specific file types
autocmd BufRead,BufNewFile Appraisals set filetype=ruby
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd Syntax javascript set syntax=jquery

" Color scheme
" colorscheme molokai
highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0

" Backspace deletes like most programs in insert mode
set backspace=2
" Show the cursor position all the time
set ruler
" Display incomplete commands
set showcmd
" Set fileencodings
set fileencodings=utf-8,bg18030,gbk,big5

filetype plugin indent on

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Numbers
set number
set numberwidth=5

set matchpairs+=<:>
set hlsearch

