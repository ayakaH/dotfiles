filetype plugin on
filetype on
filetype indent on

set rtp+=~/.vim/bundle/vundle
call vundle#begin()
Plugin 'jiangmiao/auto-pairs'
Plugin 'kien/ctrlp.vim'
Plugin 'jwhitley/vim-matchit'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/taglist.vim'
Plugin 'bling/vim-airline'
Plugin 'altercation/vim-colors-solarized'
Plugin 'easymotion/vim-easymotion'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tomasr/molokai'
Plugin 'sickill/vim-monokai'
Plugin 'terryma/vim-multiple-cursors'
call vundle#end()

set tags=tags
set nocompatible
set nobackup
set nowb
set noswapfile
set ffs=unix,dos,mac
set modelines=0
set guiheadroom=0
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set guifont=Source\ code\ pro\ Regular\ 11
set encoding=utf-8
set scrolloff=3
set autoread
set autoindent
set smartindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
set relativenumber
set ignorecase
set smartcase
set smarttab
set gdefault
set incsearch
set magic
set mat=2
set showmatch
set hlsearch
set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85
set laststatus=2
set runtimepath+=$HOME/.vim/

" colors
set t_Co=256
syntax enable
"set background=dark
colorscheme molokai

" keymappings
let mapleader = ","
nnoremap / /\v
vnoremap / /\v
nnoremap <tab> %
vnoremap <tab> %

"nnoremap <up> <nop>
"#nnoremap <down> <nop>
"#nnoremap <left> <nop>
"#nnoremap <right> <nop>
"#inoremap <up> <nop>
"#inoremap <down> <nop>
"#inoremap <left> <nop>
"#inoremap <right> <nop>
nnoremap j gj
nnoremap k gk
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>
nnoremap ; :
inoremap jj <ESC>
map <leader>q :tabprevious<cr>
map <leader>w :tabnext<cr>
map <leader>e :tabnew<cr>
"  vim-airline
let g:airline_powerline_fonts = 1


" nerdtree
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark
map <leader>nf :NERDTreeFind<cr>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") &&b:NERDTreeType == "primary") | q | endif

