" Save with spacebar
map <Space> :wall<CR>


" Get out of insert mode
imap jk <Esc>
imap kj <Esc>

let maplocalleader = ","
let mapleader = ","

" Remap change window
nnoremap <leader>w <C-w>


"  Use tab for completor
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"

" Make timeout faster (for jk mappings, etc.)
" set timeout timeoutlen=100

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Keep a backup file
set backup
set backupdir=~/.vimbackups//

" Searching
set ignorecase
set smartcase
set incsearch
set hlsearch

" CTRL+n turns off search highlighting
nmap <silent> <C-N> :silent noh<CR>

" Tabs and indentation
filetype plugin indent on
set cindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set autoindent

" Line Numbers
set number

" Enable mouse
set mouse=a

" FZF settings
nmap <leader>b :Buffers<CR>
nmap <leader>f :Files<CR>

" Switch to last edited buffer
" nmap <C-e> :e#<CR>

" Colors
set t_Co=256
" colorscheme desert

" Needed for vim-airline
set laststatus=2
set noshowmode

" Better split navigation with ALT+{h,j,k,l}
if has('nvim')
    tnoremap <A-h> <C-\><C-N><C-w>h
    tnoremap <A-j> <C-\><C-N><C-w>j
    tnoremap <A-k> <C-\><C-N><C-w>k
    tnoremap <A-l> <C-\><C-N><C-w>l
    tnoremap <Esc> <C-\><C-n>
endif

" Enter terminal normal mode with ESC
tnoremap <Esc> <C-\><C-n>

" Open new terminal
map <leader>t :terminal ++rows=10 <CR>

" Open splits on the bottom and right by default
set splitbelow
set splitright

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline_powerline_fonts = 1

" Table mode stuff
let g:table_mode_corner_corner="+"
let g:table_mode_header_fillchar="="

" Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P


map <leader>q <Esc>:q<CR>


" Install vim-plug with this command:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" Run :PlugInstall to install plugins
" Run :PlugClean to remove that are no longer in vimrc
call plug#begin('~/.vim/plugged')

" golang
Plug 'fatih/vim-go'

" Fuzzy file finder
"Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'vim-airline/vim-airline'

" Table mode
" Plug 'dhruvasagar/vim-table-mode'

" git
" Plug 'tpope/vim-fugitive'

Plug 'jnurmine/Zenburn'

" Autocomplete for Python
" pip install jedi to enable in virtualenvs
Plug 'maralla/completor.vim'
" Plug 'davidhalter/jedi-vim'


" Async linter (flake8 pylint, etc)
"Plug 'w0rp/ale'

call plug#end()

" Mappings for go plugin. ,r does go run on current file, for example
" au FileType go nmap <leader>r <Plug>(go-run)
" au FileType go nmap <leader>b <Plug>(go-build)
" au FileType go nmap <leader>t <Plug>(go-test)
" au FileType go nmap <leader>c <Plug>(go-coverage)

" jedi-vim setup (Don't use for autocompletion. Just goto definition, etc.)
" let g:jedi#use_splits_not_buffers = "bottom"
" let g:jedi#completions_enabled = 0
" No docstring preview
autocmd FileType python setlocal completeopt-=preview

let g:zenburn_high_Contrast=0
colorscheme zenburn

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
