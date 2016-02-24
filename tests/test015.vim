" Test Inconsistent buffer settings.

let g:IngoLibrary_ConfirmChoices = ['change']

edit test015.txt
IndentConsistencyCop

call vimtest#Quit()

