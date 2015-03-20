" Test Consistent, but guessed wrong setting: This is tab, not sts4.

let g:IngoLibrary_ConfirmChoices = ['wrong', 'tabstop', '4']

edit test053.txt
IndentConsistencyCop

let g:IngoLibrary_ConfirmChoices = ['change']
IndentConsistencyCop

call vimtest#Quit()
