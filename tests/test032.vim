" Test Inconsistent Java source code.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not best guess']

edit test032.txt
IndentConsistencyCop

call vimtest#Quit()

