let your_name = 'David B. Cortarello'
let your_email = 'dcortarello@gmail.com'

if !exists("*ReTag")
	function ReTag()
		exe "!ctags -R"
		exe "!sed -e '/^.*   inc\\/.*$/d' tags > tags.new"
		exe "!mv tags.new tags"
	endfunction
endif


" Some useful variables
if (filereadable(expand("%:p:h:h") . '/Makefile.am') && stridx(getcwd(), 'src') >= 0)
	" This is a common Program/{Makefile.am,src/*.{c,h}} scheme
	let progname = expand("%:p:h:h:t")
elseif (filereadable(expand("%:p:h") . '/Makefile'))
	" Just a simple good old Unix Makefile
	let progname = expand("%:p:h:t")
else
	" Plain dumb program
	let progname = expand("%:r")
endif

let year = strftime("%Y")
let gdb = '!gdb -q ./' . progname
let run_prog = '!./' . progname
let upper_name = toupper(your_name)
let upper_source = substitute(toupper(expand("%:t")), '\.', "_", "g")
let TE_Ctags_Path = "/usr/bin/ctags"

if !exists("*Compile_source")
	function Compile_source()
		let cflags="-ggdb -Wall -DDEBUG"
		echo "COMPILING"
		if (filereadable(expand("%:p:h:h") . '/Makefile.am'))
			" This is a common Program/{Makefile.am,src/*.{c,h}} scheme
			:!(cd ..; make)
		elseif (filereadable(expand("%:p:h") . '/Makefile'))
			" Just a simple good old Unix Makefile 
			:!make
		else
			" Plain dumb program
			let compile_line = '!CFLAGS="' . cflags . '" make ' . expand("%:r")
			exec compile_line
		endif
	endfunction
endif

" Include $HOME in cdpath
if has("file_in_path")
	let &cdpath=','.expand("$HOME").','.expand("$HOME").'/Projects'.','.expand("%:p:h").','.expand("%:p:h").'/src'
endif

" Better include path
set path+=src/

" Templates
if has("autocmd")
	augroup content
		autocmd!
		" Autocmd for new C files with BSD licence! :-)
		autocmd BufNewFile *.c $put = '/* vim: set sw=4 sts=4 tw=80 */' |
			\ $put = '' |
			\ $put = '/*' |
			\ $put = ' * Copyright (c) ' . year . ' , ' . your_name . ' <' . your_email . '>' |
			\ $put = ' * All rights reserved.' |
			\ $put = ' *' |
			\ $put = ' * Redistribution and use in source and binary forms, with or without' |
			\ $put = ' * modification, are permitted provided that the following conditions are met:' |
			\ $put = ' * 1. Redistributions of source code must retain the above copyright' |
			\ $put = ' *    notice, this list of conditions and the following disclaimer.' |
			\ $put = ' * 2. Redistributions in binary form must reproduce the above copyright' |
			\ $put = ' *    notice, this list of conditions and the following disclaimer in the' |
			\ $put = ' *    documentation and/or other materials provided with the distribution.' |
			\ $put = ' * 3. All advertising materials mentioning features or use of this software' |
			\ $put = ' *    must display the following acknowledgement:' |
			\ $put = ' *    This product includes software developed by ' . your_name . '.' |
			\ $put = ' * 4. Neither the name of ' . your_name . ' nor the' |
			\ $put = ' *    names of its contributors may be used to endorse or promote products' |
			\ $put = ' *    derived from this software without specific prior written permission.' |
			\ $put = ' *' |
			\ $put = ' * THIS SOFTWARE IS PROVIDED BY ' . upper_name . ' ''AS IS'' AND ANY' |
			\ $put = ' * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED' |
			\ $put = ' * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE' |
			\ $put = ' * DISCLAIMED. IN NO EVENT SHALL ' . upper_name . ' BE LIABLE FOR ANY' |
			\ $put = ' * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES' |
			\ $put = ' * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;' |
			\ $put = ' * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND' |
			\ $put = ' * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT' |
			\ $put = ' * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS' |
			\ $put = ' * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.' |
			\ $put = ' */' |
			\ $put = '' |
		autocmd BufNewFile *.h $put = '/* vim: set sw=4 sts=4 tw=80 */' |
			\ $put = '' |
			\ $put = '/*' |
			\ $put = ' * Copyright (c) ' . year . ' , ' . your_name . ' <' . your_email . '>' |
			\ $put = ' * All rights reserved.' |
			\ $put = ' *' |
			\ $put = ' * Redistribution and use in source and binary forms, with or without' |
			\ $put = ' * modification, are permitted provided that the following conditions are met:' |
			\ $put = ' * 1. Redistributions of source code must retain the above copyright' |
			\ $put = ' *    notice, this list of conditions and the following disclaimer.' |
			\ $put = ' * 2. Redistributions in binary form must reproduce the above copyright' |
			\ $put = ' *    notice, this list of conditions and the following disclaimer in the' |
			\ $put = ' *    documentation and/or other materials provided with the distribution.' |
			\ $put = ' * 3. All advertising materials mentioning features or use of this software' |
			\ $put = ' *    must display the following acknowledgement:' |
			\ $put = ' *    This product includes software developed by ' . your_name . '.' |
			\ $put = ' * 4. Neither the name of ' . your_name . ' nor the' |
			\ $put = ' *    names of its contributors may be used to endorse or promote products' |
			\ $put = ' *    derived from this software without specific prior written permission.' |
			\ $put = ' *' |
			\ $put = ' * THIS SOFTWARE IS PROVIDED BY ' . upper_name . ' ''AS IS'' AND ANY' |
			\ $put = ' * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED' |
			\ $put = ' * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE' |
			\ $put = ' * DISCLAIMED. IN NO EVENT SHALL ' . upper_name . ' BE LIABLE FOR ANY' |
			\ $put = ' * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES' |
			\ $put = ' * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;' |
			\ $put = ' * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND' |
			\ $put = ' * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT' |
			\ $put = ' * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS' |
			\ $put = ' * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.' |
			\ $put = ' */' |
			\ $put = '' |
			\ $put = '#ifndef ' . upper_source |
			\ $put = '#define ' . upper_source |
			\ $put = '' |
			\ $put = '#endif' |
	augroup END
endif

" Yeah, run it damn it!
nmap <F3> :exec run_prog <CR>
" We can debug something with this.
nmap <F6> :exec gdb <CR>
" Does this really makes any sence with big source trees?
nmap <F7> :TlistOpen <CR>
" Compile the whole stuff
nmap <F9> :call Compile_source()<CR>

" Tag explorer
nnoremap <silent> <F11> :TagExplorer<CR> 
noremap T :tselect <C-R><C-W><CR>
map <silent><C-E> <C-]>
vmap <silent> i !indent<CR>
" Re tag our code
nmap <F4> :call ReTag()<CR>

" Yeah, fancy man pages
if has("eval")
	" Enable fancy % matching
	runtime! macros/matchit.vim

	"Load the ":Man" command and match K to it
	runtime ftplugin/man.vim
	nmap K :Man <cword><CR>
endif


" Folding based on code
set foldtext=v:folddashes.'\ '.substitute(getline(v:foldstart),'/\\*\\\|\\*/\\\|{{{\\\|#','','g').'\ '



