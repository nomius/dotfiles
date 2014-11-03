set expandtab

" Templates
if has("autocmd")
	augroup content
		autocmd!
		" Autocmd for new python files! :-)
		autocmd BufNewFile *.py $put = '#!/usr/bin/env python'
	augroup END
endif

