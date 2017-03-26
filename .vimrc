" Save with spacebar
map <Space> :wall<CR>

" Get out of insert mode
imap jk <Esc>
imap kj <Esc>

" Make timeout faster (for jk mappings, etc.)
set timeout timeoutlen=100

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Keep a backup file
set backup

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

" Colors
set t_Co=256
colorscheme desert

" Setup auto-completing curly brackets
inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}

" Setup auto-completing parentheses
inoremap (      ()<Left>
inoremap (<CR>  (<CR>)<Esc>O
inoremap ((     (
inoremap ()     ()

" Needed for vim-airline
set laststatus=2
set noshowmode
let g:airline_powerline_fonts=1

" Install vim-plug with this command:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" Run :PlugInstall to install plugins
" Run :PlugClean to remove that are no longer in vimrc
call plug#begin('~/.vim/plugged')

" golang
Plug 'fatih/vim-go'

" Fuzzy file finder
Plug 'ctrlpvim/ctrlp.vim'

Plug 'vim-airline/vim-airline'

call plug#end()

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
