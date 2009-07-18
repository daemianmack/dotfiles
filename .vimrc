" I've declared .vimrc bankruptcy by snipping out all cargo-culted voodoo and am not including anything in here
" that isn't documented and known-good. This hardliner stance is expedited nicely by the fact that I'm mostly using emacs these days.

set nocompatible               " Make Vim default to nicer options
syntax on                      " Enable syntax highlighting
filetype on                    " Enable filetype detection
filetype indent on             " Enable filetype-specific indenting
filetype plugin on             " Enable filetype-specific plugins 
set noautoindent               " Autoindent is great except when it's annoying as hell

set hidden                     " Keep unsaved buffers around
set ttyfast                    " We're on a fast TTY
set scrolloff=10               " Give the cursor a forcefield
set wildmenu            
set noerrorbells novisualbell  " Don't flash screen or ringing bell
set esckeys                    " Recognize function keys in insert mode
set ruler                      " Show line and column information
set showmode                   " Always show command or insert mode
set more                       " Use a pager for long listings
set showcmd                    " Show command in status line
set laststatus=2               " Show status line even when there's only one window
set cmdheight=2                " Two-line status line
set display=lastline           " Always display last line

set viminfo='1000,\"1000,h     " Remember many things between sessions
set history=1000               " Command history
set directory=~/.vim/tmp       " Store swapfiles here

set hlsearch                   " highlight search results
set ignorecase                 " make searches case-insensitive
set incsearch                  " Show search hits as you type

set background=dark            " Better colors for white terminals
set backspace=2                " Backspaces can go over lines
set showmatch                  " Indicate matching elements when mousing over second of pair
set matchtime=1                " Very short showmatch { }
set shortmess=a                " Don't make me hit enter for dumb warnings
set wrap
set expandtab                  " Ruby tabspacing
set tabstop=2
set shiftwidth=2 
set softtabstop=2



colorscheme delek
highlight Search term=NONE cterm=bold ctermfg=2 ctermbg=4



" Automatically save/load any views
au BufWinLeave * mkview
au BufWinEnter *.* silent loadview



map <C-W>] <C-W>]:tab split<CR>gT:q<CR>gt                                              " This makes ctrl-w ] (open tag) open the file in another tab, not buffer
map E 0i#j                                                                           " Comment current line with a #
map e 0xj                                                                              " Uncomment current line (by deleting first character)
map <F4> :set nohls!<CR>:set nohls?<CR>                                                " Toggle search highlighting with F4
nmap <F9> :if has("syntax_items")<CR>syntax off<CR>else<CR>syntax on<CR>endif<CR><CR>  " Toggle syntax highlighting

map ,hic :hi Comment ctermfg=grey cterm=reverse                                        " Put comments in stark relief when terminal doesn't provide enough contrast

nnoremap <silent> <F11> :YRShow<CR>                                                    " Toggle yankring
nnoremap <silent> <C-l> :nohl<CR><C-l>                                                 " <C-l> redraws the screen and removes any search highlighting.
nnoremap  <a-right>  gt                                                                " Tab navigation (next tab) with Alt+Right
nnoremap  <a-left>   g T                                                               " Tab navigation (next tab) with Alt+Left

" From http://linuxbrit.co.uk/downloads/dot.vimrc
" When I let Vim write the current buffer I frequently mistype the
" command ":w" as ":W" - so I have to remap it to correct this typo:
nmap :W :w
nmap :Q :q
nmap :wQ :wq



" Folding stuff from
" http://216.239.51.104/search?q=cache:piF63lhqwa4J:www.dgp.toronto.edu/~mjmcguff/learn/vim/folding.txt+vimrc+folding&hl=en&lr=lang_en
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR> 
