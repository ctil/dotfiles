" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Auto execute python scripts using F5
autocmd BufRead *.py nmap <F5> :!python %<CR>

"Used for finding tags.  Generate tags using ctags
set tags=./TAGS,../TAGS,../../TAGS,../../../TAGS,../../../../TAGS,../../../../../TAGS
map t <C-]> 

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Make timeout faster (for jk mappings, etc.)
set timeout timeoutlen=100

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
set backup		" keep a backup file
endif

set history=50		" keep 50 lines of command line history
set number		" show line numbers
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Searching config
nmap <silent> <C-N> :silent noh<CR> " CTRL+n turns off search highlightin
set ignorecase
set smartcase
set incsearch

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

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

" Setup auto-completing quotes
" inoremap "      ""<Left>
" inoremap "<CR>  "<CR>"<Esc>O
" inoremap ""     "
" Zenburn color configurations
" let g:zenburn_high_Contrast=1
" let g:zenburn_alternate_Visual = 1

""colorscheme elflord
" colorscheme Zenburn2
set t_Co=256

" Save with spacebar, get out of insert mode
map <Space> :wall<CR>
imap jk <Esc>
imap kj <Esc>

" Quote selected word
nnoremap co :silent! normal "zyiw<Esc>:let @z="'".@z."'"<CR>cw<c-r>z<Esc>b
nnoremap cp :silent! normal "zyiw<Esc>:let @z="\"".@z."\""<CR>cw<c-r>z<Esc>b

" Nifty menu at bottom of vim window
set wildmenu

if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Tab and indent stuff
filetype plugin indent on
set cindent
set shiftwidth=4
set softtabstop=4

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 80 characters.
  autocmd FileType text setlocal textwidth=80

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")
