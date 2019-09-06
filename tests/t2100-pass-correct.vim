" Test Consistent, but guessed wrong setting, correct setting passed via argument.

edit test053.txt

let g:IngoLibrary_ConfirmChoices = ['wrong, use correct tab4']
IndentConsistencyCop tab4

call vimtest#Quit()
