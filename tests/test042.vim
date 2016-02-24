" Test Consistent indent settings.

let g:IngoLibrary_ConfirmChoices = []

edit test042.txt
IndentConsistencyCop

call vimtest#Quit()

