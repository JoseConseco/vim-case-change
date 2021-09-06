" {{{ Regexes to clarify current case
" \C - case sensitive
" \v  -  magic mode (no need for \)
let s:dash = '\v^[a-z0-9]+(-+[a-z0-9]+)+$' " '^[a-z0-9]+(-+[a-z0-9]+)+$'  dash-case
let s:camel = '\v\C^[a-z][a-z0-9]*([A-Z][a-z0-9]*)*$'     " camelCase
let s:snake = '\v\C^[a-z0-9]+(_+[a-z0-9]+)*$'           "snake_case
let s:upper = '\v\C^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$'       "UPPER_CASE
let s:pascal = '\v\C^[A-Z][a-z0-9]*([A-Z0-9][a-z0-9]*)*$'   "PascalCase
let s:title = '\v\C^[A-Z][a-z0-9]*( [A-Z][a-z0-9]+)*$'     "Title Case
let s:any = '\v\C^[a-zA-Z][a-zA-Z0-9]*(( |_|-)[a-zA-Z][a-zA-Z0-9]+)*$'     "aNy_casE  Any-case etc.
" }}}

let s:sessionStarted = 0

" {{{ Helpers
function! s:DashToCamel(str) abort
    return substitute(a:str, '\v-+([a-z])', '\U\1', 'g')          "camelCase
endfunction

function! s:CamelToPascal(str) abort
    return substitute(a:str, '^.*$', '\u\0', 'g')                 "PascalCase
endfunction

function! s:PascalToUpper(str) abort
    return toupper(substitute(a:str, '\C^\@<![A-Z]', '_\0', 'g'))          "UPPER_CASE
endfunction

function! s:UpperToTitle(str) abort
    let l:tit_under = substitute(a:str, '\v([A-Z])([A-Z]*)','\1\L\2','g')
    return substitute(l:tit_under,'_',' ','g')                        " Title Case
endfunction

function! s:TitleToSnake(str) abort
    return tolower(substitute(a:str, ' ', '_', 'g'))               " snake_case
endfunction

function! s:SnakeToDash(str) abort
    return substitute(a:str, '_\+', '-', 'g')                      "dash-case
endfunction
" }}}

function! s:GetSelectionColumns() abort
    let pos1 = getpos('v')[2]-1
    let pos2 = getpos('.')[2]-1
    return { 'start': min([pos1, pos2]), 'end': max([pos1, pos2]) }
endfunction

" Get visual selected text
function! s:GetSelectionWord() abort
    let selection = s:GetSelectionColumns()
    return getline('.')[selection.start:selection.end]
endfunction

" Replace visual selection to argument
function! s:GetCurrentLineWithReplacedSelection(argument)
    let selection = s:GetSelectionColumns()
    let line = getline('.')
    if (selection.start == 0)
        return a:argument.line[selection.end+1:]
    endif
    return line[:selection.start-1].a:argument.line[selection.end+1:]
endfunction

function! s:GetNewWord(str) abort
    if (a:str =~ s:dash)
        return s:DashToCamel(a:str)
    elseif (a:str =~ s:camel)
        return s:CamelToPascal(a:str)
    elseif (a:str =~ s:pascal)
        return s:PascalToUpper(a:str)
    elseif (a:str =~ s:upper)
        return s:UpperToTitle(a:str)
    elseif (a:str =~ s:title)
        return s:TitleToSnake(a:str)
    elseif (a:str =~ s:snake)   "snake
        return s:SnakeToDash(a:str)
    endif
endfunction

let s:count = 0
function! s:RestoreSettings()
    " CursorMoved is async event, so need to use a hack:
    " run this function only 
    " when this plugin's 'CursorMoved's have been triggered
    if (s:count > 0)
        let s:count -= 1
        return
    endif

    augroup ww
        autocmd!
    augroup END

    let s:sessionStarted = 0
    " exit visual mode
    execute "normal! \<Esc>"
endfunction

function! casechange#next() abort
    let s:count += 1
    augroup ww
        autocmd!
        autocmd CursorMoved * call s:RestoreSettings()
    augroup END

    let selectionColumns = s:GetSelectionColumns()
    let oldWord = s:GetSelectionWord()
    let newWord = s:GetNewWord(oldWord)
    if (s:sessionStarted)
        undojoin
    endif
    call setline('.', s:GetCurrentLineWithReplacedSelection(newWord))

    call setpos("'<", [0, line('.'), selectionColumns.start + 1])
    call setpos("'>", [0, line('.'), selectionColumns.start + len(newWord)])
    normal! gv
    let s:sessionStarted = 1
endfunction
