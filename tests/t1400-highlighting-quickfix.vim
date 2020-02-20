" Test population of quickfix list.

let g:indentconsistencycop_highlighting = 'q'
let g:IngoLibrary_ConfirmChoices = ['highlight wrong indents', 'not buffer settings']

edit test053.txt
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(7)
call vimtap#Is(map(getqflist(), 'v:val.lnum'), [13, 46, 47, 48, 49, 50, 51, 52], 'quickfix line numbers of inconsistent lines')

call vimtap#Is(getqflist()[0].text, 'Indent conflicts with tab4: ....<style', 'quickfix text for inconsistent indent')
call vimtap#Is(getqflist()[0].col, 1, 'quickfix column for inconsistent indent')

call vimtap#Is(getqflist()[2].text, 'Bad mix of space and tab: href="xxxx/xxxxx.xxxx".^I^Ititle="xxxx"', 'quickfix text for badmix')
call vimtap#Is(getqflist()[2].col, 35, 'quickfix column for badmix')

call vimtap#Is(getqflist()[6].text, 'Indent conflicts with tab4: ^I....</map>$', 'quickfix text for inconsistent indent')
call vimtap#Is(getqflist()[6].col, 1, 'quickfix column for inconsistent indent')

call vimtest#Quit()
