" casechange.vim - Lets role the cases
" Maintainer:   Ignacio Catalina
" Version:      1.0
"
" Installation:
" Place in either ~/.vim/plugin/casechange.vim (to load at start up) or
" ~/.vim/autoload/casechange.vim (to load automatically as needed).
"
" License:
" Copyright (c) Ignacio Catalina.  Distributed under the same terms as Vim itself.
" See :help license
"

if exists("g:loaded_casechange") || &cp || v:version < 700
    finish
endif
let g:loaded_casechange = 1

if !exists("g:casechange_nomap")
    vnoremap ~ <CMD>call casechange#next()<CR>
endif

" vim:set ft=vim et sw=4 sts=4:
