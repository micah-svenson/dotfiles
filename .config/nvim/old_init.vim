"------------------------
"- Setup plugin manager -  
"------------------------

"set run time path
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin('~/.config/nvim/bundle')

Plugin 'VundleVim/Vundle.vim'
Plugin 'joshdick/onedark.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
"Plugin 'ack.vim'
"Plugin 'indentpython.vim' 
"Plugin 'vim-syntastic/syntastic' 
"Plugin 'nvie/vim-flake8'
"Plugin 'vim-scripts/DoxygenToolkit.vim'
"Plugin 'itchyny/lightline.vim'
"Plugin 'HerringtonDarkholme/yats.vim'
"Plugin 'mhartington/nvim-typescript', {'do': './install.sh'}
"Plugin 'tmhedberg/SimpylFold'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'kien/ctrlp.vim'
"Plugin 'dylanaraps/wal.vim'
call vundle#end()

"turn on plugins file detection and indent
filetype plugin indent on

"----------------------------------------
"- Color Scheme and Syntax Highlighting -
"----------------------------------------

"set colorscheme
colorscheme onedark "wal
"enable syntax highlighting
syntax enable
"force vim to use default highlight colors
syntax on
"set python syntax highlighting
"let python_highlight_all=1
"ignore file types in Nerd Tree display
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


"python with virtualenv support
py3 << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF


" Enable folding
set foldmethod=indent
set foldlevel=99


set number
set showcmd
set cursorline
set wildmenu
set showmatch
set incsearch
set hlsearch
set splitbelow
set splitright
set encoding=utf-8
set clipboard=unnamedplus
set autochdir

"----------------
"- Key Mappings -
"----------------
let mapleader=","
"use semicolon to reach command prompt
nnoremap ; :
nnoremap : ;
" gj moves down to next line even if its a single line thats
nnoremap j gj
nnoremap k gk
" use kj to switch to normal mode  
inoremap kj <Esc>
" toggle nerd tree
nmap <leader>t :NERDTreeToggle<CR>

" navigate between split panes with vim keybindings
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding with the spacebar
nnoremap <space> za
nnoremap <Space> i_<Esc>r

" autcomplete close window and map goto
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

