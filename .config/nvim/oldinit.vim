set shell=/bin/zsh

" =============================================================================
" PlugIns
" =============================================================================
call vundle#begin()

" Vim Plugin Manager
Plugin 'VundleVim/Vundle.vim'

" Comment toggling with <leader> + c + Space
Plugin 'scrooloose/nerdcommenter'

" Replacement for netrw
Plugin 'scrooloose/nerdtree'

" This is needed so vim recognizes TOML syntax
Plugin 'cespare/vim-toml'

" A pack with like 10,000 color schemes
Plugin 'flazz/vim-colorschemes'

" Allows for easy switching of colorschemes with F8, Shift+F8
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-colorscheme-switcher'

" Shakespeare Coloring
Plugin 'pbrisbin/vim-syntax-shakespeare'

" Git wrapper
Plugin 'https://github.com/tpope/vim-fugitive'

" Typescript
Plugin 'leafgarland/typescript-vim'

" Code completion
Plugin 'neoclide/coc.nvim', {'branch': 'release'}

" Linting
Plugin 'dense-analysis/ale'
call vundle#end()

" =============================================================================
" End of PlugIns
" =============================================================================

" If the filetype is known by vim, it does some useful stuff
set nocompatible
filetype plugin indent on
syntax enable

" Relative Numbering
set number relativenumber

" A neat little trick I learned, basically a fuzzy file finder
set path=$PWD/**
set wildmenu
set showmatch

" Colorscheme
colorscheme up

" Tabbing/formatting stuff
"set tabstop=2
"set softtabstop=2
set expandtab
set shiftwidth=2
set textwidth=80
set autoindent
"set fileformat=unix
set wrap
set formatoptions-=t
autocmd BufRead,BufNewFile * setlocal formatoptions-=t
autocmd BufRead,BufNewFile *.cpp setlocal formatoptions+=t
autocmd BufRead,BufNewFile *.hpp setlocal formatoptions+=t
autocmd BufRead,BufNewFile *.c setlocal formatoptions+=t
autocmd BufRead,BufNewFile *.h setlocal formatoptions+=t
autocmd BufRead,BufNewFile *.py setlocal formatoptions+=t
autocmd BufRead,BufNewFile *.ts setlocal textwidth=100
autocmd BufRead,BufNewFile *.ts setlocal shiftwidth=4
autocmd BufWritePost *.tex silent exec "!pdflatex -output-directory=%:h % >/dev/null 2>&1" | redraw!
autocmd BufWritePost *.md silent exec "!pandoc ~/Documents/simulator_saves.md -o ~/Documents/simulator_saves.pdf --from markdown --template eisvogel --listings" | redraw!

" Show which line you're on
set cursorline

" Turns on incremental (search as you type) and highlighted searching
set incsearch
set hlsearch

" Move by the lines displayed, not the physical lines
nnoremap j gj
nnoremap k gk

" Move to beginning and end of line easier
nnoremap L $
nnoremap H ^

" Use jk instead of <Esc> to exit insert mode
inoremap jk <Esc>

" Set leader to comma
let mapleader=","

" Edit vimrc with ev, source with sv
nnoremap <leader>ev :sp $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Remove highlights from searching
nnoremap <leader><space> :nohlsearch<CR>

" Don't worry about pressing Shift with :
nnoremap ; :
nnoremap : ;

" New splits are either below or to the right for consistency
set splitbelow
set splitright

" UTF-8
set encoding=utf-8

" Sets the clipboard to the system clipboard
set clipboard=unnamedplus

" Don't allow scrolling into the bottom or top 5 lines
set scrolloff=5

" Set folding stuff
set foldmethod=indent
set foldnestmax=3
set nofoldenable
set foldlevelstart=200

" C-Support extra tools
let g:C_UseTool_doxygen='yes'

" Color the 80th column in the active split
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul
    autocmd WinLeave * set nocul
augroup END

" Updates the header on save
function! LastModified()
  let save_cursor = getpos(".")
  let n = min([40, line("$")])
  let line_found = search("Last ", "nw")
  if line_found > 0 && line_found < 40
    exe 'undojoin | 1,' . n . 's#Last \_.\{-}\*/#Last edited by Connor Johnstone <connor.johnstone@palski.com>\r * ' . strftime('%c') . '\r */'
  endif
  call histdel('search', -1)
  call setpos('.', save_cursor)
endfun
autocmd BufWritePre *.ts call LastModified()

" NERDTree automatic startup stuff
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif

" Nerdtree at C-n
map <C-n> :NERDTreeToggle<CR>

" Prettify json line
nnoremap <leader>json :.put! =execute('.w !json_xs -f json -t json-pretty')<CR>jdd
function! ToggleJSONFormat()
  if &syntax=='json'
    set syntax=off
  else
    set syntax=json
  endif
endfunction
nnoremap <leader>jsyn :call ToggleJSONFormat()<CR>

" Use mouse
set mouse=nv

" Case insensitive
set ignorecase
set smartcase

" CoC settings
set signcolumn=yes
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>

" TSLint
let g:ale_fixers = { 'javascript': ['tslint', 'eslint'], 'typescript': ['tslint', 'eslint'] }
let g:ale_completion_tsserver_autoimport = 1
nmap <F7> <Plug>(ale_fix)
