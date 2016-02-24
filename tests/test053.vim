" Test Consistent, but guessed wrong setting: This is tab, not sts4.

edit test053.txt

let g:IngoLibrary_ConfirmChoices = ['wrong, choose correct setting', 'tabstop', '4']
IndentConsistencyCop

let g:IngoLibrary_ConfirmChoices = ['wrong, use buffer settings']
IndentConsistencyCop

let g:IngoLibrary_ConfirmChoices = ['change']
IndentConsistencyCop

call vimtest#Quit()
