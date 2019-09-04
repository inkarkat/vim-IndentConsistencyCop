" Test filtering of block alignment.

let g:IndentConsistencyCop_line_filters = [function('IndentConsistencyCop#BlockAlignment#Filter')]

edit BlockAlignment.txt

call vimtest#StartTap()
call vimtap#Plan(5)
call vimtap#Is(call(g:IndentConsistencyCop_line_filters[0], [2, 6]), ingo#dict#FromKeys([4, 5], 1), 'filtered aligned to keyword')
call vimtap#Is(call(g:IndentConsistencyCop_line_filters[0], [7, 17]), ingo#dict#FromKeys([9, 10, 15, 16], 1), 'filtered aligned to common constructs')
call vimtap#Is(call(g:IndentConsistencyCop_line_filters[0], [18, 23]), ingo#dict#FromKeys([20], 1), 'filtered misaligned')
call vimtap#Is(call(g:IndentConsistencyCop_line_filters[0], [24, 27]), ingo#dict#FromKeys([], 1), 'unfiltered bad mix')
call vimtap#Is(call(g:IndentConsistencyCop_line_filters[0], [28, 31]), ingo#dict#FromKeys([30], 1), 'unfiltered inconsistent characters')
call vimtest#Quit()
