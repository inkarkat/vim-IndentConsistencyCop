" Test Inconsistent indent settings.

let g:IngoLibrary_ConfirmChoices = ['change']

edit test040.txt
IndentConsistencyCop

call vimtest#Quit()

