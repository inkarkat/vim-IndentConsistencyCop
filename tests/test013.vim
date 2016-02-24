" Test Inconsistent indentation.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit test013.txt
IndentConsistencyCop

call vimtest#Quit()

