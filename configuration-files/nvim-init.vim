set nocompatible " get out of horrible vi-compatible mode
filetype off     " required

call plug#begin('~/.config/nvim/plugged')

Plug 'gmarik/Vundle.vim'
Plug 'dense-analysis/ale'

Plug 'Vigemus/iron.nvim'
Plug 'github/copilot.vim'

Plug 'bfredl/nvim-ipy'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-tbone'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'luispedro/vim-ngless'
" Plug 'kevinw/pyflakes-vim'
Plug 'lukerandall/haskellmode-vim'
Plug 'scrooloose/syntastic'
Plug 'Shougo/vimproc.vim'
Plug 'Shougo/neocomplete.vim'
Plug 'eagletmt/ghcmod-vim'
Plug 'eagletmt/neco-ghc'
Plug 'gerw/vim-latex-suite'
Plug 'itchyny/calendar.vim'
Plug 'jceb/vim-orgmode'
Plug 'chrisbra/csv.vim'
Plug 'jaxbot/semantic-highlight.vim'
Plug 'airblade/vim-gitgutter'
Plug 'jalvesaq/vimcmdline'
Plug 'Shougo/deoplete.nvim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'benekastah/neomake'
Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }

call plug#end()            " required
filetype plugin indent on
filetype plugin on " detect the type of file
filetype on " detect the type of file
let g:haddock_browser = "xdg-open"
let g:haddock_browser_callformat = "%s %s"

let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
"
"


let g:necoghc_enable_detailed_browse = 1
let g:haskellmode_completion_ghc = 0
autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

set ignorecase
set history=1000 " How many lines of history to remember
set cf " enable error files and error jumping
filetype plugin on " load filetype plugins
syntax enable
set hlsearch
set nofoldenable

let g:tex_flavor='latex'
let g:Tex_FoldedSections=''
let g:Tex_FoldedEnvironments=''
let g:Tex_FoldedMisc=''
if has("autocmd") && exists("+omnifunc")
    autocmd Filetype *
    	    \	if &omnifunc == "" |
    	    \		setlocal omnifunc=syntaxcomplete#Complete |
    	    \	endif
endif

set ts=4 sts=4 sw=4 expandtab smartindent

" the mouse mode just does not work well enough. Disable it.
set mouse=
" set background=light
"colorscheme desert
vnoremap < <gv
vnoremap > >gv

let mapleader=","
let maplocalleader=";"
nnoremap <leader>v V`]

" reflow paragaph
nnoremap <leader>q gqip
" Open a new window and switch to it:
nnoremap <leader>w <C-w>v<C-w>l


set undofile
set undodir=$HOME/.vim/undo " where to save undo histories
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo

" Make search default to global
set gdefault
set backspace=indent,eol,start

" Get rid of search highlighting
nnoremap <leader><space> :noh<cr>

highlight SpellBad ctermbg=none cterm=undercurl

highlight SpellBad      ctermbg=none    cterm=undercurl
highlight DiffDelete    ctermfg=black   ctermbg=grey
highlight DiffText      ctermfg=red     ctermbg=DarkGray
highlight DiffChange    ctermfg=black   cterm=none ctermbg=LightGrey
highlight DiffAdd                       ctermbg=cyan cterm=bold


" Use deoplete.
let g:deoplete#enable_at_startup = 1
" python integration bindings
let g:nvim_ipy_perform_mappings = 0
map <silent> <c-s>   <Plug>(IPy-Run)
imap <silent> <c-s>   <ESC><Plug>(IPy-Run)i

luafile $HOME/.config/nvim/plugins.lua



" deactivate default mappings
" define custom mappings for the python filetype
augroup ironmapping
    autocmd!
    autocmd Filetype python nmap <buffer> <localleader>t <Plug>(iron-send-motion)
    autocmd Filetype python vmap <buffer> <localleader>t <Plug>(iron-send-motion)
    autocmd Filetype python nmap <buffer> <localleader>p <Plug>(iron-repeat-cmd)
augroup END

let g:python3_host_prog = '/home/luispedro/.anaconda/envs/py3.8/bin/python'
let g:ipy_set_ft = 1
let g:ipy_highlight	= 1 " (true)	add highlights for ANSI sequences in the output
let g:ipy_truncate_input = 0 "	when > 0, don't echo inputs larger than this number of lines
let g:ipy_shortprompt = 0 

set guicursor=

map <silent> <c-s>   <Plug>(IPy-Run)
