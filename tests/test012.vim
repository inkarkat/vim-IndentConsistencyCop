" Test Inconsistent indentation.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test012.txt
IndentConsistencyCop

call vimtest#Quit()

