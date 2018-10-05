#!/bin/bash

vim --version

curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo
yum -y install vim git
yum update vim*
vim --version 

mkdir -p ~/.vim/autoload 
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

cat <<EOF > ~/.vimrc
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'Blackrush/vim-gocode'
Plug 'fatih/molokai'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'SirVer/ultisnips'
Plug 'ctrlpvim/ctrlp.vim'
" Initialize plugin system
call plug#end()

""""""""""""""""""""""
"      Settings      "
"""""""""""""""""""""

set encoding=utf-8
set autoindent
autocmd BufWritePre *.go :Fmt


" Colorscheme
syntax enable
set t_Co=256
let g:rehash256 = 1
let g:molokai_original = 1
colorscheme molokaiu
EOF
