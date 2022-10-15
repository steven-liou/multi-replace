" needs to handle quotes

" apple_good_pie
" apple_pie
" apple_pie


let s:current_matching = -1

function s:InitializeSearch(type) abort
  call s:HandleMotion(a:type)
  let [start_line_num, end_line_num, start_col_num, end_col_num] = s:GetStartEndLines(a:type)
  if start_line_num !=# end_line_num | return | endif

  let pattern = s:GetSearchPattern(start_line_num, start_col_num, end_col_num)
  call s:SetSearchTermPattern(pattern)
endfunction

function s:HandleMotion(type) abort
  " get the text content selected by motion in normal or visual modes
  if a:type==# 'v'
    execute "normal! `<v`>y"
  elseif a:type ==# 'char'
    execute "normal! `[v`]y"
  else
    return
  endif
endfunction

function! s:GetStartEndLines(type) abort
  " handles normal and visual mode selected line range numbers
  if (a:type ==# 'v' || a:type==# 'V')
    let start_line = line("'<")
    let end_line = line("'>")
    let start_col_num = col("'<") - 1
    let end_col_num = col("'>") - 1
  else
    let start_line = line("'[")
    let end_line = line("']")
    let start_col_num = col("'[") - 1
    let end_col_num = col("']") - 1
  endif

  return [start_line, end_line, start_col_num, end_col_num]
endfunction 

function! s:GetSearchPattern(line_num, start_col_num, end_col_num) abort
  let string = getline(a:line_num)
  let start_string = a:start_col_num <= 0 ? '' : string[0:a:start_col_num - 1]
  let motioned_string = string[a:start_col_num:a:end_col_num]

  let end_string = string[a:end_col_num + 1:]
  let start_string_pattern = matchstr(start_string, '\v[a-zA-Z0-9_-]*$')

  let end_string_pattern = matchstr(end_string, '\v^[a-zA-Z0-9_-]*')
  let search_pattern = '\v(<' . start_string_pattern . ')@<=' . motioned_string . '(' . end_string_pattern . '>)@=\C'  
  return search_pattern
endfunction

function! s:SetSearchTermPattern(pattern) abort
  let replaceCommand = "let @/ = '" . a:pattern . "'"
  execute replaceCommand
  " execute 'normal! /' . a:pattern 
endfunction


function! s:ShowHighlight() abort
  augroup showHighlight
    autocmd!
    autocmd InsertLeave <buffer> call s:SetHighlight()
  augroup END
endfunction

function! s:SetHighlight() abort
  call feedkeys("n")
  augroup showHighlight
    autocmd!
  augroup END
  augroup! showHighlight
endfunction


function! s:SearchAndReplaceAll() abort
  let search = escape(getreg('\/'), '\')
  let replace = escape(getreg('.'), '\')
  let replaceCommand = "%s/" . search . "/" . replace . "/ge"
  execute replaceCommand
  call s:ClearCallbackAutocommand()
endfunction

function! s:ClearCallbackAutocommand() abort
  augroup replaceAll
    autocmd!
  augroup END
  augroup! replaceAll
endfunction

function! s:SetupMultiReplace() abort
    set operatorfunc=MultiReplaceOperator
endfunction

function! MultiReplaceOperator(type) abort
  call s:InitializeSearch(a:type)
  call feedkeys("cgn")
  call s:ShowHighlight()
endfunction

function! s:SetupReplaceAll() abort
    set operatorfunc=ReplaceAllOperator
endfunction

function! ReplaceAllOperator(type)
  call s:InitializeSearch(a:type)
  call feedkeys('cgn')
  augroup replaceAll
    autocmd!
    autocmd InsertLeave <buffer> call s:SearchAndReplaceAll()
  augroup END
endfunction


function s:InitializeInsertSearch(type) abort
  call s:HandleMotion(a:type)
  let [start_line_num, end_line_num, start_col_num, end_col_num] = s:GetStartEndLines(a:type)
  if start_line_num !=# end_line_num | return | endif


  let pattern = s:GetInsertSearchPattern(start_line_num, start_col_num, end_col_num)
  call s:SetSearchTermPattern(pattern)
  return pattern
endfunction

let s:start_string_pattern = ''

function! s:GetInsertSearchPattern(line_num, start_col_num, end_col_num) abort
  let string = getline(a:line_num)
  let start_string = a:start_col_num <= 0 ? '' : string[0:a:start_col_num - 1]
  let motioned_string = string[a:start_col_num:a:end_col_num]

  let end_string = string[a:end_col_num + 1:]
  let s:start_string_pattern = matchstr(start_string, '\v[a-zA-Z0-9_-]*$')

  let end_string_pattern = matchstr( end_string, '\v^[a-zA-Z0-9_-]*')
  " let search_pattern = '\v(<)@<=' . s:start_string_pattern . '(' . motioned_string . end_string_pattern . '>)@=\C'  
  let search_pattern = '\v(<)@<=' . s:start_string_pattern . '(' . motioned_string . end_string_pattern . '>)@=\C'  
  return search_pattern
endfunction



function! s:SetupMultiInsert() abort
    set operatorfunc=MultiInsertOperator
endfunction

function! MultiInsertOperator(type) abort
  call s:InitializeInsertSearch(a:type)
  call feedkeys("N")
  call feedkeys("cgn")
  " call feedkeys(getreg('"'))
  " call feedkeys(repeat("<Backspace>", len(b:start_string_pattern)))
  " call feedkeys(s:start_string_pattern[1:])
  " call s:ShowHighlight()
endfunction

function! s:SetupInsertAll() abort
    set operatorfunc=InsertAllOperator
endfunction

function! InsertAllOperator(type)
  call s:InitializeSearch(a:type)
  call feedkeys('cgn')
  call feedkeys(getreg('"'))
  augroup replaceAll
    autocmd!
    autocmd InsertLeave <buffer> call s:SearchAndReplaceAll()
  augroup END
endfunction

function! s:SetupMultiAppend() abort
    set operatorfunc=MultiAppendOperator
endfunction

function! MultiAppendOperator(type) abort
  call s:InitializeSearch(a:type)
  call feedkeys("cgn")
  call feedkeys(getreg('"'))
  call s:ShowHighlight()
endfunction

function! s:SetupAppendAll() abort
    set operatorfunc=AppendAllOperator
endfunction

function! AppendAllOperator(type)
  call s:InitializeSearch(a:type)
  call feedkeys('cgn')
  call feedkeys(getreg('"'))
  augroup replaceAll
    autocmd!
    autocmd InsertLeave <buffer> call s:SearchAndReplaceAll()
  augroup END
endfunction


" Code for mappings
nnoremap <silent> <Plug>MultiReplace :<C-u>call <SID>SetupMultiReplace()<CR>g@
xnoremap <silent> <Plug>MultiReplaceVisual :<C-u>call <SID>SetupMultiReplace()\|call MultiReplaceOperator(visualmode())<CR>
nnoremap <silent> <Plug>ReplaceAll :<C-u>call <SID>SetupReplaceAll()<CR>g@
xnoremap <silent> <Plug>ReplaceAllVisual :<C-u>call <SID>SetupReplaceAll()\|call AppendAllOperator(visualmode())<CR>

nnoremap <silent> <Plug>MultiInsert :<C-u>call <SID>SetupMultiInsert()<CR>g@
xnoremap <silent> <Plug>MultiInsertVisual :<C-u>call <SID>SetupMultiInsert()\|call MultiInsertOperator(visualmode())<CR>
nnoremap <silent> <Plug>InsertAll :<C-u>call <SID>SetupInsertAll()<CR>g@
xnoremap <silent> <Plug>InsertAllVisual :<C-u>call <SID>SetupInsertAll()\|call InsertAllOperator(visualmode())<CR>

nnoremap <silent> <Plug>MultiAppend :<C-u>call <SID>SetupMultiAppend()<CR>g@
xnoremap <silent> <Plug>MultiAppendVisual :<C-u>call <SID>SetupMultiAppend()\|call MultiAppendOperator(visualmode())<CR>
nnoremap <silent> <Plug>AppendAll :<C-u>call <SID>SetupAppendAll()<CR>g@
xnoremap <silent> <Plug>AppendAllVisual :<C-u>call <SID>SetupAppendAll()\|call AppendAllOperator(visualmode())<CR>

if !exists('g:multi_replace_mappings')
  let g:multi_replace_mappings = 1
endif

if g:multi_replace_mappings
  nmap gx <Plug>MultiReplace
  xmap gx <Plug>MultiReplaceVisual
  nmap gX <Plug>ReplaceAll
  xmap gX <Plug>ReplaceAllVisual

  nmap ga <Plug>MultiAppend
  xmap ga <Plug>MultiAppendVisual
  nmap gA <Plug>AppendAll
  xmap gA <Plug>AppendAllVisual
end
