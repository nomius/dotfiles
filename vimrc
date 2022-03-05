"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Configuration file by David B. Cortarello (Nomius) <dcortarello@gmail.com>
"

" Simple configuration
set nocompatible

" Enable a nice big viminfo file
set viminfo='1000,f1,:1000,/1000
set history=500

" Backspace behavior and tabs tweaks
set backspace=2
set tabstop=4
set shiftwidth=4

" Don't break my lines (balls) with small lines. I bought a widescreen monitor to use it!
set tw=380
set ruler
set sm
set background=dark
set isk+=_,$,@,%,#,-
set noignorecase noinfercase
set nobackup
if !has("eval")
	set nofoldenable
endif
set mouse=

" Show us the command we're typing
set showcmd

" Highlight matching parens
set showmatch

" Search options: incremental search, highlight search
set hlsearch
set incsearch

" Show full tags when doing search completion
set showfulltag

" Don't replace tab by spaces
set noexpandtab

" Speed up macros
set lazyredraw

" Try to show at least three lines and two columns of context when scrolling
set scrolloff=3
set sidescrolloff=2

" Use the cool tab complete menu
set wildmenu
set wildignore+=*.o,*~,.lo
set suffixes+=.in,.a

" Allow edit buffers to be hidden
set hidden

" 1 height windows
set winminheight=1

" Syntax when printing
set popt+=syntax:y

" set keymap=accents
set fileencodings=usc-bom,utf-8,es-cp850

" Nice statusbar
set laststatus=2
set statusline=
set statusline+=%2*%-3.3n%0*\                " buffer number
set statusline+=%f\                          " file name
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
set statusline+=%=                           " right align
set statusline+=%2*0x%-8B\                   " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset
hi StatusLine ctermbg=6 ctermfg=4
set term=xterm-256color

" Winmanager configuration
if has("eval")
	let persistentBehaviour = 0
endif


" Set the terminal title if allowed
if &term =~ "xterm" || &term =~ "rxvt"
	if has('title')
		set title
	endif
endif

" Enable syntax highlighting
if has("syntax")
	syntax on
	autocmd BufNewFile,BufRead *.tfvars set syntax=tf
endif

if has("gui")
	" Yeay, gvim like vim!
	set guioptions=aegiLt
	highlight Normal guibg=black guifg=white
endif

"Read pdf file inside vim
if has("eval")
	autocmd BufReadPost *.pdf %!pdftotext -nopgbrk "%" - |fmt -csw78
endif

" Go to the line where we left
if has("eval")
	autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif
endif

if !exists("*ReTag")
	function ReTag()
		exe "!ctags -R && sed -e '/^.*   inc\\/.*$/d' tags > tags.new  && mv tags.new tags"
	endfunction
endif

" Some keybinging
nmap <F2> :w! <CR>
" Fancy quit
nmap <F10> :q! <CR>
" Funny encriptation
nmap <F12> ggVGg?
" We have ftplugin, but hey, sometimes you just want to read something else
nmap <F8> :!man

" Move fast through files using Ctrl+N and Ctrl+P
nnoremap <C-N> :n<Enter>
nnoremap <C-P> :N<Enter>

" Tag explorer
nnoremap <silent> <F11> :TagExplorer<CR> 
noremap T :tselect <C-R><C-W><CR>
map <silent><C-E> <C-]>

" Re tag our code
nmap <F4> :call ReTag()<CR>

