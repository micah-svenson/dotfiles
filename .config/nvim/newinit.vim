set nocompatible
filetype off

set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin('~/.config/nvim/bundle')

Plugin 'VundleVim/Vundle.vim'
Plugin 'ack.vim'
Plugin 'indentpython.vim' 
Plugin 'vim-syntastic/syntastic' 
Plugin 'nvie/vim-flake8'
Plugin 'scrooloose/nerdcommenter'
"Plugin 'vim-scripts/DoxygenToolkit.vim'
Plugin 'joshdick/onedark.vim'
Plugin 'itchyny/lightline.vim'
"Plugin 'HerringtonDarkholme/yats.vim'
"Plugin 'mhartington/nvim-typescript', {'do': './install.sh'}
Plugin 'tmhedberg/SimpylFold'
"Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
call vundle#end()

filetype plugin indent on

"--------------------------

colorscheme onedark

syntax enable
let python_highlight_all=1
syntax on


"let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

" pep8 formatting
au BufNewFile,BufRead *.py:
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix

"define BadWhitespace before using in a match
highlight BadWhitespace ctermbg=grey guibg=darkred

" flag white space
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h,*.cpp,*.hpp match BadWhitespace /\s\+$/

" autcomplete close window and map goto
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

"python with virtualenv support
py3 << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

nnoremap <Space> i_<Esc>r

set number
set showcmd
set cursorline

set wildmenu
set showmatch

set incsearch
set hlsearch

nnoremap j gj
nnoremap k gk

inoremap kj <Esc>

let mapleader=","

nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader><space> :nohlsearch<CR>


nmap <leader>t :NERDTreeToggle<CR>

nnoremap ; :
nnoremap : ;
nnoremap fl :Explore

set splitbelow
set splitright

set encoding=utf-8

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>

nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

set clipboard=unnamedplus

set autochdir
