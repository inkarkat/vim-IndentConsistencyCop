" Test Inconsistent with buffer settings.

let g:IngoLibrary_ConfirmChoices = ['change']

edit test045.txt
IndentConsistencyCop

call vimtest#Quit()

