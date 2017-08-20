" MIT License
"
" Copyright (c) 2017 Alexander Serebryakov (alex.serebr@gmail.com)
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.


" Initializes plugin settings and mappings
function! VimTodoListsInit()
  set filetype=todo
  setlocal tabstop=2
  setlocal shiftwidth=2 expandtab
  setlocal cursorline
  setlocal noautoindent

  if exists('g:VimTodoListsCustomKeyMapper')
    try
      call call(g:VimTodoListsCustomKeyMapper, [])
    catch
      echo 'VimTodoLists: Error in custom key mapper.'
           \.' Falling back to default mappings'
      call VimTodoListsSetItemMode()
    endtry
  else
    call VimTodoListsSetItemMode()
  endif

endfunction


" Sets mapping for normal navigation and editing mode
function! VimTodoListsSetNormalMode()
  nunmap <buffer> o
  nunmap <buffer> O
  nunmap <buffer> j
  nunmap <buffer> k
  nnoremap <buffer> <Space> :VimTodoListsToggleItem<CR>
  vnoremap <buffer> <Space> :'<,'>VimTodoListsToggleItem<CR>
  noremap <buffer> <leader>e :silent call VimTodoListsSetItemMode()<CR>
endfunction


" Sets mappings for faster item navigation and editing
function! VimTodoListsSetItemMode()
  nnoremap <buffer> o :VimTodoListsCreateNewItemBelow<CR>
  nnoremap <buffer> O :VimTodoListsCreateNewItemAbove<CR>
  nnoremap <buffer> j :VimTodoListsGoToNextItem<CR>
  nnoremap <buffer> k :VimTodoListsGoToPreviousItem<CR>
  nnoremap <buffer> <Space> :VimTodoListsToggleItem<CR>
  vnoremap <buffer> <Space> :'<,'>VimTodoListsToggleItem<CR>
  inoremap <buffer> <CR> <CR><ESC>:VimTodoListsCreateNewItem<CR>
  noremap <buffer> <leader>e :silent call VimTodoListsSetNormalMode()<CR>
endfunction


" Creates a new item above the current line
function! VimTodoListsCreateNewItemAbove()
  normal! O  [ ] 
  startinsert!
endfunction


" Creates e new item below the current line
function! VimTodoListsCreateNewItemBelow()
  normal! o  [ ] 
  startinsert!
endfunction


" Creates e new item in the current line
function! VimTodoListsCreateNewItem()
  normal! 0i  [ ] 
  startinsert!
endfunction


" Moves te cursor to the next item
function! VimTodoListsGoToNextItem()
  normal! $
  silent exec '/^\s*\[.\]'
  silent exec 'noh'
  normal! f[
  normal! l
endfunction


" Moves te cursor to the previous item
function! VimTodoListsGoToPreviousItem()
  normal! 0
  silent exec '?^\s*\[.\]'
  silent exec 'noh'
  normal! f[
  normal! l
endfunction


" Toggles todo items in specified range
function! VimTodoListsToggleItemsRange()
  for lineno in range (a:firstline, a:lastline)
    let l:line = getline(lineno)

    if match(l:line, '^\s*\[ \].*') != -1
      call setline(lineno, substitute(l:line, '^\(\s*\)\[ \]', '\1[X]', ''))
    elseif match(l:line, '^\s*\[X\] .*') != -1
      call setline(lineno, substitute(l:line, '^\(\s*\)\[X\]', '\1[ ]', ''))
    endif
  endfor
endfunction


"Plugin startup code
if !exists('g:vimtodolists_plugin')
  let g:vimtodolists_plugin = 1

  if exists('vimtodolists_auto_commands')
    echoerr 'VimTodoLists: vimtodolists_auto_commands group already exists'
    exit
  endif

  "Defining auto commands
  augroup vimtodolists_auto_commands
    autocmd!
    autocmd BufRead,BufNewFile *.todo call VimTodoListsInit()
  augroup end

  "Defining plugin commands
  command! VimTodoListsCreateNewItemAbove silent call VimTodoListsCreateNewItemAbove()
  command! VimTodoListsCreateNewItemBelow silent call VimTodoListsCreateNewItemBelow()
  command! VimTodoListsCreateNewItem silent call VimTodoListsCreateNewItem()
  command! VimTodoListsGoToNextItem silent call VimTodoListsGoToNextItem()
  command! VimTodoListsGoToPreviousItem silent call VimTodoListsGoToPreviousItem()
  command! -range VimTodoListsToggleItem silent <line1>,<line2>call VimTodoListsToggleItemsRange()
endif

